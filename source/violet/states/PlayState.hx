package violet.states;

import violet.backend.audio.Conductor;
import violet.backend.utils.NovaUtils;
import violet.data.song.SongRegistry;

class PlayState extends violet.backend.StateBackend {

	public static var instance:PlayState;

	override public function create():Void {
		super.create();
		instance = this;
	}

	override public function destroy():Void {
		instance = null;
		super.destroy();
	}

	public static function loadSong(id:String, difficulty:String = "normal", ?variation:String) {
		var songMetaData = SongRegistry.getSongByID(id);
		NovaUtils.playMusic('$id/song/Inst${variation == null ? '' : '-$variation'}', 'songs');
		Conductor.setInitialBPM(songMetaData.bpm, songMetaData.stepsPerBeat, songMetaData.beatsPerMeasure);
	}

}