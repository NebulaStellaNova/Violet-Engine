package violet.backend.console;

import haxe.Log;
import haxe.PosInfos;

enum abstract ConsoleColors(String) from String to String {
	var RESET =         '\033[0m';

	var BLACK =         '\x1b[30m';
	var DARKRED =       '\x1b[31m';
	var DARKGREEN =     '\x1b[32m';
	var DARKYELLOW =    '\x1b[33m';
	var ORANGE =        '\x1b[33m';
	var DARKBLUE =      '\x1b[34m';
	var PURPLE =        '\x1b[35m';
	var DARKMAGENTA =   '\x1b[35m';
	var DARKCYAN =      '\x1b[36m';
	var LIGHTGRAY =     '\x1b[37m';
	var GRAY =          '\x1b[90m';
	var RED =           '\x1b[91m';
	var GREEN =         '\x1b[92m';
	var YELLOW =        '\x1b[93m';
	var BLUE =          '\x1b[94m';
	var MAGENTA =       '\x1b[95m';
	var CYAN =          '\x1b[96m';
	var WHITE =         '\x1b[97m';

	public static final colorList = {
		var lol = flixel.system.macros.FlxMacroUtil.buildMap('violet.backend.console.ConsoleColors');
		for (variable in Type.getClassFields(Logs))
			if (variable.endsWith('_COLOR'))
				lol.set(variable.split('_')[0], Reflect.getProperty(Logs, variable));
		lol;
	}

	public static function formatString(string:String):String {
		string = string.replace('lua:0', 'lua:?');
		for (name => color in colorList) {
			for (name in [name, name.toLowerCase()]) {
				string = string.replace('#$name', color);
				string = string.replace('$' + name, color);
				string = string.replace('<$name>', color);
			}
		}
		return string;
	}
}

enum abstract LogType(String) from String to String {
	var ErrorMessage = 'error';
	var WarningMessage = 'warning';
	var SystemMessage = 'system';
	var DebugMessage = 'debug';
	var LogMessage = 'log';
}

class Logs {

	public static var WARNING_COLOR:ConsoleColors = YELLOW;
	public static var SYSTEM_COLOR:ConsoleColors = BLUE;
	public static var ERROR_COLOR:ConsoleColors = RED;
	public static var DEBUG_COLOR:ConsoleColors = GREEN;
	public static var LOG_COLOR:ConsoleColors = LIGHTGRAY;

	public static var nativeTrace:(Dynamic, ?PosInfos)->Void;

	public static var traceCallback:(v:Dynamic, ?infos:Null<PosInfos>)->Void = (v:Dynamic, ?infos:PosInfos) -> {
		var type = LogMessage;
		if (v is String) {
			var res = v + '';
			if (res.startsWith('error:')) {
				type = ErrorMessage;
				res = res.substr(6);
			} else if (res.startsWith('warning:')) {
				type = WarningMessage;
				res = res.substr(8);
			} else if (res.startsWith('sys:')) {
				type = SystemMessage;
				res = res.substr(4);
			} else if (res.startsWith('system:')) {
				type = SystemMessage;
				res = res.substr(7);
			} else if (res.startsWith('debug:')) {
				type = DebugMessage;
				res = res.substr(6);
			} else if (res.startsWith('log:')) {
				res = res.substr(4);
			}
			v = res;
		}
		log(v, type, infos);
	}

	public static function init() {
		nativeTrace = Log.trace;
		Log.trace = traceCallback;
		Sys.println('\n-----------------------------------------------------------------------------');
		trace(  'error:Error Message           (tag = "error:"  )');
		trace('warning:Warning Message         (tag = "warning:")');
		trace(    'sys:System Message          (tag = "sys:"    )');
		trace( 'system:System Message (alt)    (tag = "system:" )');
		trace(  'debug:Debug Message           (tag = "debug:"  )');
		trace(    'log:Log Message (default)   (tag = "log:"    )');
		Sys.println('-----------------------------------------------------------------------------\n');
	}

	public static function log(value:Dynamic, type:LogType = LogMessage, ?infos:PosInfos) {
		var fileSplit = infos.fileName.split('/');
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
		Sys.println(ConsoleColors.formatString(finalOut) + ConsoleColors.RESET);
	}

}