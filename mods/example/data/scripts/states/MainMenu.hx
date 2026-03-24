function create() {
	trace("system:Violet Engine has HScript Support");
}

function postCreate() {
	return;
	var sprite = new NovaSprite(0, 0, Paths.image("icons/bf"));
	sprite.scrollFactor.set(1.5, 1.5);
	sprite.screenCenter(FlxAxes.X);
	add(sprite);
}
