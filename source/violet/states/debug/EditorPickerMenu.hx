package violet.states.debug;

import violet.backend.EditorListBackend.EditorListOption;

class EditorPickerMenu extends violet.backend.EditorListBackend {

    // Setup like this for easy access in scripting.
    public var editorOptions:Array<EditorListOption> = [
        { title: "Chart Editor", disabled: true },
        { title: "Stage Editor", disabled: true },
        { title: "Level Editor", disabled: true },
        { title: "Note Skin Editor", disabled: true },
        { title: "Character Editor", disabled: true }
    ];

    override public function new() {
        super(editorOptions);
    }
}