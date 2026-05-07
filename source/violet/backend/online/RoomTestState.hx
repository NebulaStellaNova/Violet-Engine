package violet.backend.online;

import flixel.FlxCamera;
import flixel.FlxObject;
import violet.data.stage.Stage;

class RoomTestState extends StateBackend {

	var camFollowPoint:FlxObject = new FlxObject();

	var textCam:FlxCamera = new FlxCamera();

	override function create() {
		super.create();
		new Stage('mainStage').load([]);


		textCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(textCam, false);

		camFollowPoint.x += FlxG.width/2;
		camFollowPoint.y += FlxG.height/2;
		FlxG.camera.follow(camFollowPoint);
		FlxG.camera.snapToTarget();

		var controlsText = new NovaText(10, 10, 0, [
			'Controls:',
			'W, A, S, D = Sing Anims',
			'←, ↓, ↑, → = Move Your BF',
			"I, J, K, L = Move Camera",
			"Q, E = Zoom Camera"
		].join("\n"), 20);
		controlsText.setFormat(Paths.font('vcr.ttf'), 40);
		controlsText.scrollFactor.set();
		controlsText.alignment = RIGHT;
		controlsText.borderStyle = OUTLINE;
		controlsText.borderColor = FlxColor.BLACK;
		controlsText.borderSize = 3;
		controlsText.updateHitbox();
		add(controlsText);

		controlsText.camera = textCam;
		controlsText.x = FlxG.width - controlsText.width - 10;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.pressed.J) camFollowPoint.x -= 1000 * elapsed;
		if (FlxG.keys.pressed.L) camFollowPoint.x += 1000 * elapsed;
		if (FlxG.keys.pressed.I) camFollowPoint.y -= 1000 * elapsed;
		if (FlxG.keys.pressed.K) camFollowPoint.y += 1000 * elapsed;
		if (FlxG.keys.pressed.Q) FlxG.camera.zoom -= elapsed;
		if (FlxG.keys.pressed.E) FlxG.camera.zoom += elapsed;
	}
}