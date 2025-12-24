package violet.data.level;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import violet.backend.utils.ParseUtil;

class Level {

    public var id:String;

    @:default(LevelRegistry.getDefaultLevelData())
    public var _data:LevelData;

    public function new(id:String) {
        this._data = LevelRegistry.levelDatas.get(id);
        this.id = id;
    }

    /**
     * Get the list of songs in this level, as an array of IDs.
     */
    public function getSongs():Array<String>
    {
        // Copy the array so that it can't be modified on accident
        return _data.songs.copy();
    }

    /**
     * Retrieve the title of the level for display on the menu.
     */
    public function getTitle():String
    {
        return _data.name;
    }

    /**
     * Construct the title graphic for the level.
     */
    public function buildTitleGraphic():NovaSprite
    {
        return new NovaSprite(Paths.image(_data.titleAsset));
    }

    /**
     * Get the list of difficulties for this level.
     */
    public function getDifficulties():Array<String>
    {
        return _data.difficulties ?? ["easy", "normal", "hard"];
    }

    /**
     * Whether this level is visible. If not, it will not be shown on the menu at all.
     */
    public function isVisible():Bool
    {
        return _data.visible;
    }

    public function buildProps():FlxTypedSpriteGroup<NovaSprite>
    {
        var group:FlxTypedSpriteGroup<NovaSprite> = new FlxTypedSpriteGroup<NovaSprite>();
        for (i=>propData in _data.props) {
            var propSprite:NovaSprite = new NovaSprite(Paths.image(propData.assetPath));
            propSprite.scale.set(propData.scale ?? 1, propData.scale ?? 1);
            propSprite.flipX = propData.flipX ?? false;
            propSprite.alpha = propData.alpha ?? 1;
            propSprite.antialiasing = propData.isPixel != null ? !propData.isPixel : true;

            for (i in propData.animations) {
                propSprite.addAnimFromJSON(i);
            }
            propSprite.updateHitbox();
            propSprite.playAnim('idle', true);

            propSprite.x = propData.offsets != null ? propData.offsets[0] : 0;
            propSprite.x += FlxG.width * 0.25 * i;
            propSprite.y = propData.offsets != null ? propData.offsets[1] : 0;

            group.add(propSprite);
        }
        return group;
    }

}