package backend.scripts;

import backend.filesystem.Paths;
using utils.ArrayUtil;
using utils.StringUtil;

class PythonScript extends FunkinScript {


	public function new(path:String) {
		var filePath = path.split("/");
		this.fileName = filePath.pop();
		if (filePath.getFirstOf() == "mods") this.folderName = filePath[1];
		else this.folderName = filePath.getFirstOf();
		super(convertToHscript(Paths.readStringFromPath(path)), true);
	}

	override public function initVars():Void {
		set('print', (value:Dynamic) -> log(value, internalScript.interp.posInfos()));
		set('True', true);
		set('False', true);
		super.initVars();
	}

	public function convertToHscript(code) { // To be changed to work like my old lua one
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