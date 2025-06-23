package states;

import backend.scripts.PythonScript;
import flixel.group.FlxGroup.FlxTypedGroup;
import backend.scripts.LuaScript;
import backend.scripts.FunkinScript;
import backend.scripts.ScriptPack;
import flixel.tweens.FlxTween;
import utils.NovaUtil;
import backend.objects.play.game.Stage;
import scripting.events.SustainHitEvent;
import backend.objects.play.StrumLine.UserType;
import scripting.events.NoteHitEvent;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxColorTransformUtil;
import backend.objects.NovaSprite;
import scripting.events.SongEvent;
import backend.objects.play.game.Character;
import flixel.FlxCamera;
import backend.objects.NovaSave;
import utils.MathUtil;
import flixel.text.FlxText;
import backend.filesystem.Paths;
import backend.audio.Conductor;
import flixel.FlxG;
import backend.objects.play.*;
import backend.MusicBeatState;
import flixel.util.FlxSort;
using StringTools;
using utils.ArrayUtil;

typedef SongSaveData = {
	var score:Int;
	var accuracy:Float;
	var misses:Int;
}

typedef ChartNote = {
	var id:Int;
	var sLen:Float;
	var time:Float;
	var type:Int;
}

typedef ChartStrumline = {
	var notes:Array<ChartNote>;
	var position:String;
	var visible:Bool;
	var characters:Array<String>;
	var vocalsSuffix:String;
}

typedef EventData = {
	var params:Array<Dynamic>;
	var name:String;
	var time:Float;
	var type:Int;
}

typedef ChartData = {
	var scrollSpeed:Float;
	var strumLines:Array<ChartStrumline>;
	var stage:String;
	var noteTypes:Array<String>;
	var events:Array<Dynamic>;
	var warning:String;
	var codenameChart:Bool;
}

class PlayState extends MusicBeatState {
	public var botplay:Bool = false;

	
	public static var camGame:FlxCamera;
	public static var camHUD:FlxCamera;
	public static var camOther:FlxCamera;
	
	public static var keybinds:Array<Array<String>>;
	
	public static var songID:String;
	public static var varient:String;
	public static var difficulty:String;
	
	public static var instance:PlayState;

	public var hitWindow = 200; // MS

	public var strumLines:FlxTypedGroup<StrumLine> = new FlxTypedGroup();
	public var characters:Array<Character> = []; // For easy access
	public var events:Array<EventNote> = [];
	public var notes:Array<Note> = [];
	public var sustains:Array<SustainNote> = [];
	public var stage:Stage;

	public var accuracy:Null<Float>;
	public var misses:Int = 0;
	public var score:Int = 0;

	public var accuracyTxt:FlxText;
	private var accuracies:Array<Float> = [];

	private var camFollowPoint:FlxPoint = new FlxPoint();

	public var dad:Character;
	public var boyfriend:Character;
	public var girlfriend:Character;

	function formatScoreTxt(string:String, localAccuracy:Dynamic, localMisses:Float, localScore:Float, localRating:String) {
		string = string.replace("$accuracy", '$localAccuracy');
		string = string.replace("$misses", '$localMisses');
		string = string.replace("$score", '$localScore');
		string = string.replace("$rating", '$localRating');
		return string;
	}

	function getKeyPress(index:Int, type:String = 'press') {
		var pressed:Bool = false;
		for (i in keybinds[index]) {
			if ((switch (type) {
				case 'release': FlxG.keys.anyJustReleased;
				case 'held': FlxG.keys.anyPressed;
				default: FlxG.keys.anyJustPressed;
			})([FlxKey.fromString(i.toUpperCase())]))
				pressed = true;
		}
		return pressed;
	}

