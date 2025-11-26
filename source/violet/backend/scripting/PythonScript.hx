#if CAN_HAXE_SCRIPT

package violet.backend.scripting;

import violet.backend.filesystem.Paths;
import violet.backend.utils.FileUtil;
using violet.backend.utils.ArrayUtil;
using violet.backend.utils.StringUtil;

class PythonScript extends FunkinScript {


	public function new(path:String) {
		var filePath = path.split("/");
		this.fileName = filePath.pop();
		if (filePath.getFirstOf() == "mods") this.folderName = filePath[1];
		else this.folderName = filePath.getFirstOf();
        var code = "";
        for (i in violet.backend.filesystem.ModdingAPI.getActiveMods()) {
			if (Paths.fileExists('mods/${i.folder}/data/scripts/import.py', true))
				code += '\n' + FileUtil.getFileContent('mods/${i.folder}/data/scripts/import.py');
		}
        code += '\n' + FileUtil.getFileContent(path);
        trace(code);
		super(convertToHscript(code), true);
	}

	override public function initVars():Void {
		set('print', (value:Dynamic) -> violet.backend.console.Logs.traceCallback(value, internalScript.getInterp(rulescript.interps.RuleScriptInterp).posInfos()));
		set('True', true);
		set('False', true);
		super.initVars();
        set('NovaSprite', violet.backend.objects.NovaSprite.new);
	}

	public function convertToHscript(code) { // To be changed to work like my old lua one
        code = StringTools.replace(code, "    ", "\t");
        var rawLines:Array<String> = code.split('\n');
        rawLines.push("");
        var isTheFunction:Bool = false;
        var finalString:String = "";
        var lineNumber:Int = 1;
        var funcCount:Int = 0;
        for (i=>line in rawLines) {
            var skip:Bool = false;
            if (funcCount != 0 && !(StringTools.startsWith(line, "\t") || StringTools.startsWith(line, "    ") || StringTools.startsWith(rawLines[i+1], "\t") || StringTools.startsWith(rawLines[i+1], "    "))) {
                funcCount--;
                finalString += "}\n";
                skip = true;
            }
            var lineSplit = StringTools.trim(line).split('');
            if (lineSplit[lineSplit.length-1] == ":") {
                funcCount++;
                var daFunc:String = StringTools.trim(line);
                daFunc = daFunc.replaceOutsideString("def", "function");
                daFunc = daFunc.replaceOutsideString(":", "{\n");
                finalString += daFunc;
            } else if (!skip && lineSplit != []) {
                var daLine = StringTools.trim(line);
                if (daLine + ";\n" != ";\n") {
                    finalString += daLine + ";\n";
                }
            }
            lineNumber++;
        }

        finalString = finalString.replaceOutsideString("except", "catch");
        finalString = finalString.replaceOutsideString("#", "//");

		return finalString;
        //trace(finalString);
        //hscriptInterp.execute(new Parser().parseString(finalString));
    }
}

#end