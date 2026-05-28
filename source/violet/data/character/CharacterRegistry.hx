package violet.data.character;

import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

@:registryData('Character', [violet.data.character.Character, violet.data.character.CharacterData])
class CharacterRegistry implements violet.data.RegistryImpl {

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		for (file in Paths.readFolder('data/characters', v -> return FileUtil.isDataFile(v) || FileUtil.hasExt(v, 'xml'))) {
			final fileName = Paths.fileName(file);
			if (FileUtil.hasExt(file, 'json')) {
				var parsed:Dynamic = ParseUtil.json('data/characters/$fileName');
				if (parsed == null) trace('warning:<orange>Could not find $fileName, "<magenta>$fileName.json<orange>", ignoring entry.');
				else switch (CharacterFormatChecker.checkFormat(parsed)) {
					case PSYCH: registerEntry(fileName, CharacterConverters.fromPsych('data/characters/$fileName'));
					case VSLICE: registerEntry(fileName, CharacterConverters.fromVSlice('data/characters/$fileName'));
					case UNKNOWN: trace('warning:<orange>Unknown $id format, "<magenta>data/characters/$fileName.json<orange>", ignoring entry.');
				}
			} else if (FileUtil.hasExt(file, 'xml')) {
				var convertedChar:Null<CharacterData> = CharacterConverters.fromCodenameEngine('data/characters/$file');
				if (convertedChar != null) registerEntry(fileName, convertedChar);
				else trace('warning:<orange>Codename Engine character "<magenta>data/characters/$fileName.xml<orange>" is invalid, ignoring entry.');
			} else {
				var parsed:Dynamic = ParseUtil.yaml('data/characters/$fileName');
				if (parsed != null) registerEntry(fileName, parsed);
				else trace('warning:<orange>Could not find $fileName, "<magenta>data/characters/$fileName.yaml<orange>", ignoring entry.');
			}
		}
	}
	public static function registerEntry(id:String, _data:CharacterData):Void {
		if (entryExists(id)) {
			trace('warning:<orange>$_id with ID "<magenta>$id<orange>" is already registered, ignoring entry.');
			return;
		}
		entries.set(id, _data);
		trace('debug:<cyan>Registered $_id entry, "<magenta>$id<cyan>".');
	}

	inline public static function fetchEntry(id:String):Null<CharacterData> {
		if (!entryExists(id)) // we love inlining :3
			trace('debug:<red>$_id entry "<yellow>$id<red>" doesn\'t exist.');
		return entries.get(id);
	}

}