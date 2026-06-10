package violet.backend.objects;

import flixel.text.FlxText;

class NovaText extends FlxText {

	public var upscaleResolution:Float;

	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, upscaleRes:Float = 1, ?font:String) {
		upscaleResolution = upscaleRes;

		var scaleFactor:Float = (upscaleResolution*2);
		fieldWidth *= scaleFactor;
		super(x, y, fieldWidth*scaleFactor, text, Math.floor(size*scaleFactor));
		this.scale.set(1/scaleFactor, 1/scaleFactor);
		this.updateHitbox();
		if (font != null) this.font = font;
	}

	inline public function getWidth(mult:Float = 1) {
		return (this.frameWidth / (upscaleResolution*2))*mult;
	}

	inline public function getHeight(mult:Float = 1) {
		return (this.frameHeight / (upscaleResolution*2))*mult;
	}

}