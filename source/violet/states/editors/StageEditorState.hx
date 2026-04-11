package violet.states.editors;

import violet.backend.utils.ParseUtil;
import lemonui.utils.ElementUtil;
import violet.backend.StateBackend;

class StageEditorState extends StateBackend {

	public function new() {
		super();

		var bg = new NovaSprite(Paths.image('menus/mainmenu/menuBGdesat'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		add(bg);

		var menuBar = ElementUtil.buildFromObject(ParseUtil.jsonOrYaml('data/ui/stage-editor/menubar'));
		add(menuBar);
		/* var menuBar = new MenuBar();
		add(menuBar);

		var menuTest = new Menu('File');
		menuBar.addElement(menuTest);

		var menuTest2 = new Menu('File2');
		menuBar.addElement(menuTest2);

		var buttonTest = new MenuItem('Test Button');
		buttonTest.onClick = ()->trace('Clicked on Button');
		buttonTest.onMouseIn = ()->trace('Hovered on Button');
		buttonTest.onMouseOut = ()->trace('Unhovered Button');
		menuTest.addElement(buttonTest);

		var buttonTest2 = new MenuItem('Test Button2');
		buttonTest2.onClick = ()->trace('Clicked on Button');
		buttonTest2.onMouseIn = ()->trace('Hovered on Button');
		buttonTest2.onMouseOut = ()->trace('Unhovered Button');
		menuTest2.addElement(buttonTest2); */
	}

}