package violet.states.menus.online;
import lemonui.elements.TextInput;

class Field extends FlxSpriteGroup {

	private var textObj:NovaText;
	private var cursor:FlxSprite;

	public var selected:Bool = false;

	public var text(get, set):String;
	function get_text() return textObj.text;
	function set_text(v) return textObj.text = v;

	override public function new() {
		super();

		textObj = new NovaText(10, 0, null, '', 50, Paths.font('Inconsolata-Bold.ttf'));
		textObj.size = 75;
		add(textObj);

		cursor = new FlxSprite(0, 5).makeGraphic(3, 40, FlxColor.WHITE);
		add(cursor);

		toggle();
	}

	var timer:FlxTimer;
	function toggle() {
		cursor.visible = !cursor.visible;
		timer = FlxTimer.wait(0.5, toggle);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		cursor.alpha = selected ? 1 : 0;

		if (selected) {
			var shifted = FlxG.keys.pressed.SHIFT;
			for (entry in @:privateAccess TextInput.PRINTABLE_KEYS) {
				if (FlxG.keys.checkStatus(entry.key, JUST_PRESSED)) {
					text += shifted ? entry.upper : entry.lower;
					break;
				}
			}
			if (FlxG.keys.justPressed.BACKSPACE) {
				text = text.substr(0, text.length-1);
			}
		}

		textObj.updateHitbox();
		cursor.x = this.x + textObj.width + 15;
		if (textObj.text == "") cursor.x -= textObj.width;
	}

	override function destroy() {
		super.destroy();
		timer.cancel();
	}

}