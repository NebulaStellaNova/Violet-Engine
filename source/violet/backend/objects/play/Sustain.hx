package violet.backend.objects.play;

import flixel.math.FlxRect;
import violet.backend.audio.Conductor;
import violet.data.Scoring;
import violet.data.notestyles.NoteStyle;
import violet.data.notestyles.NoteStyleRegistry;

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
	var preventAutoStyleSet:Bool = true;
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
	 * The style the sustain will use.
	 */
	public var style(get, set):String;
	inline function get_style():String return parentNote.style;
	inline function set_style(value:String):String return parentNote.style = value;
	var styleMeta:NoteStyle;

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
		return (time + parentNote.time) > Conductor.framePosition - (Scoring.missThreshold * parentNote.earlyWindow) && (time + parentNote.time) < Conductor.framePosition + (Scoring.missThreshold * parentNote.lateWindow);
	}
	/**
	 * If true it's too late to hit the sustain.
	 */
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return (time + parentNote.time) < Conductor.framePosition - (Scoring.missThreshold * parentNote.earlyWindow) && !wasHit;
	}
	/**
	 * If true this sustain has been hit.
	 */
	public var wasHit:Bool = false;
	/**
	 * If true this sustain has been missed.
	 */
	public var wasMissed:Bool = false;

	/**
	 * The current note type.
	 */
	public var noteType(get, set):String;
	inline function get_noteType():String return parentNote.noteType;
	inline function set_noteType(value:String):String return parentNote.noteType = value;

	public function new(parent:Note, time:Float, isEnd:Bool) {
		super(-10000, -10000);
		parentNote = parent;
		this.time = time;
		this.isEnd = isEnd;
		this.parent.sustains.add(this);

		final daScale:Float = Note.swagWidth * this.parent.strumScale;
		scale.set(daScale, isEnd ? daScale : 0);
		updateHitbox();
	}

	public function reloadStyle(?style:String):Void {
		this.anims.clear();
		animation.destroyAnimations();
		final style:String = style ?? this.style ?? parentNote.style ?? parentStrum.style ?? parent.noteStyle ?? 'default';
		this.styleMeta = NoteStyleRegistry.getNoteStyleByID(style);
		loadSprite(styleMeta.getSustainAssetPath());
		for (data in styleMeta.getSustainAnimations(id, parent.keyCount))
			addAnimFromData(data);
		var lol:Array<Float> = styleMeta.getSustainOffsets();
		globalOffset.set(lol[0], lol[1]);
		this.antialiasing = styleMeta.isSustainPixel();

		playAnim(isEnd ? 'end' : 'tail', true);
		final daScale:Float = styleMeta.sustainProperties.scale * parent.strumScale;
		scale.set(daScale, isEnd ? daScale : scale.y);
		updateHitbox(); alpha = styleMeta.sustainProperties.alpha;
		blend = styleMeta.sustainProperties.blendMode;
	}

	var lastScrollSpeed:Float = 0;
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!isEnd && lastScrollSpeed != __scrollSpeed) {
			lastScrollSpeed = __scrollSpeed;
			scale.y = (parentNote._stepLengthMs * 0.45 * Math.abs(lastScrollSpeed)) / frameHeight;
			updateHitbox();
			if (styleMeta.getSustainGapFix() != 0)
				scale.y += styleMeta.getSustainGapFix() / frameHeight;
		}
	}

	override public function draw():Void {
		if (parent.downscroll) {
			final prevY:Float = y;
			y = getDefaultCamera().height - y - height + (getDefaultCamera().height / 2 + (parentNote.height / 2) + parentNote.height) - 10;
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

	override public function destroy():Void {
		super.destroy();
		if (clipRect != null)
			clipRect.put();
	}

}