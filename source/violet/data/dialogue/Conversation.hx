package violet.data.dialogue;

import violet.backend.scripting.ScriptPack;
import violet.backend.scripting.events.EventBase;
import violet.backend.scripting.events.dialogue.*;
import violet.backend.utils.NovaUtils;
import violet.data.dialogue.ConversationData;
import violet.states.PlayState;

enum abstract ConversationState(String) {
	var START = 'start';
	var OPENING = 'opening';
	var SPEAKING = 'speaking';
	var IDLE = 'idle';
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

	var music:FlxSound;
	var backdrop:NovaSprite;

	var speaker:Speaker;
	var box:DialogueBox;

	// all loaded entries
	var boxes:Array<DialogueBox> = [];
	var speakers:Array<Speaker> = [];

	public function new(id:String, ?prefix:String, ?suffix:String) {
		super();
		this.id = id;
		inline function checkString(?str:String):Bool return str == null || str.trim() == '';
		this.formattedId = '${checkString(prefix) ? '' : '$prefix-'}$id${checkString(PlayState.variation) ? '' : '-${PlayState.variation}'}${checkString(suffix) ? '' : '-$suffix'}';
		this._data = ConversationRegistry.fetchEntry(formattedId);
		this.dialogueEntries = this._data.dialogue;

		camera = new flixel.FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera, false);

		ModdingAPI.checkForScripts('data/dialogue/conversations', formattedId, scripts);
		ModdingAPI.checkForScripts('songs/${PlayState.song}', formattedId, scripts);
		scripts.parent = this;
		scripts.callVariants('create');

		music = FlxG.sound.load();
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
		backdrop.z = 10;
		add(backdrop);

		loadEntries();

		scripts.callVariants('postCreate');

		next();
	}

	public function loadEntries():Void {
		for (entry in dialogueEntries) {
			if (boxes.exists(box -> box.id == entry.box)) {
				final box = new DialogueBox(entry.box);
				box.kill();
				boxes.push(box);
			}
			if (speakers.exists(speaker -> speaker.id == entry.speaker)) {
				final speaker = new Speaker(entry.speaker);
				speaker.kill();
				speakers.push(speaker);
			}

			for (entry in entry.lines) {
				if (entry.box != null && boxes.exists(box -> box.id == entry.box)) {
					final box = new DialogueBox(entry.box);
					box.kill();
					boxes.push(box);
				}
				if (entry.speaker != null && speakers.exists(speaker -> speaker.id == entry.speaker)) {
					final speaker = new Speaker(entry.speaker);
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
		if (box.id == boxId) return box;
		var newBox = boxes.find(box -> box.id == boxId);
		if (newBox == null) {
			trace('warning:<orange>Couldn\'t find box with ID "<magenta>$boxId<orange>", using default box.');
			newBox = boxes.find(box -> box.id == 'default');
			if (newBox == null) {
				NovaUtils.addNotification('Default box not found', 'Couldn\'t find the default box, looks like you need to double-check some things.', ERROR);
				return box;
			}
		}

		boxes.remove(newBox);
		box.kill();
		box.typingCompleteCallback = null;
		remove(box);

		add(newBox);
		newBox.revive();
		newBox.z = 300;
		newBox.typingCompleteCallback = onTypingComplete;
		return box = newBox;
	}
	public function getSpeaker(speakerId:String):Speaker {
		if (speaker.id == speakerId) return speaker;
		var newSpeaker = speakers.find(speaker -> speaker.id == speakerId);
		if (newSpeaker == null) {
			trace('warning:<orange>Couldn\'t find speaker with ID "<magenta>$speakerId<orange>", using default speaker.');
			newSpeaker = speakers.find(speaker -> speaker.id == 'bf');
			if (newSpeaker == null) {
				NovaUtils.addNotification('Default speaker not found', 'Couldn\'t find the default speaker, looks like you need to double-check some things.', ERROR);
				return speaker;
			}
		}

		speakers.remove(newSpeaker);
		speaker.kill();
		remove(speaker);

		add(newSpeaker);
		newSpeaker.revive();
		newSpeaker.z = 200;
		return speaker = newSpeaker;
	}

	public function next():Void {
		currentLineIndex++;
		if (currentLineIndex >= currentEntry.lines.length) {
			currentLineIndex = 0;
			currentEntryIndex++;

			if (currentEntryIndex >= dialogueEntries.length) {
				// end
			} else {
				if (convoState == IDLE) {
					convoState = OPENING;
					var event = runEvent('nextDialogue', new OnDialogueEntryEvent(currentEntry));
					if (event.cancelled) return;

					loadMusicViaData(event.entry.music);
					changeBox(event.entry.box);
					box.playAnim(event.entry.boxAnim, true);
					lastBoxAnim = box.animation.name;

					runEvent('nextDialoguePost', event);
				}
			}
		} else {
			convoState = SPEAKING;
			box.text += currentLine.text;
		}
	}

	var lastBoxAnim:String = '';
	override public function update(elapsed:Float):Void {
		scripts.callVariants('update', [elapsed]);
		super.update(elapsed);
		switch (convoState) {
			case START:
			case OPENING:
				if (box != null && (box.animation.finished || box.animation.name == lastBoxAnim)) {
					convoState = SPEAKING;
				}
			case SPEAKING:
			case IDLE:
			case ENDING:
				if (outroTween == null)
					outro();
		}
		scripts.callVariants('postUpdate', [elapsed]);
		scripts.callVariants('updatePost', [elapsed]);
	}

	public function outro():Void {
		this._data.outro.build(
			data -> {
				// only called if the type is unrecognized
				if (!(data.type == 'none' || data.type == null))
					scripts.callVariants('buildOutro', [data.type, data, end]);
				else end();
			},
			data -> {
				outroTween = FlxTween.tween(this, {alpha: 0.0}, data.fadeTime, {
					ease: FlxEase.circOut
					onComplete: _ -> end(),
				});
				music.fadeOut(data.fadeTime ?? 1);
			}
		);
	}

	public function end():Void {
		music.stop();
		scripts.callVariants('end');
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