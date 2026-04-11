package violet.data.song;

import violet.backend.utils.ParseUtil;
import violet.data.level.LevelRegistry;

using StringTools;

class SongRegistry {

	public static var songs:Array<Song> = [];
	public static var songDatas:Map<String, SongData> = new Map<String, SongData>();

	public static function registerSongs() {
		trace('debug:<yellow>Registering songs...');
		// Implementation for registering songs goes here
		songs.resize(0);
		songDatas.clear();
		var songList:Array<String> = [];
		for (level in LevelRegistry.getAllLevels()) {
			songList = songList.concat(level.getSongs());
		}
		for (songID in songList) {
			final parsed:Dynamic = ParseUtil.jsonOrYaml('songs/$songID/meta');
			if (parsed == {}) {
				trace('warning:Could not find meta file for song with ID "$songID". Skipping registration.');
				continue;
			} else {
				songDatas.set(songID, parsed);
				registerSong(new Song(songID));
			}
			for (i in (parsed?.variants ?? [])) {
				final variantMeta:Dynamic = ParseUtil.jsonOrYaml('songs/$songID/meta-$i');
				songDatas.set('$songID:$i', variantMeta);
				registerSong(new Song('$songID:$i'));
				// trace('$songID:$i');
			}
		}
	}

	public static function registerSong(song:Song) {
		for (existingSong in songs) {
			if (existingSong.id == song.id) {
				trace('warning:Song is already registered. Skipping duplicate registration.');
				return;
			}
		}
		trace('debug:<cyan>Found and registered song with ID "<magenta>${song.id}<cyan>"');
		songs.push(song);
	}

	public static function getAllSongs():Array<Song> {
		return songs.copy();
	}

	public static function getSongByID(songID:String):Null<Song> {
		for (song in songs) {
			if (song.id == songID) {
				return song;
			}
		}
		return null;
	}

	public static function getAllSongIDs():Array<String> {
		var ids:Array<String> = [];
		for (song in songs) {
			ids.push(song.id);
		}
		return ids;
	}

}