package violet.states.debug;

import violet.backend.EditorListBackend.EditorListOption;
import violet.states.editors.StageEditorState;

class EditorPickerMenu extends violet.backend.EditorListBackend {

    public dynamic function openStageEditor() {
        subCamera.fade(FlxColor.BLACK, 0.25, false, ()->{
            FlxG.switchState(StageEditorState.new);
            FlxG.camera.fade(FlxColor.BLACK, 0.25, true);
        });
    }

    // Setup like this for easy access in scripting.
    public var editorOptions:Array<EditorListOption> = [
        { title: "Chart Editor", disabled: true },
        { title: "Stage Editor", disabled: false },
        { title: "Level Editor", disabled: true },
        { title: "Note Style Editor", disabled: true },
        { title: "Character Editor", disabled: true }
    ];

    override public function new() {
        editorOptions[1].onClick ??= openStageEditor;
        super(editorOptions);
    }
}