package violet.data.stage;

import flixel.FlxBasic;
import violet.data.character.Character;
import violet.backend.utils.NovaUtils;
import violet.backend.StateBackend;
import violet.states.PlayState;
import violet.backend.objects.play.StageProp;

class Stage extends flixel.group.FlxGroup {

    public var id:String;
    public var _data:StageData;

    public function new(id:String) {
        super();
        this.id = id ?? 'mainStage';
		this._data = StageRegistry.stageDatas.get(id) ?? StageRegistry.stageDatas.get('mainStage');
        this._data.cameraPosition ??= [0, 0];

        if (StageRegistry.stageDatas.get(id) == null) {
            NovaUtils.addNotification('Stage not found!', 'Could not find stage with ID "$id" using default stage "mainStage."', haxe.ui.notifications.NotificationType.Error);
        }

        FlxG.camera.scroll.x = this._data.cameraPosition[0];
        FlxG.camera.scroll.y = this._data.cameraPosition[1];
    }

    public function load(characters:Array<Character>) {
        for (i in members) {
            remove(i);
        }
        for (i in this._data.props) {
            i.scroll ??= [1, 1];
            i.scale ??= [1, 1];
            i.alpha ??= 1;
            i.visible ??= true;

            var positionalArrays = [
                "player" => ["boyfriend", i.id],
                "spectator" => ["girlfriend", i.id],
                "opponent" => ["dad", i.id]
            ];

            switch (i.type) {
                case "StageProp":
                    var prop:StageProp = new StageProp(i.position[0], i.position[1], Paths.image([this._data.directory, i.assetPath].join("/")));
                    prop.name = i.name;
                    prop.scrollFactor.set(i.scroll[0] ?? 1, i.scroll[1] ?? 1);
                    prop.scale.set(i.scale[0] ?? 1, i.scale[1] ?? 1);
                    prop.flipX = i.flipX ?? false;
                    prop.flipY = i.flipY ?? false;
                    add(prop);
                case "Character":
                    i.cameraOffsets ??= [0, 0];
                    for (char in characters) {
                        if (positionalArrays.get(i.id).contains(char.stagePosition.toLowerCase())) {
                            if (i.id == "player") char.flipX = !char.flipX;
                            char.x = i.position[0] - (char.width/2);
                            char.y = i.position[1] - (char.height);
                            char.scrollFactor.set(i.scroll[0] ?? 1, i.scroll[1] ?? 1);
                            char.alpha = i.alpha;
                            char.visible = i.visible;
                            char.cameraOffsets[0] += i.cameraOffsets[0];
                            char.cameraOffsets[1] += i.cameraOffsets[1];
                            add(char);
                        }
                    }
            }
        }
    }

    public function reload(characters:Array<Character>) { load(characters); }

    override function add(basic:FlxBasic):FlxBasic {
        FlxG.state.add(basic);
        return super.add(basic);
    }
    override function insert(position:Int, object:FlxBasic):FlxBasic {
        FlxG.state.insert(position, object);
        return super.insert(position, object);
    }
    override function remove(basic:FlxBasic, splice:Bool = false):FlxBasic {
        FlxG.state.remove(basic, splice);
        return super.remove(basic, splice);
    }
}