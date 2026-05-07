package violet.data.song;

abstract Variation(Null<String>) {
	inline public static final NO_VARIANT = '[NONE]';

	public function new(?variant:String)
		this = variant;

	public function isNone():Bool
		return this == null || this.trim() == '' || this.trim() == NO_VARIANT;

	@:from inline public static function fromString(?value:String):Variation
		return new Variation(value);
	@:to inline public function toString():Null<String>
		return isNone() ? null : this;
}