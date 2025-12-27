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
	public var ?color:FlxColor; // Doesn't do shit, only here for compatibilty

	public var ?coopAllowed:Bool; // Doesn't do shit, only here for compatibilty
	public var ?opponentModeAllowed:Bool; // Doesn't do shit, only here for compatibilty

	// public var ?metas:Map<String, ChartMetaData>;
	public var ?instSuffix:String;
	public var ?vocalsSuffix:String;
	public var ?needsVoices:Bool;
}