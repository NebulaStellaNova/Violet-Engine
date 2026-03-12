package violet.states.editors;

import haxe.ui.RuntimeComponentBuilder;
import violet.backend.StateBackend;
import haxe.ui.containers.menus.MenuBar;

class StageEditorState extends StateBackend {
    var menuBar = RuntimeComponentBuilder.build("resources/data/ui/stage-editor/menubar.xml");

    public function new() {
        super();

        var bg = new NovaSprite(Paths.image("menus/mainmenu/menuBGdesat"));
		bg.setGraphicSize(FlxG.width, FlxG.height);
        add(bg);

        trace(Paths.ui("stage-editor/menubar"));
        add(menuBar);
        // addComponent(menuBar);
    }
}