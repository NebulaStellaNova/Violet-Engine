package violet.states.menus;

import flixel.FlxCamera;
import violet.backend.EditorListBackend;
import violet.backend.audio.Conductor;

class PauseMenu extends EditorListBackend {

    public var pauseMenuOptions:Array<EditorListOption> = [
        { title: "RESUME", disabled: false },
        { title: "RESTART SONG", disabled: false },
        { title: "CHANGE DIFFICULTY", disabled: true },
        { title: "CHANGE OPTIONS", disabled: true },
        { title: "ENABLE PRACTICE MODE", disabled: true },
        { title: "EXIT TO MENU", disabled: false }
    ];

    public dynamic function resume() {
        close();
    }

    public dynamic function restartSong() {
        FlxG.resetState();
    }

    public dynamic function exitToMenu() {
        subCamera.fade(0.25, ()->FlxG.switchState(new MainMenu()));
    }

    override public function new() {
        super(pauseMenuOptions);
    }

    override function create() {
        showLocks = false;
        super.create();

        bg.color = FlxColor.BLACK;
        bg.alpha = 0.6;

        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;

        Conductor.pause();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);


        options[0].onClick ??= resume;
        options[1].onClick ??= restartSong;
        options[5].onClick ??= exitToMenu;

        // subCamera.bgColor = FlxColor.interpolate(FlxColor.TRANSPARENT, FlxColor.BLACK);

        /* if (Controls.accept) {
            close();
        } */
    }

    override function close() {
        super.close();
        Conductor.play();
        FlxG.state.persistentUpdate = true;
    }

}