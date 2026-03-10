package violet.data.converters;

import yaml.Renderer.RenderOptions;
import yaml.Parser.ParserOptions;
import yaml.Yaml;
import violet.data.chart.ChartRegistry.ChartCache;
import violet.backend.utils.FileUtil;
import violet.data.chart.ChartData;
import violet.backend.utils.ParseUtil;
import haxe.Json;
import Xml;
import yaml.Renderer;


enum FileType {
    NONE;
    YAML;
    XML;
    OBJECT;
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
    public static function convertChart(chartCache:ChartCache):ChartData {
        var type:FileType = NONE;
        var parsedCache:Dynamic = null;
        switch (chartCache.fileExt) {
            case "yaml":
			    final options = new ParserOptions(); options.maps = false;
                parsedCache = Yaml.parse(FileUtil.getFileContent(chartCache.filePath), options);
                type = OBJECT;
            case "json":
                parsedCache = Json.parse(FileUtil.getFileContent(chartCache.filePath));

                type = OBJECT;
        }
        // trace('debug:Chart is a $type file.');
        if (chartCache.fileExt != "yaml") {
            sys.FileSystem.deleteFile(chartCache.filePath);
            Yaml.write(chartCache.filePath.replace('.${chartCache.fileExt}', ".yaml"), convertChartData(parsedCache,  detectJsonChartFormat(parsedCache)));
        }

        var convertedChart:ChartData;
        switch (type) {
            case OBJECT:
                var chartFormat:ChartFormat = detectJsonChartFormat(parsedCache);
                convertedChart = convertChartData(parsedCache, chartFormat);
            default:
                convertedChart = convertChartData("{}", CODENAME);
                // uhm... guys!
        }

        if (chartCache.eventsPath != "") {
            final options = new ParserOptions(); options.maps = false;
            final parsedEvents = Yaml.parse(FileUtil.getFileContent(chartCache.eventsPath), options);
            convertedChart.events = convertedChart.events.concat(parsedEvents.events);
        }
        return convertedChart;

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

    public static function stringifyChart(chart:ChartData) {
        var out = {
            codenameChart: chart?.codenameChart ?? false,
            stage: chart?.stage ?? "mainStage",
            scrollSpeed: chart.scrollSpeed,
            noteTypes: [for (i in chart?.noteTypes ?? []) '$i']
        }
        return out;
    }
}