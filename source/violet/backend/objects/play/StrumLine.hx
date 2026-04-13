package violet.backend.objects.play;

import violet.data.notestyles.NoteStyleRegistry;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.events.KeyboardEvent;
import violet.backend.audio.Conductor;
import violet.backend.options.Options;
import violet.data.Scoring;
import violet.data.character.Character;
import violet.data.chart.Chart;
import violet.data.chart.ChartData;
import violet.states.PlayState;

class StrumLine extends FlxGroup {

	public var controllerType:ChartStrumLineType;

	public final characters:Array<Character> = [];

	public var downscroll:Bool = Options.data.downscroll;
	public var disableOptionsAffect:Bool = false; // Makes it so changing downscroll in settings doesn't affect this strumline.

	/**
	 * States whether the strumLine is meant to be managed by the player.
	 */
	public var isPlayer(get, never):Bool;
	function get_isPlayer():Bool
		return controllerType == PLAYER;

	/**
	 * NOTE: Can even be true when isPlayer is true. (ex: botplay)
	 * States whether the strumLine is meant to be controlled automatically by a computer.
	 */
	public var isComputer(get, never):Bool;
	function get_isComputer():Bool {
		return !isPlayer; // like this for now, will be changed later
	}

	/**
	 * Wether the notes and sustains should show up at all.
	 */
	public var renderNotes:Bool = true;

	public final strums:FlxTypedGroup<Strum>;
	public final notes:NoteGroup;
	public final sustains:SustainGroup;

	public var splashes(get, never):Array<StrumElement>;
	function get_splashes():Array<StrumElement> {
		var value:Array<StrumElement> = [];
		for (strum in strums) value = value.concat(strum.splashes);
		return value;
	}
	public var holdCovers(get, never):Array<StrumElement>;
	function get_holdCovers():Array<StrumElement> {
		var value:Array<StrumElement> = [];
		for (strum in strums) value = value.concat(strum.holdCovers);
		return value;
	}

	public static var generalScrollSpeed:Float = 1;
	public var scrollSpeed:Null<Float>;

	public final chartData:_ChartStrumLine;
	public var keyCount(default, null):Int;

	public var x(default, set):Float;
	function set_x(value:Float):Float {
		setPosition(x = value, y);
		return x;
	}
	public var y(default, set):Float;
	function set_y(value:Float):Float {
		setPosition(x, y = value);
		return y;
	}
	public final scale:FlxCallbackPoint;

	public var strumScale:Float;
	public var strumSpacing:Float;

	public var noteStyle(default, set):String;
	function set_noteStyle(value:String):String {
		noteStyle = value;
		for (strum in strums) if (strum.style == null) strum.reloadStyle(value);
		for (note in notes) if (note.style == null) note.reloadStyle(value, true);
		return value;
	}

	public final vocals:FlxSound;

