package violet.backend.objects;

import violet.backend.utils.FileUtil;
import flixel.addons.display.FlxRuntimeShader;

class ModShader extends FlxRuntimeShader {
    override public function new(id:String) {
        super(FileUtil.getFileContent(Paths.frag(id)));
    }

    /* public function set(what:String, value:Dynamic) {
        if (value is Int) {
            setInt(what, value);
        } else if (value)
    } */
}