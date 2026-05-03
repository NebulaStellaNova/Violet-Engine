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

	public var ratingCache:Map<String, NovaSprite> = [];
	public var numberCache:Array<Array<NovaSprite>> = [ for (i in 0...10) [] ];
	public var numberCount:Array<Int> = [ for (i in 0...10) 0 ];

	public function popupRating(rating:String, combo:Int) {
		combosSpawned++;
		var comboSprite:NovaSprite = null;
		if (!ratingCache.exists('game/popup/$style/$rating')) {
			comboSprite = new NovaSprite(Paths.image('game/popup/$style/$rating'));
			comboSprite.setGraphicSize(10, 100);
			comboSprite.scale.x = comboSprite.scale.y;
			comboSprite.updateHitbox();
			comboSprite.x -= comboSprite.width/2;
			comboSprite.y -= comboSprite.height/2;
			ratingCache.set('game/popup/$style/$rating', comboSprite);
			add(comboSprite);
		} else {
			comboSprite = ratingCache.get('game/popup/$style/$rating');
			FlxTween.cancelTweensOf(comboSprite);
			comboSprite.alpha = 1;

			/* comboSprite.x = comboSprite.y = 0;
			comboSprite.setGraphicSize(10, 100);
			comboSprite.scale.x = comboSprite.scale.y;
			comboSprite.updateHitbox();
			comboSprite.alpha = 1;
			comboSprite.x -= comboSprite.width/2;
			comboSprite.y -= comboSprite.height/2; */
		}
		comboSprite.z = combosSpawned * 10;


		FlxTween.tween(comboSprite, { alpha: 0 }, 0.5, { ease: FlxEase.quadIn });
	}

	function tweenAThing(sprite:NovaSprite, startDelay:Float = 0) {
		startDelay == 0 ? (sprite.alpha = 1) : FlxTimer.wait(startDelay, ()->sprite.alpha = 1);
		FlxTween.tween(sprite, { y: sprite.y - 20 }, 0.25, { ease: FlxEase.quadOut, startDelay: startDelay });
		FlxTween.tween(sprite, { y: sprite.y + 20, alpha: 0 }, 0.5, { ease: FlxEase.quadIn, startDelay: startDelay + 0.25 });
		FlxTween.tween(sprite.scale, { x: sprite.scale.x * 1.1, y: sprite.scale.x * 1.1 }, 0.25, { ease: FlxEase.quadOut, startDelay: startDelay });
		FlxTween.tween(sprite.scale, { x: sprite.scale.x * 0.8, y: sprite.scale.x * 0.8 }, 0.5, { ease: FlxEase.quadIn, startDelay: startDelay + 0.25 });
	}

}