	override public function create()
	{
		super.create();

		trace(songID);
		var scriptsToAdd = [];
		var foldersToCheck = [
			'data/scripts/songs', 
			'data/scripts/songs/$songID',
			'songs',
			'songs/$songID/scripts'
		];
		for (folder in foldersToCheck) {
			if (Paths.folderExists('assets/$folder')) {
				for (script in Paths.readFolder('assets/$folder')) {
					if (script.endsWith(".hx") || script.endsWith(".lua") || script.endsWith(".py")) {
						if (!Paths.readStringFromPath('assets/$folder/$script').contains("scriptDisabled = true")) {
							scriptsToAdd.push('assets/$folder/$script');
						} else {
							trace('Script Disabled "$script"');
						}
					}
				}
			}
		}
		for (modID in Paths.getModList()) {
			if (Paths.checkModEnabled(modID)) {
				for (folder in foldersToCheck) {
					if (Paths.folderExists('mods/$modID/$folder')) {
						for (script in Paths.readFolder('mods/$modID/$folder')) {
							if (script.endsWith(".hx") || script.endsWith(".lua") || script.endsWith(".py")) {
								if (!Paths.readStringFromPath('mods/$modID/$folder/$script').contains("scriptDisabled = true")) {
									scriptsToAdd.push('mods/$modID/$folder/$script');
								} else {
									trace('Script Disabled "$script"');
								}
							}
						}
					}
				}
			}
		}

		stateScripts.parent = this;
		for (i in scriptsToAdd) {
			if (i.endsWith(".hx")) {
				this.stateScripts.addScript(new FunkinScript(i));
			} else if (i.endsWith(".lua")) {
				this.stateScripts.addScript(new LuaScript(i));
			} else if (i.endsWith(".py")) {
				this.stateScripts.addScript(new PythonScript(i));
			}
		}
		trace('Scripts To Add: $scriptsToAdd');

		camGame = new FlxCamera();
		FlxG.cameras.add(camGame, true);

		camHUD = new FlxCamera();
		camHUD.bgColor = 0x00000000; // No visible
		FlxG.cameras.add(camHUD, false);


		camOther = new FlxCamera();
		camOther.bgColor = 0x00000000; // No visible
		FlxG.cameras.add(camOther, false);

		keybinds = cast NovaSave.get("keybinds");

		accuracyTxt = new FlxText(0, 0, FlxG.width/1.5, formatScoreTxt(globalVariables.scoreTxt, "Unknown", 0, 0, "N/A"));
		accuracyTxt.y = FlxG.height - 100;
		accuracyTxt.size = 20;
		accuracyTxt.alignment = 'center';
		accuracyTxt.screenCenter(X);
		accuracyTxt.cameras = [camHUD];
		add(accuracyTxt);

		Conductor.curMusic = "";
		Conductor.loadSong(songID);
		loadChart();

		startSong();

		instance = this;

		if (stage == null) {
			for (character in characters) {
				switch (character.type) {
					case "opponent":
						character.x = -400;
						character.y = 200 - character.height;
					case "spectator":
						character.x = 200;
						character.y = 150 - character.height;
					case "player":
						character.x = 1100;
						character.y = 200 - character.height;
				}
			}
		} else {
			for (character in characters) {
				switch (character.type) {
					case "opponent":
						//character.updateHitbox();
						character.x = stage.stageData.characters.dad.position[0] - (character.width / 2);
						character.y = stage.stageData.characters.dad.position[1];
						character.zIndex = stage.stageData.characters.dad.zIndex;
						//character.offset.y = character.frameHeight * character.scale.y - character.offset.y;
						case "spectator":
						//character.updateHitbox();
						character.x = stage.stageData.characters.gf.position[0] - (character.width / 2);
						character.y = stage.stageData.characters.gf.position[1];
						character.zIndex = stage.stageData.characters.gf.zIndex;
						//character.offset.y = character.frameHeight * character.scale.y - character.offset.y;
						case "player":
						//character.updateHitbox();
						character.x = stage.stageData.characters.bf.position[0] - (character.width / 2);
						character.y = stage.stageData.characters.bf.position[1];
						character.zIndex = stage.stageData.characters.bf.zIndex;
						//character.offset.y = character.frameHeight * character.scale.y - character.offset.y;
				}
			}
		}
		addCharacters();
		call("postCreate");
		call("onCreatePost");
		refresh();
	}

	public function addCharacters() {
		for (character in characters) {
			if (character.type == SPECTATOR) {
				if (girlfriend == null) {
					girlfriend = character;
					set('girlfriend', character);
				}
				add(character);
			}
		}
		for (character in characters) {
			if (character.type == PLAYER) {
				if (boyfriend == null) {
					boyfriend = character;
					set('boyfriend', character);
				}
				add(character);
			}
		}
		for (character in characters) {
			if (character.type == OPPONENT) {
				if (dad == null) {
					dad = character;
					set('dad', character);
				}
				add(character);
			}
		}
	}

