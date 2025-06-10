package states;

import backend.filesystem.Paths;
import backend.audio.Conductor;
import flixel.FlxG;
import backend.objects.play.*;
import backend.MusicBeatState;

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


	public static var songID:String;
	public static var varient:String;
	public static var difficulty:String;

	public var hitWindow = 200;

	public var strumLines:Array<StrumLine> = [];

	public var notes:Array<Note> = [];

	override public function create()
	{
		super.create();

		Conductor.curMusic = "";
		Conductor.loadSong(songID);
		
		loadChart();
		
		Conductor.play();

		Conductor._onComplete = ()->{
			switchState(FreeplayState.new);
		}
		/* for (i in strumLines) {
			add(i);
			for (strum in i.members) {
				for (note in strum.notes) {
					trace("Note Found!");
					add(note);
					notes.push(note);
				}
			}
		} */
		/* var note = new Note(strumLines[0].members[0], 0, 1000, 'default');
		notes.push(note);
		strumLines[0].members[0].add(note); */

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var hitThisFrame = [false, false, false, false];

		for (i in strumLines) {
			if (i.type == "player") {
				for (strum in i.members) {
					for (note in strum.notes) {
						if (Conductor.time - note.time > (hitWindow/2) && note.alive) {
							//log("", )
							note.kill();
							FlxG.sound.play(Paths.sound("miss/" + FlxG.random.int(1, 3)));
						}
					}
				}
				for (dir => bool in [
					FlxG.keys.justPressed.W,
					FlxG.keys.justPressed.F,
					FlxG.keys.justPressed.J,
					FlxG.keys.justPressed.O 
				]) {
					if (bool) {
						var doPress = true;
						if (!hitThisFrame[dir]) {
							var strum = i.members[dir];
							for (note in strum.notes) {
								if (Conductor.time - note.time >= -(hitWindow/2) && Conductor.time - note.time <= (hitWindow/2)) {
									note.kill();
									strum.playAnim("confirm");
									doPress = false;
									hitThisFrame[dir] = true;
								}
							}
						}
						if (doPress) {
							i.members[dir].playAnim("pressed");
						}
					}
				}
	
				for (dir => bool in [
					FlxG.keys.justReleased.W,
					FlxG.keys.justReleased.F,
					FlxG.keys.justReleased.J,
					FlxG.keys.justReleased.O 
				]) {
					if (bool) {
						i.members[dir].playAnim("static");
					}
				}
			}
		}

		for (i in strumLines) {
			for (strumLine in strumLines) {
				if (strumLine.type == "opponent") {
					for (dir=>strum in strumLine.members) {
						for (note in strum.notes) {
							if (Conductor.time >= note.time && note.alive) {
								note.kill();
								i.members[dir].playAnim("confirm");
							}
						}
					}
				}
			}
		}
		
		for (note in notes) {
			note.y = note.parentStrum.y - (0.45 * (Conductor.time - note.time) * note.scrollSpeed);
		}
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