package violet.data.song;

import violet.backend.utils.ParseUtil;

class Song {

    public var id:String;

    public var displayName:String;

    public var _data:SongData;

    public function new(id:String) {
        this._data = SongRegistry.songDatas.get(id);
        this.id = id;
        this.displayName = _data.displayName;
    }
}