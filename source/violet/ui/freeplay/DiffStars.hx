package violet.ui.freeplay;

import flixel.group.FlxSpriteGroup;

class DiffStars extends FlxSpriteGroup {

	/**
	 * The handler for Diff Stars in freeplay!!
	 * Ranges for 0 to 20 because we are better than V-Slice...
	 */
	// var curDiff(default, set):Int = 0;

	/**
	 * Range from 0 to 20
	 */
	// public var diff(default, set):Int = 1;

	public var stars:NovaSprite;

	public function new(?x, ?y) {
		super(x, y);
		stars = new NovaSprite().loadSprite(Paths.image('menus/freeplay/stars'));
		stars.addAnim('idle', 'diff stars', 24);
		stars.playAnim('idle');

		add(stars);
	}

}