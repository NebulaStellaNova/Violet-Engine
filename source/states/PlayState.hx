package states;

import backend.filesystem.Paths;
import backend.audio.Conductor;
import flixel.FlxG;
import backend.objects.play.*;
import backend.MusicBeatState;
import flixel.util.FlxSort;

typedef ChartStrumline = {
	var notes:Array<Dynamic>;
	var position:String;
	var visible:Bool;
	var characters:Array<String>;
}

typedef ChartData = {
	var scrollSpeed:Float;
	var strumLines:Array<ChartStrumline>;
	var stage:String;
	var noteTypes:Array<String>;
}

class PlayState extends MusicBeatState {
	public static var keybinds:Array<Array<String>> = [
		["W", "E", "LEFT"],
		["F", "F", "DOWN"],
		["J", "K", "UP"],
		["O", "O", "RIGHT"],
	];

	public static var songID:String;
	public static var varient:String;
	public static var difficulty:String;

	public var hitWindow = 200; // MS

	public var strumLines:Array<StrumLine> = [];

	public var notes:Array<Note> = [];

	function getKeyPress(index:Int, isRelease:Bool = false) {
		var pressed:Bool = false;
		for (i in keybinds[index]) {
			if ((isRelease ? FlxG.keys.anyJustReleased : FlxG.keys.anyJustPressed)([FlxKey.fromString(i.toUpperCase())]))
				pressed = true;
		}
		return pressed;
	}

	override public function create()
	{
		super.create();
		Conductor.curMusic = "";
		Conductor.loadSong(songID);
		loadChart();

		Conductor._onComplete = () -> switchState(FreeplayState.new);
		Conductor.play();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var realHitWindow = hitWindow/2;

		if (FlxG.keys.justPressed.ENTER) {
            FlxG.state.persistentUpdate = false;
			Conductor.pause();
			openSubState(new states.substates.PauseSubState());
		}

		for (strumLine in strumLines) {
			var hitThisFrame = [false, false, false, false];
			for (dir => strum in strumLine.members) {
				var doPress = true;
				for (note in strum.notes) {
					note.y = note.parentStrum.y - (0.45 * (Conductor.time - note.time) * note.scrollSpeed);
					if (note.alive) {
						switch (strumLine.type) {
							case PLAYER:
								if (Conductor.time - note.time > realHitWindow) {
									note.kill();
									FlxG.sound.play(Paths.sound("miss/" + FlxG.random.int(1, 3)));
								}
								if (getKeyPress(dir) && !hitThisFrame[dir]) {
									if (Conductor.time - note.time >= -realHitWindow && Conductor.time - note.time <= realHitWindow) {
										note.kill();
										doPress = false;
										hitThisFrame[dir] = true;
										strum.playAnim('confirm', true);
									}
								}
								if (getKeyPress(dir, true))
									strum.playAnim('static', true);
							default:
								if (Conductor.time >= note.time) {
									note.kill();
									strum.playAnim("confirm", true);
								}
						}
					}
				}
				if (doPress && getKeyPress(dir) && strumLine.type == PLAYER) {
					strum.playAnim('pressed');
				}
			}
		}

		notes.sort((a:Note, b:Note) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
	}

	public function loadChart() {
		var positions = [
			"dad" => {
				id: "opponent",
				pos: 0.25
			},
			"boyfriend" => {
				id: "player",
				pos: 0.75
			},
			"girlfriend" => {
				id: "spectator",
				pos: 0.50
			},
		];

		var chart:ChartData = Paths.parseJson('songs/$songID/charts/$difficulty');
		//trace(chart.strumLines);
		for (i=>strumline in chart.strumLines) {
			var strumLine = new StrumLine(4, positions.get(strumline.position).id, positions.get(strumline.position).pos);
			strumLine.visible = strumline.visible ?? true;
			add(strumLine);
			strumLines.push(strumLine);
		}
		Conductor.addVocalTrack(songID);
		for (i=>strumline in chart.strumLines) {
			Conductor.addVocalTrack(songID, strumline.characters[0]);
			for (note in strumline.notes) {
				var daNote = new Note(strumLines[i].members[note.id], note.id, note.time, 'default');
				daNote.visible = strumLines[i].visible;
				notes.push(daNote);
				strumLines[i].members[note.id].add(daNote);
			}
		}
	}
}