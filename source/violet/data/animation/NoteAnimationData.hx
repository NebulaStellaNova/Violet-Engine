package violet.data.animation;

typedef NoteAnimationData = {
	> AnimationData,

	/**
	 * The direction id.
	 */
	@:alias('id')
	@:default(0)
	var directionId:Int;
	/**
	 * The mania count.
	 */
	@:alias('mania')
	@:default(4)
	var keyCount:Int;
}