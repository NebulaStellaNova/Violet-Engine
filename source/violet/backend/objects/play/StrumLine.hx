package violet.backend.objects.play;

import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import openfl.events.KeyboardEvent;
import violet.backend.audio.Conductor;
import violet.backend.options.Options;
import violet.backend.utils.MathUtil;
import violet.data.Scoring;
import violet.data.character.Character;
import violet.data.chart.Chart;
import violet.data.chart.ChartData;
import violet.data.notestyles.NoteStyleRegistry;
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
		return !isPlayer || (isPlayer && PlayState.instance != null && PlayState.instance.botplay);
	}

	/**
	 * Wether the notes and sustains should show up at all.
	 */
	public var renderNotes:Bool = true;

	public final strums:FlxTypedGroup<Strum>;
	public final notes:NoteGroup;
	public final sustains:SustainGroup;
	public final lanes:FlxTypedSpriteGroup<FlxBackdrop>;

	// TODO: allow this to be changed via noteStyle and noteType
	public final flashColors:Array<FlxColor> = [0xFFc24b99, 0xFF00ffff, 0xFF12fa05, 0xFFf9393f];

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

	/**
	 * The general scroll speed of the entire game.
	 */
	public static var generalScrollSpeed:Float = 1;
	/**
	 * The general scroll angle of the entire game.
	 */
	inline public static function generalScrollAngle(?strumLine:StrumLine):Float {
		return (strumLine?.downscroll ?? Options.data.downscroll) ? 180 : 0;
	}

	/**
	 * The scroll speed of this strumLines notes.
	 */
	public var scrollSpeed:Null<Float>;
	/**
	 * The scroll angle of this strumLines notes.
	 */
	public var scrollAngle:Null<Float>;

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


		add(lanes = new FlxTypedSpriteGroup());

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

		__on_release = _->_on_release(_);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, _on_press);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, __on_release);

		// Rodney make this work thank.
		/* if (Paths.fileExists(Paths.vocal(PlayState.song, characters[0].id, PlayState.variation)))
			vocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(PlayState.song, characters[0].id, PlayState.variation), 'root', null, true), FlxG.sound.defaultMusicGroup));
		else */
		if (chartData.vocalsSuffix == null || chartData.vocalsSuffix == "") vocals = Conductor.addAdditionalTrack(new FlxSound());
		else {
			var vocalPath = "";
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix, PlayState.variation);
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix, PlayState.variation, false);
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix.substr(0), PlayState.variation);
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix.substr(0), PlayState.variation, false);
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix, '');
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix, '', false);
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix.substr(0), '');
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix.substr(0), '', false);
			if (vocalPath == "") vocalPath = Paths.vocal(PlayState.songData.songName, chartData.vocalsSuffix, '');
			vocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(vocalPath, 'root', null, true), FlxG.sound.defaultMusicGroup));
		}

		noteStyle = chartData.noteStyle;

		for (data in chartData.notes) {
			var type = PlayState.SONG._data.noteTypes[data.type-1];
			if (type == null || !NoteStyleRegistry.doesNoteStyleExist(type)) continue;
			var noteStyle = NoteStyleRegistry.getNoteStyleByID(type);
			Cache.image(noteStyle.getSplashAssetPath(), 'root');
			Cache.image(noteStyle.getHoldCoverAssetPath(), 'root');
		}

		generateLanes();

	}

	public var dynamicLanes:Array<FlxBackdrop> = [];
	public var dynamicLanesColored:Array<FlxBackdrop> = [];

	public function generateLanes() {
		for (i in lanes.members) {
			if (dynamicLanes.contains(i)) dynamicLanes.remove(i);
			if (dynamicLanesColored.contains(i)) dynamicLanesColored.remove(i);
			lanes.remove(i);
			i.destroy();
		}
		if (Options.data.laneUnderlay) {
			if (Options.data.fancyLaneUnderlay) {
				for (i=>strum in strums) {
					var lane = new FlxBackdrop(Y);
					lane.makeGraphic(Math.round(Note.swagWidth), FlxG.height, FlxColor.BLACK);
					lane.x = Note.swagWidth * strumScale * strumSpacing * i;
					lane.alpha = Options.data.underlayOpacity / 100;
					dynamicLanes.push(lane);
					lanes.add(lane);

					var lane = new FlxBackdrop(Y);
					lane.makeGraphic(Math.round(Note.swagWidth), FlxG.height, flashColors[i % 4]);
					lane.x = Note.swagWidth * strumScale * strumSpacing * i;
					lane.alpha = 0;
					dynamicLanesColored.push(lane);
					lanes.add(lane);

				}
			} else {
				var width:Int = Math.round(Note.swagWidth * strumScale * strumSpacing * strums.length);
				width += Math.round(Options.data.laneGrow) * 2;
				var lane = new FlxBackdrop(Y);
				lane.makeGraphic(width, FlxG.height, FlxColor.BLACK);
				lane.alpha = Options.data.underlayOpacity / 100;
				lanes.add(lane);
			}
		}
	}

	public function setPosition(x:Float = 0, y:Float = 0, purePos:Bool = true):Void {
		if (Options.data.forceMiddleScroll && !purePos) {
			if (isPlayer) x = 0.5;
			else x = -1000;
		}
		if (purePos) {
			lanes.x = x;
		} else {
			var width:Int = Math.round(Note.swagWidth * strumScale * strumSpacing * strums.length);
			lanes.x = getDefaultCamera().width * x;
			lanes.x -= width/2;
			if (!Options.data.fancyLaneUnderlay) lanes.x -= Options.data.laneGrow;
			lanes.x -= 8;
		}
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
		activeNotesByLane.resize(0);
		activeNoteLaneCursors.resize(0);
		activeSustainsByLane.resize(0);
		activeSustainLaneCursors.resize(0);
		for (i in 0...keyCount) {
			strums.add(new Strum(this, i));
			currentInputs.push(false);
			activeNotesByLane.push([]);
			activeNoteLaneCursors.push(0);
			activeSustainsByLane.push([]);
			activeSustainLaneCursors.push(0);
		}
	}

	public var preparedNotes:Array<Note> = [];
	public var nextNoteIndex:Int = 0;
	public var spawnLookaheadMs:Float = 1500;

	public function generateNotes(?time:Float):Void {
		var stackedNoteCount:Int = 0;
		preparedNotes.resize(0);
		nextNoteIndex = 0;

		for (data in chartData.notes) {
			if (time != null && data.time < time) continue;

			var existingNote:Note = null;
			for (i in preparedNotes) {
				if (i.time == data.time && i.id == data.id) {
					existingNote = i;
					break;
				}
			}

			if (existingNote != null) {
				stackedNoteCount++;
				if (data.sLen <= existingNote.length)
					continue;

				preparedNotes.remove(existingNote);
				existingNote.destroy();
			}

			var targetType:Null<String> = null;
			if (data.type is String) {
				targetType = data.type;
			} else if (data.type != null) {
				targetType = PlayState.SONG._data.noteTypes[data.type-1];
			}

			preparedNotes.push(new Note(this, data.id, data.time, data.sLen, targetType));
		}
		preparedNotes.sort(Note.sortNotes);
		if (stackedNoteCount != 0) trace('warning:Found <cyan>$stackedNoteCount<reset> stacked note${stackedNoteCount == 1 ? '' : 's'} for strumline <cyan>$ID<reset>. (They where removed)');
	}

	inline function getSpawnWindow(note:Note):Float {
		var speed:Float = Math.abs(note.__scrollSpeed);
		if (speed < 0.001) speed = 0.001;
		return spawnLookaheadMs / speed;
	}

	function spawnNote(note:Note):Void {
		if (note.destroyed) return;

		notes.add(note);
		if (note.id >= 0 && note.id < activeNotesByLane.length)
			activeNotesByLane[note.id].push(note);

		for (sustain in note.tail) {
			if (sustain != null && !sustain.destroyed) {
				sustains.add(sustain);
				if (sustain.id >= 0 && sustain.id < activeSustainsByLane.length)
					activeSustainsByLane[sustain.id].push(sustain);
			}
		}
	}

	function spawnPreparedNotes():Void {
		while (
			nextNoteIndex < preparedNotes.length
			&& preparedNotes[nextNoteIndex].time - Conductor.songPosition < getSpawnWindow(preparedNotes[nextNoteIndex])
		) {
			spawnNote(preparedNotes[nextNoteIndex]);
			nextNoteIndex++;
		}
	}

	public dynamic function _onVoidTap(id:Int, strumLine:StrumLine):Void {}
	public dynamic function _onNoteHit(note:Note):Void {}
	public dynamic function _onSustainHit(sustain:Sustain):Void {}
	public dynamic function _onNoteMissed(note:Note):Void {}
	public dynamic function _onSustainMissed(sustain:Sustain):Void {}

	override public function update(elapsed:Float):Void {

		spawnPreparedNotes();

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
			for (i => input in currentInputs) {
				if (!input) continue;

				final laneSustains = activeSustainsByLane[i];
				var laneCursor = activeSustainLaneCursors[i];
				while (laneCursor < laneSustains.length) {
					final sustain = laneSustains[laneCursor];
					if (sustain != null && sustain.exists && !sustain.wasHit && !sustain.wasMissed && !sustain.tooLate)
						break;
					laneCursor++;
				}
				activeSustainLaneCursors[i] = laneCursor;

				var sustainIndex = laneCursor;
				while (sustainIndex < laneSustains.length) {
					final sustain = laneSustains[sustainIndex++];
					if (sustain == null || !sustain.exists) continue;
					if (!sustain.canHit || sustain.wasHit || sustain.wasMissed || sustain.tooLate) continue;
					if ((sustain.time + sustain.parentNote.time) < Conductor.framePosition)
						_onSustainHit(sustain);
				}
			}
		}

		super.update(elapsed);

		// checks when a note and its tail can be killed
		notes.forEachExists((note:Note) -> {
			if (note.time - Conductor.songPosition < (-Scoring.missThreshold)-10 && note.tail.length <= 1) {
				note.destroy();
				// notes.remove(note);
			}

			var wasKilled:Bool = false;
			if (note.tail.length != 0) {
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

			note.updatePosition();
		});

		for (i => strum in strums.members) {
			if (strum.animation.name == 'confirm') {
				if (strum.animation.curAnim.curFrame == 0 && dynamicLanesColored[i] != null) dynamicLanesColored[i].alpha = Options.data.laneFlashIntensity / 100;
			} else if (strum.animation.name == 'press') {
				if (dynamicLanesColored[i] != null) dynamicLanesColored[i].alpha = 0.25 * (Options.data.laneFlashIntensity / 100);
			}
		}

		for (i => lane in dynamicLanesColored) {
			lane.alpha = MathUtil.lerp(lane.alpha, 0, 0.2);
		}

		for (note in notes)
			if (note != null && note.destroyed)
				notes.remove(note);

		for (i => strum in strums.members) {
			if (strum.animation.name == 'confirm') {
				if (strum.animation.curAnim.curFrame == 0 && dynamicLanesColored[i] != null) dynamicLanesColored[i].alpha = Options.data.laneFlashIntensity / 100;
			} else if (strum.animation.name == 'press') {
				if (dynamicLanesColored[i] != null) dynamicLanesColored[i].alpha = 0.25 * (Options.data.laneFlashIntensity / 100);
			}
		}

		for (i => lane in dynamicLanesColored) {
			lane.alpha = MathUtil.lerp(lane.alpha, 0, 0.2);
		}

		for (note in notes)
			if (note != null && note.destroyed)
				notes.remove(note);

		for (i => strum in strums.members) {
			if (strum.animation.name == 'confirm') {
				if (strum.animation.curAnim.curFrame == 0 && dynamicLanesColored[i] != null) dynamicLanesColored[i].alpha = Options.data.laneFlashIntensity / 100;
			} else if (strum.animation.name == 'press') {
				if (dynamicLanesColored[i] != null) dynamicLanesColored[i].alpha = 0.25 * (Options.data.laneFlashIntensity / 100);
			}
		}

		for (i => lane in dynamicLanesColored) {
			lane.alpha = MathUtil.lerp(lane.alpha, 0, 0.2);
		}

		for (note in notes)
			if (note != null && note.destroyed)
				notes.remove(note);
	}

	final currentInputs:Array<Bool> = [];
	final activeNotesByLane:Array<Array<Note>> = [];
	final activeNoteLaneCursors:Array<Int> = [];
	final activeSustainsByLane:Array<Array<Sustain>> = [];
	final activeSustainLaneCursors:Array<Int> = [];
	function _on_press(event:KeyboardEvent):Void {
		if (FlxG.state.subState != null) return;
		if (isComputer) return;
		final inputId:Int = getKeyFromEvent(['note_left', 'note_down', 'note_up', 'note_right'], event.keyCode);
		if (inputId < 0 || inputId >= strums.length) return;
		if (!FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED)) return;
		currentInputs[inputId] = true;

		final laneNotes = activeNotesByLane[inputId];
		var laneCursor = activeNoteLaneCursors[inputId];
		while (laneCursor < laneNotes.length) {
			final note = laneNotes[laneCursor];
			if (note != null && note.exists && !note.wasHit && !note.wasMissed && !note.tooLate)
				break;
			laneCursor++;
		}
		activeNoteLaneCursors[inputId] = laneCursor;

		if (laneCursor < laneNotes.length) {
			final note = laneNotes[laneCursor];
			if (!note.canHit) {
				_onVoidTap(inputId, this);
				return;
			}
			_onNoteHit(note);
			return;
		}
		_onVoidTap(inputId, this);

	}

	var __on_release:KeyboardEvent->Void;

	function _on_release(event:KeyboardEvent, force:Bool = false):Void {
		if (FlxG.state.subState != null) return;
		if (isComputer) return;
		final inputId:Int = getKeyFromEvent(['note_left', 'note_down', 'note_up', 'note_right'], event.keyCode);
		if (!force) {
			if (inputId < 0 || inputId >= strums.length) return;
			if (!FlxG.keys.checkStatus(event.keyCode, JUST_RELEASED)) return;
		}
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
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, __on_release);
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
			if (note.time > Conductor.framePosition + (note.getDefaultCamera().height / note.getDefaultCamera().zoom / 0.45 / Math.min(Math.abs(note.__scrollSpeed), 1))) shouldRender = false;

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
