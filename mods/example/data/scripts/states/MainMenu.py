def create():
	print("system:Violet Engine has Python Support")

def postCreate():
	return
	sprite = NovaSprite(0, 300, Paths.image('icons/gf'))
	sprite.scrollFactor.set(1.5, 1.5)
	sprite.screenCenter(FlxAxes.X)
	add(sprite)
