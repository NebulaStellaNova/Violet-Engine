
import flixel.FlxG;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.*;

import backend.MusicBeatState;
class CharacterEditorState extends MusicBeatState {
    
    var topBar:MenuBar;

    override public function create() {
        super.create();

        topBar = new MenuBar();
        topBar.width = FlxG.width;
        add(topBar);
    }
}