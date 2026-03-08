package violet.data.animation;

typedef NoteAnimationData = {
	> AnimationData,

	/**
	 * The direction id.
	 */
	@:alias('id')
	var directionId:Int;
	/**
	 * The mania count.
	 */
	@:alias('mania')
	@:default(4)
	var keyCount:Int;
}