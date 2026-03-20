package violet.data.converters;

import moonchart.formats.fnf.legacy.FNFPsych;
import moonchart.formats.fnf.FNFVSlice;
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
import moonchart.formats.fnf.FNFCodename;


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

    public static var blankChart(get, never):ChartData;
    static function get_blankChart() {
        return {
            strumLines: [],
            events: [],
            meta: { name: "Unknown Song" },
            scrollSpeed: 1,
            noteTypes: [],
            stage: "default",
            codenameChart: true
        };
    }

    public static function convertChart(chartCache:ChartCache):ChartData {
        var parsedCache:Dynamic = parseFromCache(chartCache);
        var detectedFormat:ChartFormatChecker.ChartFileFormat = ChartFormatChecker.checkFormat(parsedCache);
        var convertedChart:ChartData;
        switch (detectedFormat) {
            case CODENAME:
                convertedChart = parsedCache;
            case VSLICE:
                convertedChart = fromVSlice(chartCache.filePath, chartCache.difficulty);
            case PSYCH:
                convertedChart = fromPsych(chartCache.filePath);
            default:
                convertedChart = blankChart;
        }

        if (chartCache.eventsPath != "") {
            final options = new ParserOptions(); options.maps = false;
            final parsedEvents = Yaml.parse(FileUtil.getFileContent(chartCache.eventsPath), options);
            convertedChart.events ??= [];
            for (i in parsedEvents.events ?? []) {
                convertedChart.events.push(i);
            }
        }

        return convertedChart;
    }

    public static function parseFromCache(chartCache:ChartCache):Dynamic {
        var parsedCache:Dynamic = {};
        switch (chartCache.fileExt) {
            case "yaml":
			    final options = new ParserOptions(); options.maps = false;
                parsedCache = Yaml.parse(FileUtil.getFileContent(chartCache.filePath), options);
            case "json":
                parsedCache = Json.parse(FileUtil.getFileContent(chartCache.filePath));
        }
        return parsedCache;
    }

    public static function fromVSlice(chartPath, difficulty:String):ChartData {
        return cast new FNFCodename().fromFormat(new FNFVSlice().fromFile(chartPath, difficulty)).data; // Crashes someone fix this please
    }

    public static function fromPsych(chartPath:String):ChartData {
        return cast new FNFCodename().fromFormat(new FNFPsych().fromFile(chartPath)).data;
    }

    // public static function fromImaginative(chartPath:String) {
        // return case new FNFCodename()
    // }

    /**
    ```haxe
    // Code for converting the chart to yaml.
    if (chartCache.fileExt != "yaml") {
        sys.FileSystem.deleteFile(chartCache.filePath);
        Yaml.write(chartCache.filePath.replace('.${chartCache.fileExt}', ".yaml"), convertChartData(parsedCache,  detectJsonChartFormat(parsedCache)));
    }
    ```*/
}