package violet.backend.display;

import flixel.system.ui.FlxSoundTray;

class VioletSoundTray extends FlxSoundTray {

    public function new() {
        super();

        volumeUpSound = Paths.sound("soundtray/up");
        volumeDownSound = Paths.sound("soundtray/down");
        // volumeMaxSound = Paths.sound("soundtray/max");
    }

}