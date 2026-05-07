package violet.data.song;

// as enum so I can do "NO_VARIANT" instead of "Variation.NO_VARIANT"
enum abstract Variation(Null<String>) {
	var NO_VARIANT = '[NONE]';

	public function new(?variant:String)
		this = variant;

	public function isNone():Bool
		return this == null || this.trim() == '' || this.trim() == NO_VARIANT;

	@:from public static function fromString(value:String):Variation
		return new Variation(value);
	@:to public function toString():Null<String>
		return isNone() ? null : this;
}