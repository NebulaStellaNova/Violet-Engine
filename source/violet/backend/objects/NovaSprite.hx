package violet.backend.objects;

import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import openfl.display.BitmapData;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import violet.backend.utils.NovaUtils;
import violet.data.animation.AnimationData;

#if ANIMATE_SUPPORT
import animate.FlxAnimate;
#end

typedef AnimationInfo = {
	var offset:Array<Float>;
}

class NovaSprite extends #if ANIMATE_SUPPORT FlxAnimate #else FlxSprite #end {
	public var filePath:String;
	public var fileName:String;

	public var animated:Bool = false;

	public var anims:Map<String, AnimationInfo> = new Map<String, AnimationInfo>();

	public var animationList(get, never):Array<String>;
	function get_animationList() return [ for (i in this.anims.keys()) i ];

	public var globalOffset:FlxPoint = FlxPoint.get();

	public function new(x:Float = 0.0, y:Float = 0.0, ?path:String) {
		super(x, y);
		if (path != null)
			this.loadSprite(path);
	}

	override function initVars():Void {
		super.initVars();
		animationOffset = FlxPoint.get();
		_scaledFrameOffset = FlxPoint.get();
	}

	public function loadSprite(path:String):NovaSprite {
		if (path.startsWith("https://"))
			fromWeb(path);
		else if (Paths.fileExists('${haxe.io.Path.withoutExtension(path)}/Animation.json', true)) {
			#if ANIMATE_SUPPORT
			this.filePath = '${haxe.io.Path.withoutExtension(path)}/Animation.json';
			this.fileName = Paths.getFileName(path, true);
			this.animated = true;
			this.frames = NovaUtils.getAtlasFrames(path);
			this.onLoaded();
			#else
			trace('warning:Atlas\'s aren\'t supported in this build of Violet Engine.');
			#end
		} else {
			if (Paths.fileExists(path.replace(".png", ".xml"), true)) {
				this.filePath = path;
				this.fileName = Paths.getFileName(path, true);
				this.animated = true;
				this.frames = NovaUtils.getSparrowFrames(path);
				this.onLoaded();
			} else {
				this.loadGraphic(path);
				this.updateHitbox();
				this.onLoaded();
			}
		}
		return this;
	}

	dynamic function onLoaded():Void {}

	@:unreflective var prevUrl:String = "";
	@:unreflective function fromWeb(url:String):NovaSprite @:privateAccess {
		url = url.split("?")[0];
		prevUrl = url;
		if (Cache.cache.exists(prevUrl)) {
			this.filePath = prevUrl;
			this.loadGraphic(Cache.cache.get(prevUrl));
			this.updateHitbox();
			this.onLoaded();
			return this;
		}
		final loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener("complete", (_:Dynamic) -> {
			this.filePath = prevUrl;
            final bitmap:BitmapData = BitmapData.fromBytes(loader.data);
			var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, prevUrl, false);
			graphic.destroyOnNoUse = false;
			graphic.persist = true;
			Cache.cache.set(prevUrl, graphic);
            this.loadGraphic(graphic);
            this.updateHitbox();
			this.onLoaded();
        });
        loader.load(new URLRequest(url));
		return this;
	}

	override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):NovaSprite {
		if (graphic is String) {
			this.filePath = graphic;
			this.fileName = Paths.getFileName(graphic, true);
		}
		this.animated = animated;
		return cast super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
	}

	public function playAnim(name:String, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		if (this.animation.exists(name)) {
			this.animation.play(name, forced, reversed, frame);
			if (this.anims.exists(name)) {
				// TODO: Rodney, add animation offsets like how you did in your engine! -Rodney
				final info:AnimationInfo = this.anims.get(name);
				this.animationOffset.set(info.offset[0] ?? 0, info.offset[1] ?? 0);
			}
		}
	}

	public function addAnim(name:String, prefix:OneOfTwo<String, Array<Int>>, ?indices:Array<Int>, ?offsets:Array<Float>, fps:Int = 24, looped:Bool = false, label:Bool = false):Void {
		prefix += "0";
		if (Std.isOfType(prefix, Array)) {
			this.animation.add(name, prefix, fps, looped);
		} else if (#if ANIMATE_SUPPORT isAnimate #else false #end) {
			#if ANIMATE_SUPPORT
			if (label) {
				if (indices == null || indices.length == 0)
					this.anim.addByFrameLabel(name, prefix, fps, looped);
				else this.anim.addByFrameLabelIndices(name, prefix, indices, fps, looped);
			} else {
				if (indices == null || indices.length == 0)
					this.anim.addBySymbol(name, prefix, fps, looped);
				else this.anim.addBySymbolIndices(name, prefix, indices, fps, looped);
			}
			#end
		} else {
			if (indices == null || indices.length == 0)
				this.animation.addByPrefix(name, prefix, fps, looped);
			else this.animation.addByIndices(name, prefix, indices, "", fps, looped);
		}
		this.anims.set(name, {offset: offsets != null ? [-offsets[0] ?? 0, -offsets[1] ?? 0] : [0, 0]});
	}

	public function addAnimFromJSON(data:AnimationData):Void {
		addAnim(data.name, data.prefix, data.frameIndices, data.offsets, data.frameRate, data.looped, data.byLabel);
	}

	public function addFrames(path:String):Void {
		var newFrames:FlxAtlasFrames = null;
		if (Paths.fileExists('${haxe.io.Path.withoutExtension(path)}/Animation.json', true)) {
			#if ANIMATE_SUPPORT
			newFrames = NovaUtils.getAtlasFrames(path);
			#else
			trace('warning:Atlas\'s aren\'t supported in this build of Violet Engine.');
			#end
		} else {
			if (Paths.fileExists(path.replace(".png", ".xml"), true))
				newFrames = NovaUtils.getSparrowFrames(path);
		}
		if (newFrames != null) {
			#if ANIMATE_SUPPORT
			this.frames = animate.FlxAnimateFrames.combineAtlas(cast this.frames, newFrames);
			#else
			if (this.frames is FlxAtlasFrames)
				cast(this.frames, FlxAtlasFrame).addAtlas(newFrames);
			#end
		}
	}

	var __baseFlipped:Bool = false;
	var __offsetFlipX:Bool = false;
	var __offsetFlipY:Bool = false;
	override public function draw():Void {
		// TODO: Add __baseFlipped check.
		final xFlip:Bool = flipX;
		final yFlip:Bool = flipY;
		if (xFlip) {
			__offsetFlipX = true;
			flipX = !flipX;
			scale.x *= -1;
		}
		if (yFlip) {
			__offsetFlipY = true;
			flipY = !flipY;
			scale.y *= -1;
		}
		super.draw();
		if (xFlip) {
			__offsetFlipX = false;
			flipX = !flipX;
			scale.x *= -1;
		}
		if (yFlip) {
			__offsetFlipY = false;
			flipY = !flipY;
			scale.y *= -1;
		}
		// jic
		flipX = xFlip;
		flipY = yFlip;
	}

	// for animation offsets
	var animationOffset:FlxPoint;
	var _scaledFrameOffset:FlxPoint;
	function _getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		newRect ??= FlxRect.get();
		camera ??= getDefaultCamera();
		newRect.setPosition(x, y);
		if (pixelPerfectPosition) newRect.floor();

		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		_scaledFrameOffset.set(animationOffset.x * scale.x, animationOffset.y * scale.y);
		newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x + globalOffset.x;
		newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y + globalOffset.y;

		if (isPixelPerfectRender(camera)) newRect.floor();
		newRect.setSize(frameWidth * Math.abs(scale.x), frameHeight * Math.abs(scale.y));
		return BetterRect.newGetRotatedBounds(newRect, angle, _scaledOrigin, newRect, _scaledFrameOffset);
	}
	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__offsetFlipX || __offsetFlipY) {
			if (__offsetFlipX) scale.x *= -1;
			if (__offsetFlipY) scale.y *= -1;
			final bounds = _getScreenBounds(newRect, camera);
			if (__offsetFlipX) scale.x *= -1;
			if (__offsetFlipY) scale.y *= -1;
			return bounds;
		}
		return _getScreenBounds(newRect, camera);
	}

	override function drawComplex(camera:FlxCamera):Void {
		_frame.prepareMatrix(_matrix, flixel.graphics.frames.FlxFrame.FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.translate(-animationOffset.x, -animationOffset.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();
			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtract(offset).add(globalOffset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera)) {
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	// for now
	/* override public function clone():NovaSprite {
		var returner = new NovaSprite();
		returner.loadSprite(this.filePath);
		return returner;
	} */

	override public function destroy() {
		globalOffset.put();
		animationOffset.put();
		_scaledFrameOffset.put();
		super.destroy();
	}
}

class BetterRect extends FlxRect {
	public static function newGetRotatedBounds(parent:FlxRect, degrees:Float, ?origin:FlxPoint, ?newRect:FlxRect, ?innerOffset:FlxPoint):FlxRect {
		origin ??= FlxPoint.weak();
		newRect ??= FlxRect.get();
		innerOffset ??= FlxPoint.weak();

		degrees = degrees % 360;
		if (degrees == 0) {
			newRect.set(parent.x - innerOffset.x, parent.y - innerOffset.y, parent.width, parent.height);
			origin.putWeak();
			innerOffset.putWeak();
			return newRect;
		}

		if (degrees < 0)
			degrees += 360;

		var radians = flixel.math.FlxAngle.TO_RAD * degrees;
		var cos = Math.cos(radians);
		var sin = Math.sin(radians);

		var left = -origin.x - innerOffset.x;
		var top = -origin.y - innerOffset.y;
		var right = -origin.x + parent.width - innerOffset.x;
		var bottom = -origin.y + parent.height - innerOffset.y;
		if (degrees < 90) {
			newRect.x = parent.x + origin.x + cos * left - sin * bottom;
			newRect.y = parent.y + origin.y + sin * left + cos * top;
		} else if (degrees < 180) {
			newRect.x = parent.x + origin.x + cos * right - sin * bottom;
			newRect.y = parent.y + origin.y + sin * left + cos * bottom;
		} else if (degrees < 270) {
			newRect.x = parent.x + origin.x + cos * right - sin * top;
			newRect.y = parent.y + origin.y + sin * right + cos * bottom;
		} else {
			newRect.x = parent.x + origin.x + cos * left - sin * top;
			newRect.y = parent.y + origin.y + sin * right + cos * top;
		}
		// temp var, in case input rect is the output rect
		var newHeight = Math.abs(cos * parent.height) + Math.abs(sin * parent.width);
		newRect.width = Math.abs(cos * parent.width) + Math.abs(sin * parent.height);
		newRect.height = newHeight;

		origin.putWeak();
		innerOffset.putWeak();
		return newRect;
	}
}