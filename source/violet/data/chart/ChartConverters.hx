package violet.data.chart;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import yaml.Parser;
import yaml.Renderer;
import yaml.Yaml;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;
import violet.data.character.CharacterRegistry;
import violet.data.chart.ChartData;
import violet.data.chart.ChartRegistry.ChartCache;
import violet.data.song.SongData;

enum FileType {
	NONE;
	YAML;
	XML;
	OBJECT;
}

enum ChartFormat {
	CODENAME;
	PSYCH;
	LEGACY;
	VSLICE;
	VIOLET;
	KADE;
	IMAGINATIVE;
}

typedef VSliceEntry = {
	var metadata:Dynamic;
	var chart:Dynamic;
}

class ChartConverters {

	public static function metaFromVSlice(songID, ?varient:String) {
		var meta:Dynamic = _get_vslice_meta(songID, varient);
		var metaOut:SongData = {
			name: songID,
			displayName: meta.songName,

			composer: meta.artist,
			charter: meta.charter,

			icon: meta?.icon ?? CharacterRegistry.fetchEntry(meta.playData.characters.opponent)?.healthIcon ?? "face",

			variants: meta.playData.songVariations,
			difficulties: meta.playData.difficulties,
			ratings: meta.playData.ratings,
			album: meta.playData.album,

			gradient: meta.gradient,
			freeplayCapsule: meta.freeplayCapsule,

			instSuffix: meta.playData.characters.instrumental,

			hudStyle: meta.playData.hudStyle,

			bpm: meta.timeChanges[0].bpm,
			beatsPerMeasure: meta.timeChanges[0].n,
			stepsPerBeat: meta.timeChanges[0].d,
		}
		return metaOut;
	}

	public static function chartFromVSlice(songID, difficulty:String, ?varient:String):ChartData {
		var meta:Dynamic = _get_vslice_meta(songID, varient);
		var chart:Dynamic = _get_vslice_chart(songID, varient);

		var chartOut:ChartData = {
			strumLines: [],
			events: [],
			stage: aliasVSliceStage(meta.playData.stage),
			noteStyle: meta.playData.noteStyle,
			scrollSpeed: Reflect.field(chart.scrollSpeed, difficulty),
			noteTypes: []
		}
		var opp = {
			characters: [meta.playData.characters.opponent],
			position: 'dad',
			type: OPPONENT,
			notes: [],
			vocalsSuffix: (meta.playData.characters?.opponentVocals ?? [meta.playData.characters?.opponent])[0]
		};
		var play = {
			characters: [meta.playData.characters.player],
			position: 'boyfriend',
			type: PLAYER,
			notes: [],
			vocalsSuffix: (meta.playData.characters?.playerVocals ?? [meta.playData.characters?.player])[0]
		}
		var spec = {
			characters: [meta.playData.characters.girlfriend],
			position: 'girlfriend',
			type: ADDITIONAL,
			visible: false,
			notes: []
		}
		chartOut.strumLines.push(opp);
		chartOut.strumLines.push(play);
		chartOut.strumLines.push(spec);

		for (note in cast ((Reflect.field(chart.notes, difficulty) ?? []), Array<Dynamic>)) {
			var time = note.t;
			var data = note.d;
			var length = note.l;
			var kind = note.k;
			var extra = note.p;

			var dir = data % 4;
			var strumlineID:Int = Math.floor(data / 4);

			var noteOut:ChartNote = {
				time: time,
				id: dir,
				sLen: length,
				extra: extra,
				type: kind
			}
			if (noteOut.type == null) Reflect.deleteField(noteOut, 'type');
			if (noteOut.extra == null) Reflect.deleteField(noteOut, 'extra');

			switch (strumlineID) {
				case 0:
					play.notes.push(noteOut);
				case 1:
					opp.notes.push(noteOut);
			}
		}

		var outEvents:Array<ChartEvent> = [];
		for (i in chart?.events ?? []) {
			switch (i.e) {
				case 'FocusCamera':
					var e:Null<Int> = Std.parseInt(i.v.toString());
					var target:Int = e != null ? e : i.v.char;
					var x:Null<Float> = i.v.x;
					var y:Null<Float> = i.v.y;
					var dur:Null<Float> = i.v.duration;
					var ease:Null<String> = i.v.ease;
					var easeDir:Null<String> = i.v.easeDir;

					if (target != -1) {
						if (ease == 'CLASSIC' || ease == null) {
							outEvents.push({
								name: 'Camera Movement',
								time: i.t,
								params: [[1, 0, 2][target]]
							});
						} else {
							outEvents.push({
								name: 'Camera Tween Focus',
								time: i.t,
								params: [
									[1, 0, 2][target],
									ease == 'INSTANT' ? 0.0001 : dur,
									ease,
									easeDir,
									x,
									y
								]
							});
						}
					} else {
						outEvents.push({
							name: 'Camera Position',
							time: i.t,
							params: [
								x,
								y,
								easeDir,
								ease == 'INSTANT' ? 0.0001 : dur,
								ease
							]
						});
					}
				case 'ZoomCamera':
					var zoom:Float = i.v.zoom;
					var dur:Float = i.v.duration;
					var ease:String = i.v.ease;
					var easeDir:String = i.v.easeDir;
					outEvents.push({
						name: 'Camera Zoom',
						time: i.t,
						params: [
							true,
							zoom,
							'camGame',
							ease == 'INSTANT' ? 0.0001 : dur,
							ease,
							easeDir
						]
					});
				case 'SetCameraBop':
					var rate = i.v.rate;
					var offset = i.v.offset;
					var intensity = i.v.intensity;
					outEvents.push({
						name: 'Camera Modulo Change',
						time: i.t,
						params: [
							rate,
							offset,
							intensity
						]
					});
				case 'PlayAnimation':
					var anim:String = i.v.anim;
					var target:String = i.v.target;
					outEvents.push({
						name: 'Play Animation',
						time: i.t,
						params: [
							['dad', 'boyfriend', 'girlfriend'].indexOf(target),
							anim
						]
					});

			}
		}

		var numerator:Int = 4;
		var denominator:Int = 4;
		var changes:Array<SongTimeChange> = meta.timeChanges;
		for (i=>timeChange in changes) {
			if (timeChange.n != null) numerator = timeChange.n;
			if (timeChange.d != null) denominator = timeChange.d;
			if (i == 0) continue;
			var data:{?n:Int, ?d:Int, b:Float, t:Float, bpm:Float} = timeChange;
			if (data.b != 0) {
				outEvents.push({
					name: 'Continuous BPM Change',
					time: data.t,
					params: [
						data.bpm,
						data.b * denominator
					]
				});
			} else {
				outEvents.push({
					name: "BPM Change",
					time: data.t,
					params: [ data.bpm ]
				});
			}
			if (data.n != null || data.d != null) {
				outEvents.push({
					name: "Time Signature Change",
					time: data.t,
					params: [
						numerator,
						denominator,
						false
					]
				});
			}
		}
		chartOut.events = outEvents;
		return chartOut;
	}

