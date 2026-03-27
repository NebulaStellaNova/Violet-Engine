package violet.data;

import violet.data.animation.AnimationData;

class NullChecker {

	public static var animationDefaults = {
		offsets: [0, 0],
		looped: false,
		flipX: false,
		flipY: false,
		frameRate: 24,
		frameIndices: [],
		byLabel: true
	}

	public static function checkAnimations<T:AnimationData>(anims:Array<T>):Array<T> {
		for (anim in anims) {
			anim.offsets ??= cast animationDefaults.offsets;
			anim.looped ??= animationDefaults.looped;
			anim.flipX ??= animationDefaults.flipX;
			anim.flipY ??= animationDefaults.flipY;
			anim.frameRate ??= animationDefaults.frameRate;
			anim.frameIndices ??= animationDefaults.frameIndices;
			anim.byLabel ??= animationDefaults.byLabel;
		}
		return anims;
	}
}