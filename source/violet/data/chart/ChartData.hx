package violet.data.chart;

import violet.data.song.SongData;

typedef ChartData = {
	var strumLines:Array<ChartStrumLine>;
	var events:Array<ChartEvent>;
	var meta:SongData;
	var codenameChart:Bool;
	var stage:String;
	var scrollSpeed:Float;
	var noteTypes:Array<String>;
	var ?noteStyle:String;

	var ?chartVersion:String;
	var ?fromMods:Bool;
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
	var ?noteStyle:String;
	var ?scrollSpeed:Float;
	var ?vocalsSuffix:String;
	var ?keyCount:Int;

	var ?strumLinePos:Float;
}

typedef ChartNote = {
	var time:Float;
	var id:Int;
	var sLen:Float;
	var ?type:Int;
}

typedef ChartEvent = {
	var name:Null<String>;
	var time:Float;
	var params:Array<Dynamic>;
	var ran:Bool; // TODO: make it not use this

	var type:Null<Int>; // DEPRECTATED: please use name.
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