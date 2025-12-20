package violet.data.level;

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
     * Whether this level is visible. If not, it will not be shown on the menu at all.
     */
    public function isVisible():Bool
    {
        return _data.visible;
    }

}