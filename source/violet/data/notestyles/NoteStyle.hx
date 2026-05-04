package violet.data.notestyles;

import openfl.display.BlendMode;
import violet.backend.utils.ParseUtil;
import violet.data.animation.NoteAnimationData;
import violet.data.notestyles.NoteStyleData.NoteStyleProperties;

class _NoteStyleProperties {

	public final scale:Float;
	public final alpha:Float;
	public final blendMode:BlendMode;

	public function new(part:NoteStyleProperties, base:NoteStyleProperties, ?defaults:NoteStyleProperties) {
		scale = part?.scale ?? base?.scale ?? defaults?.scale ?? 1;
		alpha = part?.alpha ?? base?.alpha ?? defaults?.alpha ?? 1;
		final toBeSafe:BlendMode = part?.blendMode ?? base?.blendMode ?? defaults?.blendMode ?? 'normal';
		blendMode = toBeSafe ?? NORMAL; // jic its null
	}

}

class NoteStyle {

	public var id:String;
	public var _data:NoteStyleData;

	public var fallback(get, never):NoteStyle;
	function get_fallback():NoteStyle {
		if (_data == null || getFallbackID() == null) return null;
		return NoteStyleRegistry.getNoteStyleByID(getFallbackID());
	}

	public function new(id:String) {
		this.id = id;
		this._data = NoteStyleRegistry.noteStyleDatas.get(id) ?? NoteStyleRegistry.getDefaultNoteStyleData();

		strumProperties = new _NoteStyleProperties(_data.strums?.properties, _data?.properties, {scale: 0.7});
		noteProperties = new _NoteStyleProperties(_data.notes?.properties, _data?.properties, {scale: 0.7});
		sustainProperties = new _NoteStyleProperties(_data.sustains?.properties, _data?.properties, {scale: 0.7});
		splashProperties = new _NoteStyleProperties(_data?.splashes?.properties, _data?.properties);
		holdCoverProperties = new _NoteStyleProperties(_data?.holdcovers?.properties, _data?.properties);

		if (this._data?.underlay?.colors != null) {
			final invalidList:Array<String> = [];
			for (field in Reflect.fields(this._data.underlay.colors)) {
				final mania:Null<Int> = Std.parseInt(field);
				if (mania != null) {
					final colors:Array<ParseColor> = Reflect.getProperty(this._data.underlay.colors, field);
					noteColors.set(mania, [for (color in colors) color.toFlxColor()]);
				} else invalidList.push(field);
			}
			if (invalidList.length != 0)
				trace('error:Fields in colors map "${invalidList.join('", "')}" are not valid integers.');
			invalidList.resize(0);
		}
	}

	public function getName():String {
		return _data.name;
	}

	public function getFallbackID():Null<String> {
		return _data.fallback;
	}

	public final strumProperties:_NoteStyleProperties;
	public final noteProperties:_NoteStyleProperties;
	public final sustainProperties:_NoteStyleProperties;
	public final splashProperties:_NoteStyleProperties;
	public final holdCoverProperties:_NoteStyleProperties;

	public final noteColors:Map<Int, Array<FlxColor>> = new Map<Int, Array<FlxColor>>();
	public function getNoteColor(id:Int, mania:Int = 4):FlxColor {
		if (mania < 1) return [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F][id % 4];
		final colors:Array<FlxColor> = noteColors.get(mania) ?? [];
		if (colors.length == 0)
			return getNoteColor(id, mania - 1);
		return colors[id % mania];
	}

	public function getSustainGapFix():Float {
		return _data.sustains?.gapFixAmount ?? 0;
	}

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

	public function getGlobalOffset():Array<Float> {
		if (_data.offsets == null) return [0, 0];
		return _data.offsets.copy();
	}
	public function getUnderlayOffset():Float {
		final offsets:Array<Float> = _data.offsets ?? [0, 0];
		return offsets[0] + _data?.underlay?.offset ?? 0;
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
		final nullCheck:String = _data.strums?.assetPath ?? _data?.assetPath ?? 'strums';
		var path:String = Paths.image(nullCheck);
		if (!Paths.fileExists(path, true))
			path = Paths.image('game/notes/$id/$nullCheck');
		if (!Paths.fileExists(path, true) && fallback != null)
			return fallback.getStrumAssetPath();
		return path;
	}
	public function getNoteAssetPath():String {
		final nullCheck:String = _data.notes?.assetPath ?? _data?.assetPath ?? 'notes';
		var path:String = Paths.image(nullCheck);
		if (!Paths.fileExists(path, true))
			path = Paths.image('game/notes/$id/$nullCheck');
		if (!Paths.fileExists(path, true) && fallback != null)
			return fallback.getNoteAssetPath();
		return path;
	}
	public function getSustainAssetPath():String {
		final nullCheck:String = _data.sustains?.assetPath ?? _data?.assetPath ?? 'sustains';
		var path:String = Paths.image(nullCheck);
		if (!Paths.fileExists(path, true))
			path = Paths.image('game/notes/$id/$nullCheck');
		if (!Paths.fileExists(path, true) && fallback != null)
			return fallback.getSustainAssetPath();
		return path;
	}
	public function getSplashAssetPath():String {
		final nullCheck:String = _data?.splashes?.assetPath ?? _data?.assetPath ?? 'splashes';
		var path:String = Paths.image(nullCheck);
		if (!Paths.fileExists(path, true))
			path = Paths.image('game/notes/$id/$nullCheck');
		if (!Paths.fileExists(path, true) && fallback != null)
			return fallback.getSplashAssetPath();
		return path;
	}
	public function getHoldCoverAssetPath():String {
		final nullCheck:String = _data?.holdcovers?.assetPath ?? _data?.assetPath ?? 'holdcovers';
		var path:String = Paths.image(nullCheck);
		if (!Paths.fileExists(path, true))
			path = Paths.image('game/notes/$id/$nullCheck');
		if (!Paths.fileExists(path, true) && fallback != null)
			return fallback.getHoldCoverAssetPath();
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