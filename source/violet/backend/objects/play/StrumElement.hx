package violet.backend.objects.play;

class StrumElement extends NovaSprite {
	public final parent:Strum;

	public function new(parent:Strum, ?path:String) {
		super(path);
		this.parent = parent;
	}

	public function setScale(value:Float, updateHitbox:Bool = true):Void {
		scale.set(value, value);
		scale.scale(parent.parent.strumScale);
		if (updateHitbox) this.updateHitbox();
	}

	override public function playAnim(name:String, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		if (this.animation.exists(name)) {
			super.playAnim(name, forced, reversed, frame);
			if (!this.anims.exists(name)) this.offset.set();
			centerOffsets();
			centerOrigin();
		}
	}

	override public function draw():Void {
		if (parent.parent.downscroll) {
			final prevY:Float = y;
			y = getDefaultCamera().height - y - height;
			globalOffset.y *= -1;
			super.draw();
			globalOffset.y *= -1;
			y = prevY;
		} else super.draw();
	}
}