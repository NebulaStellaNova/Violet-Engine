package violet.data.icon;

import violet.backend.utils.ParseUtil;

/**
 * The JSON data schema used to define the health icon for a character.
 */
typedef HealthIconData = {
	/**
	 * The ID to use for the health icon.
	 * @default The character's ID
	 */
	var id:String;

	/**
	 * The path to the image from within the images folder.
	 * @default icons/charID
	 */
	var ?assetPath:String;

	/**
	 * The scale of the health icon.
	 */
	var ?scale:Float;

	/**
	 * Whether to flip the health icon horizontally.
	 * @default false
	 */
	var ?flipX:Bool;

	/**
	 * Multiply scale by 6 and disable antialiasing
	 * @default false
	 */
	var ?isPixel:Bool;

	/**
	 * The offset of the health icon, in pixels.
	 * @default [0, 25]
	 */
	var ?offsets:Array<Float>;

	/**
	 * The color of the icon's side of the health bar.
	 */
	var ?color:ParseColor;
}