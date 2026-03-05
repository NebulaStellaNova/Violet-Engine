package violet.backend.objects.play;

import violet.backend.audio.Conductor;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import openfl.events.KeyboardEvent;
import violet.data.chart.Chart;
import violet.data.chart.ChartData;

class StrumLine extends FlxGroup {

	public var controllerType:ChartStrumLineType;

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

	public final strums:FlxTypedGroup<Strum>;
	public final notes:FlxTypedGroup<Note>;
	public final sustains:FlxTypedGroup<Sustain>;

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

	public function new(chartData:_ChartStrumLine) {
		this.chartData = chartData;
		controllerType = chartData.type;
		scrollSpeed = chartData.scrollSpeed;
		super();

		scale = new FlxCallbackPoint((point) -> {
			for (strum in strums) {
				strum.scale.set(0.7, 0.7);
				strum.scale.scale(strumScale);
				strum.updateHitbox();
			}
			for (note in notes) {
				note.scale.set(0.7, 0.7);
				note.scale.scale(strumScale);
				note.updateHitbox();
			}
			for (sustain in sustains) {
				final daScale:Float = 0.7 * strumScale;
				sustain.scale.set(daScale, sustain.isEnd ? daScale : sustain.scale.y);
				sustain.updateHitbox();
			}
		});

		add(strums = new FlxTypedGroup<Strum>());
		add(sustains = new FlxTypedGroup<Sustain>());
		sustains.memberAdded.add((_:Sustain) -> sustains.members.sort(Note.sortTail));
		sustains.memberRemoved.add((_:Sustain) -> sustains.members.sort(Note.sortTail));
		add(notes = new FlxTypedGroup<Note>());
		notes.memberAdded.add((_:Note) -> notes.members.sort(Note.sortNotes));
		notes.memberRemoved.add((_:Note) -> notes.members.sort(Note.sortNotes));

		generateStrums(chartData.keyCount);

		strumScale = chartData.strumScale;
		strumSpacing = chartData.strumSpacing;
		scale.set(1, 1); setPosition(chartData.strumPosition[0], chartData.strumPosition[1], chartData.strumPosIsPure);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, _on_press);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, _on_release);
	}

	public function setPosition(x:Float = 0, y:Float = 0, purePos:Bool = true):Void {
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
		for (data in chartData.notes) {
			if (data.time < time ?? Math.NEGATIVE_INFINITY) continue;
			notes.add(new Note(this, data.id, data.time, data.length));
		}
	}

	public dynamic function _onNoteHit(note:Note):Void {}
	public dynamic function _onSustainHit(sustain:Sustain):Void {}
	public dynamic function _onNoteMissed(note:Note):Void {}
	public dynamic function _onSustainMissed(sustain:Sustain):Void {}

	override public function update(elapsed:Float):Void {
		// auto hit and note miss
		notes.forEachExists((note:Note) -> {
			if (note.tooLate && (Conductor.songPosition - note.time) > Math.max(Conductor.stepLengthMs, 350 / Math.abs(note.__scrollSpeed)))
				if (!note.wasHit && !note.wasMissed)
					_onNoteMissed(note);
			if (isComputer)
				if (note.time <= Conductor.songPosition && !note.tooLate && !note.wasHit && !note.wasMissed)
					_onNoteHit(note);
		});
		// auto hit and sustain miss
		sustains.forEachExists((sustain:Sustain) -> {
			if (sustain.tooLate && (Conductor.songPosition - (sustain.time + sustain.parentNote.time)) > Math.max(Conductor.stepLengthMs, 350 / Math.abs(sustain.__scrollSpeed)))
				if (!sustain.wasHit && !sustain.wasMissed)
					_onSustainMissed(sustain);
			if (isComputer)
				if ((sustain.time + sustain.parentNote.time) <= Conductor.songPosition && !sustain.tooLate && !sustain.wasHit && !sustain.wasMissed)
					_onSustainHit(sustain);
		});

		if (isPlayer) {
			for (i => input in currentInputs)
				if (input) for (sustain in Note.filterTail(sustains.members, i))
					if ((sustain.time + sustain.parentNote.time) <= Conductor.songPosition)
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
			var disPos:Float = 0.45 * (Conductor.songPosition - note.time) * Math.abs(note.__scrollSpeed) * Math.abs(scale.x / scale.y);

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
				final pos:Array<Float> = [strum.x, strum.y];
				disPos = 0.45 * (Conductor.songPosition - (note.time + sustain.time)) * Math.abs(sustain.__scrollSpeed) * Math.abs(scale.x / scale.y);

				pos[0] += Math.cos(angleDir) * disPos;
				pos[0] -= sustain.width / 2;
				pos[0] += strum.width / 2;

				pos[1] += Math.sin(angleDir) * disPos;
				pos[1] += strum.height / 2;

				sustain.setPosition(pos[0], pos[1]);
				pos.resize(0);

				// prevent scaling on sustain end
				if (!sustain.isEnd) { // also temp placement
					sustain.setGraphicSize(sustain.width, 45 * Math.abs(sustain.__scrollSpeed));
					// updateHitbox
					sustain.height = Math.abs(sustain.scale.y) * sustain.frameHeight;
					sustain.offset.y = -0.5 * (sustain.height - sustain.frameHeight);
					// centerOrigin
					sustain.origin.y = sustain.frameHeight * 0.5;
				}
			}
		});
	}

	final currentInputs:Array<Bool> = [];
	function _on_press(event:KeyboardEvent):Void {
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
		} else {
			final ghostTapping:Bool = true;
			if (!ghostTapping) FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
			strums.members[inputId].playStrumAnim('press', ghostTapping);
		}
	}
	function _on_release(event:KeyboardEvent):Void {
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