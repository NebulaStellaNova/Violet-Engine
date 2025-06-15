script:import("Reflect")

function add(object)
    FlxG.state.add(object)
end

function import(index, object)
    FlxG.state.insert(index, object)
end