	public function endSong() {
		var saveData:SongSaveData = {
			score: score,
			accuracy: accuracy,
			misses: misses
		}; // ik it's not needed stfu

		NovaSave.setIfNull(songID, saveData);
		if (NovaSave.get(songID).accuracy < accuracy || NovaSave.get(songID).score < score) {
			NovaSave.set(songID, saveData);
		}
		// trace(NovaSave.get(songID));
		switchState(FreeplayState.new);
	}

	public function startSong() {
		call("onSongStart");
		call("onStartSong"); // Screw needing to type it a certain way
		Conductor._onComplete = endSong;
		Conductor.play();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var realHitWindow = hitWindow/2;

		if (curBeat < 1) {
			for (i in events) {
				i.ran = false;
			}
		}

		if (FlxG.keys.justPressed.TAB) {
			botplay = !botplay;
			log('Botplay ${botplay ? 'Enabled' : 'Disabled'}', DebugMessage);
		}

		if (FlxG.keys.justPressed.ENTER) {
			FlxG.state.persistentUpdate = false;
			Conductor.pause();
			openSubState(new states.substates.PauseSubState(camOther));
		}

		notes.sort((a:Note, b:Note) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
		sustains.sort((a:SustainNote, b:SustainNote) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));

		for (strumLine in strumLines) {
			var hitThisFrame = [false, false, false, false];
			for (dir => strum in strumLine.strums.members) {
				var doPress = true;
				strum.notes.forEachAlive((note:Note) -> {
					var distance:Float = (0.45 * (Conductor.time - note.time) * note.scrollSpeed);
					var angelDir = (note.parentStrum.angle+90+180) * Math.PI / 180;
					note.angle = note.parentStrum.angle;
					note.x = (Math.cos(angelDir) * distance) + note.parentStrum.x;
					if (!note.badHit)
						note.y = note.parentStrum.y - (0.45 * (Conductor.time - note.time) * note.scrollSpeed);
					if (strumLine.type == PLAYER && !botplay) {
						if (Conductor.time - note.time > realHitWindow) {
							for (sustain in note.tail)
								sustain.kill();
							if (!note.badHit) {
								note.kill();
							}
							if (note.canMiss && !note.badHit) {
								misses++;
								FlxG.sound.play(Paths.sound("miss/" + FlxG.random.int(1, 3)));
							}
							if (strum.holdcover != null) {
								strum.holdcover.kill();
								strum.holdcover = null;
							}
						}
						if (note.alive && getKeyPress(dir) && !hitThisFrame[dir] && note.canHit && !note.badHit) {
							if (Conductor.time - note.time >= -realHitWindow && Conductor.time - note.time <= realHitWindow) {
								createRating(strum, note, realHitWindow-Math.abs(Conductor.time - note.time));
								noteHit(note, strum, strumLine.type, Judgement.getRating(realHitWindow-Math.abs(Conductor.time - note.time)));
								doPress = false;
								hitThisFrame[dir] = true;
							}
						}
					} else {
						if (Conductor.time >= note.time) {
							if (strumLine.type == PLAYER)
								strum.onNoteHit(note);
							noteHit(note, strum, strumLine.type);
						}
					}
				});
				strum.sustains.forEachAlive((sustain:SustainNote) -> {
					var distance:Float = (0.45 * (Conductor.time - sustain.time) * sustain.parentNote.scrollSpeed);
					var angelDir = (sustain.parentStrum.angle+90+180) * Math.PI / 180;
					sustain.angle = sustain.parentStrum.angle;
					sustain.x = (Math.cos(angelDir) * distance) + sustain.parentStrum.x;

					sustain.y = sustain.parentStrum.y - (0.45 * (Conductor.time - sustain.time) * sustain.parentNote.scrollSpeed);
					if (strumLine.type == PLAYER && !botplay) {
						if (Conductor.time - sustain.time > realHitWindow) {
							for (sustain in sustain.parentNote.tail)
								sustain.kill();
							misses++;
							FlxG.sound.play(Paths.sound("miss/" + FlxG.random.int(1, 3)));
							if (strum.holdcover != null) {
								strum.holdcover.kill();
								strum.holdcover = null;
							}
						}
						if (sustain.alive && getKeyPress(dir, 'held') /* && hitThisFrame[dir] */)
							if (Conductor.time >= sustain.time/* Conductor.time - sustain.time  >= -realHitWindow && Conductor.time - sustain.time <= realHitWindow */)
								sustainHit(sustain, strum, strumLine.type);
					} else {
						if (Conductor.time >= sustain.time)
							sustainHit(sustain, strum, strumLine.type);
					}
				});
				if (strumLine.type == PLAYER && !botplay) {
					if (doPress && getKeyPress(dir))
						strum.playAnim('pressed');
					if (getKeyPress(dir, 'release'))
						strum.playAnim('static', true);
				}
			}
		}

		if (accuracy != null)
			accuracyTxt.text = formatScoreTxt(globalVariables.scoreTxt, accuracy, misses, score, Judgement.getRating(accuracy).toUpperCase()); //'Misses: $misses | Accuracy: $accuracy% [${Judgement.getRating(accuracy).toUpperCase()}] | Score: $score';
		accuracyTxt.scale.set(MathUtil.lerp(accuracyTxt.scale.x, 1, 0.1), MathUtil.lerp(accuracyTxt.scale.y, 1, 0.1));

		if (botplay) {
			accuracyTxt.text = "BOTPLAY";
		}

		for (event in events)
			if (Conductor.time >= event.time && !event.ran)
				onEvent(event);
		camGame.followLerp = 0.1;
		var targetObject:FlxObject = new FlxObject();
		targetObject.x = camFollowPoint.x;
		targetObject.y = camFollowPoint.y;
		camGame.target = targetObject;
	}

