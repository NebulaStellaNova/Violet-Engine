package violet.data.stage;

import violet.backend.scripting.ScriptPack;
import flixel.FlxBasic;
import violet.data.character.Character;
import violet.backend.utils.NovaUtils;
import violet.backend.StateBackend;
import violet.states.PlayState;
import violet.backend.objects.play.StageProp;

enum abstract StageItemType(String) {
    var COMBO = "Combo";
    var PROP = "StageProp";
    var SOLID = "Solid";
    var CHARACTER = "Character";
}

class Stage extends flixel.group.FlxGroup {

    public var stageScripts:ScriptPack = new ScriptPack();

    public var id:String;
    public var _data:StageData;

    public function new(id:String) {
        super();
        this.id = StageRegistry.stageDatas.get(id) != null ? id : 'default';
		this._data = StageRegistry.stageDatas.get(id) ?? StageRegistry.stageDatas.get('default');
        this._data.cameraPosition ??= [0, 0];

        ModdingAPI.checkForScripts('data/stages', id, stageScripts);
        stageScripts.set('directory', this._data.directory);

        if (StageRegistry.stageDatas.get(id) == null) {
            NovaUtils.addNotification('Stage not found!', 'Could not find stage with ID "$id" using default stage "theVoid."', ERROR);
        }

        FlxG.camera.scroll.x = this._data.cameraPosition[0];
        FlxG.camera.scroll.y = this._data.cameraPosition[1];
    }

    public function load(characters:Array<Character>) {
        for (i in members) {
            remove(i);
        }
        var hasCombo = false;
        for (i in this._data.props) {
            i.scroll ??= [1, 1];
            i.scale ??= [1, 1];
            i.position ??= [0, 0];
            i.alpha ??= 1;
            i.visible ??= true;
            i.color ??= FlxColor.WHITE;
            i.zIndex ??= members.length-1;
            i.type ??= PROP;
            // trace(i);

            var positionalArrays = [
                "player" => ["boyfriend", i.id],
                "spectator" => ["girlfriend", i.id],
                "opponent" => ["dad", i.id]
            ];

            switch (i.type) {
                case COMBO:
                    PlayState.instance.comboGroup.x = i.position[0];
                    PlayState.instance.comboGroup.y = i.position[1];
                    PlayState.instance.comboGroup.z = i.zIndex;
                    add(PlayState.instance.comboGroup);

                case SOLID:
                    var prop:StageProp = new StageProp(i.position[0], i.position[1]);
                    prop.name = i.name;
                    prop.makeGraphic(1, 1, i.color);
                    prop.scale.set(i.width ?? 0, i.height ?? 0);
                    prop.scrollFactor.set(i.scroll[0] ?? 1, i.scroll[1] ?? 1);
                    prop.updateHitbox();
                    prop.z = i.zIndex;
                    prop.alpha = i.alpha;
                    add(prop);
                    stageScripts.set(i?.id ?? i.name, prop);
                    applyProperties(prop, i.properties ?? {});

                case PROP:
                    var prop:StageProp = new StageProp(i.position[0], i.position[1], Paths.image([this._data.directory, i.assetPath].join("/")));
                    prop.name = i.name;
                    prop.z = i.zIndex;
                    prop.scrollFactor.set(i.scroll[0] ?? 1, i.scroll[1] ?? 1);
                    prop.scale.set(i.scale[0] ?? 1, i.scale[1] ?? 1);
                    prop.flipX = i.flipX ?? false;
                    prop.flipY = i.flipY ?? false;
                    prop.visible = i.visible;
                    prop.color = i.color;
                    prop.alpha = i.alpha;
                    prop.antialiasing = !i.isPixel;
                    prop.updateHitbox();
                    for (i in i?.animations ?? []) {
                        prop.addAnimFromData(i);
                    }
                    if (i?.animations?.length > 0) prop.playAnim(i.startingAnimation ??= prop.animationList[0], true);
                    add(prop);
                    stageScripts.set(i?.id ?? i.name, prop);
                    applyProperties(prop, i.properties ?? {});

                case CHARACTER:
                    i.cameraOffsets ??= [0, 0];
                    for (char in characters) {
                        if (positionalArrays.get(i.id).contains(char.stagePosition.toLowerCase()) || i.id == char.id) {
                            if (i.id == "player") char.flipX = !char.flipX;
                            char.x = i.position[0] - (char.width/2);
                            char.y = i.position[1] - (char.height);
                            char.z = i.zIndex;
                            char.scrollFactor.set(i.scroll[0] ?? 1, i.scroll[1] ?? 1);
                            char.alpha = i.alpha;
                            char.visible = i.visible;
                            char.cameraOffsets[0] += i.cameraOffsets[0];
                            char.cameraOffsets[1] += i.cameraOffsets[1];
                            applyProperties(char, i.properties ?? {});
                            add(char);
                        }
                    }
            }
        }
        stageScripts.call('onLoaded');
    }

    public function applyProperties(object:FlxBasic, array:Dynamic) {
        for (i in Reflect.fields(array)) {
            var recursion = i.split(".");
            var piece = Reflect.field(object, i);
            Reflect.setProperty(object, i, Reflect.field(array, i));
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