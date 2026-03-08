package violet.backend.objects;

interface IsBopper {
	function stepHit(step:Int):Void;
	function beatHit(beat:Int):Void;
	function measureHit(measure:Int):Void;
}