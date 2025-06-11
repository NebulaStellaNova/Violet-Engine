package backend.objects.play.game;

class Bopper extends NovaSprite {
    

    var danceToggle:Bool = false;
    function dance() {
        if (this.animation.exists("idle")) {
            this.playAnim("idle");
        } else if (this.animation.exists("danceLeft") && this.animation.exists("danceRight")) {
            danceToggle = !danceToggle;
            this.playAnim(danceToggle ? "danceRight" : "danceLeft");
        }
    }
}