	public function new(chartData:_ChartStrumLine) {
		this.chartData = chartData;
		controllerType = chartData.type;
		scrollSpeed = chartData.scrollSpeed;
		super();

		scale = new FlxCallbackPoint((point) -> @:privateAccess {
			for (strum in strums) {
				final daScale:Float = strum.styleMeta.strumProperties.scale;
				strum.scale.set(daScale, daScale);
				strum.scale.scale(strumScale);
				strum.updateHitbox();
			}
			for (note in notes) {
				final daScale:Float = note.styleMeta.noteProperties.scale;
				note.scale.set(daScale, daScale);
				note.scale.scale(strumScale);
				note.updateHitbox();
			}
			for (sustain in sustains) {
				final daScale:Float = sustain.styleMeta.sustainProperties.scale * strumScale;
				sustain.scale.set(daScale, sustain.isEnd ? daScale : sustain.scale.y);
				sustain.updateHitbox();
			}
		});

		add(strums = new FlxTypedGroup<Strum>());
		add(sustains = new SustainGroup());
		add(notes = new NoteGroup(this));

		generateStrums(chartData.keyCount);

		strumScale = chartData.strumScale;
		strumSpacing = chartData.strumSpacing;
		scale.set(1, 1); setPosition(chartData.strumPosition[0], chartData.strumPosition[1], chartData.strumPosIsPure);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, _on_press);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, _on_release);

		// Rodney make this work thank.
		/* if (Paths.fileExists(Paths.vocal(PlayState.song, characters[0].id, PlayState.variation)))
			vocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(PlayState.song, characters[0].id, PlayState.variation), 'root', null, true), FlxG.sound.defaultMusicGroup));
		else */ if (chartData.vocalsSuffix == null) vocals = Conductor.addAdditionalTrack(new FlxSound());
		else vocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix, PlayState.variation), 'root', null, true), FlxG.sound.defaultMusicGroup));

		noteStyle = chartData.noteStyle;

		for (data in chartData.notes) {
			var type = PlayState.SONG._data.noteTypes[data.type-1];
			if (type == null || !NoteStyleRegistry.doesNoteStyleExist(type)) continue;
			var noteStyle = NoteStyleRegistry.getNoteStyleByID(type);
			Cache.image(noteStyle.getSplashAssetPath(), 'root');
			Cache.image(noteStyle.getHoldCoverAssetPath(), 'root');
		}
	}

	public function setPosition(x:Float = 0, y:Float = 0, purePos:Bool = true):Void {
		if (downscroll) y = getDefaultCamera().height - y - Note.swagWidth;
		for (i => strum in strums) {
			var _x:Float = x;
			if (!purePos) _x = (getDefaultCamera().width * x) - ((Note.swagWidth * strumScale * (keyCount / 2) - 0.5 * strumSpacing) + Note.swagWidth * 0.5 * strumScale);
			strum.x = _x + (Note.swagWidth * strumScale * strumSpacing * i);
			strum.y = y + (Note.swagWidth * 0.5) - (Note.swagWidth * strumScale * 0.5);
		}
	}

	public function generateStrums(mania:Int = 4):Void {
		while (strums.length != 0) {
			final strum = strums.members[strums.length - 1];
			strums.remove(strum);
			strum.destroy();
		}
		keyCount = mania;
		currentInputs.resize(0);
		for (i in 0...keyCount) {
			strums.add(new Strum(this, i));
			currentInputs.push(false);
		}
	}
	public function generateNotes(?time:Float):Void {
		var stackedNoteCount:Int = 0;
		for (data in chartData.notes) {
			if (data.time < time ?? Math.NEGATIVE_INFINITY) continue;
			var note:Note = new Note(this, data.id, data.time, data.sLen, PlayState.SONG._data.noteTypes[data.type-1]);
			var exists = false;
			for (i in notes) {
				if (i.time == data.time && i.id == data.id) exists = true;
				if (exists && data.sLen > i.length) {
					notes.remove(i);
					i.destroy();
					exists = false;
				}
			}
			if (!exists) notes.add(note);
			else note.destroy();
			if (exists) stackedNoteCount++;
		}
		if (stackedNoteCount != 0) trace('warning:Found <cyan>$stackedNoteCount<reset> stacked note${stackedNoteCount == 1 ? '' : 's'} for strumline <cyan>$ID<reset>. (They where removed)');
	}

	public dynamic function _onVoidTap(id:Int, strumLine:StrumLine):Void {}
	public dynamic function _onNoteHit(note:Note):Void {}
	public dynamic function _onSustainHit(sustain:Sustain):Void {}
	public dynamic function _onNoteMissed(note:Note):Void {}
	public dynamic function _onSustainMissed(sustain:Sustain):Void {}

	override public function update(elapsed:Float):Void {
		// auto hit and note miss
		notes.forEachExists((note:Note) -> {
			if (note.tooLate && !note.wasHit && !note.wasMissed)
				_onNoteMissed(note);
			if (isComputer)
				if (note.time < Conductor.framePosition && !note.tooLate && !note.wasHit && !note.wasMissed)
					_onNoteHit(note);
		});
		// auto hit and sustain miss
		sustains.forEachExists((sustain:Sustain) -> {
			if (sustain.tooLate && !sustain.wasHit && !sustain.wasMissed)
				_onSustainMissed(sustain);
			if (isComputer)
				if ((sustain.time + sustain.parentNote.time) < Conductor.framePosition && !sustain.tooLate && !sustain.wasHit && !sustain.wasMissed)
					_onSustainHit(sustain);
		});

		if (isPlayer) {
			for (i => input in currentInputs)
				if (input) for (sustain in Note.filterTail(sustains.members, i))
					if ((sustain.time + sustain.parentNote.time) < Conductor.framePosition)
						_onSustainHit(sustain);
		}

		super.update(elapsed);

		// checks when a note and its tail can be killed
		notes.forEachExists((note:Note) -> {
			var wasKilled:Bool = false;
			if (note.tail.length != 0) {
				note.tail.sort(Note.sortTail); // jic
				final tailEnd:Sustain = note.tail[note.tail.length - 1];
				if ((tailEnd.wasHit || tailEnd.wasMissed) && tailEnd.tooLate) {
					note.kill();
					wasKilled = true;
				}
			} else {
				if ((note.wasHit || note.wasMissed) && note.tooLate) {
					note.kill();
					wasKilled = true;
				}
			}
			if (wasKilled) return;

			// note positioning code for now will be placed here
			var resultAngle:Float = 270;
			if (note.__scrollSpeed < 0) resultAngle += 180;
			final angleDir:Float = resultAngle * (Math.PI / 180);

			final strum:Strum = note.parentStrum;
			final pos:Array<Float> = [strum.x, strum.y];
			var disPos:Float = 0.45 * (Conductor.framePosition - note.time) * Math.abs(note.__scrollSpeed) * Math.abs(scale.x / scale.y);

			pos[0] += Math.cos(angleDir) * disPos;
			// TODO: Figure out how to do this better, especially for sustains.
			pos[0] -= note.width / 2;
			pos[0] += strum.width / 2;

			pos[1] += Math.sin(angleDir) * disPos;
			pos[1] -= note.height / 2;
			pos[1] += strum.height / 2;

			note.setPosition(pos[0], pos[1]);
			pos.resize(0);

			for (sustain in note.tail) {
				if (sustain == null) continue; if (!sustain.exists) continue;
				final pos:Array<Float> = [strum.x, strum.y];
				disPos = 0.45 * (Conductor.framePosition - (note.time + sustain.time)) * Math.abs(sustain.__scrollSpeed) * Math.abs(scale.x / scale.y);

				pos[0] += Math.cos(angleDir) * disPos;
				pos[0] -= sustain.width / 2;
				pos[0] += strum.width / 2;

				pos[1] += Math.sin(angleDir) * disPos;
				pos[1] += strum.height / 2;

				sustain.setPosition(pos[0], pos[1]);
				pos.resize(0);

				if (sustain.wasHit) {
					var t = FlxMath.bound((Conductor.framePosition - (note.time + sustain.time)) / sustain.height * 0.45 * sustain.__scrollSpeed, 0, 1);
					var rect = sustain.clipRect == null ? FlxRect.get() : sustain.clipRect;
					sustain.clipRect = rect.set(0, sustain.frameHeight * t, sustain.frameWidth, sustain.frameHeight * (1 - t));
				}
			}
		});
	}

	final currentInputs:Array<Bool> = [];
	function _on_press(event:KeyboardEvent):Void {
		if (FlxG.state.subState != null) return;
		if (isComputer) return;
		final inputId:Int = getKeyFromEvent(['note_left', 'note_down', 'note_up', 'note_right'], event.keyCode);
		if (inputId < 0 || inputId >= strums.length) return;
		if (!FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED)) return;
		currentInputs[inputId] = true;

		final activeNotes:Array<Note> = Note.filterNotes(notes.members, inputId);
		if (activeNotes.length != 0) {
			var frontNote:Note = activeNotes[0]; // took from psych, fixes a dumb issue where it eats up jacks
			if (activeNotes.length > 2) {
				final backNote:Note = activeNotes[1];
				if (Math.abs(backNote.time - frontNote.time) < 1.0) {
					final liveNote:Note = backNote.length < frontNote.length ? backNote : frontNote;
					final deadNote:Note = backNote.length < frontNote.length ? frontNote : backNote;
					deadNote.destroy(); // shouldn't need to keep existing
					frontNote = liveNote;
				} else if (backNote.time < frontNote.time)
					frontNote = backNote;
			}
			_onNoteHit(frontNote);
		} else _onVoidTap(inputId, this);
	}
	function _on_release(event:KeyboardEvent):Void {
		if (FlxG.state.subState != null) return;
		if (isComputer) return;
		final inputId:Int = getKeyFromEvent(['note_left', 'note_down', 'note_up', 'note_right'], event.keyCode);
		if (inputId < 0 || inputId >= strums.length) return;
		if (!FlxG.keys.checkStatus(event.keyCode, JUST_RELEASED)) return;
		currentInputs[inputId] = false;

		final strum:Strum = strums.members[inputId];
		if (strum.animation?.name != 'static')
			strum.playStrumAnim('static');
	}

	function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int {
		if (key != NONE) {
			for (i in 0...arr.length) {
				var note:Array<FlxKey> = @:privateAccess Controls.bindCheck(arr[i]);
				for (noteKey in note)
					if (key == noteKey)
						return i;
			}
		}
		return -1;
	}

	override public function destroy():Void {
		scale.put();
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _on_press);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, _on_release);
		super.destroy();
	}

}

