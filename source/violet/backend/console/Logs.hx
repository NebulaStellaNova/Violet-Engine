package violet.backend.console;

import haxe.Log;
import haxe.PosInfos;

@:publicFields
class ConsoleColors {
	static var RESET =         "\033[0m";

	static var BLACK =         "\x1b[30m";
	static var DARKRED =       "\x1b[31m";
	static var DARKGREEN =     "\x1b[32m";
	static var DARKYELLOW =    "\x1b[33m";
	static var ORANGE =        "\x1b[33m";
	static var DARKBLUE =      "\x1b[34m";
	static var PURPLE =        "\x1b[35m";
	static var DARKMAGENTA =   "\x1b[35m";
	static var DARKCYAN =      "\x1b[36m";
	static var LIGHTGRAY =     "\x1b[37m";
	static var GRAY =          "\x1b[90m";
	static var RED =           "\x1b[91m";
	static var GREEN =         "\x1b[92m";
	static var YELLOW =        "\x1b[93m";
	static var BLUE =          "\x1b[94m";
	static var MAGENTA =       "\x1b[95m";
	static var CYAN =          "\x1b[96m";
	static var WHITE =         "\x1b[97m";
}

enum abstract LogType(String) from String to String {
	var ErrorMessage = 'error';
	var WarningMessage = 'warning';
	var SystemMessage = 'system';
	var DebugMessage = 'debug';
	var LogMessage = 'log';
}

class Logs {
	public static var WARNING_COLOR:String = ConsoleColors.YELLOW;
	public static var SYSTEM_COLOR:String = ConsoleColors.BLUE;
	public static var ERROR_COLOR:String = ConsoleColors.RED;
	public static var DEBUG_COLOR:String = ConsoleColors.GREEN;
	public static var LOG_COLOR:String = ConsoleColors.LIGHTGRAY;

	public static var nativeTrace:(Dynamic, ?PosInfos)->Void;

	public static function init() {
		nativeTrace = Log.trace;
		Log.trace = (v, ?infos) -> {
			var type = LogMessage;
			if (v is String) {
				var res = v + "";
				if (res.startsWith("error:")) {
					type = ErrorMessage;
					res = res.substr(6);
				} else if (res.startsWith("warning:")) {
					type = WarningMessage;
					res = res.substr(8);
				} else if (res.startsWith("sys:")) {
					type = SystemMessage;
					res = res.substr(4);
				} else if (res.startsWith("system:")) {
					type = SystemMessage;
					res = res.substr(7);
				} else if (res.startsWith("debug:")) {
					type = DebugMessage;
					res = res.substr(6);
				} else if (res.startsWith("log:")) {
					res = res.substr(4);
				}
				v = res;
			}
			log(v, type, infos);
		}

		trace(  "error:Error Message           (tag = 'error:'  )");
		trace("warning:Warning Message         (tag = 'warning:')");
		trace(    "sys:System Message          (tag = 'sys:'    )");
		trace( "system:System Message (alt)    (tag = 'system:' )");
		trace(  "debug:Debug Message           (tag = 'debug:'  )");
		trace(    "log:Log Message (default)   (tag = 'log:'    )");
	}

	public static function log(value:Dynamic, type:LogType = LogMessage, ?infos:PosInfos) {
		var fileSplit = infos.fileName.split("/");
		var fileName = fileSplit[fileSplit.length-1];
		var finalOut:String = '';
		var dataString:String = '[  ${fileName}:${infos.lineNumber}  ]';
		switch (type) {
			case ErrorMessage:
				finalOut +=   '${ERROR_COLOR}[   ERROR   ] -> $dataString:${ConsoleColors.RESET} $value';
			case WarningMessage:
				finalOut += '${WARNING_COLOR}[  WARNING  ] -> $dataString:${ConsoleColors.RESET} $value';
			case SystemMessage:
				finalOut +=  '${SYSTEM_COLOR}[    SYS    ] -> $dataString:${ConsoleColors.RESET} $value';
			case DebugMessage:
				finalOut +=   '${DEBUG_COLOR}[   DEBUG   ] -> $dataString:${ConsoleColors.RESET} $value';
			default:
				finalOut +=     '${LOG_COLOR}[    LOG    ] -> $dataString:${ConsoleColors.RESET} $value';
		}
		Sys.println(formatString(finalOut) + ConsoleColors.RESET);
	}

	public static function formatString(string:String):String {
		for (field in Type.getClassFields(ConsoleColors)) {
			string = string.replace("#" + field.toLowerCase(), Reflect.getProperty(ConsoleColors, field));
			string = string.replace("#" + field, Reflect.getProperty(ConsoleColors, field));
			string = string.replace("$" + field.toLowerCase(), Reflect.getProperty(ConsoleColors, field));
			string = string.replace("$" + field, Reflect.getProperty(ConsoleColors, field));
		}
		return string;
	}
}