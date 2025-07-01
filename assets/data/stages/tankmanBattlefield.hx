var tankMoving:Bool = false;
var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankX:Float = 400;

function create() {
    var clouds = stage.getNamedProp('clouds');
    clouds.active = true;
    clouds.x = FlxG.random.int(-700, -100);
    clouds.y = FlxG.random.int(-20, 20);
    clouds.velocity.x = FlxG.random.float(5, 15);

    tankAngle = FlxG.random.int(-90, 45);
    tankSpeed = FlxG.random.float(5, 7);
}

function update(elapsed) {
    var daAngleOffset:Float = 1;
    tankAngle += elapsed * tankSpeed;

    var tankRolling = stage.getNamedProp('tankRolling');
    tankRolling.angle = tankAngle - 90 + 15;
    tankRolling.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
    tankRolling.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
}