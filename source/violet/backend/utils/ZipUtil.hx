package violet.backend.utils;

class ZipUtil {
    /**
     * Near instantaneous zip extracting via sys commands :D
     */
    public static function extractZip(inputPath:String, outputPath:String):Void {
        #if windows Sys.command("tar", ["-xf", inputPath, "-C", outputPath]);
        #else Sys.command("unzip", [inputPath, "-d", outputPath]); #end
    }
}