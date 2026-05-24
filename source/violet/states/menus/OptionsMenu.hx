package violet.states.menus;

import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import violet.backend.SubStateBackend;
import violet.backend.objects.Alphabet;
import violet.backend.objects.options.BaseOption;
import violet.backend.objects.options.BoolOption;
import violet.backend.objects.options.ControlOption;
import violet.backend.objects.options.NumberOption;
import violet.backend.options.Options;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ParseUtil;

enum abstract OptionsType(String) {
	var SECTION = 'section';
	var BOOL = 'bool';
	var NUMBER = 'number';
	var CONTROL = 'control';
}

typedef OptionsData = {
	var menus:Array<OptionsMenuData>;
}

typedef OptionsMenuData = {
	var title:String;
	var ?description:String;
	var ?options:Array<OptionsMenuOption>;
	var ?saveID:String; // Used for modded options.
}

typedef OptionsMenuOption = {
	var name:String;
	var ?description:String;
	var saveID:String;
	var type:OptionsType;
	var ?platform:String; // Used to have platform specific settings
	var ?disabled:Bool;
	var ?disabledInPlayState:Bool;

	var ?conditions:Array<Condition>;
	// for number option
	var ?min:Float;
	var ?max:Float;
	var ?wrap:Bool;
	var ?step:Float;
	var ?replacer:Array<{what:Int, with:String}>;
	var ?allowHolding:Bool;
}

typedef Condition = {
	var id:String;
	var ?state:Dynamic;
}


class OptionsMenu extends SubStateBackend {

	public var optionsData:OptionsData = ParseUtil.jsonOrYaml('${Paths.ASSETS_FOLDER}/data/config/options', 'root');

	public var menus:Array<Alphabet> = [];
	public var options:Array<BaseOption> = [];

	public var isAMenuOpen:Bool = false;

	public var canSelectMenu:Bool = true;

	public var menuCurSelected:Int = 0;
	public var optionCurSelected:Int = 0;

	public var descriptionTxt:FlxText;
	public var descriptionBox:NovaSprite;

	public var optionsListOffset:Float = FlxG.width + 100;

	public var enableInput:Bool = true;

	public static var instance:OptionsMenu;

	public function getMenuByTitle(title:String):Null<OptionsMenuData> {
		for (menu in optionsData.menus) {
			if (menu.title == title) return menu;
		}
		return null;
	}

	override function create() {
		super.create();

		for (i in ModdingAPI.getActiveMods()) {
			var modOptions = ParseUtil.jsonOrYaml('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/config/options', 'root', 'null');
			if (modOptions != null) {
				for (i in (modOptions?.menus ?? [])) {
					if (getMenuByTitle(i.title) != null) {
						getMenuByTitle(i.title).options = getMenuByTitle(i.title).options.concat(i.options);
					} else {
						optionsData.menus.push(i);
					}
				}
			}
		}

		instance = this;
		for (menu in optionsData.menus) {
			for (optionData in menu.options) {
				var platformTargets = optionData.platform.replace(' ', '').split(',');
				for (platform in platformTargets)
					if (!NovaUtils.platformCheck(platform))
						menu.options.remove(optionData);
				if (optionData.disabledInPlayState && FlxG.state is PlayState)
					optionData.disabled = true;
			}
		}

		camera = new FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera, false);

		for (i=>menuData in optionsData.menus) {
			var alphabet:Alphabet = new Alphabet(menuData.title.toUpperCase());
			alphabet.screenCenter(X);
			alphabet.y += i * 100;
			menus.push(alphabet);
			add(alphabet);
			alphabet.x += FlxG.width;
			FlxTween.tween(alphabet, { x: alphabet.x-FlxG.width }, 1, { ease: FlxEase.expoOut });
		}

		descriptionBox = new NovaSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descriptionBox.scrollFactor.set();
		descriptionBox.visible = false;
		add(descriptionBox);

