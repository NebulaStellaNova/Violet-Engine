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

function update() {

}

// ========== EVENTS ========== \\

// all events can be cancelled with event.cancel();

function onEvent(event) {
    event.name;
    event.parameters;
    event.type; // For legacy CNE Charts
}

// ------ Note Hit Events ----- \\
function noteHit(event) {
    event.note;
    event.strum;
    event.direction;
    event.noteType;
    event.userType; // player, spectator, opponent
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