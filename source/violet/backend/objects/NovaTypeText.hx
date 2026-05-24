package violet.backend.objects;

import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;

/**
 * Taken from VSlice.
 */
class NovaTypeText extends FlxTypeText {

	public var preWrapping:Bool;
	public var upscaleResolution:Float;

	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, upscaleRes:Float = 1, ?font:String, checkWrap:Bool = true) {
		upscaleResolution = upscaleRes;

		var scaleFactor:Float = (upscaleResolution*2);
		fieldWidth *= scaleFactor;
		super(x, y, fieldWidth*scaleFactor, text, Math.floor(size*scaleFactor));
		this.scale.set(1/scaleFactor, 1/scaleFactor);
		this.updateHitbox();
		if (font != null) this.font = font;
		preWrapping = checkWrap;
	}

	inline public function getWidth(mult:Float = 1) {
		return (this.frameWidth / (upscaleResolution*2))*mult;
	}

	inline public function getHeight(mult:Float = 1) {
		return (this.frameHeight / (upscaleResolution*2))*mult;
	}

	override public function start(?Delay:Float, ForceRestart:Bool = false, AutoErase:Bool = false, ?SkipKeys:Array<FlxKey>, ?Callback:Void->Void):Void {
		if (Delay != null) delay = Delay;
		_typing = true;
		_erasing = false;
		paused = false;
		_waiting = false;

		if (ForceRestart) {
			text = "";
			_length = 0;
		}

		autoErase = AutoErase;

		if (SkipKeys != null) skipKeys = SkipKeys;
		if (Callback != null) completeCallback = Callback;
		if (useDefaultSound) loadDefaultSound();


		// Autocomplete if the text is empty anyway. Why bother?
		if (_finalText.length == 0) {
			onComplete();
			return;
		}

		if (preWrapping)
			insertBreakLines();
	}

	override function insertBreakLines() {
		var saveText = text;

		// See what it looks like when it's finished typing.
		text = prefix + _finalText;
		var prefixLength:Null<Int> = prefix.length;
		var split:String = '';

		// trace('Breaking apart text lines...');

		for (i in 0...textField.numLines) {
			var curLine = textField.getLineText(i);
			// trace('now at line $i, curLine: $curLine');
			if (prefixLength >= curLine.length) {
				prefixLength -= curLine.length;
			} else if (prefixLength != null) {
				split += curLine.substr(prefixLength);
				prefixLength = null;
			} else {
				split += '\n' + curLine;
			}
			// trace('now at line $i, split: $split');
		}

		_finalText = split;
		text = saveText;
	}

}