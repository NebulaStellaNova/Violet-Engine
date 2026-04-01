package violet.ui.freeplay;

import violet.backend.objects.special_thanks.GenzuSprite;

class DifficultyDot extends GenzuSprite {

    public var difficulty:String;

    public function new(difficulty:String) {
        super(0, 0, Paths.image('menus/freeplay/difficulties/dot'));
        this.scale.set(1.2, 1.2);
        this.updateHitbox();
        this.difficulty = difficulty;
    }

    public function setSelected(selected:Bool) {
        if (difficulty == "erect" || difficulty == "nightmare") {
            this.color = selected ? 0xFFC28AFF : 0xFF34296A;
        } else {
            this.color = selected ? 0xFFFAFAFA : 0xFF484848;
        }
    }
}