package violet.states.menus;

import violet.backend.utils.NovaUtils;
import violet.backend.StateBackend;

class CharacterSelectMenu extends StateBackend {

    public var bg:NovaSprite;
    public var crowd:NovaSprite;
    public var stage:NovaSprite;
    public var curtains:NovaSprite;
    public var barThing:NovaSprite;
    public var speakers:NovaSprite;
    public var foregroundBlur:NovaSprite;
    public var dipshitBlur:NovaSprite;
    public var dipshitBacking:NovaSprite;
    public var chooseDipshit:NovaSprite;

    override function create() {
        super.create();
        NovaUtils.playMusic('stayFunky').fadeIn();

        bg = new NovaSprite(-153, -140, Paths.image("menus/characterselectmenu/charSelectBG"));
        bg.scrollFactor.set(0.1, 0.1);
        add(bg);

        crowd = new NovaSprite(-60, 250, Paths.image("menus/characterselectmenu/crowd"));
        crowd.addAnim('idle', 'crowd', null, [0, 0], 24, true, false);
        crowd.playAnim('idle', true);
        crowd.scrollFactor.set(0.3, 0.3);
        add(crowd);

        stage = new NovaSprite(-40, 409, Paths.image("menus/characterselectmenu/charSelectStage"));
        stage.addAnim('idle', 'stage full', null, [0, 0], 24, true, false);
        stage.playAnim('idle', true);
        add(stage);

        curtains = new NovaSprite(-212, -99, Paths.image("menus/characterselectmenu/curtains"));
        curtains.scrollFactor.set(1.4, 1.4);
        add(curtains);

        barThing = new NovaSprite(0, 50, Paths.image("menus/characterselectmenu/barThing"));
        barThing.addAnim('idle', 'name bar animated', null, [0, 0], 24, true, false);
        barThing.playAnim('idle', true);
        barThing.scrollFactor.set(0, 0);
        barThing.blend = MULTIPLY;
        barThing.scale.x = 2.5;
        add(barThing);

        add(new NovaSprite(800, 250, Paths.image('menus/characterselectmenu/charLight')));
        add(new NovaSprite(180, 240, Paths.image('menus/characterselectmenu/charLight')));

        speakers = new NovaSprite(-168, 430, Paths.image("menus/characterselectmenu/charSelectSpeakers"));
        speakers.addAnim('idle', 'Speakers ALL', null, [0, 0], 24, true, false);
        speakers.playAnim('idle', true);
        speakers.scrollFactor.set(1.8, 1.8);
        speakers.scale.set(1.05, 1.05);
        add(speakers);

        foregroundBlur = new NovaSprite(-125, 170, Paths.image("menus/characterselectmenu/foregroundBlur"));
        foregroundBlur.blend = MULTIPLY;
        add(foregroundBlur);

        dipshitBlur = new NovaSprite(419, -65, Paths.image("menus/characterselectmenu/dipshitBlur"));
        dipshitBlur.addAnim('idle', "CHOOSE vertical offset instance 1", 24, true);
        dipshitBlur.playAnim('idle', true);
        dipshitBlur.blend = ADD;
        add(dipshitBlur);

        dipshitBacking = new NovaSprite(423, -17, Paths.image("menus/characterselectmenu/dipshitBacking"));
        dipshitBacking.addAnim('idle', "CHOOSE horizontal offset instance 1", 24, true);
        dipshitBacking.playAnim('idle', true);
        dipshitBacking.blend = ADD;
        add(dipshitBacking);

        chooseDipshit = new NovaSprite(426, -13, Paths.image("menus/characterselectmenu/chooseDipshit"));
        add(chooseDipshit);

        chooseDipshit.y += 200;
        FlxTween.tween(chooseDipshit, {y: chooseDipshit.y - 200}, 1, {ease: FlxEase.expoOut});

        dipshitBacking.y += 210;
        FlxTween.tween(dipshitBacking, {y: dipshitBacking.y - 210}, 1.1, {ease: FlxEase.expoOut});

        dipshitBlur.y += 220;
        FlxTween.tween(dipshitBlur, {y: dipshitBlur.y - 220}, 1.2, {ease: FlxEase.expoOut});

        barThing.y += 80;
        FlxTween.tween(barThing, {y: barThing.y - 80}, 1.3, {ease: FlxEase.expoOut});

        chooseDipshit.scrollFactor.set();
        dipshitBacking.scrollFactor.set();
        dipshitBlur.scrollFactor.set();

        // FlxG.camera.scroll.y -= FlxG.height/2;

    }
}