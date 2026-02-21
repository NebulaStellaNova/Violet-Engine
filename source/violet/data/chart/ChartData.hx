package violet.data.chart;

import violet.data.song.SongData;

typedef ChartData = {
	public var strumLines:Array<ChartStrumLine>;
	public var events:Array<ChartEvent>;
	public var meta:SongData;
	public var codenameChart:Bool;
	public var stage:String;
	public var scrollSpeed:Float;
	public var noteTypes:Array<String>;

	public var ?chartVersion:String;
	public var ?fromMods:Bool;
}

typedef ChartStrumLine = {
	var characters:Array<String>;
	var type:ChartStrumLineType;
	var notes:Array<ChartNote>;
	var position:String;
	var ?visible:Bool;
	var ?strumPos:Array<Float>;
	var ?strumScale:Float;
	var ?strumSpacing:Float;
	var ?scrollSpeed:Float;
	var ?vocalsSuffix:String;
	@:default(4) var ?keyCount:Int;

	var ?strumLinePos:Float;
}

typedef ChartNote = {
	var time:Float;
	var id:Int;
	var type:Int;
	@:alias('sLen') var length:Float;
}

typedef ChartEvent = {
	var name:String;
	var time:Float;
	var params:Array<Dynamic>;
}

enum abstract ChartStrumLineType(Int) from Int to Int {
	/**
	 * STRUMLINE IS MARKED AS OPPONENT - WILL BE PLAYED BY CPU, OR PLAYED BY PLAYER IF OPPONENT MODE IS ON
	 */
	var OPPONENT = 0;
	/**
	 * STRUMLINE IS MARKED AS PLAYER - WILL BE PLAYED AS PLAYER, OR PLAYED AS CPU IF OPPONENT MODE IS ON
	 */
	var PLAYER = 1;
	/**
	 * STRUMLINE IS MARKED AS ADDITIONAL - WILL BE PLAYED AS CPU EVEN IF OPPONENT MODE IS ENABLED
	 */
	var ADDITIONAL = 2;
}