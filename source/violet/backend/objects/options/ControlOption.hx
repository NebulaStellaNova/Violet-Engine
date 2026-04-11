package violet.backend.objects.options;

import flixel.effects.FlxFlicker;
import violet.states.menus.OptionsMenu;
import violet.backend.utils.NovaUtils;

class ControlOption extends BaseOption {

	public var controlArray:Array<String> = ['A', 'B'];

	public var leftControl:Alphabet;
	public var rightControl:Alphabet;

	public var selectedKeybind:Bool = true;

	public dynamic function onChange(which:Bool) {}

	public function new(title:String, description:String = "") {
		super(title, description);

		leftControl = new Alphabet('A');
		add(leftControl);

		rightControl = new Alphabet('B');
		add(rightControl);
	}

	var waitingForInput:Bool = false;

	var flickering = false;

	var allowThisFrame = true;

	var time:Float = 0;
	override function update(elapsed:Float) {
		super.update(elapsed);
		time += elapsed;

		if (!allowThisFrame) allowThisFrame = true;

		for (i in [].concat(alphabet.letters).concat(leftControl.letters).concat(rightControl.letters)) {
			i.visible = flickering ? (time % 0.1 > 0.03) : true;
		}

		if (OptionsMenu.instance.enableInput) {
			if (Controls.uiLeft && !selectedKeybind) {
				selectedKeybind = true;
			} else if (Controls.uiRight && selectedKeybind) {
				selectedKeybind = false;
			}
		}

		leftControl.text = controlArray[0];
		rightControl.text = controlArray[1];

		if (!selected) return;

		if (waitingForInput) {
			var blacklist = ["NONE", "ANY", "keyManager", "status"];
			for (i in Reflect.fields(FlxG.keys.justPressed)) {
				if (blacklist.contains(i)) continue;
				if (FlxG.keys.anyJustPressed([i])) {
					allowThisFrame = false;
					controlArray[selectedKeybind ? 0 : 1] = i;
					waitingForInput = false;
					flickering = false;
					new FlxTimer().start(0.01, (_)->OptionsMenu.instance.enableInput = true);
				}
			}
		}

		if (Controls.accept && allowThisFrame) {
			OptionsMenu.instance.enableInput = false;
			waitingForInput = true;
			flickering = true;
			NovaUtils.playMenuSFX(CONFIRM);
		}
	}

	override function updatePosition() {
		super.updatePosition();

		rightControl.x = (FlxG.width - this.x) - rightControl.width;
		leftControl.x = rightControl.x - leftControl.width - 100;
		// leftControl.x = alphabet.x + alphabet.width + 100;
		// rightControl.x = leftControl.x + leftControl.width + 100;
		leftControl.y = rightControl.y = alphabet.y;

		if (selected) {
			leftControl.alpha = selectedKeybind ? 1 : 0.5;
			rightControl.alpha = !selectedKeybind ? 1 : 0.5;
		} else {
			leftControl.alpha = rightControl.alpha = alphabet.alpha;
		}
	}

}