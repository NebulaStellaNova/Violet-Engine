package violet.data.song;

typedef SongData = {
    public var name:String;
	public var ?variant:String;
	public var ?displayName:String;

	public var ?bpm:Float;
	public var ?beatsPerMeasure:Float;
	public var ?stepsPerBeat:Int;

	public var ?difficulties:Array<String>;
	public var ?variants:Array<String>;
	public var ?customValues:Dynamic;

	public var ?icon:String;
	public var ?color:FlxColor;

	public var ?coopAllowed:Bool;
	public var ?opponentModeAllowed:Bool;

	// public var ?metas:Map<String, ChartMetaData>;
	public var ?instSuffix:String;
	public var ?vocalsSuffix:String;
	public var ?needsVoices:Bool;
}