package violet.backend.display;

import violet.backend.utils.MathUtil;
import openfl.display.BitmapData;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.FPS;

using flixel.util.FlxStringUtil;
using StringTools;
class DebugDisplay extends Sprite {

    public var background:Bitmap;
    public var background2:Bitmap;

    public var memoryCounter:TextField;
    public var fpsCounter:FPS;

    public var shown:Bool = false;

    public var memoryPeak:Float = 0.0;
    public var memoryCurrent(get, never):Float;

    @:noCompletion
    private function get_memoryCurrent():Float {
        return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
    }

    public function new() {
        super();

		addChild(fpsCounter = new FPS(10, -110, FlxColor.WHITE));

        background = new Bitmap(new BitmapData(1, 1, true, 0xFF3d3f41));
        background.x = 20;
        background.y = 20;
        background.alpha = 0.5;
        addChild(background);

        background2 = new Bitmap(new BitmapData(1, 1, true, 0xFF2c2f30));
        background2.x = 15;
        background2.y = 15;
        background2.alpha = 0.5;
        addChild(background2);

        memoryCounter = new TextField();
        memoryCounter.autoSize = LEFT;
        memoryCounter.x = memoryCounter.y = 30;
		memoryCounter.defaultTextFormat = new TextFormat('Monsterrat', 18, FlxColor.WHITE);
		memoryCounter.width = FlxG.width;
        memoryCounter.mouseEnabled = memoryCounter.selectable = false;
        memoryCounter.sharpness = 0;
		addChild(memoryCounter);
    }

    override public function __enterFrame(e) {
        super.__enterFrame(e);

        if(memoryPeak < memoryCurrent)
            memoryPeak = memoryCurrent;

        memoryCounter.text = "Framerate: " + fpsCounter.text.replace("FPS: ", "") + '\nMemory: ${memoryCurrent.formatBytes()} / ${memoryPeak.formatBytes()}';

        background.width = memoryCounter.width + 21;
        background.height = memoryCounter.height + 21;

        background2.width = background.width + 10;
        background2.height = background.height + 10;

        background.x = MathUtil.lerp(background.x, shown ? 20 : - background.width - 50, 0.1);

        background2.x = background.x - 5;
        memoryCounter.x = background.x + 10;
        memoryCounter.y = background.y + 10;

        if (Controls.debugDisplay) shown = !shown;
    }

}