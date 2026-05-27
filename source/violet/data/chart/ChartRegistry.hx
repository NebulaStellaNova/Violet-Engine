package violet.data.chart;

import violet.data.song.Song;
import violet.backend.utils.ParseUtil;
import violet.data.song.SongRegistry;

typedef ChartCache = {
	var filePath:String;
	var eventsPath:String;
	var fileExt:String;
	var difficulty:String;
}

@:registryData('Chart', [violet.data.chart.Chart, violet.data.chart.ChartData])
class ChartRegistry implements violet.data.RegistryImpl {

	public static final cache:Map<String, ChartCache> = new Map<String, ChartCache>();

	inline public static function clearEntries():Void {
		data.resize(0);
		entries.clear();
		cache.clear();
	}

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		inline function pathing(path:String):String {
			final yamlPath = Paths.yaml(path);
			final jsonPath = Paths.json(path);
			return yamlPath != '' ? yamlPath : jsonPath;
		}
		for (song in SongRegistry.getAllEntries()) {
			for (diff in song.difficulties) {
				final hasVariant = !(song.variant == null || song.variant.trim() == '');
				final sub = hasVariant ? '/${song.variant}' : '';
				final chartPath = pathing('songs/${song.songName}/charts$sub/$diff');
				final eventPath = hasVariant ? pathing('songs/${song.songName}/events-${song.variant}') : pathing('songs/${song.songName}/events');

				if (chartPath != '') registerEntry(song, diff, { difficulty: diff, filePath: chartPath, fileExt: haxe.io.Path.extension(chartPath), eventsPath: eventPath })
				else trace('warning:<orange>Could not find chart for song "<magenta>${Song.setupId(song.id, diff, song.variant, '<orange>:<magenta>')}<orange>"');
			}
		}
	}

	public static function registerEntry(song:Song, diff:String, cache:ChartCache):Void {
		if (entryExists(song.id, diff, song.variant)) {
			trace('warning:<orange>$id with ID "<magenta>${Song.setupId(song.id, diff, song.variant, '<orange>:<magenta>')}<orange>" is already registered, ignoring entry.');
			return;
		}
		ChartRegistry.cache.set(Song.setupId(song.id, diff, song.variant), cache);
		getEntry(song.id, diff, song.variant, true); // Uncomment if you want to enable chart preloading for whatever reason.
		trace('debug:<cyan>Registered $id entry, "<magenta>${Song.setupId(song.id, diff, song.variant, '<cyan>:<magenta>')}<cyan>".');
	}

	public static function getEntry(id:String, diff:String, ?variant:String, force:Bool = false):Null<ChartData> {
		final fixedId:String = Song.setupId(id, diff, variant);
		if (entryExists(id, diff, variant) && !force) return entries.get(fixedId);

		var entry = ChartConverters.convertChart(cache.get(fixedId));
		entry.stage ??= 'default'; // Prevent bug where if no stage is assigned it will load all stage's scripts.
		entries.set(fixedId, entry);
		if (entryExists(id, diff, variant)) data.remove(fetchEntry(id, diff, variant));
		data.push(new Chart(id, diff, variant));
		return entry;
	}

	inline public static function entryExists(id:String, diff:String, ?variant:String):Bool return entries.exists(Song.setupId(id, diff, variant));
	inline public static function fetchEntry(id:String, diff:String, ?variant:String):Null<Chart> {
		if (!entryExists(id, diff, variant)) // we love inlining :3
			trace('debug:<red>$_id entry "<yellow>${Song.setupId(id, diff, variant, '<red>:<yellow>')}<red>" doesn\'t exist.');
		return data.find(entry -> return entry.id == id && entry.chartDifficulty == diff && (entry.chartVariant ?? '') == (variant ?? ''));
	}

}