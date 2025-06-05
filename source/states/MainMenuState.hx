package states;

import backend.filesystem.Paths;
import backend.objects.NovaSprite;
import backend.MusicBeatState;

class MainMenuState extends MusicBeatState {

    public var bg:NovaSprite;

	override public function create()
	{
		super.create();

        bg = new NovaSprite(0, 0, Paths.image("menus/mainmenu/menuBG"));
        add(bg);
        bg.playAnim("test");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

}