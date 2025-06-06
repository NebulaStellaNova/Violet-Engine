package states;

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

    public var curSelected:Int = 0;

    public var menuData:MenuData;

    public var bg:NovaSprite;

    public var menuItems:Array<NovaSprite> = [];

    public var leftWatermark:NovaText;

	override public function create()
	{
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
	}

    function uiCheck() {
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
        if (stateScript != null) {
            stateScript.call("postUpdate", [elapsed]);
            stateScript.call("onUpdatePost", [elapsed]);
        }
	}

    public function changeSelection(amt:Int) {
        if (amt != 0) {
            FlxG.sound.play(Paths.sound("scroll", "menu"));
        }
        curSelected = FlxMath.wrap(curSelected + amt, 0, menuItems.length-1);
        for (i=>item in menuItems) {
            item.playAnim(i == curSelected ? "selected" : "static");
            item.updateHitbox();
            item.screenCenter(X);
        }
    }

}