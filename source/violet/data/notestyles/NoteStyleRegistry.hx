package violet.data.notestyles;

import haxe.io.Path;
import violet.backend.utils.ParseUtil;

@:registryData('NoteStyle', [violet.data.notestyles.NoteStyle, violet.data.notestyles.NoteStyleData])
class NoteStyleRegistry implements violet.data.RegistryImpl {

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		for (file in Paths.readFolder('data/notestyles')) {
			final entryId = Path.withoutExtension(file);
			final metaPath = 'data/notestyles/$entryId';
			if (!(Paths.fileExists(Paths.json(metaPath), true) || Paths.fileExists(Paths.yaml(metaPath), true))) {
				trace('warning:<orange>Could not find $id, "<magenta>$file<orange>", ignoring entry.');
				continue;
			}
			var parsed:Dynamic = ParseUtil.jsonOrYaml(metaPath);
			if (parsed.assets != null) trace('warning:<orange>Could not parse $id, "<magenta>$file<orange>", as it is in VSlice\'s format.');
			else if (parsed != null) registerEntry(entryId, parsed);
		}
	}

}