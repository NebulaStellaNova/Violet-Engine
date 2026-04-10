package violet.backend.replay;

import violet.backend.audio.Conductor;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import violet.backend.replay.ReplayInput.PlayBackInput;
import flixel.input.keyboard.FlxKeyList;
import violet.backend.utils.ParseUtil;
import violet.backend.options.Options;
import flixel.FlxBasic;

import flixel.input.FlxBaseKeyList;

class ReplaySystem extends FlxBasic {

    public static var instance:ReplaySystem;

    // Leave empty to use whole keyboard.
    public static var includedKeys:Array<String> = [];

    public static var currentInputs:Array<ReplayInput> = [];

    public static function startRecording() {
        instance = new ReplaySystem();
        FlxG.state.add(instance);
        currentInputs.resize(0);
        instance._startRecording();
    }

    public static function stopRecording() {
        instance._stopRecording();
    }

    public static function saveRecording(key:String) {
        if (!sys.FileSystem.exists('replays')) sys.FileSystem.createDirectory('replays');
        sys.io.File.saveContent('replays/$key.yml', ParseUtil.stringifyYaml(currentInputs));
    }

    public static var recording:Bool = false;

    public function _startRecording() {
        recording = true;
    }

    public function _stopRecording() {
        recording = false;
    }


    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!recording) return;

        if (FlxG.keys.anyJustPressed([ANY])) {
            var baseFields:Array<String> = Reflect.fields(Type.createEmptyInstance(FlxBaseKeyList));
            var fields:Array<String> = Reflect.fields(FlxG.keys.justPressed).filter((v)->return !baseFields.contains(v));
            if (includedKeys.length != 0) fields = fields.filter((v)->return includedKeys.contains(v));
            trace(fields);
            for (i in fields) {
                if (FlxG.keys.anyJustPressed([FlxKey.fromString(i)])) {
                    currentInputs.push({
                        key: i,
                        time: Conductor.framePosition,
                        type: PRESS
                    });
                }
            }
        }

        if (FlxG.keys.anyJustReleased([ANY])) {
            var baseFields:Array<String> = Reflect.fields(Type.createEmptyInstance(FlxBaseKeyList));
            var fields:Array<String> = Reflect.fields(FlxG.keys.justReleased).filter((v)->return !baseFields.contains(v));
            if (includedKeys.length != 0) fields = fields.filter((v)->return includedKeys.contains(v));
            for (i in fields) {
                if (FlxG.keys.anyJustReleased([FlxKey.fromString(i)])) {
                    currentInputs.push({
                        key: i,
                        time: Conductor.framePosition,
                        type: RELEASE
                    });
                }
            }
        }
    }

    public static var currentReplayData:Array<PlayBackInput> = [];

    public static var playBackKeys:Map<String, PlayBackKey> = [];

    public static var oldPressedChecker:Int->Bool;
    public static var oldJustPressedChecker:Int->Bool;
    public static var oldJustReleasedChecker:Int->Bool;

    public static function playReplay(key:String) {
        currentReplayData = ParseUtil.yaml('replays/$key.yml', 'root', 'yml');
        FlxG.signals.preUpdate.add(updateInput);

        oldPressedChecker = @:privateAccess FlxG.keys.pressed.check;
        oldJustPressedChecker = @:privateAccess FlxG.keys.justPressed.check;
        oldJustReleasedChecker = @:privateAccess FlxG.keys.justReleased.check;

        @:privateAccess FlxG.keys.pressed.check = keyCode -> {
            trace(keyCode);
            return false;
        }

        FlxG.keys.pressed.A;

        playBackKeys.clear();
        var baseFields:Array<String> = Reflect.fields(Type.createEmptyInstance(FlxBaseKeyList));
        var fields:Array<String> = Reflect.fields(FlxG.keys.justReleased).filter((v)->return !baseFields.contains(v));
        for (i in fields) {
            playBackKeys.set(i, {
                pressed: false,
                justPressed: false,
                justReleased: false
            });
        }
    }

    public static function stopReplay() {
        FlxG.signals.preUpdate.remove(updateInput);
        @:privateAccess FlxG.keys.pressed.check = oldPressedChecker;
        @:privateAccess FlxG.keys.justPressed.check = oldJustPressedChecker;
        @:privateAccess FlxG.keys.justReleased.check = oldJustReleasedChecker;
    }

    public static function updateInput() {
        for (i in playBackKeys) {
            i.justPressed = false;
            i.justReleased = false;
        }
        for (i in currentReplayData ?? []) {
            if (i.time <= Conductor.framePosition && !i.hit) {
                i.hit = true;
                var key = playBackKeys.get(i.key);
                var flxKey = FlxKey.fromString(i.key);
                switch (i.type) {
                    case PRESS:
                        key.justPressed = true;
                        key.pressed = true;
                        FlxG.stage.dispatchEvent(new KeyboardEvent('keyDown', flxKey, flxKey));
                    case RELEASE:
                        key.justReleased = true;
                        key.pressed = false;
                        FlxG.stage.dispatchEvent(new KeyboardEvent('keyUp', flxKey, flxKey));
                }

            }
        }
    }
}

typedef PlayBackKey = {
    var pressed:Bool;
    var justPressed:Bool;
    var justReleased:Bool;
}