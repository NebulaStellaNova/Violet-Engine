package violet.backend.objects.play;

import violet.data.character.CharacterData.HealthIconData;
import violet.data.Constants;
import openfl.Assets;

class HealthIcon extends NovaSprite {

    public var id:String;
    public var _data:HealthIconData;

    public function new(iconData:HealthIconData) {
        this.id = iconData.id;
        this._data = iconData;

        iconData.flipX ??= false;
        iconData.scale ??= 1;
        iconData.offsets ??= [0, 0];
        iconData.isPixel ??= false;
        if (iconData.isPixel) {
            iconData.scale *= 4.5;
        }
        trace(iconData);

        super(0, 0, iconExists(id) ? Paths.image('icons/$id') : Paths.image('icons/${Constants.DEFAULT_HEALTH_ICON}'));

        if (this.animated) {
            this.addAnim("idle", "idle", 24, true);
            this.addAnim("winning", "winning", 24, true);
            this.addAnim("losing", "losing", 24, true);
            /* this.animation.addByPrefix("toWinning", "toWinning", 24, false);
            this.animation.addByPrefix("toLosing", "toLosing", 24, false);
            this.animation.addByPrefix("fromWinning", "fromWinning", 24, false);
            this.animation.addByPrefix("fromLosing", "fromLosing", 24, false); */
        } else {
            this.loadGraphic(this.filePath, true, 150, 150);
            this.addAnim("idle", [0], 0, false, false);
            this.addAnim("losing", [1], 0, false, false);
            if (animation.numFrames >= 3) {
                this.addAnim("winning", [2], 0, false, false);
            }
        }

        this.globalOffset.x = iconData.offsets[0] ?? 0;
        this.globalOffset.y = iconData.offsets[1] ?? 0;
        this.flipX = iconData.flipX ?? false;

    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (this._data.isPixel)
            this.antialiasing = false;
    }

    function iconExists(id:String) {
        return Assets.exists(Paths.image('icons/$id'));
    }
}