package violet.backend.objects;

class Bopper extends NovaSprite {
    public var danceEvery:Float;

    public var alternator:Bool = false;
    public function dance(force:Bool = false) {
        if (this.animation.name != "idle" && this.animation.name != "danceLeft" && this.animation.name != "danceRight" && !force) return;
        if (this.animationList.contains("danceLeft")) {
            this.playAnim(alternator ? "danceLeft" : "danceRight", true);
            alternator = !alternator;
        } else {
            this.playAnim("idle", true);
        }
    }
}