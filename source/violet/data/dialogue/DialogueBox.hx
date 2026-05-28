package violet.data.dialogue;

import violet.backend.objects.NovaTypeText;
import violet.backend.scripting.ScriptPack;

class DialogueBox extends FlxSpriteGroup {

	public var scripts:ScriptPack;

	public final id:String;
	public final _data:DialogueBoxData;

	public var boxSprite:NovaSprite;
	public var textDisplay:NovaTypeText;

	public function new(id:String) {
		super();
		this.id = id;
		this._data = DialogueBoxRegistry.fetchEntry(id) ?? DialogueBoxRegistry.fetchEntry('default');

		scripts = new ScriptPack();
		ModdingAPI.checkForScripts('data/dialogue/boxes', id, scripts);
		scripts.callVariants('create');

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
		textDisplay.setFormat(Paths.font(this._data.text.fontFamily), this._data.text.size ?? 32, this._data.text.color, LEFT, this._data.text.borderStyle, this._data.text.borderColor);
		textDisplay.borderSize = this._data.text.borderSize ?? 2;
		// textDisplay.sounds = [FlxG.sound.load(Cache.sound(), 0.6)];
		if (this._data.offsets != null) textDisplay.setPosition(this._data.text.offsets[0] ?? 0, this._data.text.offsets[1] ?? 0);

		add(boxSprite);
		add(textDisplay);

		scripts.callVariants('postCreate');
	}

}