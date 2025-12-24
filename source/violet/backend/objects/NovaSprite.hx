package violet.backend.objects;

import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.net.URLLoader;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;

typedef AnimationInfo = {
	var offset:Array<Float>;
}

class NovaSprite extends FlxSprite {
	public var filePath:String;
	public var fileName:String;

	public var animated:Bool = false;

	public var anims:Map<String, AnimationInfo> = new Map<String, AnimationInfo>();

	public var globalOffset:FlxPoint = new FlxPoint();

	public function new(x:Float = 0.0, y:Float = 0.0, ?path:String) {
		super(x, y);
		this.antialiasing = true;
		if (path != null)
			this.loadSprite(path);
	}

	public function loadSprite(path:String):NovaSprite {
		if (path.startsWith("https://")) {
			fromWeb(path);
		} else {
			if (Paths.fileExists(path.replace(".png", ".xml"), true)) {
				this.filePath = path;
				this.fileName = Paths.getFileName(path);
				this.animated = true;
				this.frames = FlxAtlasFrames.fromSparrow(path/* Cache.image(path, 'root', null) */, path.replace(".png", ".xml"));
				this.onLoaded(this);
			} else {
				this.loadGraphic(path);
				this.updateHitbox();
				this.onLoaded(this);
			}
		}
		return this;
	}

	dynamic function onLoaded(?self:NovaSprite):Void {

	}

	@:unreflective
	private var prevUrl:String = "";
	@:unreflective
	private function fromWeb(url:String) {
		url = url.split("?")[0];
		prevUrl = url;
		var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener("complete", (_:Dynamic)->
        {
			this.filePath = prevUrl;
            var bitmap:BitmapData = BitmapData.fromBytes(loader.data);

            this.loadGraphic(FlxGraphic.fromBitmapData(bitmap));
            this.updateHitbox();
			this.onLoaded(this);
        });
        loader.load(new URLRequest(url));
	}

	override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):NovaSprite {
		if (graphic is String) {
			this.filePath = graphic;
			this.fileName = Paths.getFileName(graphic);
		}
		return cast super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
	}

	public function playAnim(name:String, forced:Bool = false):Void {
		if (this.animation.exists(name)) {
			this.animation.play(name, forced);
			if (this.anims.exists(name)) {
				// TODO: Rodney, add animation offsets like how you did in your engine! -Rodney
				var info = this.anims.get(name);
				this.offset.set(info.offset[0] ?? 0, info.offset[1] ?? 0);
				this.offset.set(this.offset.x - globalOffset.x, this.offset.y - globalOffset.y);
			}
		}
	}

	public function addAnim(name:String, prefix:String, ?indices:Array<Int>, ?offsets:Array<Float>, fps:Int = 24, looped:Bool = false) {
		if (indices == null || indices.length == 0)
			this.animation.addByPrefix(name, prefix, fps, looped);
		else this.animation.addByIndices(name, prefix, indices, "", fps, looped);
		this.anims.set(name, {offset: offsets != null ? [-offsets[0], -offsets[1]] : [0, 0]});
	}

	// for now
	/* override public function clone():NovaSprite {
		var returner = new NovaSprite();
		returner.loadSprite(this.filePath);
		return returner;
	} */
}