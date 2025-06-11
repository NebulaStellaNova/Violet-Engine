package scripting.events;

class SongEvent extends EventBase {

    public var name:String = "default";
    public var parameters:Array<Dynamic>;

    public function new(name:String, ?parameters:Array<Dynamic>) {
        this.name = name;
        this.parameters = parameters ?? [];
    }

}