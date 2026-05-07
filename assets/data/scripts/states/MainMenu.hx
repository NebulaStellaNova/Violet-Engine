import violet.backend.online.NetworkManager;
import violet.backend.options.Options;
import violet.backend.online.RoomTestState;
//
function create() {

    // new NetworkManager();
    // SocketHandler.joinRoom('Global', 'globalPassword');
}

function update(?elapsed:Float) {
    // FlxG.autoPause = false;

    if (FlxG.keys.justPressed.F12) {
        if (Options.data.displayName != "Guest") {
            FlxG.switchState(new RoomTestState());
        } else {
            NovaUtils.addNotification("Wait!!!!", "Please set your display name in the options menu before entering online playroom.");
        }
    }
}

@:alias("changeSelection")
@:alias("uponChangeSelection")
function onChangeSelection(event) {
    // violet.backend.scripting.events.SelectionEvent
}

@:alias("pickSelection")
@:alias("uponPickSelection")
function onPickSelection(event) {
    // violet.backend.scripting.events.SelectionEvent
}
