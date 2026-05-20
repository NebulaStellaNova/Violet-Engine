package violet.states.menus;

import flixel.math.FlxAngle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import violet.backend.options.Options;
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
	var scale:Float;
	var state:String;
	var disabled:Bool;
	var color:ParseColor;
	var animations:MenuAnimations;
	var ?transition:Bool;
}

typedef MenuData = {
	var directory:String;
	var background:String;
	var items:Array<MenuItem>;
}

enum abstract NovaMenuAlignment(String) from String {
	var LEFT = 'left';
	var RIGHT = 'right';

	@:from public static function fromFlxTextAlign(value:FlxTextAlign):NovaMenuAlignment {
		return switch (value) {
			case FlxTextAlign.LEFT: LEFT;
			case FlxTextAlign.RIGHT: RIGHT;
			default: LEFT;
		}
	}
	@:to public function toFlxTextAlign():FlxTextAlign {
		return switch (abstract) {
			case LEFT: FlxTextAlign.LEFT;
			case RIGHT: FlxTextAlign.RIGHT;
			default: FlxTextAlign.LEFT;
		}
	}
}

class MainMenu extends StateBackend {

	public var watermarkTexts = [
		'${Constants.ENGINE_TITLE} v${Constants.ENGINE_VERSION + (Constants.ENGINE_SUFFIX != '' ? '-${Constants.ENGINE_SUFFIX}' : '')}'
	];

	public var debugTexts = [
		'Commit: ${Constants.COMMIT_INDEX} (${Constants.COMMIT_HASH})',
		'Branch: ${Constants.GITHUB_BRANCH}'
	];

	public var reloadingText:NovaText;
	public var reloadingBG:NovaSprite;

	public static var fromReload:Bool = false;

	public static var curSelected:Int = 0;

	public var menuData:MenuData;

	public var bg:NovaSprite;

	public var menuItems:Array<NovaSprite> = [];
	public var itemsGroup:FlxTypedGroup<NovaSprite>;

	public var itemRadius(default, never):FlxPoint = new FlxPoint(350, 350);
	public var itemRadiusPosOffset:Float = -90;

	public var enableMobileControls:Bool = #if mobile true #else false #end;

	public var leftWatermark:NovaText;
	public var debugWatermark:NovaText;

	public var canSelect:Bool = true;

	public var substateTrans:Bool = true;

	public var menuAlignment(default, set):NovaMenuAlignment = LEFT;
	inline function set_menuAlignment(value:NovaMenuAlignment):NovaMenuAlignment {
		if (flower != null) {
			switch (value) {
				case LEFT: flower.x = -flower.width / 2;
				case RIGHT: flower.x = FlxG.width - (flower.width / 2);
			}
		}
		switch (value) {
			case LEFT: itemRadius.x = Math.abs(itemRadius.x);
			case RIGHT: itemRadius.x = Math.abs(itemRadius.x) * -1;
		}
		return menuAlignment = value;
	}
	public var watermarkAlignment(default, set):NovaMenuAlignment = RIGHT;
	inline function set_watermarkAlignment(value:NovaMenuAlignment):NovaMenuAlignment {
		if (leftWatermark != null) {
			leftWatermark.alignment = value;
			switch (value) {
				case LEFT: leftWatermark.x = 10;
				case RIGHT: leftWatermark.x = FlxG.width - leftWatermark.getWidth() - 5;
			}
		}
		if (debugWatermark != null) {
			debugWatermark.alignment = value;
			switch (value) {
				case LEFT: debugWatermark.x = 10;
				case RIGHT: debugWatermark.x = FlxG.width - debugWatermark.getWidth();
			}
		}
		return watermarkAlignment = value;
	}

	public var flower:NovaSprite;
	@:unreflective var flowerRotation:Float = 0;

	public static var instance:MainMenu;

	public static var doReload:Bool = false;

	public var fadeIn:Bool = true;

	override public function new() {
		instance = this;
		super();
	}

