package violet.states;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import violet.backend.audio.Conductor;
import violet.backend.objects.play.StrumLine;
import violet.backend.utils.FileUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ParseUtil;
import violet.data.song.ChartData;
import violet.data.song.SongRegistry;

class PlayState extends violet.backend.StateBackend {

	public static var instance:PlayState;
	public static var SONG:ChartData;
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
		FlxG.cameras.add(camHUD);

		strumLines = new FlxTypedGroup<StrumLine>();

		final jsonPath = Paths.json('songs/test/charts/${variation == null ? '' : '$variation/'}$difficulty');
		SONG = new json2object.JsonParser<ChartData>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent(jsonPath)), jsonPath);
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
			strumLine.visible = (data.visible != false);
			// strumLine.vocals.group = FlxG.sound.defaultMusicGroup;
			strumLine.ID = i;
			strumLines.add(strumLine);
		}
		add(strumLines);
	}

	override public function destroy():Void {
		instance = null;
		super.destroy();
	}

	public static function loadSong(id:String, difficulty:String = "normal", ?variation:String) {
		var songMetaData = SongRegistry.getSongByID(id);
		NovaUtils.playMusic('$id/song/Inst${variation == null ? '' : '-$variation'}', 'songs');
		Conductor.setInitialBPM(songMetaData.bpm, songMetaData.stepsPerBeat, songMetaData.beatsPerMeasure);
		PlayState.difficulty = difficulty;
		PlayState.variation = variation;
	}

}