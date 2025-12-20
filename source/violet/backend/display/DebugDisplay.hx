package violet.backend.display;

import flixel.math.FlxMath;
import hxhardware.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;

using flixel.util.FlxStringUtil;

class DebugDisplay extends Sprite {
	public var background:Bitmap;
	public var background2:Bitmap;

	public var text:TextField;

	public var shown:Bool = false;

	public function new() {
		super();
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

		text = new TextField();
		text.autoSize = LEFT;
		text.x = text.y = 10;
		text.defaultTextFormat = new TextFormat('Monsterrat', 18, FlxColor.WHITE);
		text.width = FlxG.width;
		text.mouseEnabled = text.selectable = false;
		text.sharpness = 0;
		addChild(text);

		background.x = -FlxG.width;
		background2.x = -FlxG.width;
		text.x = -FlxG.width;
		text.y = -FlxG.width;

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	var framesPerSecond:Int = 0;
	var _framesPassed:Int = 0;
	var _previousTime:Float = 0;
	var _updateClock:Float = 999999;

	function onEnterFrame(e:Event) {
		_framesPassed++;

		final deltaTime:Float = Math.max(NovaUtils.getTimerPrecise() - _previousTime, 0);
		_updateClock += deltaTime;

		if (_updateClock >= 1000) {
			framesPerSecond = (FlxG.drawFramerate > 0) ? FlxMath.minInt(_framesPassed, FlxG.drawFramerate) : _framesPassed;
			text.text = 'Framerate: $framesPerSecond\nMemory: ${Memory.getProcessPhysicalMemoryUsage().formatBytes()} / ${Memory.getProcessPeakPhysicalMemoryUsage().formatBytes()}\nCPU: ${FlxMath.roundDecimal(CPU.getProcessCPUUsage(), 2)}% / ${FlxMath.roundDecimal(CPU.getProcessPeakCPUUsage(), 2)}%';
			_framesPassed = 0;
			_updateClock = 0;
		}
		_previousTime = NovaUtils.getTimerPrecise();

		background.width = text.width + 21;
		background.height = text.height + 21;

		background2.width = background.width + 10;
		background2.height = background.height + 10;

		background.x = MathUtil.lerp(background.x, shown ? 20 : - background.width - 50, 0.1);

		background2.x = background.x - 5;
		text.x = background.x + 10;
		text.y = background.y + 10;

		if (Controls.debugDisplay)
			shown = !shown;
	}
}