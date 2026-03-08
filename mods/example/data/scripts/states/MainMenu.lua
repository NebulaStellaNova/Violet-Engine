function create()
	print("system:Violet Engine has Lua Support")
end

--      "_" so it doesn't run
function _postCreate()
	local sprite = NovaSprite:new(0, 150, Paths.image('icons/darnell'))
	sprite.scrollFactor.set(1.5, 1.5)
	sprite.screenCenter(FlxAxes.X)
	add(sprite)
end
