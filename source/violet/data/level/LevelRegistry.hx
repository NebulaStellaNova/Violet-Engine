package violet.data.level;

import violet.backend.utils.ParseUtil;

class LevelRegistry {
    public static var levels:Array<Level> = [];
    public static var levelDatas:Map<String, LevelData> = new Map<String, LevelData>();

    public static function registerLevels() {
        trace('debug:<yellow>Registering levels...');
        levels = [];
        levelDatas.clear();
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
        }
    }

    public static function registerLevel(newLevel:Level):Void {
        for (level in levels) {
            if (level.id == newLevel.id) {
                trace('warning:Level with ID "${newLevel.id}" is already registered. Skipping duplicate registration.');
                return;
            }
        }
        trace('debug:<cyan>Found and registered level with ID "<magenta>${newLevel.id}<cyan>"');
        // Preload title graphic
        newLevel.buildTitleGraphic().destroy();
        newLevel.buildProps().destroy();
        levels.push(newLevel);
    }

    public static function getAllLevelIDs():Iterator<String> {
        return levels.map((level) -> level.id).iterator();
    }

    public static function getAllLevels():Array<Level> {
        return levels.copy();
    }

    public static function getVisibleLevels():Array<Level> {
        return getAllLevels().filter((level) -> return level.isVisible());
    }

    public static function doesLevelExist(levelID:String):Bool {
        for (level in levels) {
            if (level.id == levelID) {
                return true;
            }
        }
        return false;
    }

    public static function getLevelByID(levelID:String):Null<Level> {
        for (level in levels) {
            if (level.id == levelID) {
                return level;
            }
        }
        return null;
    }

}