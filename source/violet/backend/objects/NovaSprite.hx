package violet.backend.objects;

#if ANIMATE_SUPPORT
import animate.FlxAnimate;
#end
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import openfl.display.BitmapData;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import violet.data.animation.AnimationData;

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

	public function loadSprite(path:String):NovaSprite {
		if (path.startsWith("https://")) {
			fromWeb(path);
		} else if (Paths.fileExists('${haxe.io.Path.withoutExtension(path)}/Animation.json', true)) {
			#if ANIMATE_SUPPORT
			this.filePath = '${haxe.io.Path.withoutExtension(path)}/Animation.json';
			this.fileName = Paths.getFileName(path, true);
			this.animated = true;
			this.frames = animate.FlxAnimateFrames.fromAnimate(haxe.io.Path.withoutExtension(path));
			this.onLoaded();
			#else
			trace('warning:Atlas\'s aren\'t supported in this build of Violet Engine.');
			#end
		} else {
			if (Paths.fileExists(path.replace(".png", ".xml"), true)) {
				this.filePath = path;
				this.fileName = Paths.getFileName(path, true);
				this.animated = true;
				this.frames = FlxAtlasFrames.fromSparrow(path/* Cache.image(path, 'root', null) */, path.replace(".png", ".xml"));
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

	@:unreflective
	private var prevUrl:String = "";
	@:unreflective
	private function fromWeb(url:String):NovaSprite {
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
				var info = this.anims.get(name);
				this.offset.set(info.offset[0] ?? 0, info.offset[1] ?? 0);
				this.offset.set(this.offset.x - globalOffset.x, this.offset.y - globalOffset.y);
			}
		}
	}

	public function addAnim(name:String, prefix:String, ?indices:Array<Int>, ?offsets:Array<Float>, fps:Int = 24, looped:Bool = false, label:Bool = false):Void {
		if (#if ANIMATE_SUPPORT isAnimate #else false #end) {
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
		this.anims.set(name, {offset: offsets != null ? [-offsets[0], -offsets[1]] : [0, 0]});
	}

	public function addAnimFromJSON(data:AnimationData):Void {
		addAnim(data.name, data.prefix, data.frameIndices, data.offsets, data.frameRate, data.looped, data.byLabel);
	}

	// for now
	/* override public function clone():NovaSprite {
		var returner = new NovaSprite();
		returner.loadSprite(this.filePath);
		return returner;
	} */

	override public function destroy() {
		globalOffset.put();
		super.destroy();
	}
}