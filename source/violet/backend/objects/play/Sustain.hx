package violet.backend.objects.play;

import flixel.math.FlxRect;
import violet.backend.audio.Conductor;
import violet.data.noteskin.NoteSkin;
import violet.data.noteskin.NoteSkinRegistry;

class Sustain extends NovaSprite {
	/**
	 * The parent strumline.
	 */
	public var parent(get, never):StrumLine;
	inline function get_parent():StrumLine
		return parentNote.parent;
	/**
	 * The parent note.
	 */
	public final parentNote:Note;
	/**
	 * The parent strum.
	 */
	public var parentStrum(get, never):Strum;
	inline function get_parentStrum():Strum
		return parentNote.parentStrum;

	@:allow(violet.backend.objects.play.Note)
	var preventAutoSkinSet:Bool = true;
	/**
	 * The direction id of the sustain.
	 */
	public var id(get, set):Int;
	inline function get_id():Int return parentNote.id;
	inline function set_id(value:Int):Int return parentNote.id = value;
	/**
	 * The current position within the song.
	 */
	public var time:Float;
	/**
	 * The skin the sustain will use.
	 */
	public var skin(get, set):String;
	inline function get_skin():String return parentNote.skin;
	inline function set_skin(value:String):String return parentNote.skin = value;
	var skinMeta:NoteSkin;

	/**
	 * States if this is the end piece of a sustain tail.
	 */
	public final isEnd:Bool;

	/**
	 * The resulting scroll speed information.
	 */
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float
		return parentNote.__scrollSpeed;

	/**
	 * If true the sustain can be hit.
	 */
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool {
		return (time + parentNote.time) >= Conductor.songPosition - 230 && (time + parentNote.time) <= Conductor.songPosition + 230;
	}
	/**
	 * If true it's too late to hit the sustain.
	 */
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return (time + parentNote.time) < Conductor.songPosition - (300 / Math.abs(__scrollSpeed)) && !wasHit;
	}
	/**
	 * If true this sustain has been hit.
	 */
	public var wasHit:Bool = false;
	/**
	 * If true this sustain has been missed.
	 */
	public var wasMissed:Bool = false;

	public function new(parent:Note, time:Float, isEnd:Bool) {
		super(-10000, -10000);
		parentNote = parent;
		this.time = time;
		this.isEnd = isEnd;
		skin = 'default';
		this.parent.sustains.add(this);

		final daScale:Float = 0.7 * this.parent.strumScale;
		scale.set(daScale, isEnd ? daScale : 0);
		updateHitbox();
	}

	public function reloadSkin(?skin:String):Void {
		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		this.skinMeta = NoteSkinRegistry.getNoteSkinByID(skin);
		loadSprite(skinMeta.getSustainAssetPath());
		for (data in skinMeta.getSustainAnimations(id, parent.keyCount))
			addAnimFromData(data);
		var lol:Array<Float> = skinMeta.getSustainOffsets();
		globalOffset.set(lol[0], lol[1]);

		playAnim(isEnd ? 'end' : 'tail', true); updateHitbox();
	}

	override public function draw():Void {
		if (parent.downscroll) {
			final prevY:Float = y;
			y = FlxG.height - y - height;
			// flipping the x too so visuals aren't flipped
			flipX = !flipX; flipY = !flipY;
			globalOffset.y *= -1;
			super.draw();
			globalOffset.y *= -1;
			flipX = !flipX; flipY = !flipY;
			y = prevY;
		} else super.draw();
	}

	override function set_clipRect(value:FlxRect):FlxRect {
		clipRect = value;
		if (frames != null) frame = frames.frames[animation.frameIndex];
		return value;
	}
}