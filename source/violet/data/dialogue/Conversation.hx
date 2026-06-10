package violet.data.dialogue;

import violet.backend.scripting.ScriptPack;
import violet.backend.scripting.events.EventBase;
import violet.backend.scripting.events.dialogue.*;
import violet.backend.utils.NovaUtils;
import violet.data.dialogue.ConversationData;
import violet.states.PlayState;

enum abstract ConversationState(String) {
	/**
	 * We just startin'.
	 */
	var START = 'start';
	/**
	 * The box is opening.
	 */
	var OPENING = 'opening';
	/**
	 * Someone is speaking.
	 */
	var SPEAKING = 'speaking';
	/**
	 * Awaiting user input.
	 */
	var IDLE = 'idle';
	/**
	 * The conversation is ending.
	 */
	var ENDING = 'ending';
}

class Conversation extends FlxSpriteGroup {

	public var scripts:ScriptPack = new ScriptPack();

	public var convoState:ConversationState = START;

	public function callInScripts(name:String, ?args:Array<Dynamic>, ?otherScripts:String):Void {
		scripts.callVariants(name, args);
		box?.scripts.callVariants(otherScripts ?? name, args);
		speaker?.scripts.callVariants(otherScripts ?? name, args);
	}
	public function runEvent<T:EventBase>(func:String, event:T, ?otherScripts:String):T {
		#if SCRIPT_SUPPORT
		scripts.event(func, event);
		box?.scripts.event(otherScripts ?? func, event);
		speaker?.scripts.event(otherScripts ?? func, event);
		#end
		return event;
	}

	public final id:String;
	public final formattedId:String;
	public final _data:ConversationData;

	public final dialogueEntries:Array<DialogueEntryData>;
	public var currentEntryIndex(default, null):Int = 0;
	public var currentLineIndex(default, null):Int = 0;

	public var currentEntry(get, never):DialogueEntryData;
	public function get_currentEntry():DialogueEntryData {
		if (currentEntryIndex > dialogueEntries.length) return null;
		return dialogueEntries[currentEntryIndex];
	}
	public var currentLine(get, never):ConversationTextPiece;
	public function get_currentLine():ConversationTextPiece {
		if (currentLineIndex >= currentEntry.lines.length) return null;
		return currentEntry.lines[currentLineIndex];
	}

	@:unreflective var _text:String = '';
	public var currentText(get, set):String;
	inline function get_currentText():String {
		if (box != null) box.text = _text;
		return _text;
	}
	inline function set_currentText(value:String):String {
		if (box != null) box.text = value;
		return _text = value;
	}

	var music:FlxSound;
	var backdrop:NovaSprite;

	var speaker:Speaker;
	var box:DialogueBox;

	var lastBoxAnim:String = '';

	// all loaded entries
	var boxes:Array<DialogueBox> = [];
	var speakers:Array<Speaker> = [];

	public function new(id:String, ?prefix:String, ?suffix:String) {
		super();
		this.id = id;
		inline function checkString(?str:String):Bool return str == null || str.trim() == '';
		this.formattedId = '${checkString(prefix) ? '' : '$prefix-'}$id${checkString(PlayState.variation) ? '' : '-${PlayState.variation}'}${checkString(suffix) ? '' : '-$suffix'}';
		this._data = ConversationRegistry.fetchEntry(formattedId);
		this.dialogueEntries = this._data.dialogue.copy();

		camera = new flixel.FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera, false);

		ModdingAPI.checkForScripts('data/dialogue/conversations', formattedId, scripts);
		ModdingAPI.checkForScripts('songs/${PlayState.song}', formattedId, scripts);
		scripts.parent = this;
		scripts.callVariants('create');

		music = FlxG.sound.load(Cache.sound('flixel'));
		backdrop = new NovaSprite();
		this._data.backdrop.build(
			// calling upon conversation scripts alone, on purpose
			data -> {
				// only called if the type is unrecognized
				if (!(data.type == 'none' || data.type == null))
					scripts.callVariants('buildBackdrop', [data.type, data]);
			},
			data -> {
				var event = scripts.event('buildSolidBackdrop', new BuildSolidBackdropEvent(data.color, data.fadeTime ?? 0));
				if (event.cancelled) return;

				backdrop.makeGraphic(FlxG.width, FlxG.height, event.color);
				if (event.fadeTime >= 0) {
					backdrop.alpha = 0;
					FlxTween.tween(backdrop, {alpha: 1}, event.fadeTime, {ease: FlxEase.circOut});
				}
			}
		);
		add(backdrop);
		backdrop.z = 10;

