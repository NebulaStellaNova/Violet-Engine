package violet.states.editors;

import haxe.ui.RuntimeComponentBuilder;
import violet.backend.StateBackend;
import haxe.ui.containers.menus.MenuBar;

class StageEditorState extends StateBackend {
    var menuBar:MenuBar;

    public function new() {
        super();

        var bg = new NovaSprite(Paths.image("menus/mainmenu/menuBGdesat"));
		bg.setGraphicSize(FlxG.width, FlxG.height);
        add(bg);

        trace(Paths.ui("stage-editor/menubar"));
        menuBar = cast RuntimeComponentBuilder.build("resources/data/ui/stage-editor/menubar.xml");
        add(menuBar);
        // addComponent(menuBar);
    }
}