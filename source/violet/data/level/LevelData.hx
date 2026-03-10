package violet.data.level;

import violet.backend.utils.ParseUtil;
import violet.data.animation.AnimationData;

typedef LevelData = {
	/**
	 * The title of the level, as seen in the top corner.
	 */
	var name:String;

	/**
	 * The graphic for the level, as seen in the scrolling list.
	 */
	var titleAsset:String;

	/**
	 * The props to display over the colored background.
	 * In the base game this is usually Boyfriend and the opponent.
	 */
	var props:Array<LevelPropData>;

	/**
	 * The difficulties for the level.
	 */
	var ?difficulties:Array<String>;

	/**
	 * Whether this week is visible in the story menu.
	 * @default `true`
	 */
	var ?visible:Bool;

	/**
	 * The list of song IDs included in this level.
	 */
	var songs:Array<String>;

	/**
	 * The background for the level behind the props.
	 */
	var ?background:ParseColor;
}

/**
 * Data for a single prop for a story mode level.
 */
typedef LevelPropData =
{
	/**
	 * The image to use for the prop. May optionally be a sprite sheet.
	 */
	var assetPath:String;

	/**
	 * The scale to render the prop at.
	 * @default 1.0
	 */
	var ?scale:Float;

	/**
	 * The opacity to render the prop at.
	 * @default 1.0
	 */
	var ?alpha:Float;

	/**
	 * If true, the prop is a pixel sprite, and will be rendered without smoothing.
	 */
	var ?isPixel:Bool;

	/**
	 * The frequency to bop at, in beats.
	 * 1 = every beat, 2 = every other beat, etc.
	 * Supports up to 0.25 precision.
	 * @default 1.0
	 */
	var ?danceEvery:Float;

	/**
	 * The offset on the position to render the prop at.
	 * @default [0.0, 0.0]
	 */
	var ?offsets:Array<Float>;

	/**
	 * A set of animations to play on the prop.
	 * If default/empty, the prop will be static.
	 */
	var ?animations:Array<AnimationData>;

	/**
	 * Flips the sprite on X axis.
	 */
	var ?flipX:Bool;
}