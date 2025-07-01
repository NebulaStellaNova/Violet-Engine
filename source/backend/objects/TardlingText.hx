package backend.objects;

import backend.filesystem.Paths;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

class TardlingText extends FlxTypedGroup<FlxText> {

    public var fillColor:FlxColor;
    public var outlineColor:FlxColor;

    public var outline:FlxText;
    public var fill:FlxText;
    public var alpha:Float = 1;

    public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
        super();
        outline = new FlxText(X, Y, FieldWidth, Text, Size, EmbeddedFont);
        outline.setFormat(Paths.font("Tardling v1.1.ttf"));
        add(outline);

        fill = new FlxText(X, Y, FieldWidth, Text, Size, EmbeddedFont);
        fill.setFormat(Paths.font("Tardling-Solid.ttf"));
        add(fill);
    }

    public function setFormat(?Font:String, Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, ?BorderStyle:FlxTextBorderStyle,
			BorderColor:FlxColor = FlxColor.TRANSPARENT, EmbeddedFont:Bool = true):FlxText   
	{
        this.outline.setFormat(this.outline.font, Size, this.outline.color, Alignment, BorderStyle, BorderColor, EmbeddedFont);
        this.fill.setFormat(this.fill.font, Size, this.outline.color, Alignment, BorderStyle, BorderColor, EmbeddedFont);
        return null;
    }

    override public function update(e) {
        super.update(e);
        fill.color = fillColor;
        outline.color = outlineColor;
        fill.alpha = alpha;
        outline.alpha = alpha;
    }
}