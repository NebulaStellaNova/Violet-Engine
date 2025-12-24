package violet.backend.objects;

class Bopper extends NovaSprite {
    public var danceEvery:Float;

    public function dance() {
        this.animation.play("idle");
    }
}