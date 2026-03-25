package violet.states.editors;

import violet.states.menus.MainMenu;
import violet.data.character.CharacterData;
import yaml.Yaml;
import sys.FileSystem;
import violet.backend.utils.FileUtil;
import openfl.events.Event;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.net.FileReference;
import openfl.net.FileFilter;

import violet.data.animation.AnimationData;
import lemonui.elements.NumericStepper;
import lemonui.elements.TextInput;
import lemonui.elements.Tickbox;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import lemonui.elements.TabPanel;
import violet.data.character.Character;
import violet.data.character.CharacterRegistry;
import lemonui.elements.Dropdown;
import lemonui.elements.MenuItem;
import violet.states.debug.EditorPickerMenu;
import violet.backend.utils.ParseUtil;
import lemonui.utils.ElementUtil;
import violet.backend.StateBackend;

using violet.backend.utils.MathUtil;
using violet.backend.utils.AnimationUtil;


typedef CameraTarget = {
    var x:Float;
    var y:Float;
    var zoom:Float;
}

class CharacterEditorState extends StateBackend {

    public var characterList:Array<String> = [for (i in CharacterRegistry.characterDatas.keys()) i];

    public var animationList:Array<AnimationData> = [];
    public var selectedAnimation(get, never):AnimationData;
    function get_selectedAnimation() {
        for (i in animationList) {
            if (i.name == animationDropdown.selectedText.text) return i;
        }
        return animationList[0]; // Null safety
    }

    public var bgCamera:FlxCamera;
    public var charCamera:FlxCamera;
    public var lemonCamera:FlxCamera;

    public var character:Character;
    public var ghost:Character;

    public var characterAnim(get, never):String;
    function get_characterAnim():String {
        return character.animation.name != null ? character.animation.name : character.anim.name;
    }

    public var ghostAnim(get, never):String;
    function get_ghostAnim():String {
        return ghost.animation.name != null ? ghost.animation.name : ghost.anim.name;
    }

    public var cameraTarget:CameraTarget = { x: 0, y: 0, zoom: 1 }

    public var xOffsetStepper:NumericStepper;
    public var yOffsetStepper:NumericStepper;
    public var characterDropdown:Dropdown;
    public var animationDropdown:Dropdown;
    public var fpsStepper:NumericStepper;
    public var assetPathField:TextInput;
    public var indicesField:TextInput;
    public var prefixField:TextInput;
    public var animFlipX:Tickbox;
    public var animFlipY:Tickbox;
    public var loopedBox:Tickbox;
    public var ghostBox:Tickbox;
    public var byLabel:Tickbox;

