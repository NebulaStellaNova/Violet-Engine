package violet.states.editors.sub;

import violet.data.NullChecker;
import violet.data.character.CharacterRegistry;
import violet.data.character.CharacterData;
import violet.backend.utils.NovaUtils;
import lemonui.elements.TextInput;
import lemonui.utils.SpriteUtil;
import lemonui.elements.Button;
import lemonui.utils.ElementUtil;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

class NewCharacterScreen extends SubStateBackend {
    override function create() {
        super.create();
        FlxG.state.persistentUpdate = false;

        this.camera = new FlxCamera();
        this.camera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(this.camera, false);

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.5;
        add(bg);

        var window = ElementUtil.buildFromXML(Paths.xml("data/ui/character-editor/sub/new-character-window")).root;
        window.screenCenter();
        add(window);

        var idField:TextInput = window.findElement('id');
        var nameField:TextInput = window.findElement('name');

        var create:Button = window.findElement('create');
        create.background.color = FlxColor.interpolate(0xFF3d3f41, FlxColor.BLACK, 0.15);
        create.background.alpha = 0.15;
        SpriteUtil.roundSpriteCorners(create.background, 4);
        SpriteUtil.roundSpriteCorners(create.hoverSprite, 4);

        var cancel:Button = window.findElement('cancel');
        cancel.background.color = FlxColor.interpolate(0xFF3d3f41, FlxColor.BLACK, 0.15);
        cancel.background.alpha = 0.15;
        SpriteUtil.roundSpriteCorners(cancel.background, 4);
        SpriteUtil.roundSpriteCorners(cancel.hoverSprite, 4);

        cancel.onClickSignal.add(close);

        create.onClickSignal.add(()->{
            var id:String = idField.text;
            var name:String = nameField.text;
            if (id == "" || id == null) {
                NovaUtils.addNotification("Could not create character!", 'ID Field Must Not Be Blank!', 3000, ERROR);
                return;
            } else if (name == "" || name == null) {
                NovaUtils.addNotification("Could not create character!", 'Name Field Must Not Be Blank!', 3000, ERROR);
                return;
            }
            var characterData:CharacterData = {
                version: "1.0.0",
                name: name,
                assetPath: 'characters/bf',
                cameraOffsets: [0, 0],
                scale: 1,
                healthIcon: 'face',
                offsets: [0, 0],
                isPixel: false,
                danceEvery: 2,
                singTime: 8.0,
                flipX: false,
                animations: []
            };
            CharacterEditorState.newList.push(id);
            CharacterRegistry.register(id, characterData);
            CharacterEditorState.instance.refreshCharacterDropdown();
            FlxG.resetState();
            FlxG.signals.postStateSwitch.addOnce(()->{
                var selection:Int = 0;
                var dropdown = CharacterEditorState.instance.characterDropdown;
                for (index=>i in CharacterEditorState.instance.characterList) {
                    if (i == id) {
                        selection = index;
                        break;
                    }
                }
                dropdown.selectedIndex = selection;
                dropdown.onChange(selection, dropdown.options[selection]);
            });
        });
    }

    override function close() {
        super.close();
        FlxG.state.persistentUpdate = true;
    }
}