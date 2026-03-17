package violet.data.chart;

import violet.data.song.Song;
import violet.backend.utils.ParseUtil;
import violet.data.converters.ChartConverters;
import violet.data.song.SongRegistry;

typedef ChartCache = {
	var filePath:String;
	var eventsPath:String;
	var fileExt:String;
}

class ChartRegistry {
	public static var charts:Array<Chart> = [];
	public static var chartCache:Map<String, ChartCache> = new Map<String, ChartCache>();
	public static var chartDatas:Map<String, ChartData> = new Map<String, ChartData>();

	public static function registerCharts() {
        trace('debug:<yellow>Registering charts...');
		charts.resize(0);
		chartDatas.clear();
		chartCache.clear();
		var chartList:Array<String> = [];
		for (song in SongRegistry.getAllSongs()) {
			for (diff in song.difficulties) {
				var sub = song.variant != '' ? '/${song.variant}' : '';
				final yamlPath = Paths.yaml('songs/${song.songName}/charts$sub/$diff');
				final jsonPath = Paths.json('songs/${song.songName}/charts$sub/$diff');
				final eventsYamlPath = song.variant != '' ? Paths.yaml('songs/${song.songName}/events-${song.variant}') : Paths.yaml('songs/${song.songName}/events');

				if (yamlPath != "" || jsonPath != "") registerChart(song, diff, { filePath: yamlPath != "" ? yamlPath : jsonPath, fileExt: yamlPath != "" ? "yaml" : "json", eventsPath: eventsYamlPath })
				else trace('warning:<red>Could not find chart for song "${song.songName}" for difficulty "$diff"');
			}
		}
	}

	public static function registerChart(song:Song, diff:String, cache:ChartCache) {
		chartCache.set('${song.id}:$diff', cache);
		trace('debug:<cyan>Found and registered chart for song with ID "<magenta>${song.songName}<cyan>" for difficulty "<magenta>$diff<cyan>"' + (song.variant != '' ? ' for variant "<magenta>${song.variant}<cyan>"' : ""));
	}

	public static function fetchChart(id:String):ChartData {
		// trace(id);
		if (chartDatas.exists(id)) return chartDatas.get(id);

		var data = ChartConverters.convertChart(chartCache.get(id));
		data.stage ??= "default"; // Prevent bug where if no stage is assigned it will load all stage's scripts.
		chartDatas.set(id, data);
		return data;
	}

	public static function getChart(songID:String, diff:String, ?variant:String):Chart {
		return new Chart(songID, diff, null);
	}
}