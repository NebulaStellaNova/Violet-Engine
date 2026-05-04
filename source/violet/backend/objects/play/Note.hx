package violet.backend.objects.play;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxSort;
import violet.backend.audio.Conductor;
import violet.backend.options.Options;
import violet.data.Scoring;
import violet.data.notestyles.NoteStyle;
import violet.data.notestyles.NoteStyleRegistry;

class Note extends NovaSprite {

	public static var swagWidth:Float = 160 * 0.7;

	/**
	 * The parent strumline.
	 */
	public final parent:StrumLine;
	/**
	 * The parent strum.
	 */
	public var parentStrum(get, never):Strum;
	inline function get_parentStrum():Strum
		return parent.strums.members[id];

	var preventAutoStyleSet:Bool = true;
	/**
	 * The direction id of the note.
	 */
	public var id(default, set):Int;
	inline function set_id(value:Int):Int {
		if (id != value && !preventAutoStyleSet)
			reloadStyle(true);
		return id = value;
	}
	/**
	 * The current position within the song.
	 */
	public var time:Float;
	/**
	 * The style the note will use.
	 */
	public var style(default, set):String;
	inline function set_style(value:String):String {
		if (style != value && !preventAutoStyleSet)
			reloadStyle(value, true);
		return style = value;
	}
	var styleMeta:NoteStyle;

	/**
	 * The scroll speed of this note.
	 */
	public var scrollSpeed:Null<Float>;
	/**
	 * The resulting scroll speed information.
	 */
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float {
		if (Options.data.personalScrollSpeed != 0) return Options.data.personalScrollSpeed;
		return scrollSpeed ?? parentStrum.scrollSpeed ?? parent.scrollSpeed ?? StrumLine.generalScrollSpeed;
	}
	/**
	 * The scroll angle of this note.
	 */
	public var scrollAngle:Null<Float>;
	/**
	 * The resulting scroll angle information.
	 */
	public var __scrollAngle(get, never):Float;
	inline function get___scrollAngle():Float
		return scrollAngle ?? parentStrum.scrollAngle ?? parent.scrollAngle ?? StrumLine.generalScrollAngle(parent);

	/**
	 * The sustains tied to this note.
	 */
	public var tail(default, null):Array<Sustain> = [];
	/**
	 * The tail length in time.
	 */
	public var length(default, null):Float;

	/**
	 * How much earlier the note can be hit before it's considered a miss.
	 */
	public var earlyWindow:Float = 1;
	/**
	 * How much later the note can be hit without it being considered untouched.
	 */
	public var lateWindow:Float = 1;

