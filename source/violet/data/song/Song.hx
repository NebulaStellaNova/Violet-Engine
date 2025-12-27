package violet.data.song;

import violet.backend.utils.ParseUtil;

class Song {

    public var id:String;

    public var displayName(get, null):String;
    public function get_displayName():String {
        return _data?.displayName ?? _data?.name ?? id;
    }

    public var variant(get, null):String;
    public function get_variant():String {
        return _data.variant ?? '';
    }

    public var bpm(get, null):Float;
    public function get_bpm():Float {
        return _data?.bpm ?? 120;
    }

    public var beatsPerMeasure(get, null):Float;
    public function get_beatsPerMeasure():Float {
        return _data?.beatsPerMeasure ?? 4;
    }

    public var stepsPerBeat(get, null):Int;
    public function get_stepsPerBeat():Int {
        return _data?.stepsPerBeat ?? 4;
    }

    public var difficulties(get, null):Array<String>;
    public function get_difficulties():Array<String> {
        return _data?.difficulties ?? [];
    }

    public var variants(get, null):Array<String>;
    public function get_variants():Array<String> {
        return _data?.variants ?? [];
    }

    public var customValues(get, null):Dynamic;
    public function get_customValues():Dynamic {
        return _data?.customValues;
    }

    public var icon(get, null):String;
    public function get_icon():String {
        return _data?.icon ?? '';
    }

    public var instSuffix(get, null):Bool;
    public function get_instSuffix():Bool {
        return _data?.instSuffix ?? '';
    }

    public var vocalsSuffix(get, null):Bool;
    public function get_vocalsSuffix():Bool {
        return _data?.vocalsSuffix ?? '';
    }

    public var needsVoices(get, null):Bool;
    public function get_needsVoices():Bool {
        return _data?.needsVoices ?? false;
    }

    public var _data:SongData;

    public function new(id:String) {
        this._data = SongRegistry.songDatas.get(id);
        this.id = id;
    }
}