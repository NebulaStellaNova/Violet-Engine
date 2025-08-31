package backend.objects;

import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.display.Display.Package;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.filesystem.Paths;
import flixel.FlxSprite;

using StringTools;
class NovaSprite extends FlxSprite {
	public var filePath:String;
	public var fileName:String;

	var animated:Bool = false;

	var offsets:Map<String, Array<Float>> = [];

	public var globalOffset:FlxPoint = new FlxPoint();

	public function new(x:Float = 0.0, y:Float = 0.0, ?path:String) {
		super(x, y);
		if (path != null) {
			if (backend.Cache.spriteCache.exists(path)) {
				return backend.Cache.spriteCache.get(path);
			} else {
				this.loadSprite(path);
				backend.Cache.spriteCache.set(path, this.clone());
			}
		}
	}

	public function loadSprite(path:String):NovaSprite {
		if (Paths.fileExists(path.replace(".png", ".xml"))) {
			this.filePath = path;
			this.fileName = Paths.getFileName(path);
			this.animated = true;
			this.frames = FlxAtlasFrames.fromSparrow(path, path.replace(".png", ".xml"));
		} else {
			this.loadGraphic(path);
		}
		return this;
	}

	override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):NovaSprite {
		if (FlxStringUtil.getClassName(graphic) == "String") {
			this.filePath = graphic;
			this.fileName = Paths.getFileName(graphic);
		}
		return cast super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (this.animated) {
			if (offsets.get(this.animation.name) != null) {
				this.offset.set(offsets.get(this.animation.name)[0] ?? 0, offsets.get(this.animation.name)[1] ?? 0);
			} else {
				this.offset.set(0, 0);
			}
			this.offset.set(this.offset.x - globalOffset.x, this.offset.y - globalOffset.y);
		}
	}

	// @:unreflective  // no touchy by scripting

	public function playAnim(id, ?forced = false) {
		if (this.animation.exists(id)) {
			this.animation.play(id, forced);
			this.updateHitbox();
		} else
			log('Uh Ooooh! No animation found with ID: $id', WarningMessage);
		if (this.offsets.exists(id)) {
			this.offset.set(offsets.get(id)[0] ?? 0, offsets.get(id)[1] ?? 0);
			this.offset.set(this.offset.x - globalOffset.x, this.offset.y - globalOffset.y);
		}
	}

	public function addAnim(name:String, prefix:String, ?offsets:Array<Float>, looped:Bool = false, fps:Int = 24) {
		this.animation.addByPrefix(name, prefix, fps, looped);
		this.offsets.set(name, offsets != null ? [-offsets[0], -offsets[1]] : [0, 0]);
	}

	public function addAnimIndices(name:String, prefix:String, indices:Array<Int>, ?offsets:Array<Float>, looped:Bool = false, fps:Int = 24) {
		this.animation.addByIndices(name, prefix, indices, "", fps, looped);
		this.offsets.set(name, offsets != null ? [-offsets[0], -offsets[1]] : [0, 0]);
	}

	public function clone():NovaSprite {
		var returner = new NovaSprite();
		returner.loadSprite(this.filePath);
		return returner;
	}
}