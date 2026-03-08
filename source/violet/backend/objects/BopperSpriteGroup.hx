package violet.backend.objects;

import flixel.group.FlxSpriteGroup;

typedef BopperSpriteGroup = TypedBopperSpriteGroup<FlxSprite>;

class TypedBopperSpriteGroup<T:FlxSprite> extends FlxTypedSpriteGroup<T> implements IsBopper {

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