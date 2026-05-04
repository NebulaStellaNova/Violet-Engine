package violet.states.menus;

import flixel.FlxCamera;
import violet.backend.SubStateBackend;
import violet.states.menus.online.*;

class OnlineMenu extends SubStateBackend {

	public var gradient:NovaSprite;

	public var joinButton:NovaSprite;
	public var hostButton:NovaSprite;

	public var posOffset:Float = 0;

	public var bubbles:Array<NovaSprite> = [];

	override function create() {
		super.create();

		camera = new FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera, false);

		gradient = new NovaSprite(Paths.image('menus/onlinemenu/gradient'));
		gradient.scale.set(FlxG.width, 1);
		gradient.alpha = 0;
		add(gradient);

		for (i in 0...10) {
			var tempBubble:NovaSprite = new NovaSprite(Paths.image('menus/onlinemenu/bubble2'));
			tempBubble.y = FlxG.height + FlxG.random.int(0, FlxG.height);
			tempBubble.x = FlxG.random.int(0, FlxG.width);
			tempBubble.velocity.y = -FlxG.random.int(100, 300);
			tempBubble.scale.x = tempBubble.scale.y = FlxG.random.float(0.5, 1.5);
			tempBubble.alpha = 0.5;
			tempBubble.blend = ADD;
			add(tempBubble);
			bubbles.push(tempBubble);

			var tempBubble:NovaSprite = new NovaSprite(Paths.image('menus/onlinemenu/bubble1'));
			tempBubble.y = FlxG.height + FlxG.random.int(0, FlxG.height);
			tempBubble.x = FlxG.random.int(0, FlxG.width);
			tempBubble.velocity.y = -FlxG.random.int(100, 300);
			tempBubble.scale.x = tempBubble.scale.y = FlxG.random.float(0.5, 1.5);
			tempBubble.alpha = 0.5;
			tempBubble.blend = ADD;
			add(tempBubble);
			bubbles.push(tempBubble);
		}

		joinButton = new NovaSprite(Paths.image('menus/onlinemenu/join'));
		joinButton.x = FlxG.width;
		add(joinButton);

		hostButton = new NovaSprite(Paths.image('menus/onlinemenu/host'));
		hostButton.x = FlxG.width;
		add(hostButton);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		gradient.screenCenter(X);
		gradient.alpha = lerp(gradient.alpha, 1, 0.1);

		joinButton.screenCenter(Y);
		joinButton.y -= 115;
		joinButton.x -= posOffset;
		joinButton.x = lerp(joinButton.x,(FlxG.width/2) - (joinButton.width/2), 0.1);
		joinButton.x += posOffset;

		hostButton.screenCenter(Y);
		hostButton.y += 115;
		hostButton.x -= posOffset;
		hostButton.x = lerp(hostButton.x, (FlxG.width/2) - (hostButton.width/2), 0.1);
		hostButton.x += posOffset;

		joinButton.scale.x = joinButton.scale.y = lerp(joinButton.scale.x, FlxG.mouse.overlaps(joinButton, camera) ? 1.1 : 1, 0.2);
		hostButton.scale.x = hostButton.scale.y = lerp(hostButton.scale.x, FlxG.mouse.overlaps(hostButton, camera) ? 1.1 : 1, 0.2);

		if ((FlxG.mouse.overlaps(joinButton, camera) || FlxG.mouse.overlaps(hostButton, camera)) && FlxG.mouse.justPressed) {
			FlxTween.tween(this, { posOffset: -FlxG.width*2 }, 0.5, { ease: FlxEase.smootherStepIn });
			if (FlxG.mouse.overlaps(joinButton, camera)) {
				FlxTimer.wait(0.5, ()->openSubState(new JoinMenu()));
				persistentUpdate = true;
			} else {
				FlxTimer.wait(0.5, ()->openSubState(new HostMenu()));
				persistentUpdate = true;
			}
		}

		if (Controls.back && subState == null) {
			if (Std.isOfType(_parentState, MainMenu)) cast(_parentState, MainMenu).bg.x = 0;
			close();
		}

		for (i in bubbles) {
			if (i.y < -100) {
				i.y += FlxG.height + 100;
			}
		}
	}

	override function closeSubState() {
		super.closeSubState();
		FlxTween.tween(this, { posOffset: 0 }, 0.5, { ease: FlxEase.smootherStepOut });
	}

}