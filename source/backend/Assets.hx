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
class Assets
{
	// can't find a way to reference where a Sound's asset path is, unlike FlxGraphic
	private static var _soundReference:Map<Sound, String>;

	public static function init():Void
	{
		_soundReference = [];

		final assets = FlxG.assets;

		final oldExists = assets.exists;
		assets.exists = (id, ?type) ->
		{
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
				return oldExists(id, type);

			#if FLX_DEFAULT_SOUND_EXT
			// add file extension
			if (type == SOUND)
				id = assets.addSoundExt(id);
			#end

			return sys.FileSystem.exists(path(id, type));
		};

		final oldLocal = assets.isLocal;
		assets.isLocal = (id, ?type, cache = true) ->
		{
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
				return oldLocal(id, type, cache);

			#if FLX_DEFAULT_SOUND_EXT
			// add file extension
			if (type == SOUND)
				id = addSoundExt(id);
			#end

			return true;
		};

		final oldGet = assets.getAssetUnsafe;
		assets.getAssetUnsafe = (id, type, cache = true) ->
		{
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
				return oldGet(id, type, cache);

			// load from custom assets directory
			final canUseCache = cache && OpenFlAssets.cache.enabled;

			final asset:Any = switch type
			{
				// No caching
				case TEXT:
					// band-aid fix for xmls
					if (id.toLowerCase().endsWith('.xml'))
						type = null;
					sys.io.File.getContent(path(id, type));
				case BINARY:
					sys.io.File.getBytes(path(id, type));

				// Check cache
				case IMAGE if (canUseCache && OpenFlAssets.cache.hasBitmapData(id)):
					OpenFlAssets.cache.getBitmapData(id);
				case SOUND if (canUseCache && OpenFlAssets.cache.hasSound(id)):
					OpenFlAssets.cache.getSound(id);
				case FONT if (canUseCache && OpenFlAssets.cache.hasFont(id)):
					OpenFlAssets.cache.getFont(id);

				// Get asset and set cache
				case IMAGE:
					final bitmap = BitmapData.fromFile(path(id, type));
					if (canUseCache)
					{
						OpenFlAssets.cache.setBitmapData(id, bitmap);
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
		};
	}

	public static function getBitmapFont(id:String):String
	{
		var path:String = 'assets/images/$id.fnt';
		if (FileSystem.exists(path))
			return File.getContent(path);

		return '';
	}

	public static function path(id:String, type:FlxAssetType):String
	{
		return switch type
		{
			case BINARY: '$id';
			case TEXT: '$id';
			case IMAGE: '$id';
			case SOUND: '$id';
			case FONT: '$id';
			case null: '$id';
		};
	}

	public static function frames(id:String):FlxAtlasFrames
	{
		if (!FlxG.assets.exists(id, IMAGE) && !FlxG.assets.exists(Path.join(['images', id + '.xml']), null))
			return null;

		return FlxAtlasFrames.fromSparrow(id, Path.join(['images', id + '.xml']));
	}

	public static function list(path:String):Array<String>
	{
		var list:Array<String> = [];

		if (FileSystem.exists(Assets.path(path, null)))
			list = FileSystem.readDirectory(Assets.path(path, null));

		return list;
	}
}