	public function onEvent(event:EventNote) {
		// trace(event.name + ', ' +  event.parameters);
		var theEvent:SongEvent = new SongEvent(event.name, event.parameters, event.type);
		theEvent = runEvent("onEvent", theEvent);
		if (theEvent.cancelled) return;
		event.ran = true;

		var camMoveEvent = (theEvent:SongEvent)-> {
			camFollowPoint = new FlxPoint(0, 0);
			camFollowPoint.x += strumLines.members[theEvent.parameters[0]].parentCharacters[0].cameraCenter.x;
			camFollowPoint.y += strumLines.members[theEvent.parameters[0]].parentCharacters[0].cameraCenter.y;
			camFollowPoint.x += strumLines.members[theEvent.parameters[0]].parentCharacters[0].x;
			camFollowPoint.y += strumLines.members[theEvent.parameters[0]].parentCharacters[0].y;
		}

		switch (theEvent.type) {
			case 1:
				camMoveEvent(theEvent);
		}

		switch (theEvent.name) {
			case "Camera Movement":
				camMoveEvent(theEvent);

			case "Play Animation":
				strumLines.members[theEvent.parameters[0]].characterPlayAnim(theEvent.parameters[1], true);

		}
	}

	public function noteHit(note:Note, strum:Strum, characterType:UserType, ?rating:String) {
		var theEvent:NoteHitEvent = new NoteHitEvent(note, note.type, strum, note.direction, characterType);
		theEvent = runEvent("noteHit", theEvent);
		strum.parent.onHit.dispatch(theEvent);
		switch (characterType) {
			case PLAYER:
				theEvent = runEvent("playerNoteHit", theEvent);
			case OPPONENT:
				theEvent = runEvent("opponentNoteHit", theEvent);
			case SPECTATOR:
				theEvent = runEvent("spectatorNoteHit", theEvent);
		}
		if (theEvent.cancelled) return;
		if (rating == null) {
			note.kill();
		} else {
			switch (rating) {
				case "sick" | "good" | "bad":
					note.kill();
				default:
					note.badHit = true;
					FlxTween.tween(note, {y: note.y-300}, 0.5, {onComplete: (e)-> {
						note.kill();
					}});
					NovaUtil.desaturateSprite(note, 0.5);

					if (strum.holdcover != null)
						strum.holdcover.kill();
			}
		}
		if (theEvent.animCancelled) return;

		if (!note.badHit) {
			strum.playAnim('confirm', true);
		}

		switch (note.type) {
			case "Alt Anim Note":
				strum.parent.characterPlaySingAnim('sing${Note.directionStrings[note.direction].toUpperCase()}-alt', true);
			default:
				strum.parent.characterPlaySingAnim('sing${Note.directionStrings[note.direction].toUpperCase()}', true);
		}
	}
	public function sustainHit(sustain:SustainNote, strum:Strum, characterType:UserType) {
		strum.onSustainHit(sustain);
		var theEvent:SustainHitEvent = new SustainHitEvent(sustain, sustain.type, strum, sustain.direction, characterType);
		theEvent = runEvent("sustainHit", theEvent);
		
		sustain.clipToStrumNote(strum);
		switch (characterType) {
			case PLAYER:
				theEvent = runEvent("playerSustainHit", theEvent);
			case OPPONENT:
				theEvent = runEvent("opponentSustainHit", theEvent);
			case SPECTATOR:
				theEvent = runEvent("spectatorSustainHit", theEvent);
		}
		if (theEvent.cancelled) return;
		sustain.kill();
		if (theEvent.animCancelled) return;

		strum.playAnim('confirm', true);

		switch (sustain.type) {
			case "Alt Anim Note":
				strum.parent.characterPlaySingAnim('sing${Note.directionStrings[sustain.direction].toUpperCase()}-alt', true);
			default:
				strum.parent.characterPlaySingAnim('sing${Note.directionStrings[sustain.direction].toUpperCase()}', true);
		}
	}

