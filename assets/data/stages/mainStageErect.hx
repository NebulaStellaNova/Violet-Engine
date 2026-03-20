import violet.backend.shaders.AdjustColorShader;

public var colorShaderBf:AdjustColorShader = new AdjustColorShader();
public var colorShaderDad:AdjustColorShader = new AdjustColorShader();
public var colorShaderGf:AdjustColorShader = new AdjustColorShader();

function create() {
    colorShaderBf.brightness = -23;
    colorShaderBf.hue = 12;
    colorShaderBf.contrast = 7;
    colorShaderBf.saturation = 0;

    colorShaderGf.brightness = -30;
    colorShaderGf.hue = -9;
    colorShaderGf.contrast = -4;
    colorShaderGf.saturation = 0;

    colorShaderDad.brightness = -33;
    colorShaderDad.hue = -32;
    colorShaderDad.contrast = -23;
    colorShaderDad.saturation = 0;
}

function postCreate() {
    brightLightSmall.blend = 0;
    orangeLight.blend = 0;
    lightgreen.blend = 0;
    red.blend = 0;
    lightAbove.blend = 0;

    for (i in characters) {
        switch (i.stagePosition) {
            case "boyfriend": i.shader = colorShaderBf;
            case "girlfriend": i.shader = colorShaderGf;
            case "dad": i.shader = colorShaderDad;
        }
    }
}