package violet.states.editors;

import violet.backend.StateBackend;

class StageEditorState extends StateBackend {
    public function new() {
        super();

        var bg = new NovaSprite(Paths.image("menus/mainmenu/menuBGdesat"));
		bg.setGraphicSize(FlxG.width, FlxG.height);
        add(bg);
    }
}