package violet.backend.objects.options;

class NumberOption extends BaseOption {

	public var value:Float = 0;
	var min:Null<Float>;
	var max:Null<Float>;
	var step:Float;

	public var numberText:Alphabet;

	public dynamic function onChange(value:Float) {}
	public dynamic function onChangePost(value:Float) {}

	public function new(title:String, description:String = "", ?min:Float, ?max:Float, step:Float = 1) {
		super(title, description);
		this.min = min;
		this.max = max;
		this.step = step;

		numberText = new Alphabet('< ? >', false);
		numberText.x = alphabet.width + 40;
		add(numberText);
	}

	var time:Float = 0;
	var usePress:Bool = false;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.uiLeftPress || Controls.uiRightPress)
			time += elapsed;
		if (time > 0.5)
			usePress = true;

		if (selected) {
			if (usePress ? (Controls.uiLeftPress && time % 0.3 > 0.05) : Controls.uiLeft) {
				value -= step;
				if (min != null) value = Math.max(min, value);
				value = Math.round(value/step)*step;
				onChange(value); numberText.text = '< $value >';
				onChangePost(value);
			} else if (usePress ? (Controls.uiRightPress && time % 0.3 > 0.05) : Controls.uiRight) {
				value += step;
				if (max != null) value = Math.min(max, value);
				value = Math.round(value/step)*step;
				onChange(value); numberText.text = '< $value >';
				onChangePost(value);
			}
		}

		if (Controls.uiLeftReleased || Controls.uiRightReleased) {
			time = 0;
			usePress = false;
		}
	}

	override function updatePosition() {
		super.updatePosition();

		numberText.y = y + 3;
		numberText.x = x + alphabet.width + 40;
		numberText.alpha = alphabet.alpha;
	}

}