package violet.data.dialogue;

import violet.backend.objects.NovaTypeText;
import violet.data.song.Song;

class DialogueBox extends FlxSpriteGroup {

	public var scripts:ScriptPack = new ScriptPack();

	public final id:String;
	public final _data:DialogueBoxData;

	public var boxSprite:NovaSprite;
	public var textDisplay:NovaTypeText;

	public function new(id:String, ?prefix:String, ?suffix:String) {
		super();
		this.id = id;
		this._data = DialogueBoxRegistry.boxDatas.get(id) ?? DialogueBoxRegistry.boxDatas.get('default');

		boxSprite = new NovaSprite(Paths.image(this._data.assetPath));
		boxSprite.flipX = this._data.flipX ?? false;
		boxSprite.flipY = this._data.flipY ?? false;
		boxSprite.antialiasing = !(this._data.isPixel ?? false);
		boxSprite.scale.set(this._data.scale ?? 1, this._data.scale ?? 1);
		if (this._data.offsets != null) boxSprite.globalOffset.set(this._data.offsets[0] ?? 0, this._data.offsets[1] ?? 0);
		boxSprite.updateHitbox();

		NullChecker.checkAnimations(this._data.animations);
		for (data in this._data.animations) boxSprite.addFrames(Paths.image(data.assetPath));
		boxSprite.addAnimsFromDataArray(this._data.animations);

		textDisplay = new NovaTypeText(0, 0, this._data.text.width ?? 300);
		textDisplay.setFormat(Paths.font(this._data.text.fontFamily), this._data.text.size ?? 32, this._data.text.color, LEFT, SHADOW, this._data.text.shadowColor);
		textDisplay.borderSize = this._data.text.shadowWidth ?? 2;
		// textDisplay.sounds = [FlxG.sound.load(Cache.sound(), 0.6)];
		if (this._data.offsets != null) textDisplay.setPosition(this._data.text.offsets[0] ?? 0, this._data.text.offsets[1] ?? 0);

		add(boxSprite);
		add(textDisplay);

		ModdingAPI.checkForScripts('data/dialogue/boxes', id, scripts);

		scripts.call('create');
	}

}