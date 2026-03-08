package violet.data.chart;

import violet.data.converters.ChartConverters;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;
import violet.data.song.SongRegistry;

class ChartRegistry {
	public static var charts:Array<Chart> = [];
	public static var chartDatas:Map<String, ChartData> = new Map<String, ChartData>();

	public static function registerCharts() {
		trace('debug:Registering charts...');
		charts.resize(0);
		chartDatas.clear();
		var chartList:Array<String> = [];
		for (song in SongRegistry.getAllSongs()) {
			for (diff in song.difficulties) {
				final jsonPath = Paths.json('songs/${song.songName}/charts/$diff');
				if (!Paths.fileExists(jsonPath, true)) {
					trace('warning:Could not find chart for song ${song.id} of difficulty $diff.');
					continue;
				}
				chartDatas.set('${song.id}:$diff', ChartConverters.convertChart(FileUtil.getFileContent(jsonPath)));
				registerChart(new Chart(song.id, diff));
			}
			/* for (variant in song.variants) {
				for (diff in song.difficulties) {
					final jsonPath = Paths.json('songs/${song.songName}/charts/$variant/$diff');
					if (!Paths.fileExists(jsonPath, true)) {
						trace('warning:Could not find chart for song ${song.id} ${variant.charAt(0).toUpperCase() + variant.substr(1)} of difficulty $diff.');
						continue;
					}
					chartDatas.set('${song.id}:$diff:$variant', new json2object.JsonParser<ChartData>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent(jsonPath)), jsonPath));
					registerChart(new Chart(song.id, diff, variant));
				}
			} */
		}
	}

	public static function registerChart(chart:Chart) {
		for (existingChart in charts) {
			if (existingChart.id == chart.id && existingChart.chartDifficulty == chart.chartDifficulty && existingChart.chartVariant == chart.chartVariant) {
				trace('warning:Chart is already registered. Skipping duplicate registration.');
				return;
			}
		}
		trace('debug:Found and registered chart with ID "${chart.id}:${chart.chartDifficulty}${chart.chartVariant == null ? '' : ':${chart.chartVariant}'}"');
		charts.push(chart);
	}

	public static function getChart(songID:String, diff:String, ?variant:String):Null<Chart> {
		for (chart in charts) {
			if (chart.id == songID && chart.chartDifficulty == diff && chart.chartVariant == variant) {
				return chart;
			}
		}
		return null;
	}
}