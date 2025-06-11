package states;

import backend.objects.NovaText;
import backend.audio.Conductor;
import utils.MathUtil;
import backend.objects.NovaSprite;
import flixel.math.FlxMath;
import scripting.events.SelectionEvent;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import backend.JsonColor;
import backend.filesystem.Paths;
import backend.MusicBeatState;

typedef SongData = {
    var displayName:String;
    var bpm:Float;
    var icon:String;
    var color:JsonColor;
    var variations:Array<String>;
}

typedef SongInstance = {
    var id:String;
    var data:SongData;
}

typedef DifficultyColor = {
    var difficulty:String;
    var color:JsonColor;
}

class FreeplayState extends MusicBeatState {

    public var difficultyText:NovaText;
    
    public var bg:NovaSprite;
    
    public var curSelected:Int = 0;

    public var difficulties:Array<String> = ["easy", "normal", "hard", "erect", "nightmare", "pico"];
    public var curDifficulty:String = "normal";
    public var difficultyColors:Array<DifficultyColor> = [];

    var songList:Array<String> = Paths.getSongList();
    var songDatas:Array<SongInstance> = [];

    var texts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
    
    override public function create()
	{
		super.create();

        for (i=>song in songList) {
            var songData = parseSongData(song);
            songDatas.push(songData);

            //Conductor.loadSong(song);

            var text = new FlxText(0, 50*i, FlxG.width, songData.data.displayName, 40);
            text.alignment = 'center';
            text.ID = i;
            text.setFormat(Paths.font("Tardling v1.1.ttf"), 40);
            texts.add(text);

        }

        bg = new NovaSprite(0, 0, Paths.image("menuBGdesat", "menus/mainmenu"));
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set();
        bg.color = songDatas[curSelected].data.color;
        add(bg);

        add(texts);


        difficultyText = new NovaText(10, -10, FlxG.width, "");
        difficultyText.setFormat(Paths.font("Tardling v1.1.ttf"), 120);
        difficultyText.scrollFactor.set();
        add(difficultyText);

        difficultyColors = Paths.parseJson("data/difficulties");
        
        //trace(songDatas);

        FlxG.camera.followLerp = 0.2;
        changeSelection(0, true);
    }

    function uiCheck() {
        if (FlxG.keys.justPressed.UP)
            return -1;
        else if (FlxG.keys.justPressed.DOWN)
            return 1;
        else
            return 0;
    }
    
    function uiCheckSecond(one:Bool, minus:Bool) {
        if (one)
            return -1;
        else if (minus)
            return 1;
        else
            return 0;
    }

    public function changeDifficulty(amt:Int) {
        var diff = difficulties.indexOf(curDifficulty);
        var event:SelectionEvent = runEvent("onChangeDifficulty", new SelectionEvent(FlxMath.wrap(diff + amt, 0, difficulties.length-1)));
        if (event.cancelled) return;
        curDifficulty = difficulties[event.selection];
        if (amt != 0) {
            changeSelection(0, true);
        }
    }

    public function changeSelection(amt:Int, forceSong:Bool = false) {
        var event:SelectionEvent = runEvent("onChangeSelection", new SelectionEvent(FlxMath.wrap(curSelected + amt, 0, texts.length-1)));
        if (event.cancelled) return;
        if (amt != 0 && !event.soundCancelled) {
            FlxG.sound.play(Paths.sound("scroll", "menu"));
        }
        curSelected = event.selection;
        if (amt != 0 || forceSong) {
            if (Paths.instExists(songDatas[curSelected].id, curDifficulty)) {
                Conductor.loadSong(songDatas[curSelected].id, curDifficulty);
            } else {
                Conductor.loadSong(songDatas[curSelected].id);
            }
            Conductor.play();
        }
    }

    function parseSongData(id:String, variation:String = "") {
        var data:SongInstance = { id: id + (variation != "" ? '-$variation' : variation), data: Paths.parseJson('songs/$id/meta' + (variation != "" ? '-$variation' : variation)) };
        return data;
    }

    function getDiffColor() {
        for (i in difficultyColors) {
            if (i.difficulty == curDifficulty) {
                var col:DifficultyColor = i;
                return col;
            }
        }
        var color:DifficultyColor = { difficulty: curDifficulty, color: "#FFFFFF"};
        return color;
    }

    override public function update(elapsed:Float)
	{
		super.update(elapsed);
        bg.color = MathUtil.colorLerp(bg.color, songDatas[curSelected].data.color, 0.16);
        difficultyText.color = MathUtil.colorLerp(difficultyText.color, JsonColor.fromString(getDiffColor().color), 0.1);
        changeSelection(uiCheck());
        changeDifficulty(uiCheckSecond(FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.RIGHT));
        for (i in texts) {
            i.alpha = i.ID == curSelected ? 1 : 0.5;
            if (i.ID == curSelected) {
                FlxG.camera.target = i;
            }
        }
        difficultyText.text = curDifficulty.toUpperCase(); 

        if (FlxG.keys.justPressed.ENTER) {
            var playState = new PlayState();
            PlayState.songID = songDatas[curSelected].id;
            PlayState.difficulty = curDifficulty;
            //+playState.loadChart();
            //playState.varient = curDifficulty;
            switchState(playState);
        }

        if (FlxG.keys.justPressed.BACKSPACE) {
            switchState(MainMenuState.new);
        }
        //bg.color = MathUtil.colorLerp(bg.color, menuData.items[curSelected].color, 0.16);
        //bgColorString = JsonColor.fromInt(bg.color);

        //if (FlxG.keys.justPressed.ENTER) {
        //    pickSelection();
        //}

        call("postUpdate", [elapsed]);
        call("onUpdatePost", [elapsed]);

	}
}