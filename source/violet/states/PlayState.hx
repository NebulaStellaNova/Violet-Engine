package violet.states;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import violet.backend.audio.Conductor;
import violet.backend.objects.play.Note;
import violet.backend.objects.play.StrumLine;
import violet.backend.objects.play.Sustain;
import violet.backend.utils.NovaUtils;
import violet.data.chart.Chart;
import violet.data.chart.ChartRegistry;
import violet.data.song.SongRegistry;

class PlayState extends violet.backend.StateBackend {

	public static var instance:PlayState;
	public static var SONG:Chart;
	public static var song:String;
	public static var difficulty:String;
	public static var variation:Null<String>;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var strumLines:FlxTypedGroup<StrumLine>;

	override public function create():Void {
		super.create();
		instance = this;

		FlxG.cameras.reset(camGame = new FlxCamera());
		camHUD = new FlxCamera();
		camHUD.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camHUD, false);

		strumLines = new FlxTypedGroup<StrumLine>();

		SONG = ChartRegistry.getChart(song, difficulty, variation);
		StrumLine.generalScrollSpeed = SONG.scrollSpeed ?? 1;
		for (i => data in SONG.strumLines) {
			if (data == null) continue;

			/* var chars = [];
			var charPosName:String = data.position == null ? (switch(data.type) {
				case 0: "dad";
				case 1: "boyfriend";
				case 2: "girlfriend";
			}) : data.position;
			if (data.characters != null) for(k=>charName in data.characters) {
				var char = new Character(0, 0, charName, stage.isCharFlipped(stage.characterPoses[charName] != null ? charName : charPosName, strumLine.type == 1));
				stage.applyCharStuff(char, charPosName, k);
				chars.push(char);
			} */

			/* var strOffset:Float = data.strumLinePos != null ? data.strumLinePos : (data.type == 1 ? 0.75 : 0.25);
			var strScale:Float = data.strumScale != null ? data.strumScale : 1;
			var strSpacing:Float = data.strumSpacing == null ? 1 : data.strumSpacing;
			var keyCount:Int = data.keyCount == null ? 4 : data.keyCount;
			var strXPos:Float = StrumLine.calculateStartingXPos(strOffset, strScale, strSpacing, keyCount);
			var startingPos:FlxPoint = data.strumPos != null ?
				FlxPoint.get(data.strumPos[0] == 0 ? strXPos : data.strumPos[0], data.strumPos[1]) :
				FlxPoint.get(strXPos, this.strumLine.y); */
			var strumLine = new StrumLine(
				data
				/* chars,
				startingPos,
				data.strumScale == null ? 1 : data.strumScale,
				data.type == 2 || (!coopMode && !((data.type == 1 && !opponentMode) || (data.type == 0 && opponentMode))),
				data.type != 1, coopMode ? ((data.type == 1) != opponentMode ? controlsP1 : controlsP2) : controls,
				data.vocalsSuffix */
			);
			strumLine.cameras = [camHUD];
			strumLine.visible = data.visible;
			// strumLine.vocals.group = FlxG.sound.defaultMusicGroup;
			strumLine.ID = i;
			strumLines.add(strumLine);

			// note interactions
			strumLine._onNoteHit = (note:Note) -> {
				if (note.wasHit) return;
				note.wasHit = true;
				note.visible = false;
				note.parentStrum.playStrumAnim('confirm', true);
			}
			strumLine._onSustainHit = (sustain:Sustain) -> {
				if (sustain.wasHit) return;
				sustain.wasHit = true;
				sustain.visible = false;
				sustain.parentStrum.playStrumAnim('confirm', true);
			}
			strumLine._onNoteMissed = (note:Note) -> {
				if (note.wasMissed) return;
				note.wasMissed = true;
				note.alpha *= 0.86;
				FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				for (sustain in Note.filterTail(note.tail, true)) {
					sustain.wasMissed = true;
					sustain.alpha *= 0.86;
				}
				if (strumLine.isPlayer)
					note.parentStrum.playStrumAnim('press', true);
			}
			strumLine._onSustainMissed = (sustain:Sustain) -> {
				if (sustain.wasMissed) return;
				sustain.wasMissed = true;
				sustain.alpha *= 0.86;
				FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				for (sustain in Note.filterTail(sustain.parentNote.tail, true)) {
					sustain.wasMissed = true;
					sustain.alpha *= 0.86;
				}
				if (strumLine.isPlayer)
					sustain.parentStrum.playStrumAnim('press', true);
			}
		}
		add(strumLines);

		for (strumLine in strumLines) {
			strumLine.generateNotes();
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.back) {
			FlxG.switchState(violet.states.menus.MainMenu.new);
		}
	}

	override public function destroy():Void {
		instance = null;
		super.destroy();
	}

	public static function loadSong(id:String, difficulty:String = "normal", ?variation:String) {
		var songMetaData = SongRegistry.getSongByID(id);
		NovaUtils.playMusic('$id/song/Inst${variation == null ? '' : '-$variation'}', 'songs');
		Conductor.setInitialBPM(songMetaData.bpm, songMetaData.stepsPerBeat, songMetaData.beatsPerMeasure);
		PlayState.song = id;
		PlayState.difficulty = difficulty;
		PlayState.variation = variation;
	}

}