package violet.backend.shaders;

import violet.backend.objects.ModShader;

class ColorToAlphaShader extends ModShader {

	public var targetColor(default, set):FlxColor;
	function set_targetColor(value:FlxColor) {
		this.setFloatArray("targetColor", [value.red / 255, value.green / 255, value.blue / 255]);
		return this.targetColor = value;
	}

	public var threshold(default, set):Float;
	function set_threshold(value:Float) {
		this.setFloat("threshold", value);
		return this.threshold = value;
	}

	public var softness(default, set):Float;
	function set_softness(value:Float) {
		this.setFloat("softness", value);
		return this.softness = value;
	}

	public function new() {
		super("colorToAlpha");
		targetColor = FlxColor.WHITE;
		threshold = 0.3;
		softness = 0.3;
	}

}