package violet.backend.display;

import flixel.system.ui.FlxSoundTray;

class VioletSoundTray extends FlxSoundTray {

    public function new() {
        super();

        volumeUpSound = null;   // Cache.sound("soundtray/up");
        volumeDownSound = null; // Cache.sound("soundtray/down");
        // volumeMaxSound = Paths.sound("soundtray/max");
    }

    override function update(MS:Float) {
        super.update(MS);

        if (FlxG.sound.volume > 0.5) FlxG.sound.volume = 0.5;

    }

    override function showIncrement() {
        FlxG.sound.volume -= 0.05;
		final volume = (FlxG.sound.muted ? 0 : FlxG.sound.volume) * 2;
		showAnim(volume, silent ? null : volumeUpSound);
    }

    override function showDecrement() {
        if (FlxG.sound.volume == 0.05) FlxG.sound.volume = 0;
        else FlxG.sound.volume += 0.05;
		final volume = (FlxG.sound.muted ? 0 : FlxG.sound.volume) * 2;
		showAnim(volume, silent ? null : volumeDownSound);
    }


}