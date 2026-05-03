package violet.data.chart;

import flixel.util.typeLimit.OneOfTwo;
import violet.data.character.CharacterRegistry;
import sys.io.File;
import violet.data.song.SongData;
import sys.FileSystem;
import haxe.io.Path;
import moonchart.formats.fnf.FNFKade;
import moonchart.formats.fnf.legacy.FNFPsych;
import moonchart.formats.fnf.FNFVSlice;
import yaml.Renderer.RenderOptions;
import yaml.Parser.ParserOptions;
import yaml.Yaml;
import violet.data.chart.ChartRegistry.ChartCache;
import violet.backend.utils.FileUtil;
import violet.data.chart.ChartData;
import violet.backend.utils.ParseUtil;
import haxe.Json;
import Xml;
import yaml.Renderer;
import moonchart.formats.fnf.FNFCodename;


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

class ChartConverters {

	public static var blankChart(get, never):ChartData;
	static function get_blankChart() {
		return {
			strumLines: [],
			events: [],
			meta: { name: 'Unknown Song' },
			scrollSpeed: 1,
			noteTypes: [],
			stage: 'default',
			codenameChart: true
		};
	}

	public static function convertChart(chartCache:ChartCache):ChartData {
		if (chartCache?.fileExt == null) return blankChart;
		var parsedCache:Dynamic = parseFromCache(chartCache);
		var detectedFormat:ChartFormatChecker.ChartFileFormat = ChartFormatChecker.checkFormat(parsedCache);
		var convertedChart:ChartData;
		switch (detectedFormat) {
			case CODENAME:
				convertedChart = parsedCache;
			case VSLICE:
				convertedChart = fromVSlice(chartCache.filePath, chartCache.difficulty);
			case PSYCH:
				convertedChart = fromPsych(chartCache.filePath);
			case KADE:
				convertedChart = fromKade(chartCache.filePath, chartCache.difficulty);
			default:
				convertedChart = blankChart;
		}

		if (chartCache.eventsPath != '') {
			final parsedEvents = ParseUtil.jsonOrYaml(Path.withoutExtension(chartCache.eventsPath), 'root');
			convertedChart.events ??= [];
			for (i in parsedEvents.events ?? []) {
				i.global = true;
				convertedChart.events.push(i);
			}
		}

		for (i in convertedChart.events) {
			i.global ??= false;
		}

		return convertedChart;
	}

	public static function parseFromCache(chartCache:ChartCache):Dynamic {
		var parsedCache:Dynamic = {};
		switch (chartCache.fileExt) {
			case 'yaml':
				final options = new ParserOptions(); options.maps = false;
				parsedCache = Yaml.parse(FileUtil.getFileContent(chartCache.filePath), options);
			case 'json':
				parsedCache = Json.parse(FileUtil.getFileContent(chartCache.filePath));
		}
		return parsedCache;
	}

	public static function fromVSlice(chartPath, difficulty:String):ChartData {
		return cast new FNFCodename().fromFormat(new FNFVSlice().fromFile(chartPath, difficulty)).data; // Crashes someone fix this please
	}

	public static function fromPsych(chartPath:String):ChartData {
		return cast new FNFCodename().fromFormat(new FNFPsych().fromFile(chartPath)).data;
	}

	public static function fromKade(chartPath:String, difficulty:String):ChartData {
		var parsed = Json.parse(FileUtil.getFileContent(chartPath));
		parsed.song.eventObjects ??= [];
		return cast new FNFCodename().fromFormat(new FNFKade().fromJson(Json.stringify(parsed))).data;
	}

