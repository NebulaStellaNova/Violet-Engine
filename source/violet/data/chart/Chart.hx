package violet.data.chart;

import violet.data.chart.ChartData;
import violet.data.song.Song;
import violet.data.song.SongRegistry;

class Chart {

	public var id:String;
	public var _data:ChartData;

	public final scrollSpeed:Float;
	public var noteTypes:Array<String>;
	function get_noteTypes():Array<String> {
		if (_data.noteTypes == null) return [];
		return _data.noteTypes.copy();
	}
	public final noteStyle:String;

	public final strumLines:Array<_ChartStrumLine> = [];
	public var events(get, never):Array<ChartEvent>;
	function get_events():Array<ChartEvent> {
		if (_data.events == null) return [];
		return _data.events.copy();
	}

	public var meta(get, never):Song;
	function get_meta():Song {
		return SongRegistry.getSongByID(id);
	}

	public final stage:String;

	public final chartDifficulty:String;
	public final chartVariant:Null<String>;

	public function new(id:String, diff:String, ?variant:String) {
		this._data = ChartRegistry.fetchChart('$id:$diff${variant == null ? '' : ':${variant}'}');
		this.id = id;

		stage = _data.stage;
		scrollSpeed = _data.scrollSpeed;
		chartDifficulty = diff;
		chartVariant = variant;
		noteStyle = _data.noteStyle ?? 'default';

		for (data in _data.strumLines) {
			data.noteStyle ??= noteStyle;
			strumLines.push(new _ChartStrumLine(data));
		}
	}

}

class _ChartStrumLine {

	public var _data:ChartStrumLine;

	public final type:ChartStrumLineType;

	public var characters(get, never):Array<String>;
	function get_characters():Array<String> {
		return _data?.characters ?? [];
	}

	public var notes(get, never):Array<ChartNote>;
	function get_notes():Array<ChartNote> {
		return _data?.notes ?? [];
	}

	public final visible:Bool;
	public final charStagePosition:String;

	var _strumPos:Array<Float> = [];
	public var strumPosIsPure(default, null):Bool;
	public var strumPosition(get, never):Array<Float>;
	function get_strumPosition():Array<Float> {
		strumPosIsPure = true;
		final defaultX:Float = switch (type) {
			case OPPONENT: 0.25;
			case PLAYER: 0.75;
			case ADDITIONAL: 0.5;
		}

		if (_data.strumPos == null) {
			strumPosIsPure = false;
			return [_data?.strumLinePos ?? defaultX, 50];
		}
		_strumPos.resize(2);
		for (i => _ in _data.strumPos)
			_strumPos[i] = _data.strumPos[i] ?? (i == 0 ? 0 : 50);

		if (_strumPos[0] == 0) {
			strumPosIsPure = false;
			_strumPos[0] = defaultX;
		}

		return _strumPos.copy();
	}

	public final keyCount:Int;

	public final strumScale:Float;
	public final strumSpacing:Float;

	public final noteStyle:String;

	public final scrollSpeed:Null<Float>;
	public final vocalsSuffix:Null<String>;

	public function new(data:ChartStrumLine) {
		_data = data;
		type = _data.type;
		visible = _data.visible ?? true;
		charStagePosition = _data.position;
		keyCount = _data.keyCount ?? 4;
		strumScale = _data.strumScale ?? 1;
		strumSpacing = _data.strumSpacing ?? 1;
		noteStyle = _data.noteStyle ?? 'default';
		scrollSpeed = _data.scrollSpeed;
		vocalsSuffix = _data.vocalsSuffix;
		inline get_strumPosition(); // running here so it sets "strumPosIsPure"
	}

}