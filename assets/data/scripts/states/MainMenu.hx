import violet.backend.online.NetworkManager;
import violet.backend.options.Options;
import flixel.text.FlxTextBorderStyle;
import violet.backend.utils.NotificationType;
//
function create() {

    // new NetworkManager();
    // SocketHandler.joinRoom('Global', 'globalPassword');
}

function postCreate() {
    var leftWatermark2 = new NovaText(10, 10, 0, 'Press F1 to enter the online playroom.', 20);
    leftWatermark2.setFormat(Paths.font('vcr.ttf'), 40);
    leftWatermark2.scrollFactor.set();
    leftWatermark2.alignment = watermarkAlignment;
    leftWatermark2.borderStyle = FlxTextBorderStyle.OUTLINE;
    leftWatermark2.borderColor = FlxColor.BLACK;
    leftWatermark2.borderSize = 3;
    leftWatermark2.updateHitbox();
    add(leftWatermark2);
}

function update(?elapsed:Float) {
    // FlxG.autoPause = false;
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
