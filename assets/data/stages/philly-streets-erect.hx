import violet.backend.objects.play.ABot;

var aBot:ABot;

function onLoaded() {
	aBot = new ABot();
	positionABot();
	insert(members.length, aBot);
}

function postCreate() {
	positionABot();
	initABot();
}

function startSong() {
	positionABot();
	initABot();
}

function update(elapsed) {
	var nene = getNene();
	if (aBot != null && nene != null) {
		aBot.visible = nene.visible;
		aBot.alpha = nene.alpha;
	}
}

function initABot() {
	if (aBot != null)
		aBot.initAnalyzer();
}

function positionABot() {
	if (aBot == null) return;

	var nene = getNene();
	if (nene == null) {
		aBot.setPosition(0, 0);
		aBot.z = 290;
		return;
	}

	aBot.x = nene.x - 95 + (nene.globalOffset.x * nene.scale.x);
	aBot.y = nene.y + 384 + (nene.globalOffset.y * nene.scale.y);
	aBot.z = nene.z - 10;
	aBot.scrollFactor.set(nene.scrollFactor.x, nene.scrollFactor.y);
	aBot.alpha = nene.alpha;
	aBot.visible = nene.visible;
}

function getNene() {
	for (character in characters)
		if (character.stagePosition == "girlfriend" && character.id.indexOf("nene") == 0)
			return character;
	return null;
}
