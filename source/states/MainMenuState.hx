package states;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxColor;
import states.editors.CharacterEditorState;
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
	var scale:Float;
	var color:JsonColor;
	var animations:MenuAnimations;
}

typedef MenuData = {
	var directory:String;
	var background:String;
	var items:Array<MenuItem>;
}

class MainMenuState extends MusicBeatState {
	public var watermarkTexts = [
		"Violet Engine v0.1",
		"THIS IS NOT A FORK"
	];

	public var curSelectedString:String = "";
	public var bgColorString:String = "";

	public static var curSelected:Int = 0;

	public var menuData:MenuData;

	public var bg:NovaSprite;

	public var menuItems:Array<NovaSprite> = [];

	public var leftWatermark:NovaText;

	public var canSelect:Bool = true;

	public var menuAlignment:String = "left";
	public var watermarkAlignment:String = "right";

	override public function create()
	{
		debugVars = ["curSelected"];
		super.create();

		menuData = Paths.parseJson("data/config/menuData");

		var mult:Float = 1/(menuData.items.length-1);
		bg = new NovaSprite(Paths.image(menuData.background, menuData.directory));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.scale.x += mult;
		bg.scale.y += mult;
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = menuData.items[curSelected].color;
		bg.scrollFactor.set(0, mult);
		add(bg);

		for (i=>daItem in menuData.items) {
			var item = new NovaSprite(0, (150*i)+90, Paths.image(daItem.item, menuData.directory));
			item.addAnim("selected", daItem.item + " " + daItem.animations.selected, true);
			item.addAnim("static", daItem.item + " " + daItem.animations.idle, true);
			item.playAnim("static");
			item.scale.set(daItem.scale ?? 1, daItem.scale ?? 1);
			item.updateHitbox();
			item.centerOrigin();
			item.centerOffsets();
			//item.screenCenter(X);
			menuItems.push(item);
			add(item);
		}

		leftWatermark = new NovaText(10, 0, "Nova Engine v0.1", 20);
		leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;
		leftWatermark.setFormat(Paths.font("vcr.ttf"), 40);
		leftWatermark.scrollFactor.set();
		leftWatermark.alignment = watermarkAlignment;
		switch (watermarkAlignment) {
			case "right":
				leftWatermark.x = FlxG.width - leftWatermark.getWidth();
			default:
				leftWatermark.x = 10;
		}
		//leftWatermark.setFormat(Paths.font("Tardling v1.1.ttf"), 20);
		add(leftWatermark);


		#if FLX_DEBUG
		FlxG.watch.add(this, "curSelectedString", "Current Selected Item:");
		FlxG.watch.add(this, "bgColorString", "Background Color:");
		FlxG.game.debugger.console.registerFunction('setSelectionColor', setSelectionColor);
		FlxG.game.debugger.console.registerFunction('changeSelection', changeSelection);
		#end
		
		changeSelection(uiCheck());
		FlxG.camera.snapToTarget();
		FlxG.camera.followLerp = 0.1;
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
		watermarkTexts.sort(function(a, b):Int {
			if(a.length < b.length) return -1;
			else if(a.length > b.length) return 1;
			else return 0;
		});

		leftWatermark.borderStyle = OUTLINE;
		leftWatermark.borderColor = FlxColor.BLACK;
		leftWatermark.borderSize = 3;
		leftWatermark.text = watermarkTexts.join("\n");
		leftWatermark.updateHitbox();
		leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;


		if (FlxG.keys.justPressed.F9) {
			switchState(CharacterEditorState.new);
		}

		call("postUpdate", [elapsed]);
		call("onUpdatePost", [elapsed]);

	}

	public function changeSelection(amt:Int) {
		var event:SelectionEvent = new SelectionEvent(FlxMath.wrap(curSelected + amt, 0, menuItems.length-1));
		if (amt != 0) {
			event = runEvent("onChangeSelection", new SelectionEvent(FlxMath.wrap(curSelected + amt, 0, menuItems.length-1)));
			if (event.cancelled) return;
		}
		if (amt != 0 && !event.soundCancelled) {
			FlxG.sound.play(Paths.sound("scroll", "menu"));
		}
		curSelected = event.selection;
		for (i => item in menuItems) {
			if (i == curSelected) {
				var daTarget:FlxObject = new FlxObject();
				daTarget.x = (FlxG.width/2);
				daTarget.y = item.y;
				FlxG.camera.target = daTarget;
			}
			item.playAnim(i == curSelected ? "selected" : "static");
			item.updateHitbox();
			switch (menuAlignment) {
				case "center":
					item.screenCenter(X);
				case "left":
					item.x = 20;
				case "right":
					item.x = FlxG.width - item.width - 20;
			}
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