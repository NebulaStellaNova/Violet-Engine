package backend.scripts;

import backend.filesystem.Paths;
using utils.ArrayUtil;

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
        for (line in rawLines) {
            var skip:Bool = false;
            var keys:Array<String> = ["def", "if", "else", "while", "try", "except"];
            var isF:Bool = false;
            for (key in keys) {
                if (StringTools.startsWith(StringTools.trim(line), key)) {
                    isF = true;
                }
            }
            if (funcCount != 0 && !(StringTools.startsWith(line, "\t") || StringTools.startsWith(line, "    "))) {
            //if (funcCount != 0 && isF) {
                funcCount--;
                finalString += "}\n";
                skip = true;
            }
            var lineSplit = StringTools.trim(line).split('');
            //trace(lineSplit);
            if (lineSplit[lineSplit.length-1] == ":") {
                funcCount++;
                var daFunc = StringTools.trim(line);
                daFunc = StringTools.replace(daFunc, "def", "function");
                daFunc = StringTools.replace(daFunc, ":", "{\n");
                finalString += daFunc;
            } else if (!skip && lineSplit != []) {
                var daLine = StringTools.trim(line);
                //daLine = StringTools.replace(daLine, "print(", "print(\"" + lineNumber + ": \" + ");
                if (daLine + ";\n" != ";\n") {
                    finalString += daLine + ";\n";
                }
            }
            lineNumber++;
        }

        finalString = StringTools.replace(finalString, "except", "catch");
        finalString = StringTools.replace(finalString, "#", "//");

		return finalString;
        //trace(finalString);
        //hscriptInterp.execute(new Parser().parseString(finalString));
    }
}