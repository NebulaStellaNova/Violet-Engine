package violet.states;

import violet.data.song.SongRegistry;

class PlayState extends violet.backend.StateBackend {

    public static var instance:PlayState;

    override public function create() {
        super.create();

        instance = this;
    }

    public static function loadSong(id:String, difficulty:String = "normal", variation:String = "normal") {
        var songMetaData = SongRegistry.getSongByID(id);
        trace(songMetaData);
    }

}