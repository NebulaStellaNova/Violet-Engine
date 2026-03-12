function noteHit(event) {
    if (event.noteType == "Alt Anim Note") {
        event.animationSuffix = "alt";
    }
    trace(SONG._data.noteTypes);
}