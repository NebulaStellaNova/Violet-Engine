package violet.backend.shaders;

import violet.backend.objects.ModShader;

class AngleCropShader extends ModShader {

	public var angle(default, set):Float;
	function set_angle(value:Float) {
		this.setFloat("angle", value);
		return this.angle = value;
	}

	public var pivotY(default, set):Float;
	function set_pivotY(value:Float) {
		this.setFloat("pivotY", value);
		return this.pivotY = value;
	}

	public function new() {
		super("angleCrop");
		angle = -3.45;
		pivotY = 1;
	}

}