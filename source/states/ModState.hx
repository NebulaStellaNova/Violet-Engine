package states;

import backend.MusicBeatState;

class ModState extends MusicBeatState {
    public var stateName:String = "";

    public function new(name) {
        this.stateName = name;
        super();
    }
}