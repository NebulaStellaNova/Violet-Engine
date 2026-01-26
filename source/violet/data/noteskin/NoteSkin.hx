package violet.data.noteskin;

class NoteSkin {

    public var id:String;
    public var _data:NoteSkinData;

    public function new(id:String) {
        this.id = id;
        this._data = NoteSkinRegistry.noteSkinDatas.get(id);
    }
}
