package violet.data.noteskin;

import openfl.display.BlendMode;
import violet.data.animation.NoteAnimationData;
import violet.data.noteskin.NoteSkinData.NoteSkinProperties;

class _NoteSkinProperties {
	final part:NoteSkinProperties;
	final base:NoteSkinProperties;
	final defaults:NoteSkinProperties;

	public var scale(get, never):Float;
	function get_scale():Float
		return part?.scale ?? base?.scale ?? defaults?.scale ?? 1;

	public var alpha(get, never):Float;
	function get_alpha():Float
		return part?.alpha ?? base?.alpha ?? defaults?.alpha ?? 1;

	public var blendMode(get, never):BlendMode;
	function get_blendMode():BlendMode
		return part?.blendMode ?? base?.blendMode ?? defaults?.blendMode ?? 'normal';

	public function new(part:NoteSkinProperties, base:NoteSkinProperties, ?defaults:NoteSkinProperties) {
		this.part = part;
		this.base = base;
		this.defaults = defaults;
	}
}

class NoteSkin {

	public var id:String;
	public var _data:NoteSkinData;

	public var fallback(get, never):NoteSkin;
	function get_fallback():NoteSkin {
		if (_data == null || getFallbackID() == null) return null;
		return NoteSkinRegistry.getNoteSkinByID(getFallbackID());
	}

	public function new(id:String) {
		this.id = id;
		this._data = NoteSkinRegistry.noteSkinDatas.get(id) ?? NoteSkinRegistry.getDefaultNoteSkinData();

		strumProperties = new _NoteSkinProperties(_data.strums?.properties, _data?.properties, {scale: 0.7});
		noteProperties = new _NoteSkinProperties(_data.notes?.properties, _data?.properties, {scale: 0.7});
		sustainProperties = new _NoteSkinProperties(_data.sustains?.properties, _data?.properties, {scale: 0.7});
		splashProperties = new _NoteSkinProperties(_data?.splashes?.properties, _data?.properties);
		holdCoverProperties = new _NoteSkinProperties(_data?.holdcovers?.properties, _data?.properties);
	}

	public function getName():String {
		return _data.name;
	}

	public function getFallbackID():Null<String> {
		return _data.fallback;
	}

	public final strumProperties:_NoteSkinProperties;
	public final noteProperties:_NoteSkinProperties;
	public final sustainProperties:_NoteSkinProperties;
	public final splashProperties:_NoteSkinProperties;
	public final holdCoverProperties:_NoteSkinProperties;

	public function isStrumPixel():Bool {
		return !(_data.strums?.isPixel ?? _data?.isPixel ?? false);
	}
	public function isNotePixel():Bool {
		return !(_data.notes?.isPixel ?? _data?.isPixel ?? false);
	}
	public function isSustainPixel():Bool {
		return !(_data.sustains?.isPixel ?? _data?.isPixel ?? false);
	}
	public function isSplashPixel():Bool {
		return !(_data?.splashes?.isPixel ?? _data?.isPixel ?? false);
	}
	public function isHoldCoverPixel():Bool {
		return !(_data?.holdcovers?.isPixel ?? _data?.isPixel ?? false);
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
		final partOffsets:Array<Float> = _data?.splashes?.offsets ?? [0, 0];
		return [offsets[0] + partOffsets[0], offsets[1] + partOffsets[1]];
	}
	public function getHoldCoverOffsets():Array<Float> {
		final offsets:Array<Float> = _data.offsets ?? [0, 0];
		final partOffsets:Array<Float> = _data?.holdcovers?.offsets ?? [0, 0];
		return [offsets[0] + partOffsets[0], offsets[1] + partOffsets[1]];
	}

	public function getStrumAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data.strums?.assetPath ?? data?.assetPath ?? 'strums'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data) && fallback != null)
			recursion(fallback._data);
		return path;
	}
	public function getNoteAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data.notes?.assetPath ?? data?.assetPath ?? 'notes'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data) && fallback != null)
			recursion(fallback._data);
		return path;
	}
	public function getSustainAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data.sustains?.assetPath ?? data?.assetPath ?? 'sustains'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data) && fallback != null)
			recursion(fallback._data);
		return path;
	}
	public function getSplashAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data?.splashes?.assetPath ?? data?.assetPath ?? 'splashes'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data) && fallback != null)
			recursion(fallback._data);
		return path;
	}
	public function getHoldCoverAssetPath():String {
		var path:String;
		function recursion(data:NoteSkinData):Bool {
			path = Paths.image('game/notes/$id/${data?.holdcovers?.assetPath ?? data?.assetPath ?? 'holdcovers'}');
			return Paths.fileExists(path, true);
		}
		if (!recursion(_data) && fallback != null)
			recursion(fallback._data);
		return path;
	}

	public function getStrumAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		final anims:Array<NoteAnimationData> = [
			for (data in _data.strums.animations) {
				if (data.mania != mania) continue;
				if (data.id != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0)
			return getStrumAnimations(id, mania - 1);
		return NullChecker.checkAnimations(anims);
	}
	public function getNoteAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		final anims:Array<NoteAnimationData> = [
			for (data in _data.notes.animations) {
				if (data.mania != mania) continue;
				if (data.id != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0)
			return getNoteAnimations(id, mania - 1);
		return NullChecker.checkAnimations(anims);
	}
	public function getSustainAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		final anims:Array<NoteAnimationData> = [
			for (data in _data.sustains.animations) {
				if (data.mania != mania) continue;
				if (data.id != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0)
			return getSustainAnimations(id, mania - 1);
		return NullChecker.checkAnimations(anims);
	}
	public function getSplashAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		final anims:Array<NoteAnimationData> = [
			for (data in _data?.splashes.animations) {
				if (data.mania != mania) continue;
				if (data.id != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0 && _data.splashes != null)
			return getSplashAnimations(id, mania - 1);
		return NullChecker.checkAnimations(anims);
	}
	public function getHoldCoverAnimations(id:Int, mania:Int = 4):Array<NoteAnimationData> {
		if (mania < 1) return [];
		final anims:Array<NoteAnimationData> = [
			for (data in _data?.holdcovers.animations) {
				if (data.mania != mania) continue;
				if (data.id != (id % mania)) continue;
				data;
			}
		];
		if (anims.length == 0 && _data.holdcovers != null)
			return getHoldCoverAnimations(id, mania - 1);
		return NullChecker.checkAnimations(anims);
	}

}