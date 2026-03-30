package violet.ui.freeplay;

import openfl.filters.BitmapFilter;
import violet.backend.utils.FileUtil;
import openfl.filters.BitmapFilterQuality;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxRuntimeShader;

class CapsuleText extends FlxSpriteGroup {


    public var blurredText:NovaText;

    public var whiteText:NovaText;

    public var text(default, set):Null<String>;

    public static var glowColor:FlxColor = 0xFF00ccff;

    public static var filters:Array<BitmapFilter>;

    public static function initFilters() {
        filters = [
            new openfl.filters.GlowFilter(glowColor, 1, 10, 10, 210, BitmapFilterQuality.MEDIUM),
            new openfl.filters.BlurFilter(3, 3, BitmapFilterQuality.LOW)
        ];
    }

    override public function new(x:Float, y:Float, text:String, size:Float) {
        super(x, y);
        initFilters();

        blurredText = new NovaText(0, 0, 0, text, Std.int(size));
		blurredText.setFont(Paths.font("5by7"));
        blurredText.updateHitbox();
        blurredText.antialiasing = true;
        blurredText.setGraphicSize(blurredText.width + 2, blurredText.height + 5);
        var shader:FlxRuntimeShader = new FlxRuntimeShader(FileUtil.getFileContent(Paths.frag("gaussianBlur")));
        shader.setFloat("_amount", 2);
        blurredText.shader = shader;
        whiteText = new NovaText(0, 0, 0, text, Std.int(size));
		whiteText.setFont(Paths.font("5by7"));
        whiteText.updateHitbox();
        whiteText.antialiasing = true;

        this.text = text;

        blurredText.color = glowColor;
        whiteText.color = 0xFFFFFFFF;
        add(blurredText);
        add(whiteText);
    }

    function set_text(value:String) {
        if (value == null) return value;
        if (blurredText == null || whiteText == null) {
            trace('WARN: Capsule not initialized properly');
            return text = value;
        }

        blurredText.text = value;
        blurredText.textField.filters = [filters[1]];
        blurredText.updateHitbox();
        whiteText.text = value;
        whiteText.textField.filters = filters;
        whiteText.updateHitbox();

        return text = value;
    }

}