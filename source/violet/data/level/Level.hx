package violet.data.level;

import violet.backend.objects.Bopper;
import violet.backend.objects.BopperSpriteGroup;

class Level {

	public var id:String;
	public var _data:LevelData;

	public function new(id:String) {
		this.id = id;
		this._data = LevelRegistry.levelDatas.get(id) ?? LevelRegistry.getDefaultLevelData();
	}

	/**
	 * Get the list of songs in this level, as an array of IDs.
	 */
	public function getSongs():Array<String> {
		// Copy the array so that it can't be modified on accident
		return _data.songs.copy();
	}

	/**
	 * Retrieve the title of the level for display on the menu.
	 */
	public function getTitle():String {
		return _data.name;
	}

	/**
	 * Construct the title graphic for the level.
	 */
	public function buildTitleGraphic():NovaSprite {
		return new NovaSprite(Paths.image(_data.titleAsset));
	}

	// MAYBE: Song display name shenanigans.

	// TODO: isUnlocked

	/**
	 * Whether this level is visible. If not, it will not be shown on the menu at all.
	 */
	public function isVisible():Bool {
		return _data.visible ?? true;
	}

	// TODO: Background Related Stuff

	/**
	 * Get the list of difficulties for this level.
	 */
	public function getDifficulties():Array<String> {
		if (_data.difficulties == null) return ['easy', 'normal', 'hard'];
		return _data.difficulties.copy();
	}

	public function buildProps():TypedBopperSpriteGroup<Bopper> {
		var group:TypedBopperSpriteGroup<Bopper> = new TypedBopperSpriteGroup<Bopper>();
		for (i=>propData in _data.props ?? []) {
			var propSprite:Bopper = new Bopper(Paths.image(propData.assetPath));
			propSprite.scale.set(propData.scale ?? 1, propData.scale ?? 1);
			propSprite.flipX = propData.flipX ?? false;
			propSprite.alpha = propData.alpha ?? 1;
			propSprite.antialiasing = !(propData.isPixel ?? false);
			propSprite.danceEvery = propData.danceEvery ?? 1;

			for (i in NullChecker.checkAnimations(propData.animations))
				propSprite.addAnimFromData(i);
			propSprite.updateHitbox();
			propSprite.dance(true);
			if (propData.startingAnimation != null)
				propSprite.playAnim(propData.startingAnimation, true);

			propData.offsets ??= [0, 0];
			propSprite.x = propData.offsets[0] ?? 0;
			propSprite.x += FlxG.width * 0.25 * i;
			propSprite.y = propData.offsets[1] ?? 0;

			group.add(propSprite);
		}
		return group;
	}

}