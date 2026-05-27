package violet.data.song;

import haxe.io.Path;
import sys.io.File;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;
import violet.data.chart.ChartConverters;
import violet.data.chart.ChartData;
import violet.data.level.LevelRegistry;

@:registryData('Song', [violet.data.song.Song, violet.data.song.SongData])
class SongRegistry implements violet.data.RegistryImpl {

	inline static function checkAndConvertVSliceSongs(songList:Array<String>):Void {
		for (songID in songList) {
			if (Paths.fileExists('songs/$songID/$songID-metadata.json')) {
				if (!Paths.fileExists('songs/$songID/$songID-chart.json')) continue;
				ChartConverters.convertVSliceSong(songID);
			}
		}
	}

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		var songList:Array<String> = [
			for (level in LevelRegistry.getAllEntries())
				for (song in level.getSongs())
					song
		];
		checkAndConvertVSliceSongs(songList);
		for (songID in songList) {
			final parsed:Dynamic = ParseUtil.jsonOrYaml('songs/$songID/meta', null, 'null');
			if (parsed == null) {
				trace('warning:<orange>Could not find $id, "<magenta>$songID<orange>", ignoring entry.');
				continue;
			} else registerEntry(songID, null, parsed);
			for (i in (parsed?.variants ?? []))
				registerEntry(songID, i, ParseUtil.jsonOrYaml('songs/$songID/meta-$i'));
		}
	}

	public static function registerEntry(id:String, ?variant:String, _data:SongData):Void {
		if (entryExists(id, variant)) {
			trace('warning:<orange>$_id with ID "<magenta>${Song.setupId(id, null, variant, '<orange>:<magenta>')}<orange>" is already registered, ignoring entry.');
			return;
		}
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