    public function new() {
        super();

        bgCamera = new FlxCamera();
        FlxG.cameras.add(bgCamera, false);

        charCamera = new FlxCamera();
        charCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(charCamera, false);

        lemonCamera = new FlxCamera();
        lemonCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(lemonCamera, false);

        var bg = new NovaSprite(Paths.image("menus/mainmenu/menuBGdesat"));
		bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.camera = bgCamera;
        add(bg);

        var menuBar = ElementUtil.buildFromXML(Paths.xml("data/ui/character-editor/menubar")).root;
        menuBar.camera = lemonCamera;
        cast (menuBar.findElement('exitToMenu'), MenuItem).onClick = ()->{
            ModdingAPI.reloadRegistries();
            FlxG.switchState(new MainMenu());
        };
        cast (menuBar.findElement('saveCharacter'), MenuItem).onClick = save;
        insert(10, menuBar);

        var characterWindow = ElementUtil.buildFromXML(Paths.xml("data/ui/character-editor/character-window")).root;
        characterWindow.x = FlxG.width - characterWindow.width - 10;
        characterWindow.y = 50;
        characterWindow.camera = lemonCamera;
        insert(10, characterWindow);

        animationDropdown = characterWindow.findElement('animationDropdown');
        characterDropdown = characterWindow.findElement('characterDropdown');
        indicesField = characterWindow.findElement('frameIndices');
        assetPathField = characterWindow.findElement('assetPath');
        xOffsetStepper = characterWindow.findElement('xOffset');
        yOffsetStepper = characterWindow.findElement('yOffset');
        prefixField = characterWindow.findElement('prefixField');
        fpsStepper = characterWindow.findElement('fpsStepper');
        animFlipX = characterWindow.findElement('animFlipX');
        animFlipY = characterWindow.findElement('animFlipY');
        loopedBox = characterWindow.findElement('isLooped');
        ghostBox = characterWindow.findElement('isGhost');
        byLabel = characterWindow.findElement('byLabel');
        characterDropdown.onChange = function(v:Int, v2:String) {
            if (character != null) remove(character);
            if (ghost != null) remove(ghost);

            animationList = [];

            ghost = new Character(characterDropdown.selectedOption.id);
            ghost.screenCenter();
            ghost.alpha *= 0.5;
            ghost.x -= ghost.globalOffset.x;
            ghost.y -= ghost.globalOffset.y;
            ghost.camera = charCamera;
            ghost.updateHitbox();
            ghost.canDance = false;
            @:privateAccess ghost.__baseFlipped = false;
            add(ghost);

            character = new Character(characterDropdown.selectedOption.id);
            character.screenCenter();
            character.x -= character.globalOffset.x;
            character.y -= character.globalOffset.y;
            character.camera = charCamera;
            character.updateHitbox();
            character.canDance = false;
            @:privateAccess character.__baseFlipped = false;
            add(character);

            animationDropdown.onChange = (index, label) -> {
                character.playAnim(label, true);

                ghostBox.checked = ghostAnim == label;
                ghostBox.onChange = (value:Bool) -> {
                    if (value) {
                        ghost.playAnim(label, true);
                    } else {
                        ghost.canDance = true;
                        ghost.dance(true);
                        ghost.canDance = false;
                    }
                    ghostBox.checked = ghostAnim == label;
                }
                refreshAnimationDropdown();
                for (i in animationList) {
                    if (i.name == label) {
                        prefixField.text = i.prefix;
                        loopedBox.checked = i.looped;
                        animFlipX.checked = i.flipX;
                        animFlipY.checked = i.flipY;
                        byLabel.checked = i.byLabel ?? false;
                        assetPathField.text = i.assetPath ?? "";
                        indicesField.text = i.frameIndices.indiciesToString();
                        fpsStepper.value = i.frameRate;
                        xOffsetStepper.value = i.offsets[0];
                        yOffsetStepper.value = i.offsets[1];
                    }
                }

                prefixField.onSubmit = function(value:String) {
                    selectedAnimation.prefix = value;
                    refreshAnimations();
                }

                assetPathField.onChange = function(value:String) {
                    assetPathField.elementColor = 0xFF3d3f41;

                    if (value == "") {
                        selectedAnimation.assetPath = null;
                        refreshAnimations();
                        return;
                    }
                    if (Paths.image(value) != "") {
                        selectedAnimation.assetPath = value;
                        refreshAnimations();
                    } else {
                        assetPathField.elementColor = 0xff751b1b;
                    }
                }

                indicesField.onChange = function(value:String) {
                    selectedAnimation.frameIndices = value.stringToIndices();
                    refreshAnimations();
                }

                loopedBox.onChange = function(value:Bool) {
                    selectedAnimation.looped = value;
                    refreshAnimations();
                }

                animFlipX.onChange = function(value:Bool) {
                    selectedAnimation.flipX = value;
                    refreshAnimations();
                }

                animFlipY.onChange = function(value:Bool) {
                    selectedAnimation.flipY = value;
                    refreshAnimations();
                }

                byLabel.onChange = function(value:Bool) {
                    selectedAnimation.byLabel = value;
                    refreshAnimations();
                }

                fpsStepper.onChange = function(value:Float) {
                    selectedAnimation.frameRate = Math.floor(value);
                    refreshAnimations();
                }

                xOffsetStepper.onChange = function(value:Float) {
                    selectedAnimation.offsets[0] = value;
                    refreshAnimations();
                }

                yOffsetStepper.onChange = function(value:Float) {
                    selectedAnimation.offsets[1] = value;
                    refreshAnimations();
                }
            }

            refreshCharacterDropdown();
            characterDropdown.selectedText.text = v2;
            refreshAnimationDropdown();
            refreshAnimations(true);
            for (i => label in animationDropdown.listLabels) {
                if (label.text == characterAnim) {
                    animationDropdown.onChange(i, label.text);
                    break;
                }
            }
        }

        refreshCharacterDropdown();
    }

