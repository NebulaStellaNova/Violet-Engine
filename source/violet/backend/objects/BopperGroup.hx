package violet.backend.objects;

import flixel.FlxBasic;
import flixel.group.FlxGroup;

typedef BopperGroup = TypedBopperGroup<FlxBasic>;

class TypedBopperGroup<T:FlxBasic> extends FlxTypedGroup<T> implements IsBopper {

	public function stepHit(curStep:Int) {
		forEachAlive(sprite -> {
			if (sprite is IsBopper)
				cast(sprite, IsBopper).stepHit(curStep);
		});
	}

	public function beatHit(curBeat:Int) {
		forEachAlive(sprite -> {
			if (sprite is IsBopper)
				cast(sprite, IsBopper).beatHit(curBeat);
		});
	}

	public function measureHit(curMeasure:Int) {
		forEachAlive(sprite -> {
			if (sprite is IsBopper)
				cast(sprite, IsBopper).measureHit(curMeasure);
		});
	}

}