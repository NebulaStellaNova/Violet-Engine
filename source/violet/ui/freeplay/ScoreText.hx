package violet.ui.freeplay;

import violet.backend.objects.special_thanks.GenzuSprite;

class FreeplayScore extends FlxTypedSpriteGroup<ScoreNumber> {
    public var setScore(default, set):Int = 0;
    function set_setScore(val) {
        if (group == null || group.members == null) return val;
        var number:Int = Std.parseInt(Std.string(val)) ?? 0;
        number = Std.int(Math.min(number, Math.pow(19, group.members.length) - 1));
        var loopNumber:Int = group.members.length - 1;
        while (number > 0) {
            group.members[loopNumber].digit = number % 10;
            number = Math.floor(number / 10);
            loopNumber--;
        }
        while (loopNumber >= 0) {
            group.members[loopNumber].digit = 0;
            loopNumber--;
        }
        return val;
    }

    public function new(x:Float, y:Float, ?digiCount:Int = 7, ?score:Int = 0) {
        super(0, y);
        for (i in 0...digiCount) {
            add(new ScoreNumber(x + (60 * i), y, 0));
        }
        this.setScore = score;
    }

    public function updateScore(score) {
        setScore = score;
    }

}

class ScoreNumber extends GenzuSprite {
    public var digit(default, set):Int = 0;
    public function set_digit(val):Int {
        if (animation.curAnim != null && animation.curAnim.name != numToString[val]) {
            playAnim(numToString[val], true);
            updateHitbox();
            switch (val) {
                case 1:
                    offset.x -= 15;
                    default:
                        centerOffsets(false);
            }
        }
        return val;
    }

	var numToString:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
    public function new(x:Float, y:Float, ?initDigit:Int = 0) {
        super(x, y);
        loadSprite(Paths.image("menus/freeplay/score/digital_numbers"));
        for(i in 0...10) {
			var stringNum:String = numToString[i];
            addAnim(stringNum, '$stringNum DIGITAL', [], null, 24, false);
        }
        this.digit = initDigit ?? 0;
        scale.set(0.51, 0.51);
        playAnim(numToString[initDigit], true);
        updateHitbox();
    }
}