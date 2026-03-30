package violet.states.editors.sub;

import violet.backend.utils.NovaUtils;
import violet.backend.EditorListBackend;

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
                    ChartEditorState.variant = songData.variant;
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