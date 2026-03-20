package violet.backend.objects.play;

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

    public function popupRating(rating:String, combo:Int) {
        var comboSprite:NovaSprite = new NovaSprite(Paths.image('game/popup/$style/$rating'));
        comboSprite.setGraphicSize(10, 100);
        comboSprite.scale.x = comboSprite.scale.y;
        comboSprite.updateHitbox();
        comboSprite.x -= comboSprite.width/2;
        comboSprite.y -= comboSprite.height/2;
        add(comboSprite);

        FlxTween.tween(comboSprite, { y: comboSprite.y - 20 }, 0.25, { ease: FlxEase.quadOut });
        FlxTween.tween(comboSprite, { y: comboSprite.y + 20, alpha: 0 }, 0.5, { ease: FlxEase.quadIn, startDelay: 0.25 });
        FlxTween.tween(comboSprite.scale, { x: comboSprite.scale.x * 1.1, y: comboSprite.scale.x * 1.1 }, 0.25, { ease: FlxEase.quadOut });
        FlxTween.tween(comboSprite.scale, { x: comboSprite.scale.x * 0.8, y: comboSprite.scale.x * 0.8 }, 0.5, { ease: FlxEase.quadIn, startDelay: 0.25, onComplete: _->{
            FlxTween.cancelTweensOf(comboSprite);
            remove(comboSprite);
            comboSprite.destroy();
        }});
    }
}