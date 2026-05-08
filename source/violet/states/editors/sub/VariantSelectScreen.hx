package violet.states.editors.sub;

import violet.backend.EditorListBackend;
import violet.data.song.Variation;

class VariantSelectScreen extends EditorListBackend {

	public function new(variants:Array<Variation>) {
		variants.insert(0, Variation.NO_VARIANT);
		var list:Array<EditorListOption> = [];
		for (_i => i in variants) {
			var songData = _i == 0 ? violet.data.song.SongRegistry.getSongByID(ChartEditorState.songID)
			: violet.data.song.SongRegistry.getSongByID(ChartEditorState.songID, i);
			list.push({
				title: i.toString('default').toUpperCase(),
				disabled: false,
				onClick: () -> {
					ChartEditorState.variant = _i == 0 ? null : i;
					FlxG.switchState(new DifficultySelectScreen(songData.difficulties));
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