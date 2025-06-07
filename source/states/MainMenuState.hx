package states;

import backend.ClassData;
import flixel.util.FlxTimer;
import scripting.events.SelectionEvent;
import backend.objects.NovaText;
import flixel.text.FlxText;
import utils.MathUtil;
import flixel.math.FlxMath;
import flixel.FlxG;
import backend.JsonColor;
import backend.filesystem.Paths;
import backend.objects.NovaSprite;
import backend.MusicBeatState;
import haxe.Json;

typedef MenuAnimations = {
    var idle:String;
    var selected:String;
}

typedef MenuItem = {
    var id:String;
    var item:String;
    var state:String;
    var color:JsonColor;
    var animations:MenuAnimations;
}

typedef MenuData = {
    var directory:String;
    var background:String;
    var items:Array<MenuItem>;
} 

class MainMenuState extends MusicBeatState {

    public var curSelectedString:String = "";
    public var bgColorString:String = "";

    public var curSelected:Int = 0;

    public var menuData:MenuData;

    public var bg:NovaSprite;

    public var menuItems:Array<NovaSprite> = [];

    public var leftWatermark:NovaText;

    public var canSelect:Bool = true;

	override public function create()
	{
        debugVars = ["curSelected"];
		super.create();

        menuData = Json.parse(Paths.readStringFromPath("assets/data/config/menuData.json"));

        bg = new NovaSprite(0, 0, Paths.image(menuData.background, menuData.directory));
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.screenCenter();
        bg.color = menuData.items[curSelected].color;
        add(bg);
        
        for (i=>daItem in menuData.items) {
            var item = new NovaSprite(0, (150*i)+90, Paths.image(daItem.item, menuData.directory));
            item.addAnim("selected", daItem.item + " " + daItem.animations.selected, true);
            item.addAnim("static", daItem.item + " " + daItem.animations.idle, true);
            item.playAnim("static");
            item.updateHitbox();
            item.screenCenter(X);
            menuItems.push(item);
            add(item);
        }

        leftWatermark = new NovaText(10, 0, "Nova Engine v0.1", 20);
        leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;
        //leftWatermark.setFormat(Paths.font("Tardling v1.1.ttf"), 20);
        add(leftWatermark);

        
        #if FLX_DEBUG
		FlxG.watch.add(this, "curSelectedString", "Current Selected Item:");
		FlxG.watch.add(this, "bgColorString", "Background Color:");
		FlxG.game.debugger.console.registerFunction('setSelectionColor', setSelectionColor);
		FlxG.game.debugger.console.registerFunction('changeSelection', changeSelection);
        #end
	}

    function uiCheck() {
        if (!canSelect) return 0;
        if (FlxG.keys.justPressed.UP)
            return -1;
        else if (FlxG.keys.justPressed.DOWN)
            return 1;
        else
            return 0;
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
        changeSelection(uiCheck());   
        bg.color = MathUtil.colorLerp(bg.color, menuData.items[curSelected].color, 0.16);
        bgColorString = JsonColor.fromInt(bg.color);

        if (FlxG.keys.justPressed.ENTER) {
            pickSelection();
        }

        call("postUpdate", [elapsed]);
        call("onUpdatePost", [elapsed]);

	}

    public function changeSelection(amt:Int) {
        var event:SelectionEvent = runEvent("onChangeSelection", new SelectionEvent(FlxMath.wrap(curSelected + amt, 0, menuItems.length-1)));
        if (event.cancelled) return;
        if (amt != 0 && !event.soundCancelled) {
            FlxG.sound.play(Paths.sound("scroll", "menu"));
        }
        curSelected = event.selection;
        for (i => item in menuItems) {
            item.playAnim(i == curSelected ? "selected" : "static");
            item.updateHitbox();
            item.screenCenter(X);
        }
        curSelectedString = menuData.items[curSelected].item;
    }

    public function pickSelection() {
        var event:SelectionEvent = runEvent("onPickSelection", new SelectionEvent(curSelected));
        if (!event.soundCancelled) FlxG.sound.play(Paths.sound("confirm", "menu"));
        if (event.cancelled) return;

        canSelect = false;

        new FlxTimer().start(1, (t)->{
            switchState(new ClassData(menuData.items[curSelected].state).target);
            canSelect = true;
        });
    }

    public function setSelectionColor(hex) {
        menuData.items[curSelected].color = hex;
    }

}