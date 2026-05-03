package violet.backend.shaders;

import violet.backend.objects.ModShader;

class GaussianBlurShader extends ModShader {

	public var intensity(default, set):Float;
	function set_intensity(value:Float):Float {
		setFloat("intensity", value);
		return intensity = value;
	}

	public var quality(default, set):Float;
	function set_quality(value:Float):Float {
		setFloat("quality", value);
		return quality = value;
	}

	public function new(intensity:Float = 1.0) {
		super("gaussianBlur");
		this.intensity = intensity;
		this.quality = 12;
	}

}