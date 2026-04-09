package violet.states.editors;

import violet.data.character.Character;
import lemonui.utils.ElementUtil;
import lemonui.elements.MenuBar;
import violet.data.icon.HealthIcon;
import violet.data.character.CharacterRegistry;
import flixel.math.FlxPoint;
import violet.backend.scripting.events.NoteHitEvent;
import violet.backend.scripting.events.EventBase;
import violet.backend.utils.NovaUtils;
import violet.data.song.Song;
import violet.data.song.SongRegistry;
import violet.data.chart.ChartRegistry;
import violet.data.chart.Chart;
import flixel.addons.display.FlxBackdrop;
import violet.backend.audio.Conductor;
import violet.backend.StateBackend;

using violet.backend.utils.ArrayUtil;

class ChartEditorState extends StateBackend {

    public static var songID:String = 'test';
    public static var difficulty:String = 'normal';
    public static var variant:Null<String> = null;

    public var noteToPlace:NovaSprite;

    public var noteTypeHandlers:Map<String, NoteHitEvent->Void> = [
        "No Animation" => (e) -> {
            e.animCancelled = true;
        }
    ];

    var chart:Chart;
    var meta:Song;

    var grids:Array<FlxBackdrop> = [];
    var notes:Array<NovaSprite> = [];
    var events:Array<NovaSprite> = [];
    var icons:Array<HealthIcon> = [];

    var selectionBox:FlxSprite;
    var selectionStart:FlxPoint = new FlxPoint(200, 200);

    var charterChud:Character = new Character('charter-chud');

    var menuBar:MenuBar;

