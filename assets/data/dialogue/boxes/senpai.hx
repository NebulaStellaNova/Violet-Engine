function uponAnimationFinished(name:String):Void {
	switch (name) {
		case 'sentenceEnd': playAnim('idle', true);
		case 'click': playAnim('speaking', true);
	}
}

function uponTypingComplete():Void {
	playAnim('sentenceEnd', true);
}

function nextDialoguePost(event):Void {
	convo.convoState = 'opening';

	// FlxG.sound.play(Cache.sound('textboxClick'), 0.6);

	switch (animation.name) {
		case 'idle': playAnim('click', true);
		case 'click': playAnim('speaking', true);
	}
}

function onEndOfConvo():Void {
	textDisplay.visible = false;
	playAnim('exit', false);
}