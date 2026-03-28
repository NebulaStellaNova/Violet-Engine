package violet.data.freeplay;

import violet.backend.utils.ParseUtil;
import violet.data.freeplay.PlayerData;

class Player {
    public var id:String;
    public var _data:PlayerData;

    public function new(id:String) {
        this.id = id;
        _data = ParseUtil.jsonOrYaml('data/players/$id');
    }

}