package violet.backend;

class StateBackend extends flixel.FlxState {
    public var usesLoadingScreen = false;
    public var stuffToLoad:Array<Dynamic> = [];

    override public function add(objORcall:Dynamic) {
        if (usesLoadingScreen) {
            stuffToLoad.push(objORcall);
        } else {
            super.add(objORcall);
        }
        return objORcall;
    }

}