package violet.backend.shaders;

import violet.backend.objects.ModShader;

class RoundCornerShader extends ModShader {

	public var radius(default, set):Float;
	function set_radius(value:Float) {
		value = value < 0 ? 0 : value > 360 ? 360 : value;
		this.setFloat("_radius", value);
		return this.radius = value;
	}

	public function new() {
		super("roundCorners");
		radius = 25;
	}
}