/**
    NOTES:
        - Song Scripts can go in the following locations: data/scripts/songs, data/scripts/songs/songID, songs, songs/songID/scripts
        - This is very much a WIP engine, expect issues.
**/

// ====== GLOBAL CHECKS ======= \\

scriptDisabled = true; // You can disable a script by putting this ANYWHERE within a hscript/lua file. (Only works with songs scripts for the moment)

// ======== CALLBACKS ========= \\

function create() {
    trace("hello");
}

function postCreate() {
    trace("hello");
}

function update(elapsed:Float) {
    trace("hello");
}

// ========== EVENTS ========== \\

// all events can be cancelled with event.cancel();

function onEvent(event:SongEvent) {
    event.name:String;
    event.parameters:Array<Dynamic>;
}

// ------ Note Hit Events ----- \\
function noteHit(event:NoteHitEvent) {
    event.note:Note;
    event.strum:Strum;
    event.direction:Int;
    event.noteType:String;
    event.isComputer:Bool;
    event.animCancelled:Bool;
    event.animationSuffix:String;
}

// ---- Note Hit Sub Events --- \\
function playerNoteHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
}

function opponentNoteHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
}

function spectatorNoteHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
}

// ---- Sustain Hit Events ---- \\
function sustainHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
    event.userType; // player, spectator, opponent
}

// -- Sustain Hit Sub Events -- \\
function playerSustainHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
}

function opponentSustainHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
}

function spectatorSustainHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
}