	override public function create()
	{
		super.create();
		instance = this;

		NovaUtils.playMenuMusic();

		menuData = ParseUtil.json('data/config/menuData');
		for (i in menuData.items) {
			i.transition ??= true;
			i.animations.offsets ??= {idle: [0, 0], selected: [0, 0]};
			i.animations.offsets.idle ??= [0, 0];
			i.animations.offsets.selected ??= [0, 0];
			#if mobile if (i.id == 'mods') menuData.items.remove(i); #end
		}

		bg = new NovaSprite(Paths.image('${menuData.directory}/${menuData.background}'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.scrollFactor.set();
		bg.color = menuData.items[curSelected].color;
		add(bg);

		var overlay:NovaSprite = new NovaSprite();
		overlay.setGraphicSize(FlxG.width, FlxG.height);
		overlay.color = FlxColor.BLACK;
		overlay.alpha = 0.25;
		overlay.scrollFactor.set();
		add(overlay);

		flower = new NovaSprite(Paths.image('${menuData.directory}/violet'));
		flower.screenCenter(Y);
		flower.scrollFactor.set(1);
		add(flower);

		itemsGroup = new FlxTypedGroup<NovaSprite>();
		for (i=>daItem in menuData.items) {
			var startY = (175*i)+90;
			var item = new NovaSprite(FlxG.width/2, startY, Paths.image('${menuData.directory}/${daItem.item}'));
			item.addAnim('selected', '${daItem.item} ${daItem.animations.selected}', [], daItem.animations?.offsets?.selected ?? [0, 0], 24, true);
			item.addAnim('static', '${daItem.item} ${daItem.animations.idle}', [], daItem.animations?.offsets?.idle ?? [0, 0], 24, true);
			item.playAnim('static');
			item.scale.scale(daItem.scale ?? 1);
			item.updateHitbox();
			item.centerOffsets();
			if (daItem.disabled) item.color = FlxColor.interpolate(item.color, FlxColor.BLACK, 0.25);
			menuItems.push(itemsGroup.add(item));
		}
		add(itemsGroup);

		leftWatermark = new NovaText(10, 'Nova Engine v0.1', 20);
		leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;
		leftWatermark.setFormat(Paths.font('vcr.ttf'), 40);
		leftWatermark.scrollFactor.set();
		leftWatermark.borderStyle = OUTLINE;
		leftWatermark.borderColor = FlxColor.BLACK;
		leftWatermark.borderSize = 3;
		leftWatermark.updateHitbox();
		add(leftWatermark);

		debugWatermark = new NovaText(10, 10, debugTexts.join('\n'), 20);
		debugWatermark.setFormat(Paths.font('vcr.ttf'), 40);
		debugWatermark.scrollFactor.set();
		debugWatermark.borderStyle = OUTLINE;
		debugWatermark.borderColor = FlxColor.BLACK;
		debugWatermark.borderSize = 3;
		debugWatermark.updateHitbox();
		add(debugWatermark);

		changeSelection(uiCheck());

		if (fadeIn) FlxG.camera.fade(FlxColor.BLACK, 0.25, true);

		#if debug
		DebugDisplay.registerVariable('Current Menu Item Index', () -> return curSelected);
		DebugDisplay.registerVariable('Current Menu Item', () -> return menuData.items[curSelected].item);
		DebugDisplay.registerVariable('Background Color', () -> return bg.color.toWebString());
		DebugDisplay.registerVariable('Can Select', () -> return canSelect);
		#end

		NovaUtils.playMenuMusic();

		reloadingBG = new NovaSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		reloadingBG.scrollFactor.set();
		add(reloadingBG);

		reloadingText = new NovaText('Reloading Mods...', Paths.font('Tardling v1.1'));
		reloadingText.size = 100;
		reloadingText.x = 20;
		reloadingText.y = FlxG.height - 50;
		reloadingText.updateHitbox();
		reloadingText.scrollFactor.set();
		add(reloadingText);

		reloadingBG.alpha = fromReload ? 1 : 0;
		reloadingText.alpha = fromReload ? 1 : 0;

		if (fromReload) {
			fromReload = false;

			FlxTween.tween(reloadingBG, { alpha: 0 }, 0.5);
			FlxTween.tween(reloadingText, { alpha: 0 }, 0.5);

			// FlxTimer.wait(0.1, ()->FlxTween.tween(reloadingCamera, { alpha: 0 }, 1, { ease: FlxEase.expoOut }));
			// fromReload = false;
		}

		callInScripts('postCreate');
	}

	inline function uiCheck() {
		if (!canSelect) return 0;
		if (Controls.uiUp) return -1;
		else if (Controls.uiDown) return 1;
		else return 0;
	}

	@:unreflective final _flower_midpoint:FlxPoint = FlxPoint.get();
	@:unreflective final _cur_cat_pos:FlxPoint = FlxPoint.get();
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (doReload) {
			doReload = false;
			FlxTween.tween(reloadingBG, { alpha: 1 }, 0.5);
			FlxTween.tween(reloadingText, { alpha: 1 }, 0.5);
			FlxTimer.wait(0.6, ()->{
				LoadingState.reloadEverything();
				var mm = new MainMenu();
				fadeIn = false;
				fromReload = true;
				FlxG.switchState(mm);
			});
		}
		// trace(Main.stateClassName);
		// trace(Main.subStateClassName);
		if (canSelect && (Controls.uiUp || Controls.uiDown))
			changeSelection(uiCheck());
		bg.color = MathUtil.colorLerp(bg.color, menuData.items[curSelected].color, 0.16);

		debugWatermark.visible = Options.data.developerMode;

		if (Controls.accept) {
			pickSelection();
		}

		var flowerTargetAngle = flowerRotation + Math.PI / 2 + FlxAngle.TO_RAD * itemRadiusPosOffset;
		flower.angle = lerp(flower.angle, -flowerTargetAngle * FlxAngle.TO_DEG, 0.2);

		for (index => item in menuItems) {
			var angle = (index / menuItems.length) * Math.PI * 2 - flowerTargetAngle;

			flower.getMidpoint(_flower_midpoint);
			var position = _cur_cat_pos.set(
				_flower_midpoint.x + FlxMath.fastCos(angle) * itemRadius.x,
				_flower_midpoint.y + FlxMath.fastSin(angle) * itemRadius.y
			);
			item.setPosition(
				lerp(item.x, position.x - (item.width / 2), 0.2),
				lerp(item.y, position.y - (item.height / 2), 0.2)
			);

			var configured = menuData.items[index].scale ?? 1;
			var target = (index == curSelected) ? configured * 1.12 : configured;
			item.scale.x = item.scale.y = lerp(item.scale.x, target * 0.7, 0.2);

			item.zIndex = Std.int(((FlxMath.fastSin(angle - flowerTargetAngle) + 1) / 2) * 1000);
		}


		if (Controls.back) {
			// Main.switchState(new ClassData('TitleState')); // Crashes idk why
		}

		var instance = watermarkTexts.copy();
		for (i in ModdingAPI.getActiveMods())
			instance.push('${i.title} v${i?.mod_version}');

		instance.sort(function(a, b):Int {
			if(a.length < b.length) return -1;
			else if(a.length > b.length) return 1;
			else return 0;
		});

		leftWatermark.text = instance.join('\n');
		leftWatermark.updateHitbox();
		if (canSelect) {
			leftWatermark.y = FlxG.height - leftWatermark.getHeight() - 5;
			debugWatermark.y = 10;
		}
		instance.resize(0);


		if (FlxG.keys.justPressed.SEVEN && Options.data.developerMode) {
			substateTrans = false;
			openSubState(new violet.states.debug.EditorPickerMenu());
		}

		if (!enableMobileControls) return;
		if (canSelect) {
			for (i => item in menuItems) {
				if (FlxG.mouse.overlaps(item) && FlxG.mouse.justPressed) {
					if (curSelected == i) pickSelection();
					else changeSelection(i - curSelected);
				}
			}
		}
	}

	public function changeSelection(amt:Int) {
		var totalAmt = amt;
		var target = FlxMath.wrap(curSelected + amt, 0, menuItems.length-1);
		while (menuData.items[target].disabled) {
			target = FlxMath.wrap(target + amt, 0, menuItems.length-1);
			totalAmt += amt;
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
			item.playAnim(i == curSelected ? 'selected' : 'static');
			item.updateHitbox();
			if (canSelect) {
				menuAlignment = menuAlignment;
				watermarkAlignment = watermarkAlignment;
			}
		}

		var step = (Math.PI * 2) / menuItems.length;
		flowerRotation += step * totalAmt;
	}

	public function pickSelection() {
		if (!canSelect) return;
		var event:SelectionEvent = runEvent('pickSelection', new SelectionEvent(curSelected));
		if (!event.soundCancelled) NovaUtils.playMenuSFX(CONFIRM);
		if (event.cancelled) return;

		canSelect = false;

		var classData = new ClassData(menuData.items[curSelected].state);

		if (classData.isSubState && menuData.items[curSelected].transition) {
			FlxTween.tween(bg, {x: FlxG.width - bg.width }, 0.5*2, { ease: FlxEase.smootherStepInOut });
			for (i in menuItems) {
				FlxTween.tween(i, { x: i.x - FlxG.width }, 0.5, { ease: FlxEase.smootherStepIn });
			}
			FlxTween.tween(leftWatermark, { y: FlxG.height }, 0.5, { ease: FlxEase.backIn });
			FlxTween.tween(debugWatermark, { y: -debugWatermark.getHeight() }, 0.5, { ease: FlxEase.backIn });
		}

		new FlxTimer().start(menuData.items[curSelected].transition ? 0.5 : 0.001, (t)->{
			if (classData.isSubState) {
				openSubState(classData.target);
				persistentUpdate = true;
			} else {
				FlxG.switchState(classData.target);
			}
			// canSelect = true;
		});
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
				case LEFT: i.x = 50;
				case RIGHT: i.x = FlxG.width - i.width - 50;
			}
			FlxTween.tween(i, { x: i.x }, 0.5, { ease: FlxEase.smootherStepOut, onComplete: (_)-> canSelect = true });
			i.x = prev;
		}
		FlxTween.tween(leftWatermark, { y: FlxG.height - leftWatermark.getHeight() - 5 }, 0.5, { ease: FlxEase.backOut });
		FlxTween.tween(debugWatermark, { y: 10 }, 0.5, { ease: FlxEase.backOut });
	}

	public function reloadMods() {
		doReload = true;
	}

}