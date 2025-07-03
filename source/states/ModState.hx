package states;

import backend.MusicBeatState;

class ModState extends MusicBeatState {
    public static var stateName:String = "";

    public function new(name) {
        if (name != null) {
            stateName = name;
        }
        super();
    }
}