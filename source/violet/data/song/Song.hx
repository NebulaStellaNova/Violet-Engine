package violet.data.song;

class Song {

    public var id:String;

    public var songName(get, never):String;
    function get_songName():String {
        return _data?.name ?? id.split(":")[0];
    }

    public var displayName(get, never):String;
    function get_displayName():String {
        return _data?.displayName ?? songName;
    }

    public var variant(get, never):String;
    function get_variant():String {
        return id.split(":")[1] ?? '';
    }

    public var bpm(get, never):Float;
    function get_bpm():Float {
        return _data?.bpm ?? 120;
    }

    public var beatsPerMeasure(get, never):Int;
    function get_beatsPerMeasure():Int {
        return _data?.beatsPerMeasure ?? 4;
    }

    public var stepsPerBeat(get, never):Int;
    function get_stepsPerBeat():Int {
        return _data?.stepsPerBeat ?? 4;
    }

    public var difficulties(get, never):Array<String>;
    function get_difficulties():Array<String> {
        return [for (diff in _data?.difficulties ?? []) diff.toLowerCase()];
    }

    public var variants(get, never):Array<String>;
    function get_variants():Array<String> {
        return [for (diff in _data?.varients ?? []) diff.toLowerCase()];
    }

    public var customValues(get, never):Dynamic;
    function get_customValues():Dynamic {
        return _data?.customValues;
    }

    public var icon(get, never):String;
    function get_icon():String {
        return _data?.icon ?? '';
    }

    public var instSuffix(get, never):String;
    function get_instSuffix():String {
        return _data?.instSuffix ?? '';
    }

    public var vocalsSuffix(get, never):String;
    function get_vocalsSuffix():String {
        return _data?.vocalsSuffix ?? '';
    }

    public var needsVoices(get, never):Bool;
    function get_needsVoices():Bool {
        return _data?.needsVoices ?? false;
    }

    public var _data:SongData;

    public function new(id:String) {
        this._data = SongRegistry.songDatas.get(id);
        this.id = id;
    }
}