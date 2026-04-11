package violet.backend.utils;

import lime.app.Application;
import openfl.system.Capabilities;

class ScreenUtil {

	public static var x(get, set):Int;
	static function get_x():Int return Application.current.window.x;
	static function set_x(v:Int):Int return Application.current.window.x = v;

	public static var y(get, set):Int;
	static function get_y():Int return Application.current.window.y;
	static function set_y(v:Int):Int return Application.current.window.y = v;

	public static var gameWidth(default, set):Int = 1280;
	public static var gameHeight(default, set):Int = 720;
	static function set_gameWidth(value:Int) {
		var previous = gameWidth;
		__resizeGame(value, gameHeight);
		return gameWidth = value;
	}
	static function set_gameHeight(value:Int) {
		var previous = gameHeight;
		__resizeGame(gameWidth, value);
		return gameHeight = value;
	}

	public static function setResolution(width:Float, height:Float) {
		gameWidth = Math.round(width);
		gameHeight = Math.round(height);
	}

	public static function screenCenter() {
		var screenWidth:Float = Capabilities.screenResolutionX;
		var screenHeight:Float = Capabilities.screenResolutionY;
		Application.current.window.x = Math.round((screenWidth - Application.current.window.width) / 2);
		Application.current.window.y = Math.round((screenHeight - Application.current.window.height) / 2);
	}

	@:unreflective static function __resizeGame(width:Int, height:Int) {
		@:privateAccess FlxG.game.resizeGame(width, height);

		@:privateAccess FlxG.width = width;
		@:privateAccess FlxG.height = height;
		@:privateAccess FlxG.initialWidth = width;
		@:privateAccess FlxG.initialHeight = height;
		@:privateAccess FlxG.initRenderMethod();
		@:privateAccess FlxG.bitmap.get_maxTextureSize();
		FlxG.resizeGame(width, height);

		for (camera in FlxG.cameras.list) {
			camera.width = width;
			camera.height = height;
		}

		var prev = Application.current.window.width;
		Application.current.window.width = width;
		Application.current.window.height = height;
		var min = Math.floor((prev - width)/2);
		var max = Math.ceil((prev - width)/2);
		Application.current.window.x += Math.round((min + max)/2);
	}

}