	public static function convertVSliceSong(songID, ?varient:String) {
		var suffix = '';
		if (varient != null) {
			suffix = '-$varient';
		}
		var path = Path.directory(Paths.json('songs/$songID/$songID-metadata$suffix'));
		var meta = ParseUtil.jsonDirect('songs/$songID/$songID-metadata$suffix');
		if (meta.playData.noteStyle == 'funkin')
			meta.playData.noteStyle = 'default';
		var chart = ParseUtil.jsonDirect('songs/$songID/$songID-chart$suffix');
		var metaOut:SongData = {
			name: songID,
			displayName: meta.songName,

			composer: meta.artist,
			charter: meta.charter,

			icon: meta?.icon != null ? meta.icon : CharacterRegistry.characterDatas.get(meta.playData.characters.opponent).healthIcon,

			variants: meta.playData.songVariations,
			difficulties: meta.playData.difficulties,
			ratings: meta.playData.ratings,
			album: meta.playData.album,

			gradient: meta.gradient,
			freeplayCapsule: meta.freeplayCapsule,

			instSuffix: meta.playData.characters.instrumental,

			bpm: meta.timeChanges[0].bpm,
			beatsPerMeasure: meta.timeChanges[0].n,
			stepsPerBeat: meta.timeChanges[0].d,
		}

		if (!FileSystem.exists('$path/charts' + (varient != null ? '/$varient' : '')))
			FileSystem.createDirectory('$path/charts' + (varient != null ? '/$varient' : ''));

		for (i in metaOut.difficulties) {
			var chartOut:ChartData = {
				strumLines: [],
				events: [],
				stage: aliasVSliceStage(meta.playData.stage),
				noteStyle: meta.playData.noteStyle,
				scrollSpeed: Reflect.field(chart.scrollSpeed, i),
				noteTypes: []
			}
			var opp = {
				characters: [meta.playData.characters.opponent],
				position: 'dad',
				type: OPPONENT,
				notes: [],
				vocalsSuffix: (meta.playData.characters?.opponentVocals ?? [])[0]
			};
			var play = {
				characters: [meta.playData.characters.player],
				position: 'boyfriend',
				type: PLAYER,
				notes: [],
				vocalsSuffix: (meta.playData.characters?.playerVocals ?? [])[0]
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

			for (note in cast (Reflect.field(chart.notes, i), Array<Dynamic>)) {
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

			var sub = varient != null ? '/$varient' : '';
			File.saveContent('$path/charts$sub/$i.json', Json.stringify(chartOut, null, '\t'));
		}

		var outEvents:{events:Array<ChartEvent>} = {
			events: []
		}
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
							outEvents.events.push({
								name: 'Camera Movement',
								time: i.t,
								params: [[1, 0, 2][target]]
							});
						} else {
							outEvents.events.push({
								name: 'Camera Tween Focus',
								time: i.t,
								params: [
									[1, 0, 2][target],
									ease == 'INSTANT' ? 0.0001 : dur,
									ease,
									easeDir
								]
							});
						}
					} else {
						outEvents.events.push({
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
					outEvents.events.push({
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
					outEvents.events.push({
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
					outEvents.events.push({
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
		for (i=>timeChange in meta.timeChanges) {
			if (timeChange.n != null) numerator = timeChange.n;
			if (timeChange.d != null) denominator = timeChange.d;
			if (i == 0) continue;
			var data:{?n:Int, ?d:Int, b:Float, t:Float, bpm:Float} = timeChange;
			if (data.b != 0) {
				outEvents.events.push({
					name: 'Continuous BPM Change',
					time: data.t,
					params: [
						data.bpm,
						data.b * denominator
					]
				});
			} else {
				outEvents.events.push({
					name: "BPM Change",
					time: data.t,
					params: [ data.bpm ]
				});
			}
			if (data.n != null || data.d != null) {
				outEvents.events.push({
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

		File.saveContent('$path/events$suffix.json', Json.stringify(outEvents, null, '\t'));

		File.saveContent('$path/meta$suffix.json', Json.stringify(metaOut, null, '\t'));
		for (i in meta.playData?.songVariations ?? []) {
			convertVSliceSong(songID, i);
		}

		ModdingAPI.onRegistryFinishReload.addOnce(()->{
			if (varient == null) FileUtil.deleteDirectory('$path/charts');
			FileUtil.deleteFile('$path/meta$suffix.json');
			FileUtil.deleteFile('$path/events$suffix.json');
		});
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

		];
		if (!aliases.exists(stageID)) return stageID;
		return aliases.get(stageID);
	}

	// public static function fromImaginative(chartPath:String) {
		// return case new FNFCodename()
	// }

	/**
	```haxe
	// Code for converting the chart to yaml.
	if (chartCache.fileExt != 'yaml') {
		sys.FileSystem.deleteFile(chartCache.filePath);
		Yaml.write(chartCache.filePath.replace('.${chartCache.fileExt}', '.yaml'), convertChartData(parsedCache,  detectJsonChartFormat(parsedCache)));
	}
	```*/

}