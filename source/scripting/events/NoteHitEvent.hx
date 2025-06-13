package scripting.events;

import backend.objects.play.StrumLine.UserType;
import backend.objects.play.Strum;
import backend.objects.play.Note;

class NoteHitEvent extends EventBase {
    
    public var note:Note;
    public var strum:Strum;
    public var direction:Int;
    public var noteType:String;
    public var userType:UserType;
    public var animCancelled:Bool = false;

    public function new(note:Note, noteType:String, strum:Strum, direction:Int, userType:UserType) {
        this.note = note;
        this.strum = strum;
        this.direction = direction;
        this.noteType = noteType;
        this.userType = userType;
    }

    public function cancelAnim() {
        this.animCancelled = true;
    }
}