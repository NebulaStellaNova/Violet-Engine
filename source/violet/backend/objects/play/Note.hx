package violet.backend.objects.play;

import flixel.addons.sound.FlxRhythmConductor;
import flixel.util.FlxSort;
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

	/**
	 * The sustains tied to this note.
	 */
	public final tail:Array<Sustain> = [];

	public function new(parent:StrumLine, id:Int, time:Float, tailLength:Float) {
		super(-10000, -10000);
		this.parent = parent;
		this.id = id;
		this.time = time;
		skin = 'default';
		preventAutoSkinSet = false;

		var roundedLength:Int = Math.round(tailLength / FlxRhythmConductor.instance.stepLengthMs);
		if (roundedLength > 1) {
			for (susNote in 0...roundedLength)
				tail.push(new Sustain(this, (FlxRhythmConductor.instance.stepLengthMs * susNote), susNote == (roundedLength - 1)));
			tail.sort(sortTail);
		}
		reloadSkin(true);
	}

	public function reloadSkin(?skin:String, effectTail:Bool = false):Void {
		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		final meta:NoteSkin = NoteSkinRegistry.getNoteSkinByID(skin);
		loadSprite(meta.getNoteAssetPath());
		for (data in meta.getNoteAnimations(ID, parent.keyCount))
			addAnimFromJSON(data);
		var lol:Array<Float> = meta.getNoteOffsets();
		globalOffset.set(lol[0], lol[1]);
		if (effectTail) for (sustain in tail) sustain.reloadSkin(skin);

		playAnim('note', true); updateHitbox();
	}

	/**
	 * Filters an array of notes.
	 * @param notes An array of notes.
	 * @param i Specified note id. This is optional.
	 * @return Array<Note> ~ Resulting filter.
	 */
	inline public static function filterNotes(notes:Array<Note>, ?i:Int):Array<Note> {
		var result:Array<Note> = notes.filter((note:Note) -> return note.exists /* && note.canHit && !note.wasHit && !note.wasMissed && !note.tooLate */ && note.id == (i ?? note.id));
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
		var result:Array<Sustain> = sustains.filter((sustain:Sustain) -> return sustain.exists /* && (isMiss ? true : sustain.canHit) && !sustain.wasHit && !sustain.wasMissed && !sustain.tooLate */ && sustain.id == (i ?? sustain.id));
		result.sort(sortTail);
		return result;
	}

	/**
	 * Helper function for sorting an array of notes.
	 * @param a Note a.
	 * @param b Note b.
	 * @return Int
	 */
	inline public static function sortNotes(a:Note, b:Note):Int {
		/* if (a.lowPriority && !b.lowPriority) return 1;
		else if (!a.lowPriority && b.lowPriority) return -1; */
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
	}
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
		super.destroy();
	}
}