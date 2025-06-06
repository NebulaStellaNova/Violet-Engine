package backend.objects;

import flixel.text.FlxText;

class NovaText extends FlxText {
    public var upscaleResolution:Float = 1;

    public function new(x:Float, y:Float, fieldWidth:Float = 0, text:String, size:Int = 8, ?font:String) {
        var scaleFactor:Float = (upscaleResolution*2);
        fieldWidth *= cast scaleFactor; 
        super(x, y, fieldWidth*scaleFactor, text, Math.floor(size*scaleFactor));
        this.scale.set(1/scaleFactor, 1/scaleFactor);
        this.updateHitbox();
        if (font != null) {
            this.setFormat(font);
        }
    }

    public function getWidth() {
        return this.frameWidth / (upscaleResolution*2);
    }

    public function getHeight() {
        return this.frameHeight / (upscaleResolution*2);
    }
} 