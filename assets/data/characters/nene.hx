import violet.backend.objects.play.ABot;

var aBot:ABot;

function postCreate() {
	this.x -= 100;
	this.y -= 75;
	aBot = new ABot();
	aBot.x = this.x - 130;
	aBot.y = this.y + 220;
	aBot.z = this.z - 10;
	FlxG.state.add(aBot);

	aBot.eyes.anim.onFrameChange.add(function(name:String, frameNumber:Int, frameIndex:Int) {
		if (frameNumber == 16) {
			aBot.eyes.anim.pause();
		}
	});
}

function update(elapsed) {
	aBot.visible = this.visible;
	aBot.alpha = this.alpha;
}

function movePupilsLeft():Void {
	aBot.eyes.anim.play('idle', true, false, 0);
}

function movePupilsRight():Void {
	aBot.eyes.anim.play('idle', true, false, 17);
}

function onEventPost() {
	if (FlxG.state.strumlineTarget == 0)
		movePupilsLeft();
	else
		movePupilsRight();
}