package backend.openfl;

import flixel.math.FlxPoint;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

class Framerate extends Sprite {

	public static var memoryCounter:MemoryCounter;

    public function new() {
        super();
		__addToList(memoryCounter = new MemoryCounter());
    }

    private var __lastAddedSprite:DisplayObject = null;
	private function __addToList(spr:DisplayObject) {
		spr.x = 0;
		spr.y = __lastAddedSprite != null ? (__lastAddedSprite.y + __lastAddedSprite.height) : 4;
		//spr.y += offset.y;
		__lastAddedSprite = spr;
		addChild(spr);
	}
    
}