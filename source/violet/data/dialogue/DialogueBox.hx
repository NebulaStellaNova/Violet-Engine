package violet.data.dialogue;

import violet.backend.objects.NovaTypeText;
import violet.backend.scripting.ScriptPack;
import violet.backend.scripting.events.PlayAnimationEvent;

class DialogueBox extends FlxSpriteGroup {

	public var scripts:ScriptPack = new ScriptPack();

	public var convo:Null<Conversation>;

	public final id:String;
	public final _data:DialogueBoxData;

	public var text(get, set):String;
	inline function get_text():String
		return textDisplay.text;
	inline function set_text(value:String):String {
		textDisplay.resetText(value);
		textDisplay.start();
		return textDisplay.text = value;
	}

	public var boxSprite:NovaSprite;
	public var textDisplay:NovaTypeText;

	public function new(id:String, ?convo:Conversation) {
		super();
		this.id = id;
		this.convo = convo;
		this._data = DialogueBoxRegistry.fetchEntry(id) ?? DialogueBoxRegistry.fetchEntry('default');

		ModdingAPI.checkForScripts('data/dialogue/boxes', id, scripts);
		scripts.parent = this;
		scripts.callVariants('create');

		boxSprite = new NovaSprite(Paths.image(this._data.assetPath));
		boxSprite.antialiasing = !(this._data.isPixel ?? false);
		boxSprite.scale.set(this._data.scale ?? 1, this._data.scale ?? 1);
		if (this._data.offsets != null) boxSprite.globalOffset.set(this._data.offsets[0] ?? 0, this._data.offsets[1] ?? 0);
		boxSprite.updateHitbox();

		NullChecker.checkAnimations(this._data.animations);
		for (data in this._data.animations) boxSprite.addFrames(Paths.image(data.assetPath));
		boxSprite.addAnimsFromDataArray(this._data.animations);

		textDisplay = new NovaTypeText(0, 0, this._data.text.width ?? 300);
		textDisplay.setFormat(Paths.font(this._data.text.font), this._data.text.size ?? 32, this._data.text.color.ifNull(FlxColor.WHITE), LEFT, this._data.text.borderStyle ?? OUTLINE, this._data.text.borderColor.ifNull(FlxColor.BLACK));
		var point:ArrayPoint<Float> = this._data.text.borderSize.resolve(2);
		if (!point.isSingular() && this._data.text.borderStyle == SHADOW)
			textDisplay.borderStyle = SHADOW_XY(point[0], point[1]);
		else textDisplay.borderSize = this._data.text.borderSize ?? 2;
		point.clear();
		// textDisplay.sounds = [FlxG.sound.load(Cache.sound(), 0.6)];
		if (this._data.offsets != null) textDisplay.setPosition(this._data.text.offsets[0] ?? 0, this._data.text.offsets[1] ?? 0);

		add(boxSprite);
		add(textDisplay);

		boxSprite.animation.onFrameChange.add(this.onAnimationFrame);
   		boxSprite.animation.onFinish.add(this.onAnimationFinished);
		scripts.callVariants('postCreate');
	}

	function onAnimationFinished(name:String):Void {
		convo?.scripts.callVariants('boxAnimationFinished', [name]);
		scripts.callVariants('animationFinished', [name]);
		@:privateAccess convo?.speaker?.scripts.callVariants('boxAnimationFinished', [name]);
	}
	function onAnimationFrame(name:String, frameNumber:Int, frameIndex:Int):Void {
		convo?.scripts.callVariants('boxAnimationFrame', [name, frameNumber, frameIndex]);
		scripts.callVariants('animationFrame', [name, frameNumber, frameIndex]);
		@:privateAccess convo?.speaker?.scripts.callVariants('boxAnimationFrame', [name, frameNumber, frameIndex]);
	}

	public function playAnim(name:String, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		var event = scripts.event('playAnim', new PlayAnimationEvent(name, forced, reversed, frame));
		if (event.cancelled) return;
		boxSprite.playAnim(event.name, event.forced, event.reversed, event.frame);
		scripts.event('playAnimPost', event);
	}

	public var typingCompleteCallback:Null<Void->Void>;
	public function onTypingComplete():Void {
		if (typingCompleteCallback != null)
			typingCompleteCallback();
		scripts.callVariants('typingComplete');
	}

}