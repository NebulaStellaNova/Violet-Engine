package violet.data.stage;

import violet.backend.utils.ParseUtil;
import violet.backend.utils.ParseUtil.ParseColor;
import violet.backend.utils.AnimationUtil;
import violet.backend.utils.StringUtil;
import violet.backend.utils.FileUtil;
import violet.data.stage.StageData;

import haxe.xml.Access;

class StageConverters {

	public static function fromCodenameEngine(path:String):Null<StageData> {
		var xmlData:Xml = Xml.parse(FileUtil.getFileContent(Paths.file(path)));
		var xmlAccess:Access = new Access(xmlData);
		var stageID:String = Paths.fileName(path);
		var idSplit = stageID.replace('-', ' ').split(' ');
		for (i=>v in idSplit) idSplit[i] = StringUtil.capitalizeFirst(v);
		var stageName:String = idSplit.join(' ');

		var stage = xmlAccess.node.stage;

		var stageData:StageData = {
			name: stageName,
			basicCharPos: true,
			zoom: Std.parseFloat(d(stage, 'zoom', '0.6')),
			directory: d(stage, 'folder', ''),
			props: [],
			cameraPosition: [
				Std.parseFloat(d(stage, 'startCamPosX', '0')),
				Std.parseFloat(d(stage, 'startCamPosY', '0'))
			]
		}

		for (i in stage.elements) {
			var propToAdd:Null<StagePropData> = null;
			switch (i.name) {
				case 'sprite' | 'spr' | 'sparrow' | 'high-memory' | 'low-memory':
					if (!i.has.sprite || !i.has.name) continue;
					propToAdd = {
						type: PROP,
						id: i.att.name,
						name: i.att.name,
						assetPath: i.att.sprite,
						position: [
							Std.parseFloat(d(i, 'x', '0')),
							Std.parseFloat(d(i, 'y', '0'))
						],
						scroll: [
							Std.parseFloat(d(i, 'scrollx', null) != null ? i.att.scrollx : d(i, 'scroll', '1')),
							Std.parseFloat(d(i, 'scrolly', null) != null ? i.att.scrolly : d(i, 'scroll', '1'))
						],
						scale: [
							Std.parseFloat(d(i, 'scalex', null) != null ? i.att.scalex : d(i, 'scale', '1')),
							Std.parseFloat(d(i, 'scaley', null) != null ? i.att.scaley : d(i, 'scale', '1'))
						],
						alpha: Std.parseFloat(d(i, 'alpha', '1')),
						angle: Std.parseFloat(d(i, 'angle', '0')),
						color: d(i, 'color', '#FFFFFF'),
						isPixel: d(i, 'antialiasing', 'true') == 'true',
						flipX: d(i, 'flipX', 'false') == 'true',
						flipY: d(i, 'flipY', 'false') == 'true',
						animations: []
					}
					if (i.hasNode.anim) {
						var anims:Array<Access> = i.nodes.anim;
						for (i in anims) {
							propToAdd.animations.push({
								name: i.att.name,
								prefix: i.att.anim,
								looped: d(i, 'loop', 'false') == 'true',
								frameRate: Math.round(Std.parseFloat(d(i, 'fps', '24'))),
								offsets: [
									Std.parseFloat(d(i, 'x', '0')),
									Std.parseFloat(d(i, 'y', '0'))
								],
								frameIndices: d(i, 'indices', null) != null ? AnimationUtil.stringToIndices(d(i, 'indices', null)) : null,
								byLabel: d(i, 'label', 'true') == 'true'
							});
						}
					}
				case 'box' | 'solid':
					if (!i.has.name || !i.has.width || !i.has.height) continue;
					propToAdd = {
						type: SOLID,
						id: i.att.name,
						name: i.att.name,
						position: [
							Std.parseFloat(d(i, 'x', '0')),
							Std.parseFloat(d(i, 'y', '0'))
						],
						width: Std.parseInt(i.att.width),
						height: Std.parseInt(i.att.height),
						color: i.att.color,
						alpha: Std.parseFloat(d(i, 'alpha', '1')),
						angle: Std.parseFloat(d(i, 'angle', '0')),
						scroll: [
							Std.parseFloat(d(i, 'scrollx', null) != null ? i.att.scrollx : d(i, 'scroll', '1')),
							Std.parseFloat(d(i, 'scrolly', null) != null ? i.att.scrolly : d(i, 'scroll', '1'))
						]
					}
				case 'bf' | 'boyfriend' | 'player':
					propToAdd = getXmlCharData('player', i);
				case 'girlfriend' | 'gf':
					propToAdd = getXmlCharData('spectator', i);
				case 'dad' | 'opponent':
					propToAdd = getXmlCharData('opponent', i);
				case 'character' | 'char':
					propToAdd = getXmlCharData(i.att.name, i);
				case 'ratings' | 'combo':
					propToAdd = {
						id: 'combo',
						type: COMBO,
						position: [
							Std.parseFloat(d(i, 'x', '0')) + 90, // to account for centering
							Std.parseFloat(d(i, 'y', '0'))
						]
					}
			}
			if (propToAdd != null) stageData.props.push(propToAdd);
		}
		return stageData;
	}

