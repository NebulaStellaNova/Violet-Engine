package violet.states.menus;

import flixel.text.FlxText;
import violet.backend.options.Options;
import violet.backend.utils.MathUtil;
import flixel.group.FlxGroup;
import violet.backend.utils.NovaUtils;
import flixel.math.FlxMath;
import violet.backend.objects.Alphabet;
import violet.backend.utils.ParseUtil;
import flixel.FlxCamera;
import violet.backend.objects.options.BoolOption;
import violet.backend.objects.options.BaseOption;
import violet.backend.SubStateBackend;

enum abstract OptionsType(String) {
    var BOOL = "bool";
}

typedef OptionsData = {
    var menus:Array<OptionsMenuData>;
}

typedef OptionsMenuData = {
    var title:String;
    var ?description:String;
    var ?options:Array<OptionsMenuOption>;
}

typedef OptionsMenuOption = {
    var name:String;
    var ?description:String;
    var saveID:String;
    var type:OptionsType;
}


class OptionsMenu extends SubStateBackend {

    public var optionsData:OptionsData = ParseUtil.yaml("data/config/options");

    public var menus:Array<Alphabet> = [];
    public var options:Array<BaseOption> = [];

    public var canSelectMenu:Bool = true;

    public var menuCurSelected:Int = 0;
    public var optionCurSelected:Int = 0;

    var descriptionTxt:FlxText;
    var descriptionBox:NovaSprite;

    public var optionsListOffset:Float = FlxG.width + 100;

    override function create() {
        super.create();

        camera = new FlxCamera();
        camera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(camera, false);

        for (i=>menuData in optionsData.menus) {
            var alphabet:Alphabet = new Alphabet(menuData.title.toUpperCase());
            alphabet.screenCenter();
            alphabet.y += i * 100;
            alphabet.y -= ((optionsData.menus.length-1) * 100)/2;
            menus.push(alphabet);
            add(alphabet);
            alphabet.x += FlxG.width;
            FlxTween.tween(alphabet, { x: alphabet.x-FlxG.width }, 1, { ease: FlxEase.expoOut });
        }

        descriptionBox = new NovaSprite().makeGraphic(1, 1, FlxColor.BLACK);
        descriptionBox.scrollFactor.set();
        descriptionBox.visible = false;
        add(descriptionBox);

        descriptionTxt = new FlxText(0, 0, FlxG.width * 0.85, "Test", 30);
        descriptionTxt.scrollFactor.set();
        descriptionTxt.font = Paths.font("vcr");
        descriptionTxt.antialiasing = false;
        descriptionTxt.alignment = CENTER;
        add(descriptionTxt);

        updateDesc({});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (i=>menu in menus) {
            menu.alpha = menuCurSelected == i ? 1 : 0.5;
        }

        if (Controls.uiUp) options.length != 0 ? optionsScroll(-1) : menuScroll(-1);
        if (Controls.uiDown) options.length != 0 ? optionsScroll(1) : menuScroll(1);

        for (i=>option in options) {
            option.x -= optionsListOffset;
            option.x = MathUtil.lerp(option.x, 50 - (Math.pow(Math.abs(i-optionCurSelected), 1.6) * 10), 0.2);
            option.y = MathUtil.lerp(option.y, (FlxG.height/2) + ((i-optionCurSelected) * 100) - (option.alphabet.height/2), 0.2);
            option.x += optionsListOffset;
            option.updatePosition();
        }

        if (Controls.accept) selectMenu();

        if (Controls.back) {
            if (options.length != 0) {
                FlxTween.tween(this, { optionsListOffset: FlxG.width + 200 }, 0.5, { ease: FlxEase.expoIn, onComplete: (_)->closeOptions() });
                updateDesc({});
            } else {
                exit();
            }
            /* for (i in menus) {
                FlxTween.tween(i, )
            } */
        }
    }

    function selectMenu() {
        if (!canSelectMenu) return;
        canSelectMenu = false;
        for (i in menus) {
            FlxTween.tween(i, { y: i.y+FlxG.width }, 0.5, { ease: FlxEase.expoIn });
        }

        new FlxTimer().start(0.5, (_)->generateOptions());
    }

    function generateOptions() {
        for (i=>optionData in optionsData.menus[menuCurSelected].options) {
            if (optionData.type == BOOL) {
                var option:BoolOption = new BoolOption(optionData.name, optionData.description);
                option.x = optionsListOffset;
                option.y = (FlxG.height/2) + ((i-optionCurSelected) * 100) - (option.alphabet.height/2);
                option.checkbox.value =  Options.get(optionData.saveID) ?? false;
                option.checkbox.animation.finish();
                option.onChange = function(value:Bool) {
                    Options.set(optionData.saveID, value);
                }
                option.updatePosition();
                insert(0, option);
                options.push(option);
            }
        }
        optionsScroll(0);
        FlxTween.tween(this, { optionsListOffset: 0 }, 0.5, { ease: FlxEase.expoOut });
    }

    function closeOptions() {
        for (i in options) {
            remove(i);
            i.destroy();
        }
        canSelectMenu = true;
        options = [];

        for (i in menus) {
            FlxTween.tween(i, { y: i.y-FlxG.width }, 0.5, { ease: FlxEase.expoOut });
        }
    }

    function exit() {
        Options.flush();
        for (alphabet in menus) {
            FlxTween.tween(alphabet, { x: alphabet.x+FlxG.width }, 1, { ease: FlxEase.expoIn });
        }
        new FlxTimer().start(1, (_)->close());
		FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.5 });
    }

    function menuScroll(amt) {
        menuCurSelected = FlxMath.wrap(menuCurSelected + amt, 0, menus.length-1);
        if (amt != 0) NovaUtils.playMenuSFX(SCROLL);
        updateDesc(optionsData.menus[menuCurSelected]);
    }

    function optionsScroll(amt) {
        optionCurSelected = FlxMath.wrap(optionCurSelected + amt, 0, options.length-1);
        if (amt != 0) NovaUtils.playMenuSFX(SCROLL);
        for (i=>option in options) {
            option.selected = i == optionCurSelected;
        }
        updateDesc(optionsData.menus[menuCurSelected].options[optionCurSelected]);
    }

    function updateDesc(data:Dynamic) {
        descriptionTxt.text = data.description ?? "";
        descriptionTxt.updateHitbox();
        descriptionTxt.screenCenter();
        descriptionTxt.y += FlxG.height * 0.35;

        descriptionBox.visible = descriptionTxt.text != "";
        descriptionBox.scale.set(descriptionTxt.width + 50, descriptionTxt.height + 50);
        descriptionBox.updateHitbox();
        descriptionBox.screenCenter();
        descriptionBox.alpha = 0.7;
        descriptionBox.y += FlxG.height * 0.35;
    }
}