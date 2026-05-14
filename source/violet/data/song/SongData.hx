package violet.data.song;

import violet.backend.utils.ParseUtil;

typedef SongData = {
	public var name:String;
	public var ?variant:Variation;
	public var ?displayName:String;

	public var ?playableCharacter:String;

	public var ?composer:String;
	public var ?charter:String;

	public var ?album:String;
	public var ?ratings:Dynamic;

	public var ?bpm:Float;
	public var ?beatsPerMeasure:Int;
	public var ?stepsPerBeat:Int;

	public var ?difficulties:Array<String>;
	public var ?variants:Array<Variation>;
	public var ?customValues:Dynamic;

	public var ?freeplayText:String;
	public var ?freeplayCapsule:String;


	public var ?icon:String;
	public var ?color:ParseColor; // for cne compat
	public var ?gradient:Array<ParseColor>; // for freeplay

	public var ?coopAllowed:Bool; // Doesn't do shit, only here for compatibility
	public var ?opponentModeAllowed:Bool; // Doesn't do shit, only here for compatibility

	// public var ?metas:Map<String, SongData>;
	public var ?instSuffix:String;
	public var ?vocalsSuffix:String;
	public var ?needsVoices:Bool;

	public var ?isDev:Bool; // Hides the song in freeplay if developer is disabled.

	public var ?hudStyle:String;
}