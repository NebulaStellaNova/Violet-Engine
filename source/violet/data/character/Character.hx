package violet.data.character;

import violet.backend.scripting.ScriptPack;
import openfl.display.IGraphicsData;
import violet.backend.audio.Conductor;
import violet.backend.utils.NovaUtils;

class Character extends violet.backend.objects.Bopper {

	public var scripts:ScriptPack;

	public var id:String;
	public var _data:CharacterData;

	public var idleSuffix:String = null;

	public var stagePosition:String;

	public var cameraOffsets:Array<Float> = [0, 0];

	/**
	 * Used to help 'singTimer'.
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in steps the animation can be forced to last.
	 * If set to 0 the animation that is played plays out normally.
	 */
	public var singTimer:Float = 4;
	public var isSinging:Bool = false;

	/**
     * # Daming - Give me privileges
     *
     * # GENZU - no blackie
     *
     * # Daming - BRO
    */
	public function new(x:Float = 0, y:Float = 0, id:String = 'bf', faceLeft:Bool = false) {
		this.id = id;
		this._data = CharacterRegistry.characterDatas.get(id) ?? CharacterRegistry.characterDatas.get('bf');
		super(x, y, Paths.image(this._data.assetPath));

		this._data.healthIcon ??= this.id;

		if (CharacterRegistry.characterDatas.get(id) == null) {
            NovaUtils.addNotification('Character not found!', 'Could not find character with ID "$id" using default character "bf."', ERROR);
        }

		this.cameraOffsets = this._data.cameraOffsets?.copy() ?? [0, 0];

		if (faceLeft) flipX = !flipX;
		if (this._data.flipX ?? false) flipX = !flipX;
		__baseFlipped = flipX;

		NullChecker.checkAnimations(this._data.animations);
		for (data in this._data.animations) addFrames(Paths.image(data.assetPath));
		for (data in this._data.animations) {
			// were so funny
			data.offsets[0] *= -1;
			data.offsets[1] *= -1;
			this.addAnimFromData(data);
			data.offsets[0] *= -1;
			data.offsets[1] *= -1;
		}

		this.danceEvery = this._data.danceEvery ?? (this.animationList.contains('danceLeft') ? 1 : 2);
		this.singTimer = this._data.singTime ?? 4;
		this.scale.scale(this._data.scale ?? 1);
		if (this._data.offsets != null) this.globalOffset.set(this._data.offsets[0] ?? 0, this._data.offsets[1] ?? 0);
		this.antialiasing = !(this._data.isPixel ?? false);
		this.updateHitbox();

		dance(true);
	}

	public static var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public function playSingAnim(direction:Int, isMiss:Bool = false, ?suffix:String) {
		this.playAnim('${singAnimations[direction % singAnimations.length]}${isMiss ? 'miss' : ''}${suffix != null ? '-$suffix' : ''}', true);
		this.lastHit = Conductor.songPosition;
		this.isSinging = true;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (isSinging)
			if (singTimer > 0 ? (lastHit + (Conductor.stepLengthMs * singTimer) < Conductor.songPosition) : (animation.name == null || animation.finished)) {
				dance(true);
				isSinging = false;
			}
	}

	public var canDance:Bool = true; // For play animation event;

	override public function dance(force:Bool = false) {
		if (!canDance) return;
		final suffix:String = idleSuffix != null ? '-$idleSuffix' : '';
		if (this.animationList.contains('danceLeft$suffix')) {
			if (this.animation.name != 'danceLeft$suffix' && this.animation.name != 'danceRight$suffix' && !force) return;
			this.playAnim(alternator ? 'danceLeft$suffix' : 'danceRight$suffix', true);
			alternator = !alternator;
		} else {
			if (this.animation.name != 'idle$suffix' && !force) return;
			this.playAnim('idle$suffix', true);
		}
	}

	override function beatHit(beat:Int) {
		if (beat % danceEvery == 0 && !isSinging && canDance)
			dance(true);
	}
}