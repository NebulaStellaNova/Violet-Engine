package violet.data.character;

import sys.thread.Condition;
import violet.backend.audio.Conductor;

class Character extends violet.backend.objects.Bopper {

    public var id:String;
    public var _data:CharacterData;

	public var singTimer:Int = 0;

    /**
     *  
     *
     * Daming - Give me privileges
     *
     * GENZU - no blackie
     *
     * Daming - BRO
     *
     *  
    */
    public function new(id:String, x:Float = 0, y:Float = 0) {
        this._data = CharacterRegistry.characterDatas.get(id);// ?? CharacterRegistry.getDefaultLevelData();
        super(x, y, Paths.image(this._data.assetPath));

        this.danceEvery = this._data.danceEvery;

        for (i in this._data.animations) {
            this.addAnimFromJSON(i);
        }

        dance(true);
    }


	public var lastHit:Float = Math.NEGATIVE_INFINITY;

    public function playSingAnim(direction:Int, suffix:String = "", ?singAnimations:Array<String>) {
        singAnimations ??= ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
		this.playAnim('${singAnimations[direction]}${suffix != "" ? '-$suffix' : ''}', true);
		this.singTimer = Math.round((this._data.singTime ?? 4));
        this.lastHit = Conductor.songPosition;
	}

    var prevBeat:Int;

    override function update(elapsed:Float) {
        super.update(elapsed);

        // -- Rodney Fix Me -- \\
        if (singTimer > 0 ? (lastHit + (Conductor.stepLengthMs * singTimer) < Conductor.songPosition) : (animation.name == null || animation.finished))
            if (prevBeat != Conductor.curBeat) {
                prevBeat = Conductor.curBeat;
                if (Conductor.curBeat % this.danceEvery == 0) {
                    dance(true);
                }
            }
        // ------------------- \\
    }

}