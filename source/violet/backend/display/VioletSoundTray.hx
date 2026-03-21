package violet.backend.display;

import flixel.system.ui.FlxSoundTray;

class VioletSoundTray extends FlxSoundTray {

    public function new() {
        super();

        volumeUpSound = null;   // Cache.sound("soundtray/up");
        volumeDownSound = null; // Cache.sound("soundtray/down");
        // volumeMaxSound = Paths.sound("soundtray/max");
    }

}