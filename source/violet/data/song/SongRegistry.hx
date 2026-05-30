package violet.data.song;

import violet.data.chart.ChartConverters;
import violet.data.chart.ChartData;
import violet.data.level.LevelRegistry;

@:registryData('Song', [violet.data.song.Song, violet.data.song.SongData])
class SongRegistry implements violet.data.RegistryImpl {

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		@:privateAccess ChartConverters._cached_vslice_chart.clear();
		@:privateAccess ChartConverters._cached_vslice_meta.clear();

		clearEntries();

		var songList:Array<String> = [
			for (level in LevelRegistry.getAllEntries())
				for (song in level.getSongs())
					song
		];
		for (songID in songList) {
			var parsed:Null<SongData> = null;
			if (Paths.json('songs/$songID/$songID-metadata') != '') {
				parsed = ChartConverters.metaFromVSlice(songID);
			} else {
				parsed = ParseUtil.jsonOrYaml('songs/$songID/meta', null, 'null');
			}
			if (parsed == null) {
				trace('warning:<orange>Could not find $id, "<magenta>$songID<orange>", ignoring entry.');
				continue;
			} else registerEntry(songID, null, parsed);
			for (i in (parsed?.variants ?? [])) {
				var varParsed:Null<SongData> = null;
				if (Paths.json('songs/$songID/$songID-metadata-$i') != '') {
					varParsed = ChartConverters.metaFromVSlice(songID, i);
				} else {
					varParsed = ParseUtil.jsonOrYaml('songs/$songID/meta-$i', null, 'null');
				}
				if (varParsed == null) {
					trace('warning:<orange>Could not find $id for varient $i, "<magenta>$songID<orange>", ignoring entry.');
					continue;
				} else registerEntry(songID, i, varParsed);
			}
		}
	}

	public static function registerEntry(id:String, ?variant:String, _data:SongData):Void {
		entries.set(Song.setupId(id, null, variant), _data);
		data.push(new Song(id, variant));
		trace('debug:<cyan>Registered $_id entry, "<magenta>${Song.setupId(id, null, variant, '<cyan>:<magenta>')}<cyan>".');
	}

	inline public static function entryExists(id:String, ?variant:String):Bool return entries.exists(Song.setupId(id, null, variant));
	inline public static function fetchEntry(id:String, ?variant:String):Null<Song> {
		if (!entryExists(id, variant)) // we love inlining :3
			trace('debug:<red>$_id entry "<yellow>${Song.setupId(id, null, variant, '<red>:<yellow>')}<red>" doesn\'t exist.');
		return data.find(entry -> return entry.id == id && (entry.variant ?? '') == (variant ?? ''));
	}

	inline public static function getAllEntryIDs():Array<String> {
		final list:Array<String> = [];
		for (song in data)
			if (!list.contains(song.id))
				list.push(song.id);
		return list;
	}

}