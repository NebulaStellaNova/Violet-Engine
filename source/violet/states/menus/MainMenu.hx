package violet.states.menus;

import violet.data.Constants;
import flixel.FlxObject;
import flixel.math.FlxMath;

import violet.backend.StateBackend;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ParseUtil;
import violet.backend.scripting.events.SelectionEvent;

#if debug
import violet.backend.display.DebugDisplay;
#end

typedef MenuOffset = {
	var idle:Array<Float>;
	var selected:Array<Float>;
}

typedef MenuAnimations = {
	var idle:String;
	var selected:String;
	var ?offsets:MenuOffset;
}

typedef MenuItem = {
	var id:String;
	var item:String;
	var state:String;
	var scale:Float;
	var color:ParseColor;
	var animations:MenuAnimations;
}

typedef MenuData = {
	var directory:String;
	var background:String;
	var items:Array<MenuItem>;
}

class MainMenu extends StateBackend {
	public var watermarkTexts = [
		Constants.ENGINE_TITLE + " v" + Constants.ENGINE_VERSION
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
		super.create();

		var modMenu:violet.states.menus.ModMenu = new violet.states.menus.ModMenu();

		// FlxG.camera.color = FlxColor.BLACK;

		menuData = ParseUtil.json("data/config/menuData");

		var mult:Float = 1/(menuData.items.length);
		bg = new NovaSprite(Paths.image(menuData.directory + "/" + menuData.background));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.scale.x += mult;
		bg.scale.y += mult;
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = menuData.items[curSelected].color;
		bg.scrollFactor.set(0, mult/2);
		bg.x = 0;
		add(bg);

		for (i=>daItem in menuData.items) {
			var item = new NovaSprite(0, (175*i)+90, Paths.image(menuData.directory + "/" + daItem.item));
			item.addAnim("selected", daItem.item + " " + daItem.animations.selected, [], daItem.animations?.offsets?.selected ?? [0, 0], 24, true);
			item.addAnim("static", daItem.item + " " + daItem.animations.idle, [], daItem.animations?.offsets?.idle ?? [0, 0], 24, true);
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

		FlxG.camera.fade(FlxColor.BLACK, 0.25, true);

		#if debug
		DebugDisplay.registerVariable("Current Menu Item Index", "curSelected");
		DebugDisplay.registerVariable("Current Menu Item", "curSelectedString");
		DebugDisplay.registerVariable("Background Color", "bgColorString");
		DebugDisplay.registerVariable("Can Select", "canSelect");
		#end

		NovaUtils.playMenuMusic();

		callInScripts('postCreate');
	}

	function uiCheck() {
		if (!canSelect) return 0;
		if (Controls.uiUp)
			return -1;
		else if (Controls.uiDown)
			return 1;
		else
			return 0;
	}

	override public function update(elapsed:Float)
	{

		super.update(elapsed);
		// trace(Main.stateClassName);
		// trace(Main.subStateClassName);
		if (Controls.uiUp || Controls.uiDown)
			changeSelection(uiCheck());
		bg.color = MathUtil.colorLerp(bg.color, menuData.items[curSelected].color, 0.16);
		bgColorString = ParseColor.fromInt(bg.color);

		leftWatermark.updateHitbox();
		switch (watermarkAlignment) {
			case "right":
				leftWatermark.x = FlxG.width - leftWatermark.getWidth() - 5;
			default:
				leftWatermark.x = 10;
		}

		if (Controls.accept) {
			pickSelection();
		}

		if (Controls.back) {
			// Main.switchState(new ClassData('TitleState')); // Crashes idk why
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
		if (canSelect) {
			leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;
		}
	}

	public function changeSelection(amt:Int) {
		var event:SelectionEvent = new SelectionEvent(FlxMath.wrap(curSelected + amt, 0, menuItems.length-1));
		if (amt != 0) {
			event = runEvent("changeSelection", new SelectionEvent(FlxMath.wrap(curSelected + amt, 0, menuItems.length-1)));
			if (event.cancelled) return;
		}
		if (amt != 0 && !event.soundCancelled) {
		    NovaUtils.playMenuSFX(NovaUtils.SCROLL);
		}
		curSelected = event.selection;
		for (i => item in menuItems) {
			if (i == curSelected) {
				item.updateHitbox();
				var daTarget:FlxObject = new FlxObject();
				daTarget.x = (FlxG.width/2);
				daTarget.y = item.y + (item.height/2);
				FlxG.camera.target = daTarget;
			}
			item.playAnim(i == curSelected ? "selected" : "static");
			item.updateHitbox();
			if (canSelect) {
				switch (menuAlignment) {
					case "center":
						item.screenCenter(X);
					case "left":
						item.x = 20;
					case "right":
						item.x = FlxG.width - item.width - 20;
				}
			}
			item.offset.x = item.anims.get(i == curSelected ? "selected" : "static").offset[0];
			item.offset.y =  item.anims.get(i == curSelected ? "selected" : "static").offset[1];
		}
		curSelectedString = menuData.items[curSelected].item;
	}

	public function pickSelection() {
		if (!canSelect) return;
		var event:SelectionEvent = runEvent("pickSelection", new SelectionEvent(curSelected));
		if (!event.soundCancelled) NovaUtils.playMenuSFX(NovaUtils.CONFIRM);
		if (event.cancelled) return;

		canSelect = false;

		var classData = new ClassData(menuData.items[curSelected].state);


		if (classData.isSubState) {
			FlxTween.tween(bg, {x: FlxG.width - bg.width }, 0.5*2, { ease: FlxEase.smootherStepInOut });
			for (i in menuItems) {
				FlxTween.tween(i, { x: i.x - FlxG.width }, 0.5, { ease: FlxEase.smootherStepIn });
			}
			FlxTween.tween(leftWatermark, { y: FlxG.height }, 0.5, { ease: FlxEase.backIn });
		}

		new FlxTimer().start(0.5, (t)->{
			if (classData.isSubState) {
				openSubState(classData.target);
				persistentUpdate = true;
			} else {
				Main.switchState(classData.target);
			}
			// canSelect = true;
		});
	}

	public function setSelectionColor(hex) {
		menuData.items[curSelected].color = hex;
	}

	override function closeSubState() {
		super.closeSubState();
		for (i in menuItems) {
			FlxTween.tween(i, { x: i.x + FlxG.width }, 0.5, { ease: FlxEase.smootherStepOut, onComplete: (_)-> canSelect = true });
		}
		FlxTween.tween(leftWatermark, { y: FlxG.height - leftWatermark.getHeight() - 5 }, 0.5, { ease: FlxEase.backOut });
	}
}