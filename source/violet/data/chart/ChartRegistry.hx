package violet.data.chart;

import violet.data.converters.ChartConverters;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;
import violet.data.song.SongRegistry;

typedef ChartCache = {
	var content:String;
}

class ChartRegistry {
	public static var charts:Array<Chart> = [];
	public static var chartCache:Map<String, ChartCache> = new Map<String, ChartCache>();
	public static var chartDatas:Map<String, ChartData> = new Map<String, ChartData>();

	public static function registerCharts() {
		trace('debug:Registering charts...');
		charts.resize(0);
		chartDatas.clear();
		chartCache.clear();
		var chartList:Array<String> = [];
		for (song in SongRegistry.getAllSongs()) {
			for (diff in song.difficulties) {
				final jsonPath = Paths.json('songs/${song.songName}/charts/$diff');
				if (!Paths.fileExists(jsonPath, true)) {
					trace('warning:Could not find chart for song ${song.id} of difficulty $diff.');
					continue;
				}
				chartCache.set('${song.id}:$diff', { content: FileUtil.getFileContent(jsonPath) });
			}
		}
	}

	public static function fetchChart(id:String):ChartData {
		if (chartDatas.exists(id)) return chartDatas.get(id);

		var data = ChartConverters.convertChart(chartCache.get(id).content);
		chartDatas.set(id, data);
		return data;
	}

	public static function getChart(songID:String, diff:String, ?variant:String):Chart {
		return new Chart(songID, diff, variant);
	}
}