    override public function new() {
        super();

        // FlxG.camera.zoom = 0.7; // Looks funny

        chart = ChartRegistry.getChart(songID, difficulty, variant);
		meta = SongRegistry.getSongByID(songID);

        Conductor.stop();
        Conductor.playSong(meta.songName, meta.variant);
		if (meta.needsVoices) Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(meta.songName, null, meta.variant), 'root', null, true), FlxG.sound.defaultMusicGroup));
		else Conductor.addAdditionalTrack(new FlxSound());
        Conductor.pause();

        var barRoot = ElementUtil.buildFromXML(Paths.xml("data/ui/chart-editor/menubar")).root;
        menuBar = barRoot.findElement('menubar');

        var bg = new NovaSprite(Paths.image("menus/mainmenu/menuBGdesat"));
		bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.alpha = 0.2;
        add(bg);

        var gridBase = new FlxSprite().makeGraphic(200, 100, FlxColor.WHITE);

        var blackBox = new FlxSprite().makeGraphic(50, 50, FlxColor.BLACK);

        gridBase.stamp(blackBox, 0, 50);
        gridBase.stamp(blackBox, 50, 0);
        gridBase.stamp(blackBox, 100, 50);
        gridBase.stamp(blackBox, 150, 0);

        var size = (chart.strumLines.length - 1) * 200;
        for (i=>line in chart.strumLines) {
            var chartGrid = new FlxBackdrop(gridBase.pixels, Y);
            chartGrid.alpha = 0.2;
            chartGrid.screenCenter(X);
            chartGrid.x += i * 200;
            chartGrid.x -= size/2;
            chartGrid.alpha *= line._data.visible ? 1 : 0.75;
            add(chartGrid);
            grids.push(chartGrid);

            var characterID = line.characters[0];
            var characterData = CharacterRegistry.characterDatas.get(characterID);
            var icon = new HealthIcon(characterData?.healthIcon ?? characterID);
            icon.x = chartGrid.x + chartGrid.width/2 - icon.width/2;
            icon.y = chartGrid.y + 200/2 - icon.height/2;
            icon.globalOffset.x = icon.globalOffset.y = 0;
            icon.y += 35;
            icons.push(icon);

            if (line.vocalsSuffix != null)
                Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(meta.songName, line.vocalsSuffix, meta.variant), 'root', null, true), FlxG.sound.defaultMusicGroup));

            for (id => note in line.notes) {
                var noteSprite = new NovaSprite(Paths.image('game/notes/default/notes'));
                noteSprite.addAnim('idle', 'note' + ['Left', 'Down', 'Up', 'Right'][note.id]);
                noteSprite.playAnim('idle');
                noteSprite.setGraphicSize(50, 50);
                noteSprite.updateHitbox();
                noteSprite.x = chartGrid.x + (50 * note.id);
                noteSprite.y = note.time;
                noteSprite.extra.set('noteData', note);
                noteSprite.extra.set('strumLine', i);
                notes.push(noteSprite);
                add(noteSprite);

                var overlay = noteSprite.clone();
                overlay.visible = false;
                overlay.blend = ADD;
                noteSprite.extra.set('overlay', overlay);
                add(overlay);
            }
        }

        for (i in 0...chart.strumLines.length+1) {
            var seperator = new FlxSprite().makeGraphic(2, FlxG.height, FlxColor.WHITE);
            seperator.screenCenter();
            seperator.alpha = 0.5;
            seperator.x += i * 200;
            seperator.x -= size / 2;
            seperator.x -= 100;
            add(seperator);
        }

        for (i in icons) add(i);

        for (i in chart.events) {
            var eventSprite = new NovaSprite(Paths.image('ui/editors/charter/event'));
            if (!i.global) {
                eventSprite.x = grids.last().x + grids.last().width;
            } else {
                eventSprite.flipX = true;
                eventSprite.x = grids.first().x - eventSprite.width;
            }
            eventSprite.extra.set('eventData', i);
            add(eventSprite);
            events.push(eventSprite);
        }

        var line = new FlxSprite().makeGraphic(size + 210, 2, FlxColor.RED);
        line.screenCenter();
        line.alpha = 0.5;
        add(line);

        selectionBox = new FlxSprite().makeGraphic(1, 1, FlxColor.GREEN);
        selectionBox.alpha = 0.5;
        // selectionBox.visible = false;
        add(selectionBox);
        Conductor.setSongPosition(0);

        add(barRoot);

        charterChud.x = 100;
        charterChud.y = FlxG.height - 200;
        add(charterChud);

        noteToPlace = new NovaSprite(Paths.image('game/notes/default/notes'));
        for (i in 0...5) {
            noteToPlace.addAnim('$i', 'note' + ['Left', 'Down', 'Up', 'Right'][i]);
        }
        noteToPlace.playAnim('0');
        noteToPlace.setGraphicSize(50, 50);
        noteToPlace.updateHitbox();
        add(noteToPlace);
    }

    var numTween:FlxTween;
    var selectionTween:FlxTween;

    var playedThisFrame:Bool = false;

    override function update(e) {
        super.update(e);
        playedThisFrame = false;

        var yOffset = grids[0].y % 50;
        yOffset /= 2;
        var delta = FlxG.mouse.gameX - grids[0].x;
        noteToPlace.x = grids[0].x + Math.round((delta-25)/50)*50;
        noteToPlace.y = grids[0].y % 50;
        var gridDelta = grids[0].y % 50;
        if (FlxG.keys.pressed.SHIFT) {
            noteToPlace.y += FlxG.mouse.gameY - 25;
        } else {
            noteToPlace.y += Math.round((FlxG.mouse.gameY-(gridDelta+25))/50)*50;
        }
        noteToPlace.playAnim('${Math.round((delta-25)/50) % 4}', true);
        var strumlineToPlaceOn = Math.floor(Math.round((delta-25)/50)/4);
        // noteToPlace.extra.set('strumLine', strumlineToPlaceOn);

        noteToPlace.visible = !(delta < 0 || delta > 200 * grids.length);

        var placeOffset = (FlxG.height/2) - noteToPlace.y;

        if (FlxG.mouse.justPressed && noteToPlace.visible) {
            var noteToAdd = new NovaSprite(Paths.image('game/notes/default/notes'));
            for (i in 0...5) {
                noteToAdd.addAnim('$i', 'note' + ['Left', 'Down', 'Up', 'Right'][i]);
            }
            noteToAdd.playAnim(noteToPlace.animation.name);
            noteToAdd.setGraphicSize(50, 50);
            noteToAdd.updateHitbox();
            var thing = (noteToPlace.y);
            thing -= FlxG.height/2;
            thing /= 0.5;
            thing /= 25 * 4;
            thing *=  Conductor.stepLengthMs;
            thing += Conductor.framePosition;
            noteToAdd.extra.set('noteData', {
                id: Std.parseInt(noteToPlace.animation.name),
                time:thing
            });
            noteToAdd.extra.set('strumLine', strumlineToPlaceOn);
            notes.push(noteToAdd);
            add(noteToAdd);

            var overlay = noteToAdd.clone();
            overlay.visible = false;
            overlay.blend = ADD;
            noteToAdd.extra.set('overlay', overlay);
            add(overlay);
        }

        for (grid in grids) {
            grid.y = (-Conductor.framePosition / Conductor.stepLengthMs) * 25 * 4;
            grid.y *= 0.5;
            grid.y += FlxG.height/2;
        }

        for (i in icons) {
            i.canDance = Conductor.instrumental.playing;
        }

        for (event in events) {
            var eventData = event.extra.get('eventData');
            var time = eventData.time - Conductor.framePosition;
            event.y = (time / Conductor.stepLengthMs) * 25 * 4;
            event.y *= 0.5;
            event.y += FlxG.height/2;
            event.alpha = eventData.time < Conductor.framePosition ? 0.5 : 1;
        }

        for (note in notes) {
            var noteData = note.extra.get('noteData');
            var time = noteData.time - Conductor.framePosition;
            note.y = (time / Conductor.stepLengthMs) * 25 * 4;
            note.y *= 0.5;
            note.y += FlxG.height/2;
            note.alpha = noteData.time < Conductor.framePosition ? 0.5 : 1;
            note.x = grids[note.extra.get('strumLine')].x + (50 * noteData.id);

            if (note.alpha == 1) note.extra.set('hit', false);
            else if (note.alpha == 0.5 && !note.extra.get('hit')) {
                note.extra.set('hit', true);
                if (Conductor.instrumental.playing && !playedThisFrame) {
                    NovaUtils.playSound('charter/hitsound', 0.75);
                    charterChud.playSingAnim(noteData.id);
                    playedThisFrame = true;
                }
            }

            var overlay = note.extra.get('overlay');
            overlay.x = note.x;
            overlay.y = note.y;
            overlay.alpha = note.alpha;
            overlay.visible = FlxG.mouse.overlaps(note);

            note.color = overlay.visible ? FlxColor.interpolate(FlxColor.BLACK, FlxColor.WHITE, 0.5) : FlxColor.WHITE;

        }

        charterChud.color = [
            "idle" =>      0xFFFFFFFF,
            "singLEFT" =>  0xFFc24b99,
            "singDOWN" =>  0xFF00FFFF,
            "singUP" =>    0xFF12fa05,
            "singRIGHT" => 0xFFf9393f
        ].get(charterChud.animation.name);

        if (FlxG.mouse.wheel != 0) {
            var scrollAmt = Conductor.stepLengthMs;
            if (FlxG.mouse.wheel < 0) scrollAmt *= -1;
            Conductor.pause();
            numTween?.cancel();
            numTween = FlxTween.num(Conductor.framePosition, Conductor.framePosition - scrollAmt, 0.25, {ease: FlxEase.circOut}, (value) -> {
                Conductor.setSongPosition(value);
            });
            selectionTween?.cancel();
            selectionTween = FlxTween.num(selectionStart.y, selectionStart.y + (scrollAmt/2), 0.25, {ease: FlxEase.circOut}, (value) -> {
                selectionStart.y = value;
            });
        }
        if (FlxG.keys.justPressed.SPACE) {
            if (!Conductor.instrumental.playing) {
                numTween?.cancel();
                selectionTween?.cancel();
                Conductor.play();
            } else {
                Conductor.pause();
            }
        }

        if (ElementUtil.anythingOpened) return;

        if (FlxG.mouse.justPressed) {
            selectionStart.x = FlxG.mouse.x;
            selectionStart.y = FlxG.mouse.y;
            selectionBox.setGraphicSize(0, 0);
            selectionBox.updateHitbox();
        }
        if (FlxG.mouse.pressed) {
            selectionBox.x = Math.min(FlxG.mouse.x, selectionStart.x);
            selectionBox.y = Math.min(FlxG.mouse.y, selectionStart.y);
            selectionBox.setGraphicSize(Math.abs(FlxG.mouse.x - selectionStart.x), Math.abs(FlxG.mouse.y - selectionStart.y));
            selectionBox.updateHitbox();
        }
        selectionBox.visible = FlxG.mouse.pressed && selectionStart.x != FlxG.mouse.x && selectionStart.y != FlxG.mouse.y;

    }
}