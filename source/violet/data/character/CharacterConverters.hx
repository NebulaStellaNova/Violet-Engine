package violet.data.character;

import violet.data.animation.AnimationData;
import violet.backend.utils.ParseUtil;
import violet.backend.utils.ParseUtil.ParseColor;
import violet.data.character.CharacterData;
import violet.backend.utils.AnimationUtil;
import violet.backend.utils.StringUtil;
import violet.backend.utils.FileUtil;

import haxe.xml.Access;

class CharacterConverters {

	public static function nameFromId(id:String):String {
		var idSplit = id.replace('-', ' ').split(' ');
		for (i=>v in idSplit) idSplit[i] = StringUtil.capitalizeFirst(v);
		return idSplit.join(' ');
	}

	public static function fromCodenameEngine(path:String):Null<CharacterData> {
		var xmlData:Xml = Xml.parse(FileUtil.getFileContent(Paths.file(path)));
		var xmlAccess:Access = new Access(xmlData);
		var characterID:String = Paths.fileName(path);
		var characterName:String = nameFromId(characterID);

		var character = xmlAccess.node.character;

		if (d(character, 'sprite', null) == null) return null;

		var assetPath:String = 'characters/' + character.att.sprite;

		var xPosition:Float = Std.parseFloat(d(character, 'x', '0'));
		var yPosition:Float = Std.parseFloat(d(character, 'y', '0'));
		var interval:Float = Std.parseFloat(d(character, 'interval', '2'));
		var cameraX:Float = Std.parseFloat(d(character, 'camx', '0'));
		var cameraY:Float = Std.parseFloat(d(character, 'camy', '0'));
		var holdTime:Float = Std.parseFloat(d(character, 'holdTime', '4'));
		var isPlayer:Bool = d(character, 'isPlayer', 'false') == 'true';
		var flipX:Bool = d(character, 'flipX', 'false') == 'true';
		var icon:String = d(character, 'icon', characterID);
		var gameOverChar:String = d(character, 'gameOverChar', null);
		var tempColor:String = d(character, 'color', null);
		var color:Null<FlxColor> = tempColor != null ? ParseColor.fromString(tempColor) : null;
		var scale:Float = Std.parseFloat(d(character, 'scale', '1'));
		var antialiasing:Bool = d(character, 'antialiasing', 'true') == 'true';

		var characterData:CharacterData = {
			version: '1.0.0',
			name: characterName,
			assetPath: assetPath,
			scale: scale,
			healthIcon: icon,
			deathCharacter: gameOverChar,
			offsets: [xPosition, yPosition],
			cameraOffsets: [cameraX, cameraY],
			isPixel: !antialiasing,
			danceEvery: interval,
			singTime: holdTime,
			animations: [],
			flipX: flipX
		}

		var anims:Array<Access> = character.nodes.anim;
		for (i in anims) {
			var name:String = i.att.name;
			var prefix:String = i.att.anim;
			var looped:Bool = d(i, 'loop', 'false') == 'true';
			var frameRate:Float = Std.parseFloat(d(i, 'fps', '24'));
			var offsetX:Float = Std.parseFloat(d(i, 'x', '0'));
			var offsetY:Float = Std.parseFloat(d(i, 'y', '0'));
			var frameIndices:String = d(i, 'indices', null);
			var byLabel:Bool = d(i, 'label', 'true') == 'true';
			characterData.animations.push({
				name: name,
				prefix: prefix,
				looped: looped,
				frameRate: Math.round(frameRate),
				offsets: [offsetX, offsetY],
				frameIndices: frameIndices != null ? AnimationUtil.stringToIndices(frameIndices) : null,
				byLabel: byLabel
			});
		}

		return characterData;
	}


	private static function d(access:Access, attribute:String, def:String):String {
		return access.has.resolve(attribute) ? access.att.resolve(attribute) : def;
	}

	public static function fromPsych(path:String):Null<CharacterData> {
		var characterData = ParseUtil.json(path);
		if (characterData.image == null) return null;
		if (characterData.animations == null) return null;

		var characterID:String = Paths.fileName(path);
		var characterName:String = nameFromId(characterID);

		var out:CharacterData = {
			version: '1.0.0',
			name: characterName,
			assetPath: characterData.image,
			scale: characterData?.scale ?? 1,
			healthIcon: characterData?.healthicon ?? 'face',
			offsets: characterData?.position ?? [0.0, 0.0],
			cameraOffsets: characterData?.camera_position ?? [0.0, 0.0],
			flipX: characterData?.flip_x ?? false,
			isPixel: characterData?.no_antialiasing ?? false,
			animations: []
		}

		for (i in cast (characterData.animations, Array<Dynamic>)) {
			var anim:AnimationData = {
				name: i.anim,
				prefix: i.name,
				frameRate: i?.fps ?? 24,
				looped: i?.loop ?? false,
				frameIndices: i?.indices,
				offsets: cast i?.offsets ?? [0.0, 0.0]
			}
			out.animations.push(anim);
		}

		return out;
	}

	public static function fromVSlice(path:String):CharacterData {
		var characterData = ParseUtil.json(path);
		if (characterData.assetPath == null) return null;

		var characterID:String = Paths.fileName(path);
		var characterName:String = nameFromId(characterID);

		return {
			version: '1.0.0',
			name: characterName,
			assetPath: '${characterData.assetPath}'.replace('shared:', ''),
			scale: characterData?.scale ?? 1,
			healthIcon: characterData?.healthIcon?.id ?? characterID,
			offsets: characterData?.offsets ?? [0.0, 0.0],
			cameraOffsets: characterData?.cameraOffsets ?? [0.0, 0.0],
			flipX: characterData?.flipX ?? false,
			isPixel: characterData?.isPixel ?? false,
			animations: characterData.animations != null ? cast characterData.animations : []
		};
	}
}