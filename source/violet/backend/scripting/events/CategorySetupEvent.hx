package violet.backend.scripting.events;

import violet.states.menus.FreeplayMenu;

class CategorySetupEvent extends EventBase {

	public var list:Map<String, CategoryData>;

	override public function new(categoryData:Map<String, CategoryData>) {
		super();
		list = categoryData;
	}

	inline public function addData(id:String, data:CategoryData):Void
		list.set(id, data);

}