package violet.backend.objects;

class Bopper extends NovaSprite {
    public var danceEvery:Float;

    public var alternator:Bool = false;
    public function dance() {
        if (this.animationList.contains("danceLeft")) {
            this.animation.play(alternator ? "danceLeft" : "danceRight");
            alternator = !alternator;
        } else {
            this.animation.play("idle");
        }
    }
}