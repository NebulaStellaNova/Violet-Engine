package backend.objects.play.game;

class Bopper extends NovaSprite {

	public var doBop:Bool = true;
	
	public var parent:MusicBeatState;

	public var singTimer:Int = 0;

	var danceToggle:Bool = false;
	public function dance() {
		if (this.animation.exists("idle")) {
			this.playAnim("idle", true);
		} else if (this.animation.exists("danceLeft") && this.animation.exists("danceRight")) {
			danceToggle = !danceToggle;
			this.playAnim(danceToggle ? "danceRight" : "danceLeft", true);
		}
	}
}