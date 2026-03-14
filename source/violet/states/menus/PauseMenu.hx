package violet.states.menus;

import flixel.FlxCamera;
import violet.backend.scripting.events.EventBase;
import violet.backend.EditorListBackend;
import violet.backend.audio.Conductor;

class PauseMenu extends EditorListBackend {

    public var pauseMenuOptions:Array<EditorListOption>;

    override public function new() {
        pauseMenuOptions = [
            { title: "RESUME", disabled: false, onClick: ()->{
                if (FlxG.mouse.justPressed) return;
                var event:EventBase = PlayState.instance.songScripts.event('onResume', new EventBase());
                // event = subStateScripts.event('resume', event);
                if (!event.cancelled) close();
            }},
            { title: "RESTART SONG", disabled: false, onClick: ()->{
                if (FlxG.mouse.justPressed) return;
                var event:EventBase = PlayState.instance.songScripts.event('onRestartSong', new EventBase());
                // event = subStateScripts.event('restartSong', event);
                if (!event.cancelled) FlxG.resetState();
            }},
            { title: "CHANGE DIFFICULTY", disabled: true, onClick: ()->{

            }},
            { title: "CHANGE OPTIONS", disabled: true, onClick: ()->{

            }},
            { title: "ENABLE PRACTICE MODE", disabled: true, onClick: ()->{

            }},
            { title: "EXIT TO MENU", disabled: false, onClick: ()->{
                if (FlxG.mouse.justPressed) return;
                var event:EventBase = PlayState.instance.songScripts.event('onExitToMenu', new EventBase());
                // event = subStateScripts.event('exitToMenu', event);
                if (!event.cancelled) subCamera.fade(0.25, () -> {
                    FlxG.switchState(new FreeplayMenu().build());
                });
            }}
        ];
        if (PlayState.instance.inCutscene) {
            pauseMenuOptions[1].title = pauseMenuOptions[1].title.replace("SONG", "CUTSCENE");
            pauseMenuOptions.insert(1, { title: "SKIP CUTSCENE", disabled: false, onClick: ()->PlayState.instance.callSongScripts("onSkipCutscene")});
        }
        super(pauseMenuOptions);
    }

    override function create() {
        options = pauseMenuOptions;
        showLocks = false;
        super.create();

        bg.color = FlxColor.BLACK;
        bg.alpha = 0.6;

        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;

        Conductor.pause();
    }

    override function close() {
        super.close();
        if (PlayState.instance.songStarted) Conductor.play();
        FlxG.state.persistentUpdate = true;
    }

}