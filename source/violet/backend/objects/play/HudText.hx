package violet.backend.objects.play;

import flixel.group.FlxSpriteGroup;
import violet.backend.utils.AnimationUtil;

class HudText extends FlxSpriteGroup {

	public var text(default, set):String = 'test';
	public var realWidth:Float = 0;
	function set_text(v:String) {
		refreshDisplay(v);
		realWidth = 0;
		for (i in letters) {
			realWidth += i.width;
		}
		realWidth -= 27;
		return text = v;
	}

	private var letters:Array<NovaSprite> = [];

	public var fontSize = 50;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		text = 'test';
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	public function refreshDisplay(?text:String):String {
		text ??= this.text;
		var theScale = fontSize/100;
		var off:Float = this.x;
		var active:Array<NovaSprite> = [];
		for (i=>letter in text.split('')) {
			var l:NovaSprite;
			if (letters[i] == null) {
				l = new NovaSprite(Paths.image("game/hud/score/english"));
				l.scale.set(theScale, theScale);
				l.updateHitbox();
				for (anim in AnimationUtil.getAnimListFromXML(Paths.image("game/hud/score/english"))) {
					l.addAnim(nameAlias(anim), anim);
				}
				add(l);
				letters.push(l);
			} else {
				l = letters[i];
				if (!members.contains(l)) add(l);
			}
			if (letter == ' ') {
				l.playAnim('a', true);
				l.visible = false;
			} else {
				l.playAnim(letter.toLowerCase(), true);
				l.visible = true;
			}
			l.x = off;
			if (letter == ':') l.x += 5;
			active.push(l);
			off += l.width - 2;
		}
		for (i in letters) {
			if (!active.contains(i)) remove(i);
		}
		return text;
	}

	public function nameAlias(animName:String):String {
		var aliases:Map<String, String> = [
			"zero" => "0", "one" => "1", "two" => "2", "three" => "3", "four" => "4",
			"five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9",
			"percent" => "%", "colon" => ":", "dash" => "-", "period" => "."
		];
		if (!aliases.exists(animName)) return animName;
		return aliases.get(animName);
	}
}