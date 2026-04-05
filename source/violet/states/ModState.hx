package violet.states;

import violet.backend.StateBackend;

class ModState extends StateBackend {

    public var id:String;

    override public function new(id:String) {
        this.id = id;
        super();
    }

    override function getScriptName():String {
        return id;
    }
}