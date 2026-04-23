package violet.states.menus;

import violet.backend.options.Options;
import violet.data.Constants;
import flixel.FlxObject;
import flixel.math.FlxMath;

import violet.backend.StateBackend;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ParseUtil;
import violet.backend.scripting.events.SelectionEvent;

import thx.semver.Version;

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
	var scale:Float;
	var state:String;
	var disabled:Bool;
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
		Constants.ENGINE_TITLE + ' v' + Constants.ENGINE_VERSION + (Constants.ENGINE_SUFFIX != '' ? '-${Constants.ENGINE_SUFFIX}' : '')
	];

	public var debugTexts = [
		'Commit: ${Constants.COMMIT_INDEX} (${Constants.COMMIT_HASH})',
		'Branch: ${Constants.GITHUB_BRANCH}'
	];

	public var curSelectedString:String = '';
	public var bgColorString:String = '';

	public static var curSelected:Int = 0;

	public var menuData:MenuData;

	public var bg:NovaSprite;

	public var menuItems:Array<NovaSprite> = [];

	public var baseYs:Array<Float> = [];
	public var floatOffsets:Array<Float> = [];
	public var menuTime:Float = 0;

	public var enableMobileControls:Bool = #if mobile true #else false #end;

	public var leftWatermark:NovaText;
	public var debugWatermark:NovaText;

	public var canSelect:Bool = true;

	public var substateTrans:Bool = true;

	public var menuAlignment:String = 'center';
	public var watermarkAlignment:String = 'right';

	public var flower:NovaSprite;
	public var flowerTargetAngle:Float = 0;

	public static var instance:MainMenu;

	override public function new() {
		instance = this;
		super();
	}

	override public function create()
	{
		super.create();

		NovaUtils.playMenuMusic();

		var modMenu:violet.states.menus.ModMenu = new violet.states.menus.ModMenu();

		// FlxG.camera.color = FlxColor.BLACK;

		menuData = ParseUtil.json('data/config/menuData');

		#if mobile
		for (i in menuData.items) {
			if (i.id == 'mods') menuData.items.remove(i);
		}
		#end

		var mult:Float = 1/(menuData.items.length);
		bg = new NovaSprite(Paths.image(menuData.directory + '/' + menuData.background));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.scale.x += mult;
		bg.scale.y += mult;
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = menuData.items[curSelected].color;
		bg.scrollFactor.set(0, mult/2);
		bg.x = 0;
		add(bg);

		var overlay:NovaSprite = new NovaSprite(0, 0);
		overlay.setGraphicSize(FlxG.width, FlxG.height);
		overlay.color = FlxColor.BLACK;
		overlay.alpha = 0.25;
		overlay.scrollFactor.set();
		add(overlay);

		flower = new NovaSprite(0, 0, Paths.image(menuData.directory + '/violet'));
		flower.screenCenter(Y);
		flower.scrollFactor.set(1, 0);
		flower.updateHitbox();
		flower.centerOrigin();
		flower.x = FlxG.width - flower.width / 2;
		// add(flower);

		for (i=>daItem in menuData.items) {
			var startY = (175*i)+90;
			var item = new NovaSprite(FlxG.width/2, startY, Paths.image(menuData.directory + '/' + daItem.item));
			item.addAnim('selected', daItem.item + ' ' + daItem.animations.selected, [], daItem.animations?.offsets?.selected ?? [0, 0], 24, true);
			item.addAnim('static', daItem.item + ' ' + daItem.animations.idle, [], daItem.animations?.offsets?.idle ?? [0, 0], 24, true);
			item.playAnim('static');
			item.scale.set(daItem.scale ?? 1, daItem.scale ?? 1);
			item.updateHitbox();
			item.centerOrigin();
			item.centerOffsets();
			baseYs.push(startY);
			floatOffsets.push(Math.random() * Math.PI * 2);
			if (daItem.disabled) item.color = FlxColor.interpolate(item.color, FlxColor.BLACK, 0.25);
			//item.screenCenter(X);
			menuItems.push(item);
			add(item);
		}

		leftWatermark = new NovaText(10, 0, 'Nova Engine v0.1', 20);
		leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;
		leftWatermark.setFormat(Paths.font('vcr.ttf'), 40);
		leftWatermark.scrollFactor.set();
		leftWatermark.alignment = watermarkAlignment;
		switch (watermarkAlignment) {
			case 'right':
				leftWatermark.x = FlxG.width - leftWatermark.getWidth();
			default:
				leftWatermark.x = 10;
		}
		//leftWatermark.setFormat(Paths.font('Tardling v1.1.ttf'), 20);
		add(leftWatermark);

		debugWatermark = new NovaText(10, 10, debugTexts.join('\n'), 20);
		debugWatermark.setFormat(Paths.font('vcr.ttf'), 40);
		debugWatermark.scrollFactor.set();
		debugWatermark.alignment = watermarkAlignment;
		switch (watermarkAlignment) {
			case 'right':
				debugWatermark.x = FlxG.width - debugWatermark.getWidth();
			default:
				debugWatermark.x = 10;
		}
		//leftWatermark.setFormat(Paths.font('Tardling v1.1.ttf'), 20);
		add(debugWatermark);


		#if FLX_DEBUG
		FlxG.watch.add(this, 'curSelectedString', 'Current Selected Item:');
		FlxG.watch.add(this, 'bgColorString', 'Background Color:');
		FlxG.game.debugger.console.registerFunction('setSelectionColor', setSelectionColor);
		FlxG.game.debugger.console.registerFunction('changeSelection', changeSelection);
		#end

		changeSelection(uiCheck());
		FlxG.camera.snapToTarget();
		FlxG.camera.followLerp = 0.1;

		FlxG.camera.fade(FlxColor.BLACK, 0.25, true);

		#if debug
		DebugDisplay.registerVariable('Current Menu Item Index', () -> return curSelected);
		DebugDisplay.registerVariable('Current Menu Item', () -> return curSelectedString);
		DebugDisplay.registerVariable('Background Color', () -> return bgColorString);
		DebugDisplay.registerVariable('Can Select', () -> return canSelect);
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
		if (canSelect && (Controls.uiUp || Controls.uiDown))
			changeSelection(uiCheck());
		bg.color = MathUtil.colorLerp(bg.color, menuData.items[curSelected].color, 0.16);
		bgColorString = ParseColor.fromInt(bg.color);

		leftWatermark.updateHitbox();
		switch (watermarkAlignment) {
			case 'right':
				leftWatermark.x = FlxG.width - leftWatermark.getWidth() - 5;
			default:
				leftWatermark.x = 10;
		}

		debugWatermark.visible = Options.data.developerMode;
		debugWatermark.updateHitbox();
		switch (watermarkAlignment) {
			case 'right':
				debugWatermark.x = FlxG.width - debugWatermark.getWidth() - 5;
			default:
				debugWatermark.x = 10;
		}

		if (Controls.accept) {
			pickSelection();
		}

		menuTime += elapsed;
		for (i => item in menuItems) {
			var bob = Math.sin(menuTime * 1.6 + floatOffsets[i]) * 6;
			item.y = baseYs[i] + bob;
			var configured = menuData.items[i].scale ?? 1;
			var target = (i == curSelected) ? configured * 1.12 : configured;
			item.scale.x = FlxMath.lerp(item.scale.x, target, 0.12);
			item.scale.y = item.scale.x;
		}

		flower.angle = FlxMath.lerp(flower.angle, flowerTargetAngle, Math.min(1, elapsed * 8));

		if (Controls.back) {
			// Main.switchState(new ClassData('TitleState')); // Crashes idk why
		}

		var instance = watermarkTexts.copy();
		for (i in ModdingAPI.getActiveMods()) {
			instance.push('${i.title} v${i?.mod_version}');
		}

		instance.sort(function(a, b):Int {
			if(a.length < b.length) return -1;
			else if(a.length > b.length) return 1;
			else return 0;
		});


		leftWatermark.borderStyle = OUTLINE;
		leftWatermark.borderColor = FlxColor.BLACK;
		leftWatermark.borderSize = 3;
		leftWatermark.text = instance.join('\n');
		leftWatermark.updateHitbox();
		if (canSelect) {
			leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;
		}

		debugWatermark.borderStyle = OUTLINE;
		debugWatermark.borderColor = FlxColor.BLACK;
		debugWatermark.borderSize = 3;
		debugWatermark.updateHitbox();
		if (canSelect) {
			debugWatermark.y = 10;
		}

		if (FlxG.keys.justPressed.SEVEN && Options.data.developerMode) {
			substateTrans = false;
			openSubState(new violet.states.debug.EditorPickerMenu());
		}

		if (!enableMobileControls) return;
		if (canSelect) {
			for (i => item in menuItems) {
				if (FlxG.mouse.overlaps(item) && FlxG.mouse.justPressed) {
					if (curSelected == i) {
						pickSelection();
					} else {
						changeSelection(i-curSelected);
					}
				}
			}
		}
	}

	public function changeSelection(amt:Int) {
		var target = FlxMath.wrap(curSelected + amt, 0, menuItems.length-1);
		while (menuData.items[target].disabled) {
			target = FlxMath.wrap(target + amt, 0, menuItems.length-1);
		}
		var event:SelectionEvent = new SelectionEvent(target);
		if (amt != 0) {
			event = runEvent('changeSelection', new SelectionEvent(target));
			if (event.cancelled) return;
		}
		if (amt != 0 && !event.soundCancelled) {
			NovaUtils.playMenuSFX(SCROLL);
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
			item.playAnim(i == curSelected ? 'selected' : 'static');
			item.updateHitbox();
			if (menuAlignment != 'center') { // looked weird with the offset animations, so might as well not apply them for centered menus
				item.offset.x = item.anims.get(i == curSelected ? 'selected' : 'static').offset[0];
				item.offset.y = item.anims.get(i == curSelected ? 'selected' : 'static').offset[1];
			}
			if (canSelect) {
				switch (menuAlignment) {
					case 'center':
						item.screenCenter(X);
					case 'left':
						item.x = 50;
					case 'right':
						item.x = FlxG.width - item.width - 50;
				}
			}
		}
		curSelectedString = menuData.items[curSelected].item;
		flowerTargetAngle += -amt * 360 / 6;
	}

	public function pickSelection() {
		if (!canSelect) return;
		var event:SelectionEvent = runEvent('pickSelection', new SelectionEvent(curSelected));
		if (!event.soundCancelled) NovaUtils.playMenuSFX(CONFIRM);
		if (event.cancelled) return;

		canSelect = false;

		var classData = new ClassData(menuData.items[curSelected].state);

		if (classData.isSubState) {
			FlxTween.tween(bg, {x: FlxG.width - bg.width }, 0.5*2, { ease: FlxEase.smootherStepInOut });
			for (i in menuItems) {
				FlxTween.tween(i, { x: i.x - FlxG.width }, 0.5, { ease: FlxEase.smootherStepIn });
			}
			FlxTween.tween(leftWatermark, { y: FlxG.height }, 0.5, { ease: FlxEase.backIn });
			FlxTween.tween(debugWatermark, { y: -debugWatermark.getHeight() }, 0.5, { ease: FlxEase.backIn });
		}

		new FlxTimer().start(0.5, (t)->{
			if (classData.isSubState) {
				openSubState(classData.target);
				persistentUpdate = true;
			} else {
				FlxG.switchState(classData.target);
			}
			// canSelect = true;
		});
	}

	public function setSelectionColor(hex) {
		menuData.items[curSelected].color = hex;
	}

	override function closeSubState() {
		super.closeSubState();
		if (!substateTrans) {
			substateTrans = true;
			return;
		}
		for (i in menuItems) {
			var prev = i.x;
			switch (menuAlignment) {
				case 'center':
					i.screenCenter(X);
				case 'left':
					i.x = 50;
				case 'right':
					i.x = FlxG.width - i.width - 50;
			}
			FlxTween.tween(i, { x: i.x }, 0.5, { ease: FlxEase.smootherStepOut, onComplete: (_)-> canSelect = true });
			i.x = prev;
		}
		FlxTween.tween(leftWatermark, { y: FlxG.height - leftWatermark.getHeight() - 5 }, 0.5, { ease: FlxEase.backOut });
		FlxTween.tween(debugWatermark, { y: 10 }, 0.5, { ease: FlxEase.backOut });
	}

}