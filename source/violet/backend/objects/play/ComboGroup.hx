package violet.backend.objects.play;

import violet.backend.utils.ScoreUtil;
import violet.backend.utils.FileUtil;
import flixel.group.FlxSpriteGroup;

class ComboGroup extends FlxSpriteGroup {

	public var style:String;

	/**
	 * # TODO: make it so ui styles exist.
	 */
	override public function new(style:String = "funkin") {
		super();
		this.style = style;
		for (i in Paths.readFolder('images/game/popup/$style')) new FlxSprite().loadGraphic(Paths.image('game/popup/$style/$i')); // Cache (cash NOT cashaye) sprites // don't listen to them rodney, you do you!!
	}


	public var combosSpawned:Int = 0;

	public var prevs:Array<NovaSprite> = [];

	public function popupRating(rating:String, combo:Int) {
		for (i in prevs) {
			FlxTween.cancelTweensOf(i);
			remove(i);
		}
		combosSpawned++;
		var comboSprite:NovaSprite = new NovaSprite(Paths.image('game/popup/$style/$rating'));
		comboSprite.setGraphicSize(10, 100);
		comboSprite.scale.x = comboSprite.scale.y;
		comboSprite.updateHitbox();
		comboSprite.x -= comboSprite.width/2;
		comboSprite.y -= comboSprite.height/2;
		comboSprite.z = combosSpawned * 10;
		prevs.push(comboSprite);
		add(comboSprite);

		var comboSplit = '$combo'.split('');
		var offset = (70*comboSplit.length)/2;
		if (combo >= 10) for (i=>num in comboSplit) {
			var numberPath = Paths.image('game/popup/$style/num$num');
			if (numberPath == "") numberPath = Paths.image('game/popup/funkin/num$num');
			var number = new NovaSprite(70*i, 30, numberPath);
			number.scale.set(0.7, 0.7);
			number.updateHitbox();
			number.x -= offset;
			number.alpha = 0;
			number.z = combosSpawned * 10;
			prevs.push(number);
			add(number);

			tweenAThing(number);
		}

		tweenAThing(comboSprite);
	}

	function tweenAThing(sprite:NovaSprite, startDelay:Float = 0) {
		startDelay == 0 ? (sprite.alpha = 1) : FlxTimer.wait(startDelay, ()->sprite.alpha = 1);
		FlxTween.tween(sprite, { y: sprite.y - 20 }, 0.25, { ease: FlxEase.quadOut, startDelay: startDelay });
		FlxTween.tween(sprite, { y: sprite.y + 20, alpha: 0 }, 0.5, { ease: FlxEase.quadIn, startDelay: startDelay + 0.25 });
		FlxTween.tween(sprite.scale, { x: sprite.scale.x * 1.1, y: sprite.scale.x * 1.1 }, 0.25, { ease: FlxEase.quadOut, startDelay: startDelay });
		FlxTween.tween(sprite.scale, { x: sprite.scale.x * 0.8, y: sprite.scale.x * 0.8 }, 0.5, { ease: FlxEase.quadIn, startDelay: startDelay + 0.25, onComplete: _->{
			FlxTween.cancelTweensOf(sprite);
			remove(sprite);
			sprite.destroy();
		}});
	}

}