		loadEntries();

		scripts.callVariants('postCreate');

		trace(0);
		if (currentEntry.music != null)
			loadMusicViaData(currentEntry.music);
		trace(1);
		convoState = OPENING;
		trace(2);
		changeBox(currentEntry.box);
		trace(3);
		box.playAnim(currentEntry.boxAnim, true);
		trace(4);
		lastBoxAnim = box.animation?.name ?? '';
		trace(5);
		// next();
	}

	public function loadEntries():Void {
		for (entry in dialogueEntries) {
			if (!boxes.exists(box -> return box.id == entry.box)) {
				final box = new DialogueBox(entry.box, this);
				box.kill();
				boxes.push(box);
			}
			if (!speakers.exists(speaker -> return speaker.id == entry.speaker)) {
				final speaker = new Speaker(entry.speaker, this);
				speaker.kill();
				speakers.push(speaker);
			}

			for (entry in entry.lines) {
				if (entry.box != null && !boxes.exists(box -> return box.id == entry.box)) {
					final box = new DialogueBox(entry.box, this);
					box.kill();
					boxes.push(box);
				}
				if (entry.speaker != null && !speakers.exists(speaker -> return speaker.id == entry.speaker)) {
					final speaker = new Speaker(entry.speaker, this);
					speaker.kill();
					speakers.push(speaker);
				}
			}
		}
	}

	public function loadMusicViaData(data:MusicData):Void {
		if (data.pause != null) {
			var event = runEvent('musicPause', new EventBase());
			if (event.cancelled) return;
			if (data.pause) music.pause();
			else music.play();
			return;
		}
		loadMusic(data.asset, data.fadeTime ?? 0);
	}
	public function loadMusic(asset:String, fadeTime:Float = 0):Void {
		var event = runEvent('preLoadMusic', new ConversationMusicEvent(Paths.music(asset), fadeTime));
		if (event.cancelled) return;

		music.loadEmbedded(event.asset, true);
		music.volume = 1;
		if (event.fadeTime >= 0) {
			music.fadeIn(event.fadeTime);
		} else music.play(true);

		runEvent('postLoadMusic', event);
	}

	public function changeBox(boxId:String):DialogueBox {
		final wasNull = box == null;
		if (!wasNull && box.id == boxId) return box;
		var newBox = boxes.find(box -> return box.id == boxId);
		if (newBox == null) {
			trace('warning:<orange>Couldn\'t find box with ID "<magenta>$boxId<orange>", using default box.');
			newBox = boxes.find(box -> return box.id == 'default');
			if (newBox == null) {
				NovaUtils.addNotification('Default box not found', 'Couldn\'t find the default box, looks like you need to double-check some things.', ERROR);
				return box;
			}
		}

		boxes.remove(newBox);
		if (!wasNull) {
			box.typingCompleteCallback = null;
			box.kill();
		}
		if (members.has(box))
			members.remove(box);

		add(newBox);
		newBox.revive();
		newBox.z = 300;
		newBox.typingCompleteCallback = onTypingComplete;
		return box = newBox;
	}
	public function getSpeaker(speakerId:String):Speaker {
		final wasNull = speaker == null;
		if (!wasNull && speaker.id == speakerId) return speaker;
		var newSpeaker = speakers.find(speaker -> return speaker.id == speakerId);
		if (newSpeaker == null) {
			trace('warning:<orange>Couldn\'t find speaker with ID "<magenta>$speakerId<orange>", using default speaker.');
			newSpeaker = speakers.find(speaker -> return speaker.id == 'bf');
			if (newSpeaker == null) {
				NovaUtils.addNotification('Default speaker not found', 'Couldn\'t find the default speaker, looks like you need to double-check some things.', ERROR);
				return speaker;
			}
		}

		speakers.remove(newSpeaker);
		if (!wasNull) speaker.kill();
		if (members.has(speaker))
			members.remove(speaker);

		add(newSpeaker);
		newSpeaker.revive();
		newSpeaker.z = 200;
		return speaker = newSpeaker;
	}

	public function next():Void {
		trace(0);
		var event = runEvent('preNextDialogue', new EventBase());
		if (event.cancelled) return;
		var dialogueEvent:Null<OnDialogueEntryEvent> = null;
		trace(1);

		currentLineIndex++;
		if (currentLineIndex >= currentEntry.lines.length) {
			trace(2);
			currentLineIndex = 0;
			currentEntryIndex++;

			if (currentEntryIndex >= dialogueEntries.length)
				end();
			else {
				trace(3);
				if (convoState == IDLE) {
					trace(4);
					dialogueEvent = runEvent('nextDialogue', new OnDialogueEntryEvent(currentEntry, currentLine));
					if (dialogueEvent.cancelled) return;
					convoState = OPENING;

					if (dialogueEvent.entry.music != null)
						loadMusicViaData(dialogueEvent.entry.music);
					changeBox(dialogueEvent.entry.box);
					box.playAnim(dialogueEvent.entry.boxAnim, true);
					lastBoxAnim = box.animation.name;
					trace(5);
				}
				trace(6);
			}
		} else {
			trace(7);
			trace([currentEntryIndex, currentLineIndex, dialogueEvent, convoState]);
			trace([currentEntry, currentLine]);
			dialogueEvent = runEvent('nextDialogue', new OnDialogueEntryEvent(currentEntry, currentLine));
			if (dialogueEvent.cancelled) return;
			convoState = SPEAKING;

			trace(8);
			if (dialogueEvent.line.music != null)
				loadMusicViaData(dialogueEvent.line.music);
			trace(9);
			if (dialogueEvent.line.box != null) {
				trace(10);
				var prevBox = box;
				changeBox(dialogueEvent.line.box);
				if (prevBox != box) {
					get_currentText();
					box.textDisplay.skip();
				}
				trace(11);
			}
			trace(12);
			trace([box, dialogueEvent.line.boxAnim]);
			if (dialogueEvent.line.boxAnim != null) {
				trace(13);
				box.playAnim(dialogueEvent.line.boxAnim, true);
				lastBoxAnim = box.animation.name;
			} else box.playAnim(lastBoxAnim, true);
			trace(14);

			currentText += dialogueEvent.line.text;
			trace(15);
		}
		trace([currentEntryIndex, currentLineIndex, dialogueEvent, convoState]);

		runEvent('nextDialoguePost', dialogueEvent ?? new OnDialogueEntryEvent(currentEntry, currentLine));
	}

	override public function update(elapsed:Float):Void {
		scripts.callVariants('update', [elapsed]);
		super.update(elapsed);
		switch (convoState) {
			case START:
			case OPENING:
				if (box != null && (box.animation.finished || box.animation?.name == lastBoxAnim)) {
					convoState = SPEAKING;
					getSpeaker(currentEntry.speaker);
					speaker.playAnim(currentEntry.speakerAnim, true);
					currentText = currentLine.text;
				}
			case SPEAKING:
			case IDLE:
			case ENDING:
				if (outroTween == null)
					outro();
		}
		if (Controls.accept) {
			switch (convoState) {
				case START:
				case OPENING: box?.textDisplay.skip();
				case SPEAKING: box?.textDisplay.skip();
				case IDLE: next();
				case ENDING: end();
			}
		}
		scripts.callVariants('postUpdate', [elapsed]);
		scripts.callVariants('updatePost', [elapsed]);
	}

	var outroTween:FlxTween;
	public function outro():Void {
		this._data.outro.build(
			data -> {
				// only called if the type is unrecognized
				if (!(data.type == 'none' || data.type == null))
					scripts.callVariants('buildOutro', [data.type, data, end]);
				else end();
			},
			data -> {
				final fadeTime = data.fadeTime ?? 1;
				outroTween = FlxTween.tween(this, {alpha: 0.0}, fadeTime, {
					ease: FlxEase.circOut,
					onComplete: _ -> end()
				});
				music.fadeOut(fadeTime);
			}
		);
	}

	public var completeOutroCallback:Null<Void->Void>;
	public function end():Void {
		convoState = ENDING;
		music.stop();
		if (completeOutroCallback != null)
			completeOutroCallback();
		callInScripts('endOfConvo');
	}

	public function onTypingComplete():Void {
		if (convoState != SPEAKING)
			trace('warning:<orange>Unexpected state transition from $convoState.');
		convoState = IDLE;
		callInScripts('typingComplete', 'convoTypingComplete');
	}

	override public function destroy():Void {
		scripts.callVariants('destroy');
		for (box in boxes) box.destroy();
		for (speaker in speakers) speaker.destroy();
		music.destroy();
		FlxG.cameras.remove(camera);
		super.destroy();
	}

}