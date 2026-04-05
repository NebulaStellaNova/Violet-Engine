package violet.data.icon;

import violet.backend.objects.Bopper;
import violet.backend.utils.MathUtil;
import violet.data.Constants;

class HealthIcon extends Bopper {

	public var id:String;
	public var _data:HealthIconData;
	public var isOpponent:Bool = false;
	public var canDance:Bool = true;

	public function new(id:String) {
		this.id = id;
		var defaultData = HealthIconRegistry.healthIconDatas.get(Constants.DEFAULT_HEALTH_ICON);
		this._data = HealthIconRegistry.healthIconDatas.get(id) ?? defaultData;

		this._data.flipX ??= false;
		this._data.scale ??= 1;
		this._data.offsets ??= [0, 0];
		this._data.isPixel ??= false;
		this._data.assetPath ??= 'icons/$id';

		super(Paths.image(this._data.assetPath) != "" ? Paths.image(this._data.assetPath) : Paths.image(defaultData.assetPath));

		if (this.animated) {
			this.addAnim("idle", "idle", 24, true);
			this.addAnim("winning", "winning", 24, true);
			this.addAnim("losing", "losing", 24, true);
			/* this.animation.addByPrefix("toWinning", "toWinning", 24, false);
			this.animation.addByPrefix("toLosing", "toLosing", 24, false);
			this.animation.addByPrefix("fromWinning", "fromWinning", 24, false);
			this.animation.addByPrefix("fromLosing", "fromLosing", 24, false); */
		} else {
			var frameSize = this._data.isPixel ? 32 : 150;
			this.loadGraphic(this.graphic, true, frameSize, frameSize);
			this.animation.add("idle", [0], 1, false, false);
			this.animation.add("losing", [1], 1, false, false);
			if (animation.numFrames >= 3) this.animation.add("winning", [2], 1, false, false);
		}

		this.flipX = this._data.flipX;
		this.globalOffset.x = this._data.offsets[0] ?? 0;
		this.globalOffset.y = this._data.offsets[1] ?? 0;
		if (this._data.isPixel) this.antialiasing = false;

		this.scale.scale(this._data.scale);
		this.updateHitbox();
	}

	public function updateFromHealth(value:Float) {
		if (isOpponent) value = 1-value;
		if (this.animation.exists('winning')) {
			if (value >= 0.75) playAnim('winning');
			if (value < 0.75 && value > 0.25) playAnim('idle');
			if (value <= 0.25) playAnim('losing');
		} else {
			if (value > 0.25) playAnim('idle');
			if (value <= 0.25) playAnim('losing');
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		this.globalOffset.x = this._data.offsets[0] ?? 0;
		// this.globalOffset.y = this._data.offsets[1] ?? 0;
		if (this.flipX) this.globalOffset.x *= -1;
		// if (this._data.isPixel) this.antialiasing = false;
		if (sillyBop) this.angle = MathUtil.lerp(this.angle, 0, 0.2);
		this.scale.x = this.scale.y = MathUtil.lerp(this.scale.y, this._data.scale, 0.2);
	}

	public var sillyBop(default, set):Bool = false; // Silly Icon Bop :3
	function set_sillyBop(value:Bool):Bool {
		if (!value) this.angle = 0;
		return sillyBop = value;
	}
	override function dance(force:Bool = false) {
		if (!canDance) return;
		if (sillyBop) {
			alternator = !alternator;
			var alt:Bool = alternator;
			if (isOpponent) alt = !alt;
			this.angle = alt ? 20 : -20;
		}
		this.scale.x = this.scale.y = this._data.scale * 1.2;
	}
}