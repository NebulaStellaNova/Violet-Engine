package violet.data.character;

import thx.semver.Version;
import violet.backend.utils.ParseUtil;
import violet.data.animation.AnimationData;

/**
 * The JSON data schema used to define a character.
 */
typedef CharacterData = {
	/**
	 * The semantic version number of the character data JSON format.
	 */
	var version:Version;

	/**
	 * The readable name of the character.
	 */
	var name:String;

	/**
	 * Behavior varies by render type:
	 * - SPARROW: Path to retrieve both the spritesheet and the XML data from.
	 * - PACKER: Path to retrieve both the spritesheet and the TXT data from.
	 */
	var assetPath:String;

	/**
	 * The scale of the graphic as a float.
	 * Pro tip: On pixel-art levels, save the sprites small and set this value to 6 or so to save memory.
	 * @default 1
	 */
	var ?scale:Float;

	/**
	 * Fuck the niggas. /ref
	 */
	var ?healthIcon:String;

	/**
	 * The character to use when death, duh!
	 */
	var ?deathCharacter:String;

	/**
	 * The global offset to the character's position, in pixels.
	 * @default [0, 0]
	 */
	var ?offsets:Array<Float>;

	/**
	 * The amount to offset the camera by while focusing on this character.
	 * Default value focuses on the character directly.
	 * @default [0, 0]
	 */
	var cameraOffsets:Array<Float>;

	/**
	 * Setting this to true disables anti-aliasing for the character.
	 * @default false
	 */
	var ?isPixel:Bool;

	/**
	 * The frequency at which the character will play its idle animation, in beats.
	 * Increasing this number will make the character dance less often.
	 * Supports up to `0.25` precision.
	 * @default `1.0` on characters
	 */
	var ?danceEvery:Float;

	/**
	 * The minimum duration that a character will play a note animation for, in beats.
	 * If this number is too low, you may see the character start playing the idle animation between notes.
	 * If this number is too high, you may see the the character play the sing animation for too long after the notes are gone.
	 *
	 * Examples:
	 * - Daddy Dearest uses a value of `1.525`.
	 * @default 1.0
	 */
	var ?singTime:Float;

	/**
	 * An optional array of animations which the character can play.
	 */
	var animations:Array<AnimationData>;

	/**
	 * If animations are used, this is the name of the animation to play first.
	 * @default idle
	 */
	var ?startingAnimation:String;

	/**
	 * Whether or not the whole ass sprite is flipped by default.
	 * Useful for characters that could also be played (Pico)
	 *
	 * @default false
	 */
	var ?flipX:Bool;

	/**
	 * NOTE: This only applies to animate atlas characters.
	 *
	 * Whether to apply the stage matrix, if it was exported from a symbol instance.
	 * Also positions the Texture Atlas as it displays in Animate.
	 * Turning this on is only recommended if you prepositioned the character in Animate.
	 * For other cases, it should be turned off to act similarly to a normal FlxSprite.
	 */
	// var ?applyStageMatrix:Bool;

	/**
	 * Various settings for the prop.
	 * Only available for texture atlases.
	 */
	// var ?atlasSettings:funkin.data.stage.StageData.TextureAtlasData;
};