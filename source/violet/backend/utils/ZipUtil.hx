package violet.backend.utils;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.zip.Reader;
import haxe.io.Path;
import cpp.Native;
@:cppFileCode('
	#include <windows.h>
	#include <stdio.h>
')
class ZipUtil {

	/**
	 * Near instantaneous zip extracting via sys commands :D
	 */
	public static function extractZip(inputPath:String, outputPath:String):Void {
		#if windows
		NovaUtils.runHiddenCommand("tar", ["-xf", inputPath, "-C", outputPath]);
		#else
		NovaUtils.runHiddenCommand("unzip", [inputPath, "-d", outputPath]);
		#end
	}

	public static function getZipEntries(inputPath:String):Array<String> {
		#if windows
		var process = new sys.io.Process('tar -tf "$inputPath"');
		var output = process.stdout.readAll().toString();
		var errors = process.stderr.readAll().toString();
		var code = process.exitCode();
		process.close();

		var entries = output.split('\n').filter(s -> s != "");
		for (i in 0...entries.length) entries[i] = entries[i].trim();
		return entries;
		#else
		// The echo for this on mac and linux is like SUPER extra and I don't feel like dealing with allat so someone else figure it out.
		return [];
		#end
	}

}