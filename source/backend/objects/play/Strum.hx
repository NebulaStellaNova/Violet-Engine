package backend.objects.play;

import states.PlayState;
import utils.NovaUtil;
import flixel.group.FlxGroup;
import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxG;
import backend.filesystem.Paths;
import flixel.util.FlxSort;

using StringTools;
class Strum extends NovaSprite {
	public var direction:Int = 0;
	public var skin(default, set):String;
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var skinData:NoteSkin;
	public var notes:FlxTypedGroup<Note>;
	public var sustains:FlxTypedGroup<SustainNote>;
	public var parent:StrumLine;
	public var holdcover:NovaSprite;

	override public function new(id:Int, skin:String = 'default') {
		super();

		notes = new FlxTypedGroup<Note>();
		sustains = new FlxTypedGroup<SustainNote>();

		this.direction = id;
		this.skin = skin;

		this.animation.onFinish.add((name)->{
			if (name == "confirm") {
				this.playAnim(this.parent.type == PLAYER && PlayState.instance != null && !PlayState.instance.botplay ? "pressed" : "static");
			}
		});
	}

	function set_skin(value:String):String {
		if (skin != value)
			reloadSkin(value);
		return skin = value;
	}

	public function reloadSkin(?skin:String) {
		var target = skin ?? this.skin;
		if (!Paths.fileExists(Paths.json('images/game/notes/$skin/meta')))
			target = 'default';
		else if (!Paths.fileExists(Paths.image('game/notes/$skin/strums')))
			target = 'default';

		skinData = Paths.parseJson('images/game/notes/$target/meta');
		this.loadSprite(Paths.image('${skinData.animations.strum.assetPath.replace("./", 'game/notes/$target/')}'));

		var direction = Note.directionStrings[this.direction];
		var dir = direction.split('');
		dir[0] = dir[0].toUpperCase();
		var capped = dir.join('');
		//var globalOffset:Array<Float> = skinData.offsets.global != null ? [skinData.offsets.global[0], skinData.offsets.global[1]] : [0, 0];

		var staticData = switch (this.direction) {
			case 1:
				skinData.animations.strum.idle.down;
			case 2:
				skinData.animations.strum.idle.up;
			case 3:
				skinData.animations.strum.idle.right;
			case _:
				skinData.animations.strum.idle.left;
		}

		var pressData = switch (this.direction) {
			case 1:
				skinData.animations.strum.pressed.down;
			case 2:
				skinData.animations.strum.pressed.up;
			case 3:
				skinData.animations.strum.pressed.right;
			case _:
				skinData.animations.strum.pressed.left;
		}

		var confirmData = switch (this.direction) {
			case 1:
				skinData.animations.strum.confirm.down;
			case 2:
				skinData.animations.strum.confirm.up;
			case 3:
				skinData.animations.strum.confirm.right;
			case _:
				skinData.animations.strum.confirm.left;
		}

		this.addAnim('static', staticData.prefix, [
			staticData.offsets[0]+skinData.animations.strum.idle.global.offsets[0], 
			staticData.offsets[1]+skinData.animations.strum.idle.global.offsets[1]
		]);
		this.addAnim('confirm', confirmData.prefix, [
			confirmData.offsets[0]+skinData.animations.strum.confirm.global.offsets[0], 
			confirmData.offsets[1]+skinData.animations.strum.confirm.global.offsets[1]
		]);
		this.addAnim('pressed', pressData.prefix, [
			pressData.offsets[0]+skinData.animations.strum.pressed.global.offsets[0], 
			pressData.offsets[1]+skinData.animations.strum.pressed.global.offsets[1]
		]);

		this.playAnim('static');
		this.scale.set(0.7, 0.7);
		this.updateHitbox();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		notes.members.sort((a:Note, b:Note) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
		sustains.members.sort((a:SustainNote, b:SustainNote) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
	}

	public function add(note:OneOfTwo<Note, SustainNote>) {
		if (note is Note) {
			var note:Note = cast note;
			this.notes.add(note);
			note.x = this.parent.strums.x + (Note.swagWidth*direction);
			note.y = this.parent.strums.y;
		} else if (note is SustainNote) {
			var sustain:SustainNote = cast note;
			this.sustains.add(note);
			sustain.x = sustain.parentNote.x + (sustain.parentNote.width/2) - (sustain.width/2);
			sustain.y = this.parent.strums.y;
		}
	}

	public function onNoteHit(note:Note, rating:String = "sick") {
		if (rating == "sick") {
			var splash = parent.splashes.recycle(() -> new NovaSprite());
			splash.loadSprite(Paths.image('game/notes/${note.skinData.splashSkin.name}/splashes'));
			var globalOffset:Array<Float> = skinData.offsets.global ??= [0, 0];
			var skinData:NoteSkin = Paths.parseJson('images/game/notes/${note.skinData.splashSkin.name}/meta');
			splash.addAnim("hit", 'note impact ${FlxG.random.int(1, 2)} ${Note.colorStrings[note.direction]}', [globalOffset[0]+skinData.offsets.splashes[0], globalOffset[1]+skinData.offsets.splashes[1]]);
			splash.playAnim("hit", true);
			splash.updateHitbox();
			var midpoint = this.getMidpoint();
			splash.x = midpoint.x - (splash.width/2);
			splash.y = midpoint.y - (splash.height/2);
			midpoint.put();
			splash.animation.onFinish.add((name) -> splash.kill());
			splash.cameras = this.parent.cameras;

			// force in front
			parent.splashes.remove(splash);
			parent.splashes.add(splash);
		}

		if (note.tail.length != 0 && holdcover == null) {
			var cover = holdcover = parent.holdcovers.recycle(() -> new NovaSprite());
			cover.loadSprite(Paths.image('game/notes/${note.skinData.holdCoverSkin.name}/holdcovers'));
			var globalOffset:Array<Float> = skinData.offsets.global ??= [0, 0];
			var skinData:NoteSkin = Paths.parseJson('images/game/notes/${note.skinData.holdCoverSkin.name}/meta');
			var coverOffset:Array<Float> = skinData.offsets.covers.global ??= [0, 0];
			cover.addAnim('start', 'holdCoverStart${NovaUtil.capitalizeFirstLetter(Note.colorStrings[note.direction])}', [globalOffset[0]+coverOffset[0]+skinData.offsets.covers.start[0], globalOffset[1]+coverOffset[1]+skinData.offsets.covers.start[1]]);
			cover.addAnim('hold', 'holdCover${NovaUtil.capitalizeFirstLetter(Note.colorStrings[note.direction])}', [globalOffset[0]+coverOffset[0]+skinData.offsets.covers.hold[0], globalOffset[1]+coverOffset[1]+skinData.offsets.covers.hold[1]], true);
			cover.addAnim('end', 'holdCoverEnd${NovaUtil.capitalizeFirstLetter(Note.colorStrings[note.direction])}', [globalOffset[0]+coverOffset[0]+skinData.offsets.covers.end[0], globalOffset[1]+coverOffset[1]+skinData.offsets.covers.end[1]]);
			cover.playAnim('start', true);
			cover.updateHitbox();
			var midpoint = this.getMidpoint();
			cover.x = midpoint.x - (cover.width/2);
			cover.y = midpoint.y - (cover.height/2);
			midpoint.put();
			cover.animation.onFinish.add((name) -> {
				switch (name) {
					case 'start': cover.playAnim('hold', true);
					case 'end': cover.kill();
				}
			});
			cover.cameras = this.parent.cameras;

			// force in front
			parent.holdcovers.remove(cover);
			parent.holdcovers.add(cover);
		}
	}
	public function onSustainHit(sustain:SustainNote) {
		if (sustain.isEnd && holdcover != null) {
			if (this.parent.type == PLAYER && PlayState.instance != null && !PlayState.instance.botplay)
				holdcover.playAnim('end', true);
			else holdcover.kill();
			holdcover = null;
		} else if (!sustain.isEnd && holdcover == null) {
			var cover = holdcover = parent.holdcovers.recycle(() -> new NovaSprite());
			cover.loadSprite(Paths.image('game/notes/${sustain.skinData.holdCoverSkin.name}/holdcovers'));
			var globalOffset:Array<Float> = skinData.offsets.global ??= [0, 0];
			var skinData:NoteSkin = Paths.parseJson('images/game/notes/${sustain.skinData.holdCoverSkin.name}/meta');
			var coverOffset:Array<Float> = skinData.offsets.covers.global ??= [0, 0];
			cover.addAnim('start', 'holdCoverStart${NovaUtil.capitalizeFirstLetter(Note.colorStrings[sustain.direction])}', [globalOffset[0]+coverOffset[0]+skinData.offsets.covers.start[0], globalOffset[1]+coverOffset[1]+skinData.offsets.covers.start[1]]);
			cover.addAnim('hold', 'holdCover${NovaUtil.capitalizeFirstLetter(Note.colorStrings[sustain.direction])}', [globalOffset[0]+coverOffset[0]+skinData.offsets.covers.hold[0], globalOffset[1]+coverOffset[1]+skinData.offsets.covers.hold[1]], true);
			cover.addAnim('end', 'holdCoverEnd${NovaUtil.capitalizeFirstLetter(Note.colorStrings[sustain.direction])}', [globalOffset[0]+coverOffset[0]+skinData.offsets.covers.end[0], globalOffset[1]+coverOffset[1]+skinData.offsets.covers.end[1]]);
			cover.playAnim('start', true);
			cover.updateHitbox();
			var midpoint = this.getMidpoint();
			cover.x = midpoint.x - (cover.width/2);
			cover.y = midpoint.y - (cover.height/2);
			midpoint.put();
			cover.animation.onFinish.add((name) -> {
				switch (name) {
					case 'start': cover.playAnim('hold', true);
					case 'end': cover.kill();
				}
			});
			cover.cameras = this.parent.cameras;

			// force in front
			parent.holdcovers.remove(cover);
			parent.holdcovers.add(cover);
		}
	}
}