    public function refreshCharacterDropdown() {
        @:privateAccess characterDropdown.close();
        characterList.sort(function(a:String, b:String){
            a = a.toUpperCase();
            b = b.toUpperCase();
            return a == b ? 0 : a > b ? 1 : -1;
        });
        characterDropdown.clearOptions();
        for (i in characterList) {
            characterDropdown.addOption(CharacterRegistry.characterDatas.get(i).name, i);
            // add(character);
        }
    }

    public function refreshAnimationDropdown() {
        @:privateAccess animationDropdown.close();
        animationDropdown.clearOptions();
        for (i in animationList) {
            animationDropdown.addOption(i.name);
        }
        animationDropdown.selectedText.text = characterAnim ?? "Unknown Error Occurred";
        animationDropdown.selectedText.updateHitbox();
    }

    public function refreshAnimations(doArray:Bool = false) {
        var cGA = characterAnim;
        var pGA = ghostAnim;

        if (doArray) {
            animationList = [];
            for (i in character._data.animations) {
                animationDropdown.addOption(i.name);
                animationList.push({
                    name: i.name,
                    prefix: i.prefix,
                    assetPath: i.assetPath,
                    offsets: [for (o in i.offsets) o],
                    looped: i.looped ?? false,
                    flipX: i.flipX ?? false,
                    flipY: i.flipY ?? false,
                    frameRate: i.frameRate ?? 24,
                    frameIndices: i.frameIndices,
                    byLabel: i.byLabel ?? true
                });
            }
        }

        for (i in character.animation.getNameList()) {
            character.removeAnim(i);
            ghost.removeAnim(i);
        }

        for (i in animationList) {
			i.offsets[0] *= -1;
			i.offsets[1] *= -1;
            character.addAnimFromData(i);
            ghost.addAnimFromData(i);
			i.offsets[0] *= -1;
			i.offsets[1] *= -1;
        }

        character.playAnim(cGA, true);
        ghost.playAnim(pGA, true);
        character.animation.finish();
        ghost.animation.finish();
    }

    public function save() {
        FileUtil.openSaveDialog("Test", FileUtil.characterFilter, (path:String)->{
            if (FileSystem.exists(path)) FileSystem.deleteFile(path);
            var data = character.cloneData();
            data.animations = animationList;
            Yaml.write(path, data);
        });
    }
    override function update(elapsed:Float) {
        super.update(elapsed);

        if (ElementUtil.anythingFocused) return;

        var movement:Int = FlxG.keys.pressed.SHIFT ? 20 : 5;
        cameraTarget.x += FlxG.keys.pressed.A ? -movement : FlxG.keys.pressed.D ? movement : 0;
        cameraTarget.y += FlxG.keys.pressed.W ? -movement : FlxG.keys.pressed.S ? movement : 0;
        var zoomAmt = (movement/250)/cameraTarget.zoom;
        cameraTarget.zoom += FlxG.keys.pressed.Q ? -zoomAmt : FlxG.keys.pressed.E ? zoomAmt : 0;
        cameraTarget.zoom = FlxMath.bound(cameraTarget.zoom, 0.1, 50);

        if (FlxG.keys.justPressed.SPACE) character.playAnim(characterAnim, true);

        if (FlxG.keys.justPressed.I) {
            animationDropdown.selectedIndex -= 1;
            animationDropdown.onChange(animationDropdown.selectedIndex, animationDropdown.options[animationDropdown.selectedIndex]);
        } else if (FlxG.keys.justPressed.K) {
            animationDropdown.selectedIndex += 1;
            animationDropdown.onChange(animationDropdown.selectedIndex, animationDropdown.options[animationDropdown.selectedIndex]);
        }

        charCamera.scroll.pointLerp(cameraTarget.x, 0.1, X);
        charCamera.scroll.pointLerp(cameraTarget.y, 0.1, Y);
        charCamera.zoom = charCamera.zoom.lerp(cameraTarget.zoom, 0.1);
    }
}