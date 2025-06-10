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

	public var hitWindow = 100;

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

		if (FlxG.keys.justPressed.ENTER) {
            FlxG.state.persistentUpdate = false;
			Conductor.pause();
			openSubState(new states.substates.PauseSubState());
		}

		for (strumLine in strumLines) {
			for (strum in strumLine.members) {
				for (note in strum.notes) {
					note.y = note.parentStrum.y - (0.45 * (Conductor.time - note.time) * note.scrollSpeed);
					switch (strumLine.type) {
						case PLAYER:
							var hitNote:Bool = false;
							if (note.alive) {
								if (Conductor.time - note.time > hitWindow) {
									note.kill();
									FlxG.sound.play(Paths.sound("miss/" + FlxG.random.int(1, 3)));
								}
								for (pressed in [for (i => _ in keybinds) getKeyPress(i)]) {
									if (pressed) {
										if (Conductor.time - note.time >= -hitWindow && Conductor.time - note.time <= hitWindow) {
											hitNote = true;
											note.kill();
											strum.playAnim('confirm', true);
										}
									}
								}
							}
							if (!hitNote)
								strum.playAnim('pressed', true);
							for (released in [for (i => _ in keybinds) getKeyPress(i, true)])
								if (released)
									strum.playAnim('static', true);
						default:
							if (Conductor.time >= note.time && note.alive) {
								note.kill();
								strum.playAnim("confirm", true);
							}
					}
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