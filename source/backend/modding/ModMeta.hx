package backend.modding;

import backend.JsonColor;

typedef Contributor = {
    var name:String;
    var color:JsonColor;
    var roles:String;
    var icon:String;
    var url:String;
} 

typedef ModMeta = {
    var title:String;
    var description:String;
    var tag:String;
    var contributors:Array<Contributor>;
    var mod_enabled:Bool;
    var mod_version:String;
}