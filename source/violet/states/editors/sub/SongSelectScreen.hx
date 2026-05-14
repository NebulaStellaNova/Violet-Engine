package violet.states.editors.sub;

import violet.backend.EditorListBackend;
import violet.backend.utils.NovaUtils;

class SongSelectScreen extends EditorListBackend {

	public function new() {
		var list:Array<EditorListOption> = [];
		var idList = violet.data.song.SongRegistry.getAllSongIDs();
		idList.sort(NovaUtils.sortAlphabetically);
		for (songID in idList) {
			var songData = violet.data.song.SongRegistry.getSongByID(songID);
			list.push({
				title: songData.displayName,
				disabled: false,
				onClick: () -> {
					ChartEditorState.songID = songID;
					if (songData.variantsList.length == 0) FlxG.switchState(new DifficultySelectScreen(songData.difficulties));
					else FlxG.switchState(new VariantSelectScreen(songData.variantsList));
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