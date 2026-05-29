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
	public static final cache:Map<String, ChartData> = new Map<String, ChartData>();

	inline public static function clearEntries():Void {
		data.resize(0);
		entries.clear();
		cache.clear();
	}

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		for (song in SongRegistry.getAllEntries()) {
			for (diff in song.difficulties) {
				final hasVariant = !(song.variant == null || song.variant.trim() == '');
				var parsed:Null<ChartData> = null;
				if (Paths.json('songs/${song.songName}/${song.songName}-metadata${hasVariant ? '-${song.variant.trim()}' : ''}') != '') {
					parsed = ChartConverters.chartFromVSlice(song.songName, diff, hasVariant ? song.variant.trim() : null);
				} else {
					final sub = hasVariant ? '/${song.variant}' : '';
					final chartData = ParseUtil.jsonOrYaml('songs/${song.songName}/charts$sub/$diff');
					final eventData = hasVariant ? ParseUtil.jsonOrYaml('songs/${song.songName}/events-${song.variant}') : ParseUtil.jsonOrYaml('songs/${song.songName}/events');
					chartData.events ??= [];
					for (i in eventData.events ?? []) {
						i.global = true;
						chartData.events.push(i);
					}
					parsed = chartData;
				}
				if (parsed != null)
					registerEntry(song, diff, parsed)
				else trace('warning:<orange>Could not find chart for song "<magenta>${Song.setupId(song.id, diff, song.variant, '<orange>:<magenta>')}<orange>"');
			}
		}
	}

	public static function registerEntry(song:Song, diff:String, parsed:ChartData):Void {
		ChartRegistry.cache.set(Song.setupId(song.id, diff, song.variant), parsed);
		getEntry(song.id, diff, song.variant, true);
		trace('debug:<cyan>Registered $id entry, "<magenta>${Song.setupId(song.id, diff, song.variant, '<cyan>:<magenta>')}<cyan>".');
	}

	public static function getEntry(id:String, diff:String, ?variant:String, force:Bool = false):Null<ChartData> {
		final fixedId:String = Song.setupId(id, diff, variant);
		if (entryExists(id, diff, variant) && !force)
			return entries.get(fixedId);

		var entry = cache.get(fixedId);
		entry.stage ??= 'default'; // Prevent bug where if no stage is assigned it will load all stage's scripts.
		entries.set(fixedId, entry);
		if (entryExists(id, diff, variant))
			data.remove(fetchEntry(id, diff, variant));
		data.push(new Chart(id, diff, variant));
		return entry;
	}

	inline public static function entryExists(id:String, diff:String, ?variant:String):Bool
		return entries.exists(Song.setupId(id, diff, variant));

	inline public static function fetchEntry(id:String, diff:String, ?variant:String):Null<Chart> {
		if (!entryExists(id, diff, variant)) // we love inlining :3
			trace('debug:<red>$_id entry "<yellow>${Song.setupId(id, diff, variant, '<red>:<yellow>')}<red>" doesn\'t exist.');
		return data.find(entry -> return entry.id == id && entry.chartDifficulty == diff && (entry.chartVariant ?? '') == (variant ?? ''));
	}
}
