package violet.data.song;

import violet.backend.utils.ParseUtil;
import violet.data.level.LevelRegistry;

using StringTools;
class SongRegistry {

    public static var songs:Array<Song> = [];
    public static var songDatas:Map<String, SongData> = new Map<String, SongData>();

    public static function registerSongs() {
        trace("debug:Registering songs...");
        // Implementation for registering songs goes here
        songs = [];
        var songList:Array<String> = [];
        for (level in LevelRegistry.getAllLevels()) {
            songList = songList.concat(level.getSongs());
        }
        for (songID in songList) {
            var folderName = songID.replace("-", " ");
            if (!Paths.fileExists('songs/$folderName/meta.json')) {
                trace('warning:Could not find meta file for song with ID $folderName. Skipping registration.');
                continue;
            }
            songDatas.set(songID, ParseUtil.json('songs/$folderName/meta.json'));
            registerSong(new Song(songID));
        }
    }

    public static function registerSong(song:Song) {
        for (existingSong in songs) {
            if (existingSong.id == song.id) {
                trace('warning:Song is already registered. Skipping duplicate registration.');
                return;
            }
        }
        trace('debug:Found and registered song with ID "${song.id}"');
        songs.push(song);
    }

    public static function getSongByID(songID:String):Null<Song> {
        for (song in songs) {
            if (song.id == songID) {
                return song;
            }
        }
        return null;
    }

}