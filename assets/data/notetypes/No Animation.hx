function noteHit(event) {
    if (event.noteType == "No Animation") {
        event.animCancelled = true;
    }
}

function sustainHit(event) {
    if (event.noteType == "No Animation") {
        event.animCancelled = true;
    }
}