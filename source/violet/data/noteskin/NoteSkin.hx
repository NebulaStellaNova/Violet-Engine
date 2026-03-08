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
		final offsets:Array<Float> = _data.offsets ?? [0, 0];
		final partOffsets:Array<Float> = _data.strums?.offsets ?? [0, 0];
		return [offsets[0] + partOffsets[0], offsets[1] + partOffsets[1]];
	}
	public function getNoteOffsets():Array<Float> {
		final offsets:Array<Float> = _data.offsets ?? [0, 0];
		final partOffsets:Array<Float> = _data.notes?.offsets ?? [0, 0];
		return [offsets[0] + partOffsets[0], offsets[1] + partOffsets[1]];
	}
	public function getSustainOffsets():Array<Float> {
		final offsets:Array<Float> = _data.offsets ?? [0, 0];
		final partOffsets:Array<Float> = _data.sustains?.offsets ?? [0, 0];
		return [offsets[0] + partOffsets[0], offsets[1] + partOffsets[1]];
	}
	public function getSplashOffsets():Array<Float> {
		final offsets:Array<Float> = _data.offsets ?? [0, 0];
		final partOffsets:Array<Float> = _data.splashes?.offsets ?? [0, 0];
		return [offsets[0] + partOffsets[0], offsets[1] + partOffsets[1]];
	}

	public function getStrumAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data.strums?.assetPath ?? data?.assetPath ?? 'strums'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data))
			recursion(fallback._data);
		return path;
	}
	public function getNoteAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data.notes?.assetPath ?? data?.assetPath ?? 'notes'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data))
			recursion(fallback._data);
		return path;
	}
	public function getSustainAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data.sustains?.assetPath ?? data?.assetPath ?? 'sustains'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data))
			recursion(fallback._data);
		return path;
	}
	public function getSplashAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data.splashes?.assetPath ?? data?.assetPath ?? 'sustains'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data))
			recursion(fallback._data);
		return path;
	}

	public function getStrumAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		var anims:Array<NoteAnimationData> = [
			for (data in _data.strums.animations) {
				if (data.keyCount != mania) continue;
				if (data.directionId != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0)
			return getStrumAnimations(id, mania - 1);
		return anims;
	}
	public function getNoteAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		var anims:Array<NoteAnimationData> = [
			for (data in _data.notes.animations) {
				if (data.keyCount != mania) continue;
				if (data.directionId != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0)
			return getNoteAnimations(id, mania - 1);
		return anims;
	}
	public function getSustainAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		var anims:Array<NoteAnimationData> = [
			for (data in _data.sustains.animations) {
				if (data.keyCount != mania) continue;
				if (data.directionId != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0)
			return getSustainAnimations(id, mania - 1);
		return anims;
	}
	public function getSplashAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		var anims:Array<NoteAnimationData> = [
			for (data in _data.splashes.animations) {
				if (data.keyCount != mania) continue;
				if (data.directionId != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0)
			return getSplashAnimations(id, mania - 1);
		return anims;
	}

}