	private static var _cached_vslice_meta:Map<String, Dynamic> = new Map<String, Dynamic>();
	private static var _cached_vslice_chart:Map<String, Dynamic> = new Map<String, Dynamic>();

	private static function _get_vslice_meta(songID, ?varient:String):Dynamic {
		var fileName = '$songID-metadata${varient != null ? '-$varient' : ''}';
		if (_cached_vslice_meta.exists(fileName)) return _cached_vslice_meta.get(fileName);

		if (Paths.json('songs/$songID/$fileName') == '') return null;
		var meta = ParseUtil.jsonDirect('songs/$songID/$fileName');
		if (meta.playData.noteStyle == 'funkin')
			meta.playData.noteStyle = 'default';
		meta = ParseUtil.applyMerge(meta, '_merge/data/songs/$songID/$fileName');
		_cached_vslice_meta.set(fileName, meta);
		return meta;
	}

	private static function _get_vslice_chart(songID, ?varient:String):Dynamic {
		var fileName = '$songID-chart${varient != null ? '-$varient' : ''}';
		if (_cached_vslice_chart.exists(fileName)) return _cached_vslice_chart.get(fileName);

		if (Paths.json('songs/$songID/$fileName') == '') return null;
		var chart = ParseUtil.jsonDirect('songs/$songID/$fileName');
		_cached_vslice_chart.set(fileName, chart);
		return chart;
	}

	public static function aliasVSliceStage(stageID:String):String {
		var aliases:Map<String, String> = [
			"limoRide" => "limo",
			"limoRideErect" => "limo-erect",
			"tankmanBattlefield" => "tank",
			"tankmanBattlefieldErect" => "tank-erect",
			"phillyStreets" => "philly-streets",
			"phillyTrain" => "train",
			"phillyTrainErect" => "train-erect",
			"mallXmas" => "mall",
			"mallXmasErect" => "mall-erect",
			"schoolErect" => "school-erect",
			"schoolEvil" => "school-evil",
			"schoolEvilErect" => "school-evil-erect",
			"spookyMansion" => "spooky",
			"spookyMansionErect" => "spooky-erect"
		];
		if (!aliases.exists(stageID)) return stageID;
		return aliases.get(stageID);
	}
}

typedef SongTimeChange = {
	public var t:Float;
	public var ?b:Float;
	public var bpm:Float;
	public var ?n:Int;
	public var ?d:Int;
	public var ?bt:Array<Int>;
}