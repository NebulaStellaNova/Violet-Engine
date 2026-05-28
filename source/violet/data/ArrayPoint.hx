package violet.data;

abstract ArrayPoint<T>(Dynamic) from Array<T> from T {
	@:to inline public function toArray():Array<T>
		return resolve();
	@:to inline public function toT():T
		return this is Array ? this[0] : this;

	public function resolve(?defaultValue:T, forceDefaultUse:Bool = false):Array<T> {
		if (this == null) return [defaultValue, defaultValue];
		final array:Array<T> = this is Array ? this : [this];
		while (array.length < 2)
			array.push((forceDefaultUse ? defaultValue : null) ?? (array.length > 0 ? array[0] : defaultValue));
		return array;
	}
}