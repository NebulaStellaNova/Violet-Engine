package violet.backend;

import flixel.text.FlxText;
import violet.backend.utils.NovaUtils;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import violet.backend.objects.Alphabet;

typedef EditorListOption = {
    var title:String;
    var ?description:String;
    var ?onClick:Void->Void;
    var ?disabled:Bool;
}

class EditorListBackend extends violet.backend.SubStateBackend {

    public var showLocks:Bool = true;

    var options:Array<EditorListOption> = [];

    public var items:Array<Alphabet> = [];

    public var debugCurSelected:Int = 0;

    var exitScrollY:Float = 0;

    var subCamera:FlxCamera;

    var bg:NovaSprite;

    var descriptionTxt:FlxText;
    var descriptionBox:NovaSprite;

    override public function new(?options:Array<EditorListOption>) {
        super();
        options ??= [];
        this.options = options;
    }

    override function create() {
        super.create();

        var needsFailSafe = true;
        for (i in options) {
            if (!i.disabled) needsFailSafe = false;
        }
        if (needsFailSafe) options.push({ title: "Uh Oh!", description: "All options are disabled so in order to not cause recursion this option was created."});

        subCamera = new FlxCamera();
        subCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(subCamera, false);

        FlxG.state.persistentDraw = false;
        FlxG.state.persistentUpdate = false;

        var offset = (options.length-1) * 100;
		bg = new NovaSprite(Paths.image("menus/mainmenu/menuBGdesat"));
		bg.setGraphicSize(FlxG.width + offset, FlxG.height + offset);
        bg.updateHitbox();
        bg.screenCenter();
        bg.camera = subCamera;
        bg.scrollFactor.set(0, 1/(options.length-1));
        bg.color = FlxColor.interpolate(FlxColor.CYAN, FlxColor.BLUE);
        add(bg);

        for (i=>data in options) {
            var option:Alphabet = new Alphabet(data.title);
            option.camera = subCamera;
            option.screenCenter();
            option.y += i * 100;
            if (data.disabled) {
                for (i in option.letters) i.color = FlxColor.interpolate(i.color, FlxColor.BLACK, 0.5);
                if (showLocks) {
                    var lock = new NovaSprite(Paths.image("menus/lock-bold"));
                    lock.antialiasing = true;
                    lock.scale.set(0.8, 0.8);
                    lock.updateHitbox();
                    lock.x = option.letters[0].x + (option.width/2) - (lock.width/2);
                    lock.y = option.letters[0].y + (option.height/2) - (lock.height/2);
                    option.add(lock);
                }
            }
            add(option);
            items.push(option);
        }

        descriptionBox = new NovaSprite().makeGraphic(1, 1, FlxColor.BLACK);
        descriptionBox.scrollFactor.set();
        descriptionBox.camera = subCamera;
        descriptionBox.visible = false;
        add(descriptionBox);

        descriptionTxt = new FlxText(0, 0, FlxG.width * 0.85, "Test", 30);
        descriptionTxt.scrollFactor.set();
        descriptionTxt.camera = subCamera;
        descriptionTxt.font = Paths.font("vcr");
        descriptionTxt.antialiasing = false;
        descriptionTxt.alignment = CENTER;
        add(descriptionTxt);

        scroll(0);
    }

    var frame = 0;

    override function update(elapsed:Float) {
        if (Controls.uiUp) scroll(-1);
        if (Controls.uiDown) scroll(1);

        if (Controls.back) {
            close();
        }

        if (Controls.accept && frame > 3) {
            pickOption(options[debugCurSelected]);
        }

        frame++;
    }

    function scroll(amt:Int) {
        var prevSelected = debugCurSelected;
        debugCurSelected = FlxMath.wrap(debugCurSelected + amt, 0, options.length-1);
        while (options[debugCurSelected].disabled) {
			debugCurSelected = FlxMath.wrap(debugCurSelected + (amt != 0 ? amt : 1), 0, options.length-1);
		}
        if (debugCurSelected != prevSelected/*  && !event.soundCancelled */) {
		    NovaUtils.playMenuSFX(SCROLL);
		}

        for (i=>item in items) item.alpha = i == debugCurSelected ? 1 : 0.5;
        var targetItem:Alphabet = items[debugCurSelected];
        FlxTween.cancelTweensOf(subCamera.scroll);
        FlxTween.tween(subCamera.scroll, { y: targetItem.y - (FlxG.height/2) + (targetItem.height/2) }, 0.5, { ease: FlxEase.quartOut });

        descriptionTxt.text = options[debugCurSelected].description ?? "";
        descriptionTxt.updateHitbox();
        descriptionTxt.screenCenter();
        descriptionTxt.y += FlxG.height * 0.35;

        descriptionBox.visible = descriptionTxt.text != "";
        descriptionBox.scale.set(descriptionTxt.width + 50, descriptionTxt.height + 50);
        descriptionBox.updateHitbox();
        descriptionBox.screenCenter();
        descriptionBox.alpha = 0.5;
        descriptionBox.y += FlxG.height * 0.35;
    }

    override function close() {
        debugCurSelected = 0;
        FlxG.state.persistentDraw = true;
        FlxG.state.persistentUpdate = true;
        FlxG.cameras.remove(subCamera);
        super.close();
    }

    public function pickOption(option:{title:String, onClick:Void->Void}) {
        option.onClick ??= ()->{};
        option.onClick();
    }
}