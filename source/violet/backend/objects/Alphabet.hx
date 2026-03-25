package violet.backend.objects;

import violet.backend.utils.NovaUtils;
import flixel.util.FlxAxes;
import flixel.math.FlxPoint;

class Alphabet extends flixel.group.FlxGroup {

    public static var characterOffsets:Map<String, Array<Float>> = [
        "." => [0, 38]
    ];
    public static var boldCharacterOffsets:Map<String, Array<Float>> = [
        "." => [0, 43],
        ":" => [0, 10]
    ];

    public static var xmlNames:Map<String, String> = [
        // -- Letters -- \\
        "a" => "a", "b" => "b", "c" => "c",
        "d" => "d", "e" => "e", "f" => "f",
        "g" => "g", "h" => "h", "i" => "i",
        "j" => "j", "k" => "k", "l" => "l",
        "m" => "m", "n" => "n", "o" => "o",
        "p" => "p", "q" => "q", "r" => "r",
        "s" => "s", "t" => "t", "u" => "u",
        "v" => "v", "x" => "x", "w" => "w",
        "y" => "y", "z" => "z",

        // -- Numbers -- \\
        "0" => "zero", "1" => "one", "2" => "two",
        "3" => "three", "4" => "four", "5" => "five",
        "6" => "six", "7" => "seven", "8" => "eight",
        "9" => "nine",

        // -- Symbols -- \\
        "&" => "ampersand",
        "<" => "anglebracket-left",
        ">" => "anglebracket-right",
        "*" => "asterisk",
        "@" => "at",
        "\\" => "backslash",
        "`" => "backtick",
        "^" => "caret",
        ":" => "colon",
        "," => "comma",
        "{" => "curlybracket-left",
        "}" => "curlybracket-right",
        "$" => "dollar",
        '"' => "doublequote",
        "=" => "equal",
        "!" => "exclamationmark",
        "-" => "hyphen",
        "%" => "percent",
        "." => "period",
        "+" => "plus",
        "#" => "pound",
        "?" => "questionmark",
        "(" => "roundbracket-left",
        ")" => "roundbracket-right",
        ";" => "semicolon",
        "'" => "singlequote",
        "/" => "slash",
        "[" => "squarebracket-left",
        "]" => "squarebracket-right",
        "~" => "tilde",
        "_" => "underscore",
        "|" => "verticalbar",
    ];

    public static var xmlNamesAlt:Map<String, String> = [
        '"' => "doublequote-alt",
        "!" => "exclamationmark-alt",
        "?" => "questionmark-alt",
    ];

    public var alpha(default, set):Float = 1;
    function set_alpha(value:Float) {
        for (i in letters) i.alpha = value;
        return alpha = value;
    }

    public var x(default, set):Float = 0;
    public var y(default, set):Float = 0;
    function set_x(value:Float) {
        x = value;
        updatePos();
        return value;
    }
    function set_y(value:Float) {
        y = value;
        updatePos();
        return value;
    }

    public var letters:Array</* NovaSprite */FlxSprite> = [];

    public var text(default, set):String;
    function set_text(value:String) {
        var reload = false;
        if (text != value) reload = true;
        text = value;
        if (reload) refresh();
        return value;
    }
    public var scaleX:Float = 1;
    public var scaleY:Float = 1;
    public var bold:Bool = false;
    public var useAlt:Bool = false;

    public function new(text:String, bold:Bool = true, useAlt:Bool = false) {
        super();
        @:bypassAccessor this.text = text;
        @:bypassAccessor this.bold = bold;
        @:bypassAccessor this.useAlt = useAlt;
        refresh();
    }

    public function refresh() {
        letters = [];
        for (i in members) remove(i);
        var textSplit:Array<String> = this.text.split("");
        var xPos:Float = 0;
        for (i in textSplit) {
            var isLowerCase = i != i.toUpperCase();
            i = i.toLowerCase();
            if (i == " ") {
                xPos += 30 * scaleX;
                continue;
            }
            var animationName:String = 'character-' + ((useAlt && xmlNamesAlt.exists(i)) ? xmlNamesAlt.get(i) : xmlNames.get(i)) + (xmlNamesAlt.exists(i) ? "0" : "");
            var letter = new FlxSprite(xPos + x, y);
            letter.frames = NovaUtils.getSparrowFrames(Paths.image('alphabet/english-${bold ? 'bold' : 'regular'}'));
            letter.animation.addByPrefix(i, '${animationName}0', 24, true);
            letter.animation.play(i);
            var off = (bold ? boldCharacterOffsets.get(i) : characterOffsets.get(i)) ?? [0, 0];
            letter.offset.x = -off[0];
            letter.offset.y = -off[1];
            /* var letter = new NovaSprite(xPos + x, y, Paths.image('alphabet/english-${bold ? 'bold' : 'regular'}'));
            letter.addAnim("idle", animationName, null, (bold ? boldCharacterOffsets.get(i) : characterOffsets.get(i)) ?? [0, 0], 24, true);
            letter.playAnim("idle", true); */
            letter.antialiasing = true;
            letter.scale.set(scaleX, scaleY);
            letter.updateHitbox();
            if (isLowerCase) {
                letter.scale.x *= 0.9;
                letter.scale.y *= 0.9;
                letter.y += (letter.height / 0.9) - letter.height;
                letter.updateHitbox();
            }
            letters.push(letter);
            add(letter);
            xPos += letter.width;
        }
    }

    override function update(e) {
        super.update(e);
        updatePos();
    }

    public function updatePos() {
        var textSplit:Array<String> = this.text.split("");
        var xPos:Float = 0;
        var offset:Int = 0;
        for (id => e in textSplit) {
            var l = textSplit[id];
            var isLowerCase = l != l.toUpperCase();
            var off = (bold ? boldCharacterOffsets.get(l) : characterOffsets.get(l)) ?? [0, 0];
            if (l == " ") {
                xPos += 30 * scaleX;
                offset++;
                continue;
            }
            var i = letters[id - offset];
            i.x = xPos + x + off[0];
            i.y = y + off[1];
            if (isLowerCase) {
                i.y += (i.height / 0.9) - i.height;
                i.updateHitbox();
            }
            xPos += i.width;
        }
    }

    public var width(get, never):Float;
    function get_width() {
        var out:Float = 0;
        if (letters.length == 0) return 0;
        for (i in letters) {
            if (i.x + i.width > out ) out = i.x + i.width;
        }
        out -= letters[0].x;
        return out;
    }

    public var height(get, never):Float;
    function get_height() {
        var out:Float = 0;
        if (letters.length == 0) return 0;
        for (i in letters) {
            if (i.y + i.height > out ) out = i.y + i.height;
        }
        out -= letters[0].y;
        return out;
    }

    public function screenCenter(axis:FlxAxes = XY) {
        if (axis == X || axis == XY) x = (this.camera.width/2) - (width/2);
        if (axis == Y || axis == XY) y = (this.camera.height/2) - (height/2);
        updatePos();
    }
}