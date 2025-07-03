package backend;

import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.frontEnds.AssetFrontEnd;
import openfl.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Assets {
	// can't find a way to reference where a Sound's asset path is, unlike FlxGraphic
	private static var _soundReference:Map<Sound, String> = [];

	public static function init():Void {
		final oldExists = FlxG.assets.exists;
		FlxG.assets.exists = (id, ?type) -> {
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
				return oldExists(id, type);

			#if FLX_DEFAULT_SOUND_EXT
			// add file extension
			if (type == SOUND)
				id = FlxG.assets.addSoundExt(id);
			#end

			return sys.FileSystem.exists(path(id, type));
		}

		final oldLocal = FlxG.assets.isLocal;
		FlxG.assets.isLocal = (id, ?type, cache = true) -> {
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
				return oldLocal(id, type, cache);

			#if FLX_DEFAULT_SOUND_EXT
			// add file extension
			if (type == SOUND)
				id = addSoundExt(id);
			#end

			return true;
		}

		final oldGet = FlxG.assets.getAssetUnsafe;
		FlxG.assets.getAssetUnsafe = (id, type, cache = true) -> {
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
				return oldGet(id, type, cache);

			// load from custom assets directory
			final canUseCache = cache && OpenFlAssets.cache.enabled;

			final asset:Any = switch(type) {
				case TEXT: // No caching
					// band-aid fix for xml's
					if (id.toLowerCase().endsWith('.xml'))
						type = null;
					sys.io.File.getContent(path(id, type));

				case BINARY:
					sys.io.File.getBytes(path(id, type));

				case IMAGE if (canUseCache && OpenFlAssets.cache.hasBitmapData(id)): // Check cache
					var bitmap = OpenFlAssets.cache.getBitmapData(id);
					@:privateAccess
					if (/* ClientPrefs.data.cacheOnGPU && */ bitmap.image != null) {
						bitmap.lock();
						if (bitmap.__texture == null) {
							bitmap.image.premultiplied = true;
							bitmap.getTexture(FlxG.stage.context3D);
						}
						bitmap.getSurface();
						bitmap.disposeImage();
						bitmap.image.data = null;
						bitmap.image = null;
						bitmap.readable = true;
					}
					bitmap;
				case SOUND if (canUseCache && OpenFlAssets.cache.hasSound(id)):
					OpenFlAssets.cache.getSound(id);
				case FONT if (canUseCache && OpenFlAssets.cache.hasFont(id)):
					OpenFlAssets.cache.getFont(id);

				case IMAGE: // Get asset and set cache
					var bitmap = BitmapData.fromFile(path(id, type));
					if (canUseCache)
					{
						OpenFlAssets.cache.setBitmapData(id, bitmap);
					}

					@:privateAccess
					if (/* ClientPrefs.data.cacheOnGPU && */ bitmap.image != null) {
						bitmap.lock();
						if (bitmap.__texture == null) {
							bitmap.image.premultiplied = true;
							bitmap.getTexture(FlxG.stage.context3D);
						}
						bitmap.getSurface();
						bitmap.disposeImage();
						bitmap.image.data = null;
						bitmap.image = null;
						bitmap.readable = true;
					}

					var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);
					FlxG.bitmap.addGraphic(graphic);

					bitmap;
				case SOUND:
					final sound = Sound.fromFile(path(id, type));
					if (canUseCache)
					{
						OpenFlAssets.cache.setSound(id, sound);
						_soundReference.set(sound, id);
					}

					sound;
				case FONT:
					final font = Font.fromFile(path(id, type));
					if (canUseCache)
					{
						OpenFlAssets.cache.setFont(id, font);
						Font.registerFont(font);
					}
					font;
			}

			return asset;
		}
	}

	public static function getBitmapFont(id:String):String {
		var path:String = 'assets/images/$id.fnt';
		if (FileSystem.exists(path))
			return File.getContent(path);
		return '';
	}

	public static function path(id:String, type:FlxAssetType):String {
		return switch(type) {
			case BINARY: '$id';
			case TEXT: '$id';
			case IMAGE: '$id';
			case SOUND: '$id';
			case FONT: '$id';
			default: '$id';
		}
	}

	public static function frames(id:String):FlxAtlasFrames {
		if (!FlxG.assets.exists(id, IMAGE) && !FlxG.assets.exists(Path.join(['images', id + '.xml']), null))
			return null;
		return FlxAtlasFrames.fromSparrow(id, Path.join(['images', id + '.xml']));
	}

	public static function list(path:String):Array<String> {
		var list:Array<String> = [];
		if (FileSystem.exists(Assets.path(path, null)))
			list = FileSystem.readDirectory(Assets.path(path, null));
		return list;
	}
}
