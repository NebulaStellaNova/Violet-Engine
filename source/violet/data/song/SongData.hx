package violet.data.song;

typedef SongData = {
    public var name:String;
	public var ?variant:String;
	public var ?displayName:String;

	public var ?bpm:Float;
	public var ?beatsPerMeasure:Int;
	public var ?stepsPerBeat:Int;

	public var ?difficulties:Array<String>;
	public var ?variants:Array<String>;
	public var ?customValues:Dynamic;

	public var ?icon:String;
	public var ?color:violet.backend.utils.ParseUtil.ParseColor; // Doesn't do shit, only here for compatibility

	public var ?coopAllowed:Bool; // Doesn't do shit, only here for compatibility
	public var ?opponentModeAllowed:Bool; // Doesn't do shit, only here for compatibility

	// public var ?metas:Map<String, SongData>;
	public var ?instSuffix:String;
	public var ?vocalsSuffix:String;
	public var ?needsVoices:Bool;
}