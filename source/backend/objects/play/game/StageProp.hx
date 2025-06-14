package backend.objects.play.game;

class StageProp extends NovaSprite {
    
    public var id:String;

    public function new(id:String, x:Int, y:Int, ?path:String) {
        super(x, y, path);
        this.id = id;

    }
}