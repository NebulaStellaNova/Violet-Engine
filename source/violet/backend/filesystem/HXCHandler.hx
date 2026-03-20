package violet.backend.filesystem;
import violet.backend.utils.FileUtil;
import violet.backend.scripting.ScriptPack;

class HXCHandler extends flixel.FlxBasic {
    public static var instance:HXCHandler;

	public var hxcScripts:ScriptPack = new ScriptPack();
    public var clear:Void->Void;

    public var importRedirects:Map<String, String> = [
        "funkin.modding.module.Module" => "violet.backend.scripting.hxc.Module"
    ];

    public function addScript(path:String) {
        var scriptCode:String = FileUtil.getFileContent(path);
        for (i in importRedirects.keys()) {
            scriptCode = scriptCode.replace(i, importRedirects.get(i));
        }


        hxcScripts.addScript(new violet.backend.scripting.FunkinScript(scriptCode, true, true));
    }

    override public function new() {
        super();
        clear = hxcScripts.clear;
        instance = this;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}