package violet.data.converters;

import violet.backend.utils.FileUtil;
import violet.data.chart.ChartData;
import violet.backend.utils.ParseUtil;
import haxe.Json;
import Xml;

enum FileType {
    NONE;
    JSON;
    YAML;
    XML;
}

enum ChartFormat {
    CODENAME;
    PSYCH;
    LEGACY;
    VSLICE;
    VIOLET;
    IMAGINATIVE;
}

class ChartConverters {
    public static function convertChart(rawString:String):ChartData {
        var type:FileType = NONE;
        var parsedJsonCache:Dynamic = null;
        try {
            parsedJsonCache = Json.parse(ParseUtil.removeJsonComments(rawString));
            type = JSON;
        } catch (e:Dynamic) { /* Not a JSON. */ }
        try {
            if (!rawString.contains("</") || !rawString.contains(">")) throw "";
            type = XML;
        } catch (e:Dynamic) { /* Not a XML */ }
        // trace('debug:Chart is a $type file.');
        switch (type) {
            case JSON:
                var chartFormat:ChartFormat = detectJsonChartFormat(parsedJsonCache);
                return convertChartData(parsedJsonCache, chartFormat);
            default:
                return convertChartData("{}", CODENAME);
                // uhm... guys!
        }
    }

    public static function detectJsonChartFormat(parsedChart:Dynamic):ChartFormat {
        if (Reflect.getProperty(parsedChart, "codenameChart")) return CODENAME;
        return CODENAME;
    }

    public static function convertChartData(chart:Dynamic, from:ChartFormat):ChartData {
        switch (from) {
            case CODENAME:
                return chart;
            default:
                return new json2object.JsonParser<ChartData>().fromJson("{}");
        }
    }
}