	private static function getXmlCharData(id:String, i:Access):StagePropData {
		return {
			id: id,
			type: CHARACTER,
			position: [
				Std.parseFloat(d(i, 'x', '0')),
				Std.parseFloat(d(i, 'y', '0'))
			],
			cameraOffsets: [
				Std.parseFloat(d(i, 'camxoffset', '0')),
				Std.parseFloat(d(i, 'camyoffset', '0'))
			],
			alpha: Std.parseFloat(d(i, 'alpha', '1')),
			angle: Std.parseFloat(d(i, 'angle', '0')),
			flipX: d(i, 'flip', 'false') == 'true' || d(i, 'flipX', 'false') == 'true',
			scale: [
				Std.parseFloat(d(i, 'scalex', null) != null ? i.att.scalex : d(i, 'scale', '1')),
				Std.parseFloat(d(i, 'scaley', null) != null ? i.att.scaley : d(i, 'scale', '1'))
			],
			scroll: [
				Std.parseFloat(d(i, 'scrollx', null) != null ? i.att.scrollx : d(i, 'scroll', (id == 'spectator' ? '0.9' : '1'))),
				Std.parseFloat(d(i, 'scrolly', null) != null ? i.att.scrolly : d(i, 'scroll', (id == 'spectator' ? '0.9' : '1')))
			]
		}
	}

	private static function d(access:Access, attribute:String, def:String):String {
		return access.has.resolve(attribute) ? access.att.resolve(attribute) : def;
	}

	public static function fromVSlice(path:String):StageData {
		var stageData = ParseUtil.json(path);
		var props:Array<StagePropData> = [];

		var out:StageData = {
			cameraPosition: [0, 0],
			name: stageData.name,
			zoom: stageData.cameraZoom,
			directory: 'stages/' + stageData.directory,
			props: stageData.props
		}

		var bf:StageDataCharacter = stageData.characters.bf;
		var data:StagePropData = {
			id: 'player',
			type: CHARACTER,
			zIndex: bf?.zIndex,
			position: bf?.position,
			cameraOffsets: bf?.cameraOffsets,
			scale: [bf?.scale ?? 1, bf?.scale ?? 1],
			scroll: bf?.scroll,
			angle: bf?.angle,
			alpha: bf?.alpha
		};
		out.props.push(data);

		var gf:StageDataCharacter = stageData.characters.gf;
		var data:StagePropData = {
			id: 'spectator',
			type: CHARACTER,
			zIndex: gf?.zIndex,
			position: gf?.position,
			cameraOffsets: gf?.cameraOffsets,
			scale: [gf?.scale ?? 1, gf?.scale ?? 1],
			scroll: gf?.scroll,
			angle: gf?.angle,
			alpha: gf?.alpha
		};
		out.props.push(data);

		var dad:StageDataCharacter = stageData.characters.dad;
		var data:StagePropData = {
			id: 'opponent',
			type: CHARACTER,
			zIndex: dad?.zIndex,
			position: dad?.position,
			cameraOffsets: dad?.cameraOffsets,
			scale: [dad?.scale ?? 1, dad?.scale ?? 1],
			scroll: dad?.scroll,
			angle: dad?.angle,
			alpha: dad?.alpha
		};
		out.props.push(data);

		return out;
	}
}

typedef StageDataCharacter =
{
  var ?zIndex:Int;
  var ?position:Array<Float>;
  var ?scale:Float;
  var ?cameraOffsets:Array<Float>;
  var ?scroll:Array<Float>;
  var ?alpha:Float;
  var ?angle:Float;
};