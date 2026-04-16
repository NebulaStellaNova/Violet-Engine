package violet.backend.objects.play;

import violet.data.animation.AnimationData;
import violet.backend.utils.ParseUtil;

enum abstract Side(String) {
	var L = "left";
	var R = "right";
	// var C = "center";
}

typedef BoxData = {
	var assetPath:String;
	var ?offsets:Array<Float>;
	var ?textPosition:Array<Float>;
	var animations:Array<AnimationData>;
}

typedef ConverstationPiece = {
	var text:String;
	var sound:String;
	var portait:String;
	var side:Side;

	@:default("basic")
	var ?box:String;
	@:default(1.0)
	var ?speed:Float;
}

class DialogueHandler extends FlxSpriteGroup {

	public var boxes:Map<String, NovaSprite> = [];
	public var conversation:Array<ConverstationPiece> = [];

	public var currentDialogue:Int = -1;

	public dynamic function onDialogueEnd() {}

	override public function new(conversation:Array<ConverstationPiece>) {
		super();
		this.conversation = conversation;
		if (conversation == null) return;
		for (i in conversation) {
			i.box ??= "basic";
			i.speed ??= 1;

			if (!boxes.exists(i.box)) {
				var boxData:BoxData = ParseUtil.jsonOrYaml('data/ui/dialogue/boxes/${i.box}');
				boxData.offsets ??= [0, 0];

				if (boxData != null) {
					var box = new NovaSprite(0, 0, Paths.image(boxData.assetPath));
					box.addAnimsFromDataArray(boxData.animations);
					box.animation.onFinish.add(name->{
						if (name == "open") box.playAnim('idle', true);
					});
					box.updateHitbox();
					box.extra.set('data', boxData);
					box.x -= box.width/2;
					box.y -= box.height/2;
					box.visible = false;
					// box.playAnim('open', true);
					add(box);
					boxes.set(i.box, box);
				} else {
					trace('error:Could not find data for dialogue box with id "<cyan>${i.box}<reset>" (skipping...)');
				}
			}
		}
		advanceDialogue();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.accept) {
			advanceDialogue();
		}
	}


	var previousBox:NovaSprite = null;

	public function advanceDialogue() {
		currentDialogue++;

		if (previousBox != null) previousBox.visible = false;

		var currentPiece:ConverstationPiece = conversation[currentDialogue];
		if (currentPiece == null) {
			onDialogueEnd();
			return;
		}

		previousBox = boxes.get(currentPiece.box);
		previousBox.playAnim('open', true);
		previousBox.visible = true;
		previousBox.flipX = currentPiece.side == L;
		var boxData:BoxData = previousBox.extra.get('data');
		previousBox.globalOffset.set(boxData.offsets[0] * (previousBox.flipX ? -1 : 1), boxData.offsets[1]);


		trace(currentPiece.text);
	}

}