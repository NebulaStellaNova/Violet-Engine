package violet.backend.shaders;

import violet.backend.objects.ModShader;

class OutlineExtractionShader extends ModShader {

	public var sentivity(default, set):Float;
	function set_sentivity(value:Float):Float {
		this.setFloat('cutOffLimit', value);
		return this.sentivity = value;
	}

	public function new() {
		super("outlineExtractionShader");
		sentivity = 0.3;
	}

}