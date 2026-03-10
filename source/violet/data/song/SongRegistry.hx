package violet.data.song;

import violet.backend.utils.FileUtil;
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
        songDatas.clear();
        var songList:Array<String> = [];
        for (level in LevelRegistry.getAllLevels()) {
            songList = songList.concat(level.getSongs());
        }
        for (songID in songList) {
            var folderName = songID.replace("-", " ");
            final jsonPath = Paths.json('songs/$folderName/meta');
            if (!Paths.fileExists(jsonPath, true)) {
                trace('warning:Could not find meta file for song with ID "$folderName". Skipping registration.');
                continue;
            }
            var songData:SongData = new json2object.JsonParser<SongData>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent(jsonPath)), jsonPath);
            songData.difficulties ??= ["EASY", "NORMAL", "HARD"];
            songDatas.set(songID, songData);
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