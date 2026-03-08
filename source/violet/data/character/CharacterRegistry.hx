package violet.data.character;

import openfl.Assets;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

import yaml.Yaml;
import yaml.Parser.ParserOptions;

using StringTools;

class CharacterRegistry {

    public static var characterDatas:Map<String, CharacterData> = new Map<String, CharacterData>();

    public static function registerCharacters() {
        characterDatas.clear();

        var characterFiles = Paths.readFolder("data/characters");
        for (file in characterFiles) {
            var fileSplit = file.split(".");
            fileSplit.pop();
            final charID = fileSplit.join(".");
            // trace(charID);
            var characterData:CharacterData;
            // trace('$charID.yaml ' + );
            // trace('$charID.json ' + );
            if (Assets.exists(Paths.file('data/characters/$charID.yaml'))) {
                final options = new ParserOptions();
                options.maps = false;
                characterData = Yaml.parse(FileUtil.getFileContent(Paths.file('data/characters/$charID.yaml')), options);
                characterDatas.set(charID, characterData);
                trace('debug:Found and registered character with ID "${charID}"');
            } else if (Assets.exists(Paths.file('data/characters/$charID.json'))) {
                characterDatas.set(charID, new json2object.JsonParser<CharacterData>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent(Paths.file('data/characters/$charID.json')))));
                trace('debug:Found and registered character with ID "${charID}"');
            }

            // registerNoteSkin(new NoteSkin(file));
        }
    }

    /* public static function getDefaultNoteSkinData():NoteSkinData {
        return {
            name: 'default',
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

        trace('debug:Found and registered note skin with ID "${newSkin.id}"');

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
    } */

}