	/**
	 * If true the note can be hit.
	 */
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool {
		return time > Conductor.framePosition - (Scoring.missThreshold * earlyWindow) && time < Conductor.framePosition + (Scoring.missThreshold * lateWindow);
	}
	/**
	 * If true it's too late to hit the note.
	 */
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return time < Conductor.framePosition - (Scoring.missThreshold * earlyWindow) && !wasHit;
	}
	/**
	 * If true this note has been hit.
	 */
	public var wasHit:Bool = false;
	/**
	 * If true this note has been missed.
	 */
	public var wasMissed:Bool = false;

	/**
	 * The current note type.
	 */
	public var noteType:String = null;

	@:allow(violet.backend.objects.play.Sustain)
	final _stepLengthMs:Float;
	@:allow(violet.backend.objects.play.StrumLine)
	var _beingRendered:Bool = false;

	public function new(parent:StrumLine, id:Int, time:Float, tailLength:Float, noteType:String) {
		super(-10000, -10000);
		this.parent = parent;
		this.id = id;
		this.time = time;
		this.noteType = noteType;
		style = null;
		preventAutoStyleSet = false;

		_stepLengthMs = flixel.addons.sound.FlxRhythmConductorUtil.getStepLengthMs(flixel.addons.sound.FlxRhythmConductor.instance.getCurrentTimeChangeBPMAccurate(time));

		final roundedLength:Int = Math.floor(tailLength / _stepLengthMs);
		if (roundedLength > 1) {
			for (susNote in 0...roundedLength)
				tail.push(new Sustain(this, (_stepLengthMs * susNote), susNote == (roundedLength - 1)));
			tail.sort(sortTail);
			length = tail[tail.length - 1].time;
		}

		if (NoteStyleRegistry.doesNoteStyleExist(noteType) && noteType != null) style = noteType;

		reloadStyle(style, true);
	}

	public function applyUnderlayColor():Void {
		// TODO: Add notetype stuff later.
		if (parent.underlay.lanes.length != 0) // jic
			parent.underlay.lanes.members[id % parent.underlay.lanes.length].setColor(styleMeta.getNoteColor(id, parent.keyCount));
	}

	public function reloadStyle(?style:String, effectTail:Bool = false):Void {
		this.anims.clear();
		animation.destroyAnimations();
		final style:String = style ?? this.style ?? parentStrum.style ?? parent.noteStyle ?? 'default';
		this.styleMeta = NoteStyleRegistry.getNoteStyleByID(style);
		loadSprite(styleMeta.getNoteAssetPath());
		for (data in styleMeta.getNoteAnimations(id, parent.keyCount))
			addAnimFromData(data);
		globalOffset.set(styleMeta.noteOffset.x, styleMeta.noteOffset.y);
		this.antialiasing = styleMeta.isNotePixel();
		if (effectTail) for (sustain in tail) sustain.reloadStyle(style);

		playAnim('note', true);
		final daScale:Float = styleMeta.noteProperties.scale;
		scale.set(daScale, daScale);
		scale.scale(parent.strumScale);
		updateHitbox(); alpha = styleMeta.noteProperties.alpha;
		blend = styleMeta.noteProperties.blendMode;
	}

	// Credits to CNE devs for the note angle code
	@:unreflective static final _note_pos:FlxPoint = FlxPoint.get();
	@:unreflective static var _last_cos:Float = 0;
	@:unreflective static var _last_sin:Float = 0;
	public function updatePosition(?strum:Strum):Void {
		strum ??= parentStrum;
		if (strum == null) return;
		if (!exists || !strum.exists) return;

		var resultAngle:Float = __scrollAngle;
		if (__scrollSpeed > 0) resultAngle += 180;
		final angleDir:Float = (resultAngle + 90) * flixel.math.FlxAngle.TO_RAD;

		final disPos:Float = (Conductor.framePosition - time) * 0.45 * Math.abs(__scrollSpeed);
		_note_pos.set(FlxMath.fastCos(angleDir) * disPos, FlxMath.fastSin(angleDir) * disPos);
		_note_pos -= origin; _note_pos += offset;
		// _note_pos += animationOffset;
		_note_pos.add(strum.x + (swagWidth / 2), strum.y + (swagWidth / 2));
		setPosition(_note_pos.x, _note_pos.y);

		// makes sense for sustains to always follow their parent note
		for (sustain in tail) {
			if (sustain == null) continue;
			if (!sustain.exists) continue;

			final disPos:Float = (Conductor.framePosition - (time + sustain.time)) * 0.45 * Math.abs(__scrollSpeed);
			_note_pos.set((_last_cos = FlxMath.fastCos(angleDir)) * disPos, (_last_sin = FlxMath.fastSin(angleDir)) * disPos);
			_note_pos -= sustain.origin; _note_pos += sustain.offset;
			// _note_pos += sustain.animationOffset;
			_note_pos.add(_last_cos * sustain.height * -0.5, _last_sin * sustain.height * -0.5);
			_note_pos.add(strum.x + (swagWidth / 2), strum.y + (swagWidth / 2));
			sustain.setPosition(_note_pos.x, _note_pos.y);
			sustain.angle = resultAngle + 180;
		}
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
		length = 0;
		tail.resize(0);
		super.destroy();
	}

}
