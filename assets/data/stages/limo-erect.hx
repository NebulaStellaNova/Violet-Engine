import violet.backend.shaders.AdjustColorShader;
import flixel.addons.display.FlxBackdrop;

var colorShader:AdjustColorShader = new AdjustColorShader();

var mist1:FlxBackdrop;
var mist2:FlxBackdrop;
var mist3:FlxBackdrop;
var mist4:FlxBackdrop;
var mist5:FlxBackdrop;

function postCreate() {
    colorShader.hue = -30;
    colorShader.saturation = -20;
    colorShader.contrast = 0;
    colorShader.brightness = -30;

    limoDancer1.shader = colorShader;
    limoDancer2.shader = colorShader;
    limoDancer3.shader = colorShader;
    limoDancer4.shader = colorShader;
    limoDancer5.shader = colorShader;

	for (i in characters) {
		i.shader = colorShader;
	}

    mist1 = new FlxBackdrop(Paths.image('stages/week4/erect/mistMid'), X);
    mist1.setPosition(-650, -100);
    mist1.scrollFactor.set(1.1, 1.1);
    mist1.zIndex = 400;
    mist1.blend = 0;
    mist1.color = 0xFFc6bfde;
    mist1.alpha = 0.4;
    mist1.velocity.x = 1700;
    add(mist1);

    mist2 = new FlxBackdrop(Paths.image('stages/week4/erect/mistBack'), X);
    mist2.setPosition(-650, -100);
    mist2.scrollFactor.set(1.2, 1.2);
    mist2.zIndex = 401;
    mist2.blend = 0;
    mist2.color = 0xFF6a4da1;
    mist2.alpha = 1;
    mist2.velocity.x = 2100;
    mist1.scale.set(1.3, 1.3);
    add(mist2);

    mist3 = new FlxBackdrop(Paths.image('stages/week4/erect/mistMid'), X);
    mist3.setPosition(-650, -100);
    mist3.scrollFactor.set(0.8, 0.8);
    mist3.zIndex = 99;
    mist3.blend = 0;
    mist3.color = 0xFFa7d9be;
    mist3.alpha = 0.5;
    mist3.velocity.x = 900;
    mist3.scale.set(1.5, 1.5);
    add(mist3);

    mist4 = new FlxBackdrop(Paths.image('stages/week4/erect/mistBack'), X);
    mist4.setPosition(-650, -380);
    mist4.scrollFactor.set(0.6, 0.6);
    mist4.zIndex = 98;
    mist4.blend = 0;
    mist4.color = 0xFF9c77c7;
    mist4.alpha = 1;
    mist4.velocity.x = 700;
    mist4.scale.set(1.5, 1.5);
    add(mist4);

    mist5 = new FlxBackdrop(Paths.image('stages/week4/erect/mistMid'), X);
    mist5.setPosition(-650, -400);
    mist5.scrollFactor.set(0.2, 0.2);
    mist5.zIndex = 15;
    mist5.blend = 0;
    mist5.color = 0xFFE7A480;
    mist5.alpha = 1;
    mist5.velocity.x = 100;
    mist5.scale.set(1.5, 1.5);
    add(mist5);
}

var _timer:Float = 0;
function update(elapsed:Float) {
    _timer += elapsed;
    mist1.y = 100 + (Math.sin(_timer) * 200);
    mist2.y = 0 + (Math.sin(_timer * 0.8) * 100);
    mist3.y = -20 + (Math.sin(_timer * 0.5) * 200);
    mist4.y = -180 + (Math.sin(_timer * 0.4) * 300);
    mist5.y = -450 + (Math.sin(_timer * 0.2) * 150);
}