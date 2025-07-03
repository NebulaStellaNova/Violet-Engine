package backend.converters;

import haxe.io.Path;
import backend.objects.play.game.Stage.StageData;
import backend.objects.play.game.Stage.PropData;
import Xml;

class StageConverters {
    
    public static function parseBool(string:String) {
        return string == "true";
    }

    public static function fromCNE(obj:Xml) {
        var template:StageData = {
            name: "???",
            directory: "",
            cameraZoom: 1,
            props: [],
            characters: {
                bf: {
                    zIndex: 1,
                    position: [0, 0],
                    cameraOffsets: [0, 0]
                },
                gf: {
                    zIndex: 2,
                    position: [0, 0],
                    cameraOffsets: [0, 0]
                },
                dad: {
                    zIndex: 3,
                    position: [0, 0],
                    cameraOffsets: [0, 0]
                }
            }
        }
        
        var stageData = obj.firstElement();
        template.directory = Path.removeTrailingSlashes(stageData.get('folder') ?? "");

        var i:Int = 0; // fuckass xml
        for (node in stageData.iterator()) {
            if (node.nodeType == Xml.Element) {
                switch (node.nodeName) {
                    case 'bf':
                        template.characters.bf.zIndex = i;
                        template.characters.bf.position[0] = Std.parseFloat(node.get('x'));
                        template.characters.bf.position[1] = Std.parseFloat(node.get('y')) + (flixel.FlxG.height);
                        template.characters.bf.cameraOffsets[0] = Std.parseFloat(node.get('camxoffset') ?? "0");
                        template.characters.bf.cameraOffsets[1] = Std.parseFloat(node.get('camyoffset') ?? "0");
                    case 'dad':
                        template.characters.dad.zIndex = i;
                        template.characters.dad.position[0] = Std.parseFloat(node.get('x'));
                        template.characters.dad.position[1] = Std.parseFloat(node.get('y'));
                        template.characters.dad.cameraOffsets[0] = Std.parseFloat(node.get('camxoffset') ?? "0");
                        template.characters.dad.cameraOffsets[1] = Std.parseFloat(node.get('camyoffset') ?? "0") + (flixel.FlxG.height);
                    case 'gf':
                        template.characters.gf.zIndex = i;
                        template.characters.gf.position[0] = Std.parseFloat(node.get('x'));
                        template.characters.gf.position[1] = Std.parseFloat(node.get('y'));
                        template.characters.gf.cameraOffsets[0] = Std.parseFloat(node.get('camxoffset') ?? "0");
                        template.characters.gf.cameraOffsets[1] = Std.parseFloat(node.get('camyoffset') ?? "0") + (flixel.FlxG.height);
                    case 'sprite':
                        var prop:PropData = {
                            zIndex: i,
                            name: node.get('name'),
                            assetPath: node.get('sprite'),
                            position: [
                                Std.parseFloat(node.get('x') ?? "0"),
                                Std.parseFloat(node.get('y') ?? "0")
                            ],
                            scroll: [
                                Std.parseFloat(node.get('scrollx') ?? "1"),
                                Std.parseFloat(node.get('scrolly') ?? "1")
                            ],
                            scale: [
                                Std.parseFloat(node.get('scale') ?? "1"),
                                Std.parseFloat(node.get('scale') ?? "1")
                            ],
                            flipX: false,
                            flipY: false,
                            animType: "sparrow",
                            animations: [],
                            startingAnimation: null,
                            danceEvery: 0
                        }
                        template.props.push(prop);
                    default:
                        //
                }
            }
            i++;
        }
        return template;
    }

}