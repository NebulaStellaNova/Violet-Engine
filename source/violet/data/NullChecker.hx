package violet.data;

import violet.data.animation.AnimationData;

class NullChecker {
	public static function checkAnimations(anims:Array<AnimationData>):Array<AnimationData> {
		for (anim in anims) {
			anim.offsets ??= [0, 0];
			anim.looped ??= false;
			anim.flipX ??= false;
			anim.flipY ??= false;
			anim.frameRate ??= 24;
			anim.frameIndices ??= [];
			anim.byLabel ??= false;
		}
		return anims;
	}
}