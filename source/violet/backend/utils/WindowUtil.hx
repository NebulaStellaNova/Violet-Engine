package violet.backend.utils;

import openfl.Lib;

class WindowUtil {
	public static var titleFull(default, set):String = '';
	public static var title(default, set):String = '';
	public static var prefix(default, set):String = '';
	public static var suffix(default, set):String = '';

	static function set_titleFull(value:String):String {
		titleFull = value;
		updateTitle();
		return titleFull;
	}

	static function set_title(value:String):String {
		title = value;
		@:bypassAccessor titleFull = prefix + title + suffix;
		updateTitle();
		return title;
	}
	static function set_prefix(value:String):String {
		prefix = value;
		@:bypassAccessor titleFull = prefix + title + suffix;
		updateTitle();
		return prefix;
	}
	static function set_suffix(value:String):String {
		suffix = value;
		@:bypassAccessor titleFull = prefix + title + suffix;
		updateTitle();
		return suffix;
	}

	static function updateTitle() Lib.application.window.title = titleFull;

}