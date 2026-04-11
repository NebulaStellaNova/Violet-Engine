package violet.backend.objects.options;

class BoolOption extends BaseOption {

	public var checkbox:Checkbox;

	public dynamic function onChange(value:Bool) {}

	public function new(title:String, description:String = "") {
		super(title, description);

		checkbox = new Checkbox(alphabet.width + 10, 0, false);
		add(checkbox);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (selected && Controls.accept) {
			checkbox.value = !checkbox.value;
			onChange(checkbox.value);
		}
	}

	override function updatePosition() {
		super.updatePosition();

		checkbox.y = y + 3;
		checkbox.x = x + alphabet.width + 10;
		checkbox.alpha = alphabet.alpha;
	}

}

class Checkbox extends NovaSprite {

	public var value(default, set):Bool = false;
	function set_value(v:Bool) {
		playAnim(v ? 'selected' : 'deselected', true);
		return value = v;
	}

	public function new(x:Float = 0, y:Float = 0, value:Bool) {
		super(x, y, Paths.image("menus/optionsmenu/checkbox"));

		addAnim('selected', 'Check Box selecting animation', null, [-35, -29], 24, false);
		addAnim('deselected', 'Check Box deselect animation', null, [-25, 12], 24, false);

		this.globalOffset.y = -80;

		this.scale.set(0.75, 0.75);

		this.value = value;
		this.animation.finish();
	}

}