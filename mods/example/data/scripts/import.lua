script:import("Reflect")

function add(object)
	FlxG.state.add(object)
end

function remove(object)
	FlxG.state.remove(object)
end

function insert(index, object)
	FlxG.state.insert(index, object)
end