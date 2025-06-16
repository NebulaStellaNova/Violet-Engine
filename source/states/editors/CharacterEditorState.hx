package states.editors;

import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.menus.Menu;
import flixel.FlxG;
import haxe.ui.containers.menus.MenuBar;

import backend.MusicBeatState;
class CharacterEditorState extends MusicBeatState {
    
    var topBar:MenuBar;

    override public function create() {
        super.create();

        topBar = new MenuBar();
        topBar.width = FlxG.width;
        add(topBar);
        
        var fileMenu = new Menu();
        fileMenu.text = "File";
        topBar.addComponent(fileMenu);

        var exitButton = new MenuItem();
        exitButton.onClick = (e)->{
            switchState(MainMenuState.new);
        };
        exitButton.text = "Exit";
        fileMenu.addComponent(exitButton);

    }
}