package violet.boot;

typedef CursorParams = {
	graphic:String,
	scale:Float,
	offsetX:Int,
	offsetY:Int,
}

class HaxeUIHelper {
	public static function init() {
		haxe.ui.Toolkit.init();
		haxe.ui.Toolkit.theme = 'dark';
		haxe.ui.Toolkit.styleSheet.parse(".body, .label, .link, .textfield, .textarea { font-name: \"Inconsolata\"; font-size: 14px; font-bold: true; }");
		haxe.ui.Toolkit.autoScale = false;

		registerCursors();
	}

	public static final CURSOR_DEFAULT_PARAMS:CursorParams = {
		graphic: Paths.image("ui/cursor"),
		scale: 1.0,
		offsetX: 0,
		offsetY: 0,
	};
	static var assetCursorDefault:Null<openfl.display.BitmapData> = null;

	public static function registerCursors() {
		haxe.ui.backend.flixel.CursorHelper.useCustomCursors = true;
		registerCursor('default', CURSOR_DEFAULT_PARAMS);
		registerCursor('cross', CURSOR_DEFAULT_PARAMS);
		registerCursor('eraser', CURSOR_DEFAULT_PARAMS);
		registerCursor('grabbing', CURSOR_DEFAULT_PARAMS);
		registerCursor('hourglass', CURSOR_DEFAULT_PARAMS);
		registerCursor('pointer', CURSOR_DEFAULT_PARAMS);
		registerCursor('move', CURSOR_DEFAULT_PARAMS);
		registerCursor('text', CURSOR_DEFAULT_PARAMS);
		registerCursor('text-vertical', CURSOR_DEFAULT_PARAMS);
		registerCursor('zoom-in', CURSOR_DEFAULT_PARAMS);
		registerCursor('zoom-out', CURSOR_DEFAULT_PARAMS);
		registerCursor('crosshair', CURSOR_DEFAULT_PARAMS);
		registerCursor('cell', CURSOR_DEFAULT_PARAMS);
		registerCursor('scroll', CURSOR_DEFAULT_PARAMS);
	}

	public static function registerCursor(id:String, params:CursorParams):Void {
		haxe.ui.backend.flixel.CursorHelper.registerCursor(id, params.graphic, params.scale, params.offsetX, params.offsetY);
	}
}