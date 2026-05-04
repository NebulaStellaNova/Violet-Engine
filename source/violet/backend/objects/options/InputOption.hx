package violet.backend.objects.options;

import violet.states.menus.OptionsMenu;

class InputOption extends BaseOption {

	public var field:Alphabet;
	public var typeInField:Alphabet;

	public var bg:FlxSprite;

	override public function new(a, b) {
		super(a, b);

		field = new Alphabet('', false);
		field.x = alphabet.width + 40;
		add(field);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.5;
		add(bg);

		typeInField = new Alphabet('');
		typeInField.x = alphabet.width + 40;
		typeInField.visible = false;
		add(typeInField);
	}

	public dynamic function onChange(value:String) {}

	public var open:Bool = false;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER) {
			open = !open;
			OptionsMenu.instance.enableInput = !open;
			typeInField.visible = open;
			if (open) {
				typeInField.text = field.text;
			} else {
				typeInField.text = typeInField.text.trim();
				field.text = typeInField.text;
				onChange(typeInField.text);
			}
		}


		bg.alpha = open ? 0.5 : 0;
		if (selected) OptionsMenu.instance.descriptionTxt.alpha = open ? 0.5 : 1;

		if (open) {
			var blacklist = ["NONE", "ANY", "keyManager", "status", "BACKSPACE", "ENTER", "SHIFT"];
			for (i in Reflect.fields(FlxG.keys.justPressed)) {
				if (blacklist.contains(i)) continue;
				if (FlxG.keys.anyJustPressed([i])) {
					var alias = [
						"ONE" => "1", "TWO" => "2", "THREE" => "3", "FOUR" => "4", "FIVE" => "5", "SIX" => "6", "SEVEN" => "7", "EIGHT" => "8", "NINE" => "9",
						"MINUS" => FlxG.keys.pressed.SHIFT ? "_" : "-",
						"SPACE" => " ",
						"PERIOD" => FlxG.keys.pressed.SHIFT ? ">" : ".",
					];
					var out = alias.get(i) ?? i;
					typeInField.text += FlxG.keys.pressed.SHIFT ? out.toUpperCase() : out.toLowerCase();
				}
			}
			if (FlxG.keys.justPressed.BACKSPACE) {
				typeInField.text = typeInField.text.substr(0, typeInField.text.length-1);
			}
		}

		typeInField.screenCenter();
	}

	override function updatePosition() {
		super.updatePosition();

		field.y = y + 3;
		field.x = x + alphabet.width + 40;
		field.alpha = alphabet.alpha;
	}
}