import flixel.FlxCamera;
import hxvlc.flixel.FlxVideoSprite;
import violet.data.dialogue.Conversation;
import violet.data.dialogue.ConversationRegistry;
import violet.states.PlayState;

using StringTools;

public var cutsceneCamera:FlxCamera;

public var cutscenePrefix:String = 'start';
public var cutsceneSuffix:String = null;

public var conversationPrefix:String = null;
public var conversationSuffix:String = null;

var video:FlxVideoSprite;
var conversation:Conversation;

function postCreate() {
	cutsceneCamera = new FlxCamera();
	FlxG.cameras.add(cutsceneCamera, false);
}

function checkString(?str:String):Bool {
	return str == null || str.trim() == '';
}
function renderFixes(str:String, ?prefix:String, ?suffix:String):String {
	var result = str;
	if (!checkString(prefix)) result = '$prefix-$result';
	if (!checkString(suffix)) result += '-$suffix';
	return result;
}

// TODO: Move this to source!
function onStartCountdown(event) {
	if (!PlayState.hasSeenCutscene /* && PlayState.isStoryMode */) {
		var cutsceneFix = renderFixes('cutscene', cutscenePrefix, cutsceneSuffix);
		if (Paths.fileExists('songs/${PlayState.songData.songName}/$cutsceneFix.mp4')) {
			event.cancel();
			inCutscene = true;

			video = new FlxVideoSprite(0, 0);
			video.antialiasing = true;
			video.bitmap.onEndReached.add(finishCutscene);
			video.bitmap.onFormatSetup.add(function():Void {
				if (video.bitmap != null && video.bitmap.bitmapData != null) {
					final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);
					video.camera = cutsceneCamera;
					video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
					video.updateHitbox();
					video.screenCenter();
				}
			});

			video.load(Paths.file('songs/${PlayState.songData.songName}/$cutsceneFix.mp4'));

			FlxTimer.wait(0.0001, ()->{
				video.play();
			});
			add(video);
		} else {
			var conversationFix = renderFixes(renderFixes(PlayState.song, null, PlayState.variation), conversationPrefix, conversationSuffix);
			if (ConversationRegistry.entryExists(conversationFix)) {
				event.cancel();
				conversation = new Conversation(PlayState.song, conversationPrefix, conversationSuffix);
				add(conversation);
			}
		}
	}
}

function onPause(event) {
	if (inCutscene) {
		if (video != null)
			video.pause();
		if (conversation != null)
			conversation.pause();
	}
}
function onResume() {
	if (inCutscene) {
		if (video != null)
			video.resume();
		if (conversation != null)
			conversation.resume();
	}
}

function onSkipCutscene() {
	subState.close();
	finishCutscene();
}

function finishCutscene() {
	inCutscene = false;
	PlayState.hasSeenCutscene = true;
	if (video != null) {
		video.destroy();
		video = null;
	}
	if (conversation != null) {
		conversation.destroy();
		conversation = null;
	}
	startCountdown();
}

function update(elapsed:Float) {
	if (!inCutscene || video == null) cutsceneCamera.alpha = 0;
}