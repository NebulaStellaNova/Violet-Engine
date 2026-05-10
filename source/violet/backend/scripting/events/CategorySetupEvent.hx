package violet.backend.scripting.events;

import violet.states.menus.FreeplayMenu;

class CategorySetupEvent extends EventBase {

	public var list:Array<CategoryData>;

	override public function new(categoryData:Array<CategoryData>) {
		super();
		list = categoryData;
	}

}