package violet.backend.objects.play;

import flixel.util.FlxSort;
import violet.backend.audio.Conductor;
import violet.data.noteskin.NoteSkin;
import violet.data.noteskin.NoteSkinRegistry;

class Note extends NovaSprite {
	public static var swagWidth:Float = 160 * 0.7;

	/**
	 * The parent strumline.
	 */
	public final parent:StrumLine;
	public var parentStrum(get, never):Strum;
	/**
	 * The parent strum.
	 */
	inline function get_parentStrum():Strum
		return parent.strums.members[id];

	var preventAutoSkinSet:Bool = true;
	/**
	 * The direction id of the note.
	 */
	public var id(default, set):Int;
	inline function set_id(value:Int):Int {
		if (id != value && !preventAutoSkinSet)
			reloadSkin(true);
		return id = value;
	}
	/**
	 * The current position within the song.
	 */
	public var time:Float;
	/**
	 * The skin the note will use.
	 */
	public var skin(default, set):String;
	inline function set_skin(value:String):String {
		if (skin != value && !preventAutoSkinSet)
			reloadSkin(value, true);
		return skin = value;
	}
	var skinMeta:NoteSkin;

	/**
	 * The scroll speed of this note.
	 */
	public var scrollSpeed:Null<Float> = null;
	/**
	 * The resulting scroll speed information.
	 */
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float
		return scrollSpeed ?? parent.scrollSpeed ?? StrumLine.generalScrollSpeed;

	/**
	 * The sustains tied to this note.
	 */
	public final tail:Array<Sustain> = [];
	/**
	 * The tail length in time.
	 */
	public var length(get, never):Float;
	inline function get_length():Float {
		tail.sort(sortTail); // jic
		return tail.length != 0 ? tail[tail.length - 1].time : 0;
	}

	/**
	 * If true the note can be hit.
	 */
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool {
		return time >= Conductor.songPosition - 230 && time <= Conductor.songPosition + 230;
	}
	/**
	 * If true it's too late to hit the note.
	 */
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return time < Conductor.songPosition - (300 / Math.abs(__scrollSpeed)) && !wasHit;
	}
	/**
	 * If true this note has been hit.
	 */
	public var wasHit:Bool = false;
	/**
	 * If true this note has been missed.
	 */
	public var wasMissed:Bool = false;

	public var noteType:String = "default";

	public function new(parent:StrumLine, id:Int, time:Float, tailLength:Float) {
		super(-10000, -10000);
		this.parent = parent;
		this.id = id;
		this.time = time;
		skin = 'default';
		preventAutoSkinSet = false;

		var roundedLength:Int = Math.round(tailLength / Conductor.stepLengthMs);
		if (roundedLength > 1) {
			for (susNote in 0...roundedLength)
				tail.push(new Sustain(this, (Conductor.stepLengthMs * susNote), susNote == (roundedLength - 1)));
			tail.sort(sortTail);
		}
		reloadSkin(true);

		scale.set(0.7, 0.7);
		scale.scale(parent.strumScale);
		updateHitbox();
	}

	public function reloadSkin(?skin:String, effectTail:Bool = false):Void {
		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		this.skinMeta = NoteSkinRegistry.getNoteSkinByID(skin);
		loadSprite(skinMeta.getNoteAssetPath());
		for (data in skinMeta.getNoteAnimations(id, parent.keyCount))
			addAnimFromData(data);
		var lol:Array<Float> = skinMeta.getNoteOffsets();
		globalOffset.set(lol[0], lol[1]);
		if (effectTail) for (sustain in tail) sustain.reloadSkin(skin);

		playAnim('note', true); updateHitbox();
	}

	override public function draw():Void {
		if (parent.downscroll) {
			final prevY:Float = y;
			y = FlxG.height - y - height;
			globalOffset.y *= -1;
			super.draw();
			globalOffset.y *= -1;
			y = prevY;
		} else super.draw();
	}

	/**
	 * Filters an array of notes.
	 * @param notes An array of notes.
	 * @param i Specified note id. This is optional.
	 * @return Array<Note> ~ Resulting filter.
	 */
	inline public static function filterNotes(notes:Array<Note>, ?i:Int):Array<Note> {
		var result:Array<Note> = notes.filter((note:Note) -> return note.exists && note.canHit && !note.wasHit && !note.wasMissed && !note.tooLate && note.id == (i ?? note.id));
		result.sort(sortNotes);
		return result;
	}
	/**
	 * Filters an array of sustains.
	 * @param sustains An array of sustains.
	 * @param isMiss If true then this filters out sustains that can't be hit.
	 * @param i Specified sustain id. This is optional.
	 * @return Array<Sustain> ~ Resulting filter.
	 */
	inline public static function filterTail(sustains:Array<Sustain>, isMiss:Bool = false, ?i:Int):Array<Sustain> {
		var result:Array<Sustain> = sustains.filter((sustain:Sustain) -> return sustain.exists && (isMiss ? true : sustain.canHit) && !sustain.wasHit && !sustain.wasMissed && !sustain.tooLate && sustain.id == (i ?? sustain.id));
		result.sort(sortTail);
		return result;
	}

	/**
	 * Helper function for sorting an array of notes.
	 * @param a Note a.
	 * @param b Note b.
	 * @return Int
	 */
	inline public static function sortNotes(a:Note, b:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
	/**
	 * Helper function for sorting an array of sustains.
	 * @param a Note a.
	 * @param b Note b.
	 * @return Int
	 */
	inline public static function sortTail(a:Sustain, b:Sustain):Int
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);

	override public function kill():Void {
		for (sustain in tail)
			sustain.kill();
		super.kill();
	}
	override public function revive():Void {
		for (sustain in tail)
			sustain.revive();
		super.revive();
	}
	override public function destroy():Void {
		for (sustain in tail)
			sustain.destroy();
		tail.resize(0);
		super.destroy();
	}
}