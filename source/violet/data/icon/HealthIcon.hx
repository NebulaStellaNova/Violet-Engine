package violet.data.icon;

import violet.data.Constants;
import openfl.Assets;

class HealthIcon extends NovaSprite {

    public var id:String;
    public var _data:HealthIconData;

    public function new(id:String) {
        this.id = id;
        var defaultData = HealthIconRegistry.healthIconDatas.get(Constants.DEFAULT_HEALTH_ICON);
        this._data = HealthIconRegistry.healthIconDatas.get(id) ?? defaultData;
        var iconData = this._data; // fuck my fat chud life omg
        iconData.flipX ??= false;
        iconData.scale ??= 1;
        iconData.offsets ??= [0, 0];
        iconData.isPixel ??= false;
        iconData.assetPath ??= 'icons/$id';
        if (iconData.isPixel) {
            iconData.scale *= 4.5;
        }

        super(0, 0, iconExists(iconData.assetPath) ? Paths.image(iconData.assetPath) : Paths.image(defaultData.assetPath));

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

        this.flipX = iconData.flipX ?? false;
        this.globalOffset.x = iconData.offsets[0] ?? 0;
        this.globalOffset.y = iconData.offsets[1] ?? 0;

    }

    override function update(elapsed:Float) {
        super.update(elapsed);


        this.globalOffset.x = this._data.offsets[0] ?? 0;
        this.globalOffset.y = this._data.offsets[1] ?? 0;
        if (this.flipX) this.globalOffset.x *= -1;

        if (this._data.isPixel)
            this.antialiasing = false;
    }

    function iconExists(assetPath:String) {
        return Paths.image(assetPath) != "";
    }

    override function destroy() {
        super.destroy();
        if (this._data.isPixel) {
            this._data.scale /= 4.5;
        }
    }
}