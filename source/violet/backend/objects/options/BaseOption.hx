package violet.backend.objects.options;

import flixel.group.FlxGroup;

class BaseOption extends FlxGroup {

	public var selected:Bool = false;
	public var alphabet:Alphabet;

	public var color(default, set):FlxColor;
	function set_color(value:FlxColor) {
		for (i in alphabet.letters) {
			i.color = value;
		}
		return color = value;
	}

	public var centerX:Bool = false;

	public var title(default, set):String;
	function set_title(value:String) {
		alphabet.text = value;
		return title = value;
	}

	public var x(default, set):Float;
	function set_x(value:Float) return x = alphabet.x = value;
	public var y(default, set):Float;
	function set_y(value:Float) return y = alphabet.y = value;

	public var description:String;

	public function new(title:String, description:String = "") {
		super();

		alphabet = new Alphabet("");
		add(alphabet);

		this.title = title;
		this.description = title;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		this.alphabet.alpha = this.selected ? 1 : 0.5;
		updatePosition();
	}

	public function updatePosition() {}

	public var enabled:Bool = true;
	public function setEnabled(enabled:Bool) {
		this.color = enabled ? FlxColor.WHITE : FlxColor.interpolate(FlxColor.WHITE, FlxColor.BLACK, 0.5);
		this.enabled = enabled;
	}

}