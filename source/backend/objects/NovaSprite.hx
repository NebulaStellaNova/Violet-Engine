package backend.objects;

import backend.console.ConsoleColors;
import flixel.FlxSprite;

class NovaSprite extends FlxSprite {
    
    // @:unreflective  // no touchy by scripting

    public function playAnim(id, ?forced = false) {
        // code this later LOL
        if (this.animation.exists(id))
            this.animation.play(id, forced);
        else
            log('Uh Ooooh! No animation found with ID: $id', WarningMessage);
    }

}