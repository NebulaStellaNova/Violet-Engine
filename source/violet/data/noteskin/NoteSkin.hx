package violet.data.noteskin;

import violet.data.animation.NoteAnimationData;

class NoteSkin {

	public var id:String;
	public var _data:NoteSkinData;

	public var fallback(get, never):NoteSkin;
	function get_fallback():NoteSkin {
		if (_data == null || _data.fallback == null) return null;
		return NoteSkinRegistry.getNoteSkinByID(_data.fallback);
	}

	public function new(id:String) {
		this.id = id;
		this._data = NoteSkinRegistry.noteSkinDatas.get(id) ?? NoteSkinRegistry.getDefaultNoteSkinData();
	}

	public function getName():String {
		return _data.name;
	}

	public function getFallbackID():Null<String> {
		return _data.fallback;
	}

	public function getStrumOffsets():Array<Float> {
		return _data.strums?.offsets ?? [0, 0];
	}
	public function getNoteOffsets():Array<Float> {
		return _data.notes?.offsets ?? [0, 0];
	}
	public function getSustainOffsets():Array<Float> {
		return _data.sustains?.offsets ?? [0, 0];
	}

	public function getStrumAssetPath():String {
		var path = Paths.image('$id/${_data.strums?.assetPath ?? _data?.assetPath ?? 'strums'}', 'game/notes');
		if (Paths.fileExists(path, true)) return path;
		return Paths.image('${fallback.id}/${fallback._data.strums?.assetPath ?? fallback._data?.assetPath ?? 'strums'}', 'game/notes');
	}
	public function getNoteAssetPath():String {
		var path = Paths.image('$id/${_data.notes?.assetPath ?? _data?.assetPath ?? 'notes'}', 'game/notes');
		if (Paths.fileExists(path, true)) return path;
		return Paths.image('${fallback.id}/${fallback._data.notes?.assetPath ?? fallback._data?.assetPath ?? 'notes'}', 'game/notes');
	}
	public function getSustainAssetPath():String {
		var path = Paths.image('$id/${_data.sustains?.assetPath ?? _data?.assetPath ?? 'sustains'}', 'game/notes');
		if (Paths.fileExists(path, true)) return path;
		return Paths.image('${fallback.id}/${fallback._data.sustains?.assetPath ?? fallback._data?.assetPath ?? 'sustains'}', 'game/notes');
	}

	public function getStrumAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		return [
			for (data in _data.strums.animations) {
				if (data.directionId != id) continue;
				if (data.keyCount != mania) continue;
				data;
			}
		];
	}
	public function getNoteAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		return [
			for (data in _data.notes.animations) {
				if (data.directionId != id) continue;
				if (data.keyCount != mania) continue;
				data;
			}
		];
	}
	public function getSustainAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		return [
			for (data in _data.sustains.animations) {
				if (data.directionId != id) continue;
				if (data.keyCount != mania) continue;
				data;
			}
		];
	}

}