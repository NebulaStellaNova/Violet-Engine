package violet.data.converters;

import Reflect;

@:structInit @:publicFields class VSliceChart {
    var version:String;
    var scrollSpeed:Dynamic<Float>;
    var events:Array<Dynamic>;
    var notes:Array<Dynamic>;
}

@:structInit @:publicFields class CodenameEngineChart {
    var strumLines:Array<Dynamic>;
    var events:Array<Dynamic>;
    var stage:String;
    var scrollSpeed:Float;
    var noteTypes:Array<String>;
}

@:structInit @:publicFields class PsychEngineChart {
    var song:String;
    var notes:Array<Dynamic>;
    var events:Array<Dynamic>;
    var bpm:Float;
    var needsVoices:Bool;
    var speed:Float;
    var offset:Float;

    var player1:String;
    var player2:String;
    var gfVersion:String;
    var stage:String;
    var format:String;
}

enum abstract ChartFileFormat(String) {
    var CODENAME = "codename";
    var VSLICE = "vslice";
    var PSYCH = "psych";
    var UNKNOWN = "unknown";
}

class ChartFormatChecker {

    public static function checkFormat(parsedChartObject:Dynamic):ChartFileFormat {
        var isVSlice:Bool = true;
        var isCNE:Bool = true;
        var isPE:Bool = true;

        for (i in Type.getInstanceFields(PsychEngineChart)) {
            if (Reflect.field(parsedChartObject, i) == null) isPE = false;
        }
        if (isPE) return PSYCH;

        for (i in Type.getInstanceFields(CodenameEngineChart)) {
            if (Reflect.field(parsedChartObject, i) == null) isCNE = false;
        }
        if (isCNE) return CODENAME;

        for (i in Type.getInstanceFields(VSliceChart)) {
            if (Reflect.field(parsedChartObject, i) == null) isVSlice = false;
        }
        if (isVSlice) return VSLICE;

        return UNKNOWN;
    }
}