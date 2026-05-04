package violet.states.menus.online;

import violet.backend.online.SocketHandler;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

class HostMenu extends SubStateBackend {

	var fieldsImage:NovaSprite;
	var doneButton:NovaSprite;

	var nameHitbox:FlxSprite;
	var passwordHitbox:FlxSprite;

	var nameField:Field;
	var passwordField:Field;


	override function create() {
		super.create();

		camera = new FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera, false);

		fieldsImage = new NovaSprite(Paths.image('menus/onlinemenu/fields'));
		add(fieldsImage);

		nameHitbox = new FlxSprite(620, 300).makeGraphic(443, 49, FlxColor.RED);
		nameHitbox.alpha = 0;
		add(nameHitbox);

		nameField = new Field();
		nameField.x = nameHitbox.x;
		nameField.y = nameHitbox.y;
		add(nameField);

		passwordHitbox = new FlxSprite(620, 378).makeGraphic(443, 49, FlxColor.RED);
		passwordHitbox.alpha = 0;
		add(passwordHitbox);

		passwordField = new Field();
		passwordField.x = passwordHitbox.x;
		passwordField.y = passwordHitbox.y;
		add(passwordField);

		doneButton = new NovaSprite(Paths.image('menus/onlinemenu/done'));
		doneButton.screenCenter(X);
		add(doneButton);
	}

	function onClickDone() {
		SocketHandler.createRoom(nameField.text, passwordField.text);
		close();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		fieldsImage.screenCenter();
		doneButton.screenCenter(X);
		doneButton.y = fieldsImage.y + fieldsImage.height + 50;

		doneButton.scale.x = doneButton.scale.y = lerp(doneButton.scale.y, FlxG.mouse.overlaps(doneButton, camera) ? 1.1 : 1, 0.2);
		if (FlxG.mouse.overlaps(doneButton, camera) && FlxG.mouse.justPressed) onClickDone();

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(nameHitbox, camera) || FlxG.mouse.overlaps(passwordHitbox, camera)) {
				if (FlxG.mouse.overlaps(nameHitbox, camera)) {
					nameField.selected = true;
					passwordField.selected = false;
				} else if (FlxG.mouse.overlaps(passwordHitbox, camera)) {
					nameField.selected = false;
					passwordField.selected = true;
				}
			} else {
				nameField.selected = false;
				passwordField.selected = false;
			}
		}

		if (FlxG.keys.justPressed.ESCAPE) close();
	}
}