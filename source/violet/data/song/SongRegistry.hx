package violet.data.song;

import violet.backend.utils.ParseUtil;
import violet.data.chart.ChartConverters;
import violet.data.level.LevelRegistry;

class SongRegistry {

	public static var songs:Array<Song> = [];
	public static var songDatas:Map<String, SongData> = new Map<String, SongData>();

	public static function registerSongs() {
		trace('debug:<yellow>Registering songs...');
		// Implementation for registering songs goes here
		songs.resize(0);
		songDatas.clear();
		var songList:Array<String> = [];
		for (level in LevelRegistry.getAllLevels())
			songList = songList.concat(level.getSongs());
		checkAndConvertVSliceSongs(songList);
		for (songID in songList) {
			final parsed:SongData = ParseUtil.jsonOrYaml('songs/$songID/meta', null, 'null');
			if (parsed == null) {
				trace('warning:Could not find meta file for song with ID "$songID". Skipping registration.');
				continue;
			} else {
				songDatas.set(songID, parsed);
				registerSong(new Song(songID));
			}
			for (i in parsed?.variants ?? []) {
				final variantMeta:SongData = ParseUtil.jsonOrYaml('songs/$songID/meta-$i');
				songDatas.set(Song.setupId(songID, null, i), variantMeta);
				registerSong(new Song(songID, i));
			}
		}
	}

	static function checkAndConvertVSliceSongs(songList:Array<String>) {
		for (songID in songList) {
			if (Paths.fileExists('songs/$songID/$songID-metadata.json')) {
				if (!Paths.fileExists('songs/$songID/$songID-chart.json')) continue;
				ChartConverters.convertVSliceSong(songID);
			}
		}
	}

	public static function registerSong(song:Song) {
		trace('debug:<cyan>Found and registered song with ID "<magenta>${song.id}<cyan>" and variant of "<magenta>${song.variant.isNone() ? Variation.NO_VARIANT : song.variant}<cyan>"');
		songs.push(song);
	}

	public static function getAllSongs(?variantFilter:Variation = NO_VARIANT):Array<Song> {
		if (variantFilter == NO_VARIANT) return songs.copy(); // we need to be able to all variations too
		return songs.filter(song -> return song.variant == variantFilter);
	}

	public static function getSongByID(songID:String, ?variantID:Variation):Null<Song> {
		for (song in songs) {
			if (song.id == songID && song.variant == variantID) {
				return song;
			}
		}
		return null;
	}

	public static function getAllSongIDs(?variantFilter:Variation = NO_VARIANT):Array<String> {
		if (variantFilter == NO_VARIANT) // we need to be able to all variations too
			return [for (song in songs) song.id];
		return [
			for (song in songs)
				if (song.variant == variantFilter)
					song.id
		];
	}

}