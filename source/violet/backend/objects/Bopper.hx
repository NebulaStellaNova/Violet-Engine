package violet.backend.objects;

class Bopper extends NovaSprite implements IsBopper {

	public var danceEvery:Float = 1;

	public var alternator:Bool = false;
	public function dance(force:Bool = false) {
		if (this.animationList.contains('danceLeft')) {
			if (this.animation.name != 'danceLeft' && this.animation.name != 'danceRight' && !force) return;
			this.playAnim(alternator ? 'danceLeft' : 'danceRight', true);
			alternator = !alternator;
		} else {
			if (this.animation.name != 'idle' && !force) return;
			this.playAnim('idle', true);
		}
	}

	public function stepHit(step:Int) {}

	public function beatHit(beat:Int) {
		if (beat % danceEvery == 0)
			dance();
	}

	public function measureHit(measure:Int) {}

}