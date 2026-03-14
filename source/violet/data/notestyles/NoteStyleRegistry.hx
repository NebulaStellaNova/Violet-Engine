package violet.data.notestyles;

import violet.backend.utils.ParseUtil;

class NoteStyleRegistry {

    public static var noteStyles:Array<NoteStyle> = [];
    public static var noteStyleDatas:Map<String, NoteStyleData> = new Map<String, NoteStyleData>();

    public static function registerNoteStyles() {
        trace('debug:<yellow>Registering note styles...');
        noteStyles = [];
        noteStyleDatas.clear();

        for (file in Paths.readFolder("data/notestyles")) {
            final fileName = file.replace(".json", "");
            final metaPath = 'data/notestyles/$fileName';
            if (!(Paths.fileExists(Paths.json(metaPath), true) || Paths.fileExists(Paths.yaml(metaPath), true))) {
                trace('warning:Could not find meta file for note style with ID $file. Skipping registration.');
                continue;
            }
            noteStyleDatas.set(fileName, ParseUtil.jsonOrYaml(metaPath));
            registerNoteStyle(new NoteStyle(fileName));
        }
    }

    public static function getDefaultNoteStyleData():NoteStyleData {
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

    public static function registerNoteStyle(newStyle:NoteStyle) {
        for (noteStyle in noteStyles) {
            if (noteStyle.id == newStyle.id) {
                trace('warning:Level with ID "${newStyle.id}" is already registered. Skipping duplicate registration.');
                return;
            }
        }

        trace('debug:<cyan>Found and registered note style with ID "<magenta>${newStyle.id}<cyan>"');

        noteStyles.push(newStyle);
    }

    public static function getAllNoteStyleIDs():Iterator<String> {
        return noteStyles.map((noteStyle) -> noteStyle.id).iterator();
    }

    public static function getAllNoteStyles():Array<NoteStyle> {
        return noteStyles.copy();
    }

    public static function doesNoteStyleExist(id:String):Bool {
        for (noteStyle in noteStyles) {
            if (noteStyle.id == id) {
                return true;
            }
        }
        return false;
    }

    public static function getNoteStyleByID(id:String):Null<NoteStyle> {
        for (noteStyle in noteStyles) {
            if (noteStyle.id == id) {
                return noteStyle;
            }
        }
        return null;
    }

}