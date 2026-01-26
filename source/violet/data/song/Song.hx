package violet.data.song;



class Song {

    public var id:String;

    public var displayName(get, null):String;
    function get_displayName():String {
        return _data?.displayName ?? _data?.name ?? id;
    }

    public var variant(get, null):String;
    function get_variant():String {
        return _data.variant ?? '';
    }

    public var bpm(get, null):Float;
    function get_bpm():Float {
        return _data?.bpm ?? 120;
    }

    public var beatsPerMeasure(get, null):Int;
    function get_beatsPerMeasure():Int {
        return _data?.beatsPerMeasure ?? 4;
    }

    public var stepsPerBeat(get, null):Int;
    function get_stepsPerBeat():Int {
        return _data?.stepsPerBeat ?? 4;
    }

    public var difficulties(get, null):Array<String>;
    function get_difficulties():Array<String> {
        return _data?.difficulties ?? [];
    }

    public var variants(get, null):Array<String>;
    function get_variants():Array<String> {
        return _data?.variants ?? [];
    }

    public var customValues(get, null):Dynamic;
    function get_customValues():Dynamic {
        return _data?.customValues;
    }

    public var icon(get, null):String;
    function get_icon():String {
        return _data?.icon ?? '';
    }

    public var instSuffix(get, null):String;
    function get_instSuffix():String {
        return _data?.instSuffix ?? '';
    }

    public var vocalsSuffix(get, null):String;
    function get_vocalsSuffix():String {
        return _data?.vocalsSuffix ?? '';
    }

    public var needsVoices(get, null):Bool;
    function get_needsVoices():Bool {
        return _data?.needsVoices ?? false;
    }

    public var _data:SongData;

    public function new(id:String) {
        this._data = SongRegistry.songDatas.get(id);
        this.id = id;
    }
}