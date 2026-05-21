function startCountdown() {
	FlxG.state.comboGroup.x = getGirlfriend().x + 350;
	FlxG.state.comboGroup.y = getGirlfriend().y + 500;
	FlxG.state.comboGroup.zIndex = getGirlfriend().zIndex;
	FlxG.state.reorder();
}

function getGirlfriend() {
	for (character in characters)
		if (character.stagePosition == 'girlfriend')
			return character;
}