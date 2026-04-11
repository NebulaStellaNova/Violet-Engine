package violet.backend.shaders;

class AdjustColorShader extends FlxRuntimeShader {

	// TODO: Add getters.
	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;
	public var contrast(default, set):Float = 0;

	/**
	 * Y'know, the shit.
	 */
	public function new() {
		super(FileUtil.getFileContent(Paths.frag('adjustColor')));
		hue = 0;
		saturation = 0;
		brightness = 0;
		contrast = 0;
	}

	function set_hue(value:Float) {
		this.setFloat('hue', value);
		this.hue = value;

		return this.hue;
	}

	function set_saturation(value:Float) {
		this.setFloat('saturation', value);
		this.saturation = value;

		return this.saturation;
	}

	function set_brightness(value:Float) {
		this.setFloat('brightness', value);
		this.brightness = value;

		return this.brightness;
	}

	function set_contrast(value:Float) {
		this.setFloat('contrast', value);
		this.contrast = value;

		return this.contrast;
	}

}