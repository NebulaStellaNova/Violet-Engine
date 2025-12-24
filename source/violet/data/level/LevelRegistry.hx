package violet.data.level;

import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

class LevelRegistry {

    public static var levels:Array<Level> = [];
    public static var levelDatas:Map<String, LevelData> = new Map<String, LevelData>();

    public static function registerLevels() {
        trace("debug:Registering levels...");
        levels = [];
        var levelFiles = Paths.readFolder("data/levels");
        for (levelFile in levelFiles) {
            levelDatas.set(levelFile.replace(".json", ""), ParseUtil.json('data/levels/$levelFile'));
            registerLevel(new Level(levelFile.replace(".json", "")));
        }
    }

    public static function getDefaultLevelData():LevelData {
        return {
            name: "Untitled Level",
            titleAsset: "",
            props: [],
            visible: true,
            songs: [],
            background: "#F9CF51",
            difficulties: ["easy", "normal", "hard"]
        };
    }

    public static function registerLevel(newLevel:Level):Void {
        for (level in levels) {
            if (level.id == newLevel.id) {
                trace('warning:Level with ID "${newLevel.id}" is already registered. Skipping duplicate registration.');
                return;
            }
        }
        trace('debug:Found and registered level with ID "${newLevel.id}"');
        // Preload title graphic
        newLevel.buildTitleGraphic();
        levels.push(newLevel);
    }

    /* public static function getLevelData(levelID:String):Null<LevelData> {
        for (level in levels) {
            if (level.id == levelID) {
                return level._data;
            }
        };
        return null;
    } */

    public static function getAllLevelIDs():Iterator<String> {
        return levels.map((level) -> level.id).iterator();
    }

    public static function getAllLevels():Array<Level> {
        return levels.copy();
    }

    public static function doesLevelExist(levelID:String):Bool {
        for (level in levels) {
            if (level.id == levelID) {
                return true;
            }
        };
        return false;
    }

}