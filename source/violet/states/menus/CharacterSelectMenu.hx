package violet.states.menus;

import violet.backend.utils.NovaUtils;
import violet.backend.StateBackend;

class CharacterSelectMenu extends StateBackend {

    public var bg:NovaSprite;
    public var crowd:NovaSprite;
    public var stage:NovaSprite;
    public var curtains:NovaSprite;
    public var barThing:NovaSprite;

    override function create() {
        super.create();
        NovaUtils.playMusic('stayFunky').fadeIn();

        bg = new NovaSprite(-153, -140, Paths.image("menus/characterselectmenu/charSelectBG"));
        bg.scrollFactor.set(0.1, 0.1);
        add(bg);

        crowd = new NovaSprite(0, 0, Paths.image("menus/characterselectmenu/crowd"));
        crowd.addAnim('idle', 'crowd', null, [0, 0], 24, true, false);
        crowd.playAnim('idle', true);
        crowd.scrollFactor.set(0.3, 0.3);
        add(crowd);

        stage = new NovaSprite(0, 0, Paths.image("menus/characterselectmenu/charSelectStage"));
        stage.addAnim('idle', 'stage full', null, [0, 0], 24, true, false);
        stage.playAnim('idle', true);
        add(stage);

        curtains = new NovaSprite(-212, -99, Paths.image("menus/characterselectmenu/curtains"));
        curtains.scrollFactor.set(1.4, 1.4);
        add(curtains);

        barThing = new NovaSprite(0, 0, Paths.image("menus/characterselectmenu/barThing"));
        barThing.addAnim('idle', 'name bar animated', null, [0, 0], 24, true, false);
        barThing.playAnim('idle', true);
        barThing.scrollFactor.set(0, 0);
        barThing.blend = MULTIPLY;
        barThing.scale.x = 2.5;
        add(barThing);

        barThing.y += 80;
        FlxTween.tween(barThing, {y: barThing.y - 80}, 1.3, {ease: FlxEase.expoOut});

        // FlxG.camera.scroll.y -= FlxG.height/2;

    }
}