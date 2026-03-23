package violet.backend.objects;

import flixel.FlxCamera;

class NovaCamera extends FlxCamera {

    // TODO: Make this a macro
    override function draw() {
        var xLog = this.x;
        var yLog = this.y;
        this.scroll.x += this.x;
        this.scroll.y += this.y;
        this.x = this.y = 0;
        super.draw();
        this.x = xLog;
        this.y = yLog;
        this.scroll.x -= this.x;
        this.scroll.y -= this.y;
    }
}