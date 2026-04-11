package violet.states.editors.sub;

import violet.data.NullChecker;
import violet.data.animation.AnimationData;
import violet.data.character.CharacterRegistry;
import violet.data.character.CharacterData;
import violet.backend.utils.NovaUtils;
import lemonui.elements.TextInput;
import lemonui.utils.SpriteUtil;
import lemonui.elements.Button;
import lemonui.utils.ElementUtil;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

class NewAnimationScreen extends SubStateBackend {

	override function create() {
		super.create();
		FlxG.state.persistentUpdate = false;

		this.camera = new FlxCamera();
		this.camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(this.camera, false);

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.5;
		add(bg);

		var window = ElementUtil.buildFromXML(Paths.xml("data/ui/character-editor/sub/new-animation-window")).root;
		window.screenCenter();
		add(window);

		var nameField:TextInput = window.findElement('name');
		var prefixField:TextInput = window.findElement('prefix');

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
			var name:Null<String> = nameField.text;
			var prefix:Null<String> = prefixField.text;
			if (name == "" || name == null) {
				NovaUtils.addNotification("Could not create animation!", 'Name Field Must Not Be Blank!', 3000, ERROR);
				return;
			}else if (prefix == "" || prefix == null) {
				NovaUtils.addNotification("Could not create animation!", 'Prefix Field Must Not Be Blank!', 3000, ERROR);
				return;
			}
			var animationData:AnimationData = {
				name: name,
				prefix: prefix
			};
			CharacterEditorState.instance.animationList.push(NullChecker.checkAnimation(animationData));
			CharacterEditorState.instance.refreshAnimations();
			CharacterEditorState.instance.refreshAnimationDropdown();
			var dpdw = CharacterEditorState.instance.animationDropdown;
			dpdw.selectedIndex = dpdw.options.length - 1;
			dpdw.onChange(dpdw.selectedIndex, dpdw.options[dpdw.selectedIndex]);
			close();
		});
	}

	override function close() {
		super.close();
		FlxG.state.persistentUpdate = true;
	}

}