package violet.states;

import violet.backend.filesystem.Paths;
import violet.backend.objects.NovaSprite;

class TitleState extends flixel.FlxState { // for now

	public var bootAnimation:NovaSprite;

	override public function create() {
		super.create();

		bootAnimation = new NovaSprite(Paths.image("menus/titlescreen/bootAnimation"));
		bootAnimation.addAnim("boot", "animation", [0, 0], 40, false);
		bootAnimation.playAnim("boot");
		bootAnimation.scale.set(0.7, 0.7);
		add(bootAnimation);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		bootAnimation.updateHitbox();
		bootAnimation.screenCenter();
	}
}