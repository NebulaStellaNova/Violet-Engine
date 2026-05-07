package violet.data.chart;

import violet.data.song.Song;
import violet.data.song.SongRegistry;
import violet.data.song.Variation;

typedef ChartCache = {
	var filePath:String;
	var eventsPath:String;
	var fileExt:String;
	var difficulty:String;
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
		for (song in SongRegistry.getAllSongs(null)) {
			for (diff in song.difficulties) {
				final yamlPath = Paths.yaml('songs/${song.songName}/charts/$diff');
				final jsonPath = Paths.json('songs/${song.songName}/charts/$diff');
				final eventsYamlPath = Paths.yaml('songs/${song.songName}/events');
				final eventsJsonPath = Paths.json('songs/${song.songName}/events');

				if (yamlPath != '' || jsonPath != '')
					registerChart(song, diff, {
						filePath: yamlPath != '' ? yamlPath : jsonPath,
						eventsPath: eventsYamlPath != '' ? eventsYamlPath : eventsJsonPath,
						fileExt: yamlPath != '' ? 'yaml' : 'json',
						difficulty: diff
					});
				else trace('warning:<red>Could not find chart for song "${song.songName}" for difficulty "$diff"');
			}
			for (song in song.variants) {
				for (diff in song.difficulties) {
					final yamlPath = Paths.yaml('songs/${song.songName}/charts/${song.variant}/$diff');
					final jsonPath = Paths.json('songs/${song.songName}/charts/${song.variant}/$diff');
					final eventsYamlPath = Paths.yaml('songs/${song.songName}/events-${song.variant}');
					final eventsJsonPath = Paths.json('songs/${song.songName}/events-${song.variant}');

					if (yamlPath != '' || jsonPath != '')
						registerChart(song, diff, {
							filePath: yamlPath != '' ? yamlPath : jsonPath,
							eventsPath: eventsYamlPath != '' ? eventsYamlPath : eventsJsonPath,
							fileExt: yamlPath != '' ? 'yaml' : 'json',
							difficulty: diff
						});
					else trace('warning:<red>Could not find chart for song "${song.songName}:${song.variant}" for difficulty "$diff"');
				}
			}
		}
	}

	public static function registerChart(song:Song, diff:String, cache:ChartCache) {
		final fixedId = Song.setupId(song.id, diff, song.variant);
		chartCache.set(fixedId, cache);
		fetchChart(fixedId, true); // Uncomment if you want to enable chart preloading for whatever reason.
		trace('debug:<cyan>Found and registered chart for song with ID "<magenta>${song.songName}<cyan>" for difficulty "<magenta>$diff<cyan>"' + (!song.variant.isNone() ? ' for variant "<magenta>${song.variant}<cyan>"' : ''));
	}

	public static function fetchChart(id:String, force:Bool = false):ChartData {
		// trace(id);
		if (chartDatas.exists(id) && !force) return chartDatas.get(id);

		var data = ChartConverters.convertChart(chartCache.get(id));
		data.stage ??= 'default'; // Prevent bug where if no stage is assigned it will load all stage's scripts.
		chartDatas.set(id, data);
		return data;
	}

	public static function getChart(songID:String, diff:String, ?variant:Variation):Chart {
		return new Chart(songID, diff, variant);
	}

}