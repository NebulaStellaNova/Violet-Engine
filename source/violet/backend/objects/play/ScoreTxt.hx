package violet.backend.objects.play;

import flixel.group.FlxSpriteGroup;

class ScoreTxt extends FlxSpriteGroup {

    private var numbers:Array<NovaSprite> = [];

    public var fontSize = 50;

    public var value:Int = 0;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        var theScale = fontSize/100;
        var score = new NovaSprite(0, 0, Paths.image("game/hud/score/score"));
        score.antialiasing = true;
        score.scale.set(theScale, theScale);
        score.updateHitbox();
        add(score);

        var x = score.x + score.width + 10;
        for (i in 0...8) {
            var number = new NovaSprite(x, 0, Paths.image("game/hud/score/numbers"));
            for (i in ["-"].concat([for (i in 0...10) '$i'])) {
                number.addAnim(i, i);
            }
            number.playAnim("0", true);
            number.antialiasing = true;
            number.scale.set(theScale, theScale);
            number.updateHitbox();
            add(number);
            numbers.push(number);
            x += number.width - 2;
        }
    }

    function addZeros(number:Int) {
        var finalStr = number + "";
        for (i in 0...8-finalStr.length) {
            finalStr = "0" + finalStr;
        }
        return finalStr;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        var target = addZeros(value).split("");
        for (i=>number in numbers) {
            number.playAnim(target[i], true);
        }
    }
}