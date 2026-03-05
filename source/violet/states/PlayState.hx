package violet.states;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import violet.backend.audio.Conductor;
import violet.backend.objects.play.Note;
import violet.backend.objects.play.StrumLine;
import violet.backend.objects.play.Sustain;
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
	public var generalVocals:Null<FlxSound>;

	override public function create():Void {
		super.create();
		instance = this;

		FlxG.cameras.reset(camGame = new FlxCamera());
		camHUD = new FlxCamera();
		camHUD.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camHUD, false);

		strumLines = new FlxTypedGroup<StrumLine>();

		Conductor.instrumental.time = 0;
		SONG = ChartRegistry.getChart(song, difficulty, variation);
		if (SONG.meta.needsVoices) generalVocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(PlayState.song, '', PlayState.variation), 'root', null, true), FlxG.sound.defaultMusicGroup));
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

			var strumLine = new StrumLine(data);
			strumLine.cameras = [camHUD];
			strumLine.visible = data.visible;
			strumLine.ID = i;
			strumLines.add(strumLine);

			// note interactions
			final ghostTapping:Bool = true;
			strumLine._onVoidTap = (id:Int) -> {
				if (!ghostTapping) FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				strumLine.strums.members[id].playStrumAnim('press', ghostTapping);
			}
			strumLine._onNoteHit = (note:Note) -> {
				if (note.wasHit) return;
				note.wasHit = true;
				note.visible = false;
				if (generalVocals != null) generalVocals.volume = 1;
				if (strumLine.vocals != null) strumLine.vocals.volume = 1;
				note.parentStrum.playStrumAnim('confirm', true);
			}
			strumLine._onSustainHit = (sustain:Sustain) -> {
				if (sustain.wasHit) return;
				sustain.wasHit = true;
				sustain.visible = false;
				if (generalVocals != null) generalVocals.volume = 1;
				if (strumLine.vocals != null) strumLine.vocals.volume = 1;
				sustain.parentStrum.playStrumAnim('confirm', true);
			}
			strumLine._onNoteMissed = (note:Note) -> {
				if (note.wasMissed) return;
				note.wasMissed = true;
				note.alpha *= 0.6;
				FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				if (generalVocals != null) generalVocals.volume = 0;
				if (strumLine.vocals != null) strumLine.vocals.volume = 0;
				for (sustain in Note.filterTail(note.tail, true)) {
					sustain.wasMissed = true;
					sustain.alpha *= 0.6;
				}
			}
			strumLine._onSustainMissed = (sustain:Sustain) -> {
				if (sustain.wasMissed) return;
				sustain.wasMissed = true;
				sustain.alpha *= 0.6;
				FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				if (generalVocals != null) generalVocals.volume = 0;
				if (strumLine.vocals != null) strumLine.vocals.volume = 0;
				for (sustain in Note.filterTail(sustain.parentNote.tail, true)) {
					sustain.wasMissed = true;
					sustain.alpha *= 0.6;
				}
			}
		}
		add(strumLines);
		Conductor.instrumental.onComplete = () -> {
			FlxG.switchState(violet.states.menus.MainMenu.new);
		}

		for (strumLine in strumLines)
			strumLine.generateNotes(Conductor.instrumental.time);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	override public function destroy():Void {
		instance = null;
		super.destroy();
	}

	public static function loadSong(id:String, difficulty:String = "normal", ?variation:String) {
		var songMetaData = SongRegistry.getSongByID(id);
		Conductor.playSong(id, variation);
		Conductor.setInitialBPM(songMetaData.bpm, songMetaData.stepsPerBeat, songMetaData.beatsPerMeasure);
		PlayState.song = id;
		PlayState.difficulty = difficulty;
		PlayState.variation = variation;
	}

}