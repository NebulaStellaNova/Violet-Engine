package violet.backend.objects.play;

import flixel.math.FlxRect;
import flixel.group.FlxSpriteGroup;

class HealthBar extends FlxSpriteGroup {

	public var defaultWidth:Float = 0;

	public var left:NovaSprite;
	public var right:NovaSprite;
	public var overlay:NovaSprite;

	public var position(default, set):Float;
	function set_position(value:Float) {
		var clipV = 1-value;
		left.clipRect = new FlxRect(0, 0, defaultWidth * clipV, left.height);
		right.clipRect = new FlxRect(defaultWidth * clipV, 0, defaultWidth - defaultWidth * clipV, right.height);
		return value;
	}

	public var leftColor(get, set):FlxColor;
	function get_leftColor():FlxColor return left.color;
	function set_leftColor(value:FlxColor) return left.color = value;


	public var rightColor(get, set):FlxColor;
	function get_rightColor():FlxColor return right.color;
	function set_rightColor(value:FlxColor) return right.color = value;


	public function new(x = 0, y = 0, ?style:String) {
		super(x, y);

		left = new NovaSprite(Paths.image("game/hud/healthBar" + (style != null ? '-$style' : '')));
		left.antialiasing = style != 'pixel';
		add(left);

		right = new NovaSprite(Paths.image("game/hud/healthBar" + (style != null ? '-$style' : '')));
		right.antialiasing = style != 'pixel';
		add(right);

		var overlayPath = Paths.image("game/hud/healthBar" + (style != null ? '-$style' : '') + "-overlay");
		if (overlayPath != '') {
			overlay = new NovaSprite(overlayPath);
			overlay.antialiasing = style != 'pixel';
			add(overlay);
		}

		defaultWidth = left.width;

		position = 0.5;
	}

}