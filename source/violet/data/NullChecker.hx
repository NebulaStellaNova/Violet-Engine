package violet.data;

import violet.data.animation.AnimationData;

class NullChecker {

	public static var animationDefaults:AnimationData = cast { // so it no reqire "name"
		offsets: [0, 0],
		looped: false,
		flipX: false,
		flipY: false,
		frameRate: 24,
		frameIndices: [],
		byLabel: true
	}

	public static function checkAnimation<T:AnimationData>(anim:T):T {
		anim.offsets ??= animationDefaults.offsets;
		while (anim.offsets.length < 2) anim.offsets.push(anim.offsets[0] ?? 0); // jic array length is short
		anim.looped ??= animationDefaults.looped;
		anim.flipX ??= animationDefaults.flipX;
		anim.flipY ??= animationDefaults.flipY;
		anim.frameRate ??= animationDefaults.frameRate;
		anim.frameIndices ??= animationDefaults.frameIndices;
		anim.byLabel ??= animationDefaults.byLabel;
		return anim;
	}

	public static function checkAnimations<T:AnimationData>(anims:Array<T>):Array<T> {
		for (i in 0...anims.length) // so it doesn't create another array
			anims[i] = checkAnimation(anims[i]);
		return anims;
	}

}