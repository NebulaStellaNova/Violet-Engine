package violet.data.converters;

import Reflect;

typedef VSliceChart = {
    var version:String;
    var scrollSpeed:Map<String, Float>;
    var events:Array<Dynamic>;
    var notes:Array<Dynamic>;
}

typedef CodenameEngineChart = {
    var strumLines:Array<Dynamic>;
    var events:Array<Dynamic>;
    var stage:String;
    var scrollSpeed:Float;
    var noteTypes:Array<String>;
}

typedef PsychEngineChart = {
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
        var VSLICE_CHART:VSliceChart = parsedChartObject;
        var CNE_CHART:CodenameEngineChart = parsedChartObject;
        var PE_CHART:PsychEngineChart = parsedChartObject;

        var isVSlice:Bool = true;
        var isCNE:Bool = true;
        var isPE:Bool = true;

        for (i in Reflect.fields(PE_CHART)) {
            if (Reflect.field(PE_CHART, i) == null) isPE = false;
        }
        if (isPE) return CODENAME;

        for (i in Reflect.fields(CNE_CHART)) {
            if (Reflect.field(CNE_CHART, i) == null) isCNE = false;
        }
        if (isCNE) return CODENAME;

        for (i in Reflect.fields(VSLICE_CHART)) {
            if (Reflect.field(VSLICE_CHART, i) == null) isVSlice = false;
        }
        if (isVSlice) return VSLICE;

        return UNKNOWN;
    }
}