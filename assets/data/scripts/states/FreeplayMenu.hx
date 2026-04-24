import violet.backend.objects.freeplay.Capsule;

function update(?elapsed:Float) {
	if (FlxG.keys.justPressed.E) trace(Capsule.angleCropShader.angle -= 0.01);
	if (FlxG.keys.justPressed.Q) trace(Capsule.angleCropShader.angle += 0.01);
}