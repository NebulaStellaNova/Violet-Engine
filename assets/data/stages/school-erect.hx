import violet.backend.shaders.DropShadowShader;

function postCreate() {
	for (character in characters) {
		var rim = new DropShadowShader();
		rim.setAdjustColor(-66, -10, 24, -23);
		rim.color = 0xFF52351d;
		rim.antialiasAmt = 0;
		rim.attachedSprite = character;
		rim.distance = 5;

		switch (character.stagePosition) {
			case 'boyfriend':
				rim.angle = 90;
				character.shader = rim;

				if (character.id == 'pico-pixel') {
					rim.loadAltMask(Paths.image('stages/week6/weeb/erect/masks/picoPixel_mask'));
				} else {
					rim.loadAltMask(Paths.image('stages/week6/weeb/erect/masks/bfPixel_mask'));
				}

				rim.maskThreshold = 1;
				rim.useAltMask = true;

				character.animation.onFrameChange.add(function() {
					if (getBoyfriend() != null) {
						rim.updateFrameInfo(getBoyfriend().frame);
					}
				});
			case 'girlfriend':
				rim.setAdjustColor(-42, -10, 5, -25);
				rim.angle = 90;
				character.shader = rim;
				rim.distance = 3;
				rim.threshold = 0.3;

				if (character.id == 'nene-pixel') {
					rim.loadAltMask(Paths.image('stages/week6/weeb/erect/masks/nenePixel_mask'));
					// character.addSunsetShaders();
				} else {
					rim.loadAltMask(Paths.image('stages/week6/weeb/erect/masks/gfPixel_mask'));
				}

				rim.maskThreshold = 1;
				rim.useAltMask = true;

				character.animation.onFrameChange.add(function() {
					if (getGirlfriend() != null) {
						rim.updateFrameInfo(getGirlfriend().frame);
					}
				});
			case 'dad':
				rim.angle = 90;
				character.shader = rim;

				rim.loadAltMask(Paths.image('stages/week6/weeb/erect/masks/senpai_mask'));
				rim.maskThreshold = 1;
				rim.useAltMask = true;

				character.animation.onFrameChange.add(function() {
					if (getDad() != null) {
						rim.updateFrameInfo(getDad().frame);
					}
				});
		}
	}
}

function getBoyfriend() {
	for (character in characters)
		if (character.stagePosition == 'boyfriend')
			return character;
}

function getGirlfriend() {
	for (character in characters)
		if (character.stagePosition == 'girlfriend')
			return character;
}

function getDad() {
	for (character in characters)
		if (character.stagePosition == 'dad')
			return character;
}
