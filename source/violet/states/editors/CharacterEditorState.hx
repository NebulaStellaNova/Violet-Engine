package violet.states.editors;

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

typedef CameraTarget = {
    var x:Float;
    var y:Float;
    var zoom:Float;
}

class CharacterEditorState extends StateBackend {

    public var characterList:Array<String> = [for (i in CharacterRegistry.characterDatas.keys()) i];

    public var bgCamera:FlxCamera;
    public var charCamera:FlxCamera;
    public var lemonCamera:FlxCamera;

    public var character:Character;
    public var ghost:Character;

    public var cameraTarget:CameraTarget = { x: 0, y: 0, zoom: 1 }

    public var characterDropdown:Dropdown;
    public var animationDropdown:Dropdown;
    public var ghostBox:Tickbox;

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
        cast (menuBar.findElement('exitToMenu'), MenuItem).onClick = ()->FlxG.switchState(new EditorPickerMenu());
        insert(10, menuBar);

        var characterWindow = ElementUtil.buildFromXML(Paths.xml("data/ui/character-editor/character-window")).root;
        characterWindow.x = FlxG.width - characterWindow.width - 10;
        characterWindow.y = 50;
        characterWindow.camera = lemonCamera;
        insert(10, characterWindow);

        animationDropdown = characterWindow.findElement('animationDropdown');
        characterDropdown = characterWindow.findElement('characterDropdown');
        ghostBox = characterWindow.findElement('isGhost');
        characterDropdown.onChange = function(v:Int, v2:String) {
            if (character != null) remove(character);
            if (ghost != null) remove(ghost);

            ghost = new Character(characterDropdown.selectedOption.id);
            ghost.screenCenter();
            ghost.alpha *= 0.5;
            ghost.x -= ghost.globalOffset.x;
            ghost.y -= ghost.globalOffset.y;
            ghost.camera = charCamera;
            ghost.updateHitbox();
            ghost.canDance = false;
            add(ghost);

            character = new Character(characterDropdown.selectedOption.id);
            character.screenCenter();
            character.x -= character.globalOffset.x;
            character.y -= character.globalOffset.y;
            character.camera = charCamera;
            character.updateHitbox();
            character.canDance = false;
            add(character);

            animationDropdown.onChange = (index, label) -> {
                character.playAnim(label, true);
                ghostBox.checked = ghost.animation.name == label;
                ghostBox.onChange = (value:Bool) -> {
                    if (value) {
                        ghost.playAnim(label, true);
                    } else {
                        ghost.canDance = true;
                        ghost.dance(true);
                        ghost.canDance = false;
                    }
                    ghostBox.checked = ghost.animation.name == label;
                }
                refreshAnimationDropdown();
            }

            cameraTarget.zoom = 0.7;

            refreshCharacterDropdown();
            characterDropdown.selectedText.text = v2;
            refreshAnimationDropdown();
            for (i => label in animationDropdown.listLabels) {
                if (label.text == character.animation.name) {
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
        for (i in character.animationList) {
            animationDropdown.addOption(i);
        }
        animationDropdown.selectedText.text = character.animation.name;
        animationDropdown.selectedText.updateHitbox();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var movement:Int = FlxG.keys.pressed.SHIFT ? 20 : 5;
        cameraTarget.x += FlxG.keys.pressed.A ? -movement : FlxG.keys.pressed.D ? movement : 0;
        cameraTarget.y += FlxG.keys.pressed.W ? -movement : FlxG.keys.pressed.S ? movement : 0;
        var zoomAmt = (movement/250)/cameraTarget.zoom;
        cameraTarget.zoom += FlxG.keys.pressed.Q ? -zoomAmt : FlxG.keys.pressed.E ? zoomAmt : 0;
        cameraTarget.zoom = FlxMath.bound(cameraTarget.zoom, 0.1, 50);

        charCamera.scroll.pointLerp(cameraTarget.x, 0.1, x);
        charCamera.scroll.pointLerp(cameraTarget.y, 0.1, y);
        charCamera.zoom = charCamera.zoom.lerp(cameraTarget.zoom, 0.1);
    }
}