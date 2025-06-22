package backend.objects.play;

import flixel.group.FlxGroup;
import backend.objects.play.game.Character;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import scripting.events.NoteHitEvent;

enum abstract UserType(String) from String to String {
	var OPPONENT = 'opponent';
	var PLAYER = 'player';
	var SPECTATOR = 'spectator';
}

class StrumLine extends FlxGroup {

	// ============= CNE SUPPORT ============= \\
	
	/**
	 * Signal that triggers whenever a note is hit. Similar to onPlayerHit and onDadHit, except strumline specific.
	 * To add a listener, do
	 * `strumLine.onHit.add(function(e:NoteHitEvent) {});`
	 */
	public var onHit:FlxTypedSignal<NoteHitEvent->Void> = new FlxTypedSignal<NoteHitEvent->Void>();
	
	// ======================================= \\
	
	public var type:UserType;
	public var parentCharacters:Array<Character> = [];

	public var strums:FlxTypedSpriteGroup<Strum>;
	public var holdcovers:FlxTypedGroup<NovaSprite>;
	public var splashes:FlxTypedGroup<NovaSprite>;

	public function new(length:Int, type:UserType = OPPONENT, position:Float = 0.5) {
		super();
		this.strums = new FlxTypedSpriteGroup<Strum>();
		this.type = type;
		this.strums.y = 20;
		for (i in 0...length) {
			var strum = new Strum(i % 4, cast(FlxG.state, MusicBeatState).globalVariables.noteSkin);
			strum.parent = this;
			strum.x = Note.swagWidth*i;
			strum.scale.set(0.7, 0.7);
			strum.updateHitbox();
			this.strums.add(strum);
		}
		this.strums.x = (FlxG.width*position)-(this.strums.width/2);
		this.add(this.strums);

		for (strum in this.strums) {
			this.add(strum.sustains);
			this.add(strum.notes);
		}
		this.holdcovers = new FlxTypedGroup<NovaSprite>();
		this.add(this.holdcovers);
		this.splashes = new FlxTypedGroup<NovaSprite>();
		this.add(this.splashes);
	}

	public function addCharacter(character:Character) {
		if (character != null) {
			this.parentCharacters.push(character);
		}
	}

	public function characterPlayAnim(id:String, forced:Bool = false, finishAnimation:String = "idle") {
		// Code this
		for (character in this.parentCharacters) {
			character.playAnim(id, forced);
			character.animation.onFinish.add((animName)->{
				if (animName == id)
					character.playAnim(finishAnimation, true);
			});
		}
	}
	public function characterPlaySingAnim(id:String, forced:Bool = false) {
		// Code this
		for (character in this.parentCharacters) {
			character.playSingAnim(id);
		}
	}
}