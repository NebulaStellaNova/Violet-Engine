import violet.backend.shaders.AdjustColorShader;

var colorShader:AdjustColorShader = new AdjustColorShader();

function postCreate() {
    colorShader.hue = -26;
    colorShader.saturation = -16;
    colorShader.contrast = 0;
    colorShader.brightness = -5;

	for (i in characters) {
		i.shader = colorShader;
	}
}