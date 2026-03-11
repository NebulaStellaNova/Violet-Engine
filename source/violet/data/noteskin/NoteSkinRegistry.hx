package violet.data.noteskin;

import violet.backend.utils.ParseUtil;

class NoteSkinRegistry {

    public static var noteSkins:Array<NoteSkin> = [];
    public static var noteSkinDatas:Map<String, NoteSkinData> = new Map<String, NoteSkinData>();

    public static function registerNoteSkins() {
        trace('debug:<yellow>Registering note skins...');
        noteSkins = [];
        noteSkinDatas.clear();

        for (file in Paths.readFolder("data/noteskins")) {
            final fileName = file.replace(".json", "");
            final jsonPath = 'data/noteskins/$fileName';
            if (!Paths.fileExists(Paths.json(jsonPath), true)) {
                trace('warning:Could not find meta file for note skin with ID $file. Skipping registration.');
                continue;
            }
            noteSkinDatas.set(fileName, ParseUtil.json(jsonPath));
            registerNoteSkin(new NoteSkin(fileName));
        }
    }

    public static function getDefaultNoteSkinData():NoteSkinData {
        return {
            name: 'default',
            offsets: [0, 0],
            strums: {
                offsets: [0, 0],
                assetPath: 'strums',
                animations: []
            },
            notes: {
                offsets: [0, 0],
                assetPath: 'notes',
                animations: []
            },
            sustains: {
                offsets: [0, 0],
                assetPath: 'sustains',
                animations: []
            },
            splashes: {
                offsets: [0, 0],
                assetPath: 'sustains',
                animations: []
            },
            holdcovers: {
                offsets: [0, 0],
                assetPath: 'holdcovers',
                animations: []
            }
        }
    }

    public static function registerNoteSkin(newSkin:NoteSkin) {
        for (noteSkin in noteSkins) {
            if (noteSkin.id == newSkin.id) {
                trace('warning:Level with ID "${newSkin.id}" is already registered. Skipping duplicate registration.');
                return;
            }
        }

        trace('debug:<cyan>Found and registered note skin with ID "<magenta>${newSkin.id}<cyan>"');

        noteSkins.push(newSkin);
    }

    public static function getAllNoteSkinIDs():Iterator<String> {
        return noteSkins.map((noteSkin) -> noteSkin.id).iterator();
    }

    public static function getAllNoteSkins():Array<NoteSkin> {
        return noteSkins.copy();
    }

    public static function doesNoteSkinExist(id:String):Bool {
        for (noteSkin in noteSkins) {
            if (noteSkin.id == id) {
                return true;
            }
        }
        return false;
    }

    public static function getNoteSkinByID(id:String):Null<NoteSkin> {
        for (noteSkin in noteSkins) {
            if (noteSkin.id == id) {
                return noteSkin;
            }
        }
        return null;
    }

}