	public function createRating(strum:Strum, note:Note, percent:Float) {
		strum.onNoteHit(note, Judgement.getRating(percent));
		score += Judgement.getScore(percent);
		accuracies.push(Judgement.getAccuracy(percent));
		var acc:Float = 0;
		for (i in accuracies) acc += i;
		accuracy = Math.round((acc/(accuracies.length))*100)/100;
		accuracyTxt.scale.x += 0.05;
		accuracyTxt.scale.y += 0.05;
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
				pos: 0.75
			},
		];

		var chart:ChartData = Paths.parseJson('songs/$songID/charts/$difficulty');
		if (chart.noteTypes == null)
			chart.noteTypes = ["default"];
		else
			chart.noteTypes.insert(0, "default");

		if (chart.stage != null) {
			stage = new Stage(chart.stage);
			add(stage);
		}
		// trace(chart.noteTypes);

		if (chart.warning == "File Not Found") {
			log('Failed to load chart! Error: ${chart.warning}.', ErrorMessage);
			return;
		}
		if (!chart.codenameChart) {
			log("Failed to load chart! Error: Incorrect Chart Format.");
			return;
		}

		if (chart.events != null)
			for (event in chart.events) {
				// trace("Found Event: " + event);
				events.push(new EventNote(event.name, event.time, event.params ?? [], event.type));
			}
		//trace(chart.strumLines);
		for (i=>strumline in chart.strumLines) {
			var strumLine = new StrumLine(4, positions.get(strumline.position).id, positions.get(strumline.position).pos);
			strumLine.visible = strumline.visible ?? true;
			strumLine.cameras = [camHUD];
			add(strumLine);
			strumLines.add(strumLine);

			for (id in strumline.characters) {
				var character = new Character(id, positions.get(strumline.position).id);
				strumLine.addCharacter(character);
				characters.push(character);
				//add(character);
			}
		}
		Conductor.addVocalTrack(songID);
		for (i=>strumline in chart.strumLines) {
			Conductor.addVocalTrack(songID, strumline.vocalsSuffix ?? strumline.characters[0]);
			for (note in strumline.notes) {
				var daNote = new Note(strumLines.members[i].strums.members[note.id], note.id, note.time, globalVariables.noteSkin);
				daNote.visible = strumLines.members[i].visible;
				daNote.typeID = note.type;
				// trace(chart.noteTypes[note.type] + ", " + note.type + ", " + chart.noteTypes);
				if (chart.noteTypes != null)
					daNote.type = chart.noteTypes[note.type];
				notes.push(daNote);
				strumLines.members[i].strums.members[note.id].add(daNote);

				var roundedLength:Int = Math.floor(note.sLen / Conductor.stepTime); // not compatible with bpm changes yet
				if (roundedLength > 0) {
					for (susNote in 0...roundedLength) {
						var sustain:SustainNote = new SustainNote(daNote, daNote.time + (Conductor.stepTime * susNote), susNote == (roundedLength - 1));
						strumLines.members[i].strums.members[sustain.direction].add(sustain);
						daNote.tail.push(sustain);
						sustains.push(sustain);
					}
					daNote.reloadSkin();
				}
			}
		}
	}

	override function stepHit(step:Int) {
		super.stepHit(step);
		for (character in characters) {

			if (character.singTimer == 0) {
				if (step % ((character.characterData.danceEvery ?? 1)*4) == 0) {
					character.dance();
				}
			}

			if (character.singTimer > 0) {
				character.singTimer--;
			}
		}
	}
	
	public function restartSong() {
		Conductor.restart();
		for (i in notes) {
			i.revive();
		}
		for (i in sustains) {
			i.revive();
		}

		for (i in events) {
			i.ran = false;
		}
	}
}