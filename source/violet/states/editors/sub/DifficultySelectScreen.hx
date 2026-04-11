package violet.states.editors.sub;

import violet.backend.utils.NovaUtils;
import violet.backend.EditorListBackend;

class DifficultySelectScreen extends EditorListBackend {

	public function new(difficulties:Array<String>) {
		difficulties ??= ['easy', 'normal', 'hard'];
		var list:Array<EditorListOption> = [];
		for (i in difficulties) {
			list.push({
				title: i.toUpperCase(),
				disabled: false,
				onClick: () -> {
					ChartEditorState.difficulty = i;
					FlxG.switchState(ChartEditorState.new);
				}
			});
		}
		super(list, true);
	}

	override public function create() {
		super.create();
		bg.scrollFactor.set();
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.x = bg.y = 0;
		bg.updateHitbox();
	}

}