		descriptionTxt = new FlxText(0, 0, FlxG.width * 0.85, 'Test', 30);
		descriptionTxt.scrollFactor.set();
		descriptionTxt.font = Paths.font('vcr');
		descriptionTxt.antialiasing = false;
		descriptionTxt.alignment = CENTER;
		add(descriptionTxt);

		updateDesc({});
	}

	var menuOffset:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		for (i=>menu in menus) {
			menu.alpha = menuCurSelected == i ? 1 : 0.5;
		}

		var target = (menuCurSelected * 100) - (FlxG.height/2) + 50;
		menuOffset = lerp(menuOffset, target, 0.2);
		camera.scroll.y = isAMenuOpen ? 0 : menuOffset;

		if (Controls.uiUp && enableInput) options.length != 0 ? optionsScroll(-1) : menuScroll(-1);
		if (Controls.uiDown && enableInput) options.length != 0 ? optionsScroll(1) : menuScroll(1);

		for (i=>option in options) {
			option.x -= optionsListOffset;
			if (option.centerX) {
				option.x = (FlxG.width/2) - (option.alphabet.width/2);
			} else option.x = MathUtil.lerp(option.x, 50 - (Math.pow(Math.abs(i-optionCurSelected), 1.6) * 10), 0.2);

			option.y = MathUtil.lerp(option.y, (FlxG.height/2) + ((i-optionCurSelected) * 100) - (option.alphabet.height/2), 0.2);
			option.x += optionsListOffset;
			option.updatePosition();

			var data = optionsData.menus[menuCurSelected].options[i];
			if (data.conditions != null) {
				var enabled = true;
				for (i in data.conditions) {
					i.state ??= true;
					if (Reflect.field(Options.data, i.id) != i.state) enabled = false;
				}
				option.setEnabled(enabled);
			}
			optionsData.menus[menuCurSelected].options[i].disabled = !option.enabled;
		}

		if (options.length != 0 && enableInput) optionsScroll(0);

		if (Controls.accept && enableInput) {
			selectMenu();
		}

		if (Controls.back && enableInput) {
			enableInput = false;
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
		enableInput = false;
		for (i in menus) {
			FlxTween.tween(i, { y: i.y+FlxG.width }, 0.5, { ease: FlxEase.expoIn });
		}

		new FlxTimer().start(0.5, (_)->generateOptions());
	}

	function generateOptions() {
		for (i=>optionData in optionsData.menus[menuCurSelected].options) {
			switch (optionData.type) {
				case SECTION:
					var option:BaseOption = new BaseOption('${optionData.name}', optionData.description);
					option.x = optionsListOffset;
					option.centerX = true;
					option.y = (FlxG.height/2) + ((i-optionCurSelected) * 100) - (option.alphabet.height/2);
					option.updatePosition();
					insert(0, option);
					options.push(option);

				case BOOL:
					var option:BoolOption = new BoolOption(optionData.name, optionData.description);
					option.x = optionsListOffset;
					option.y = (FlxG.height/2) + ((i-optionCurSelected) * 100) - (option.alphabet.height/2);
					option.checkbox.value = Options.get(optionData.saveID) ?? false; option.checkbox.animation.finish();
					option.onChange = (value:Bool) -> set(optionData.saveID, value);
					option.updatePosition();
					option.setEnabled(!optionData.disabled);
					insert(0, option);
					options.push(option);

				case NUMBER:
					var option:NumberOption = new NumberOption('${optionData.name}:', optionData.description, optionData.min, optionData.max, optionData.step);
					option.allowHolding = optionData.allowHolding ?? true;
					option.wrap = optionData.wrap ?? false;
					option.x = optionsListOffset;
					option.y = (FlxG.height/2) + ((i-optionCurSelected) * 100) - (option.alphabet.height/2);
					option.value = Options.get(optionData.saveID) ?? 0;
					option.numberText.text = '< ${option.value} >';
					option.onChange = (value:Float) -> set(optionData.saveID, value);
					option.onChangePost = (value:Float) -> {
						for (i in (optionData?.replacer ?? [])) {
							if (value == i.what)
								option.numberText.text = option.numberText.text.replace('${i.what}', i.with);
						}
					}
					option.onChangePost(option.value);
					option.updatePosition();
					option.setEnabled(!optionData.disabled);
					insert(0, option);
					options.push(option);

				case CONTROL:
					var option:ControlOption = new ControlOption('${optionData.name}:', optionData.description);
					option.x = optionsListOffset;
					option.y = (FlxG.height/2) + ((i-optionCurSelected) * 100) - (option.alphabet.height/2);
					option.updatePosition();
					option.controlArray = Options.data.controls.exists(optionData.saveID) ? Options.data.controls.get(optionData.saveID).copy() : [];
					option.onChange = (value:Array<flixel.input.keyboard.FlxKey>) -> Options.data.controls.set(optionData.saveID, value);
					option.setEnabled(!optionData.disabled);
					insert(0, option);
					options.push(option);
			}
		}
		optionsScroll(0);
		enableInput = true;
		isAMenuOpen = true;
		FlxTween.tween(this, { optionsListOffset: 0 }, 0.5, { ease: FlxEase.expoOut });
	}

	inline function set(what, value:Dynamic) {
		Options.set(what, value);
		Options.flush();
	}

	function closeOptions() {
		for (i in options) {
			remove(i);
			i.destroy();
		}
		canSelectMenu = true;
		enableInput = true;
		options.resize(0);
		optionCurSelected = 0;
		isAMenuOpen = false;
		for (i in menus) {
			FlxTween.tween(i, { y: i.y-FlxG.width }, 0.5, { ease: FlxEase.expoOut });
		}
	}

	function exit() {
		for (alphabet in menus) {
			FlxTween.tween(alphabet, { x: alphabet.x+FlxG.width }, 0.5, { ease: FlxEase.quadIn });
		}
		new FlxTimer().start(0.5, (_)->close());
		if (Std.isOfType(_parentState, MainMenu)) FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut });
	}

	function menuScroll(amt) {
		menuCurSelected = FlxMath.wrap(menuCurSelected + amt, 0, menus.length-1);
		if (amt != 0) NovaUtils.playMenuSFX(SCROLL);
		updateDesc(optionsData.menus[menuCurSelected]);
	}

	function optionsScroll(amt) {
		optionCurSelected = FlxMath.wrap(optionCurSelected + amt, 0, options.length-1);
		while (optionsData.menus[menuCurSelected].options[optionCurSelected].type == SECTION || optionsData.menus[menuCurSelected].options[optionCurSelected].disabled) {
			optionCurSelected = FlxMath.wrap(optionCurSelected + (amt != 0 ? amt : 1), 0, options.length-1);
		}
		if (amt != 0) NovaUtils.playMenuSFX(SCROLL);
		for (i=>option in options) {
			option.selected = i == optionCurSelected || optionsData.menus[menuCurSelected].options[i].type == SECTION;
		}
		updateDesc(optionsData.menus[menuCurSelected].options[optionCurSelected]);
	}

	function updateDesc(data:Dynamic) {
		descriptionTxt.text = (data.description ?? '').replace('\\n', '\n');
		descriptionTxt.updateHitbox();
		descriptionTxt.screenCenter();
		descriptionTxt.y += FlxG.height * 0.35;

		descriptionBox.visible = descriptionTxt.text != '';
		descriptionBox.scale.set(descriptionTxt.width + 50, descriptionTxt.height + 50);
		descriptionBox.updateHitbox();
		descriptionBox.screenCenter();
		descriptionBox.alpha = 0.7;
		descriptionBox.y += FlxG.height * 0.35;
	}

	override function destroy() {
		super.destroy();
		Options.flush();
	}

}