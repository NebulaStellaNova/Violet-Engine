package violet.backend.utils;

import sys.thread.Thread;
import sys.io.FileInput;
import sys.io.File;

/**
 * This is ONLY used for the ModdingAPI's temp folders, this is also INTENTIONALLY not allowed to be used by scripting.
*/
class FileLocker {

	@:unreflective
	public static function lockFile(path:String):Void {
        var os = Sys.systemName();
        switch (os) {
            case "Windows":
                _run("icacls", [path, "/deny", "Everyone:(D,W)"]);
            case "Mac":
                _run("chflags", ["uchg", path]);
            case "Linux":
                _run("chmod", ["a-w", path]);
        }
    }

	@:unreflective
    public static function unlockFile(path:String):Void {
        var os = Sys.systemName();
        switch (os) {
            case "Windows":
                _run("icacls", [path, "/remove:d", "Everyone"]);
            case "Mac":
                _run("chflags", ["nouchg", path]);
            case "Linux":
                _run("chmod", ["a+w", path]);
        }
    }

	@:unreflective
	private static function _run(command:String, args:Array<String>) {
		args ??= [];
		args.insert(0, command);
		@:privateAccess NovaUtils._runHidden(args.join(' '));
	}

}