class NoteGroup extends FlxTypedGroup<Note> {

	/**
	 * Applies a function to all rendered members.
	 * @param func A function that modifies one note at a time.
	 */
	public function forEachRendered(func:Note->Void):Void {
		var shouldRender:Bool = true;
		forEachExists((note:Note) -> {
			note._beingRendered = false;
			if (!parentField.renderNotes) return;

			shouldRender = true;
			if ((note.time + note.length) < Conductor.framePosition - (Scoring.missThreshold * note.earlyWindow)) shouldRender = false;
			if (note.time > Conductor.framePosition + (note.getDefaultCamera().height / note.getDefaultCamera().zoom / 0.45 / Math.min(note.__scrollSpeed, 1))) shouldRender = false;

			if (shouldRender) {
				note._beingRendered = true;
				func(note);
			}
		});
	}

	var parentField:StrumLine;
	override public function new(parent:StrumLine) {
		super();
		this.parentField = parent;
		sortBy = 'time';
	}

	override public function update(elapsed:Float):Void {
		forEachRendered(
			(note:Note) ->
				if (note.visible)
					note.update(elapsed)
		);
	}

	@:access(flixel.FlxCamera)
	override public function draw():Void {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null) FlxCamera._defaultCameras = _cameras;
		forEachRendered(
			(note:Note) ->
				if (note.visible)
					note.draw()
		);
		FlxCamera._defaultCameras = oldDefaultCameras;
	}

}

class SustainGroup extends FlxTypedGroup<Sustain> {

	/**
	 * Applies a function to all rendered members.
	 * @param func A function that modifies one sustain at a time.
	 */
	public function forEachRendered(func:Sustain->Void):Void {
		forEachExists((sustain:Sustain) ->
			if (sustain.parentNote._beingRendered)
				func(sustain)
		);
	}

	override public function new() {
		super();
		sortBy = 'time';
	}

	override public function update(elapsed:Float):Void {
		forEachRendered(
			(sustain:Sustain) ->
				if (sustain.visible)
					sustain.update(elapsed)
		);
	}

	@:access(flixel.FlxCamera)
	override public function draw():Void {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null) FlxCamera._defaultCameras = _cameras;
		forEachRendered(
			(sustain:Sustain) ->
				if (sustain.visible)
					sustain.draw()
		);
		FlxCamera._defaultCameras = oldDefaultCameras;
	}

}