package backend.console;

import haxe.Log;
import haxe.PosInfos;

enum abstract LogType(String) from String to String {
	var ErrorMessage = 'error';
	var WarningMessage = 'warning';
	var SystemMessage = 'system';
	var DebugMessage = 'debug';
	var LogMessage = 'log';
}

class Logs {
    public static var nativeTrace:(Dynamic, ?PosInfos)->Void;

    public static function init() {
        nativeTrace = Log.trace;
        Log.trace = (v, ?infos) -> {
            log(v, infos);
        }
    }

    public static function log(value:Dynamic, type:LogType = LogMessage, ?infos:PosInfos) {
        var fileSplit = infos.fileName.split("/");
        var fileName = fileSplit[fileSplit.length-1];
        var finalOut:String = '';
        var dataString:String = '[  ${fileName}:${infos.lineNumber}  ]';
        switch (type) {
            case ErrorMessage:
                finalOut +=       '${ConsoleColors.RED}[   ERROR   ] -> $dataString:${ConsoleColors.WHITE} $value';
            case WarningMessage:
                finalOut +=    '${ConsoleColors.YELLOW}[  WARNING  ] -> $dataString:${ConsoleColors.WHITE} $value';
            case SystemMessage:
                finalOut +=      '${ConsoleColors.BLUE}[    SYS    ] -> $dataString:${ConsoleColors.WHITE} $value';
            case DebugMessage:
                finalOut += '${ConsoleColors.DARKGREEN}[   DEBUG   ] -> $dataString:${ConsoleColors.WHITE} $value';
            default:
                finalOut +=      '${ConsoleColors.GRAY}[    LOG    ] -> $dataString:${ConsoleColors.WHITE} $value';
        }
        Sys.println(finalOut + ConsoleColors.WHITE);
    }
    
}