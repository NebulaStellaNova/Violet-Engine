package violet.backend.utils;

class ZipUtil {

    /**
     * Near instantaneous zip extracting via sys commands :D
     */
    public static function extractZip(inputPath:String, outputPath:String):Void {
        #if windows
        var process = Sys.command("tar", ["-xf", inputPath, "-C", outputPath]);
        #else
        var process = Sys.command("unzip", [inputPath, "-d", outputPath]);
        #end
    }

    public static function getZipEntries(inputPath:String):Array<String> {
        #if windows
        Sys.command('tar -tf "$inputPath" > output.txt');
        var entries = FileUtil.getFileContent('output.txt').split('\n').filter(s -> s != "");
        for (i in 0...entries.length) entries[i] = entries[i].trim();
        sys.FileSystem.deleteFile('output.txt');
        return entries;
        #else
        // The echo for this on mac and linux is like SUPER extra and I don't feel like dealing with allat so someone else figure it out.
        return [];
        #end
    }
}