package violet.backend.scripting.events.dialogue;

import violet.data.dialogue.ConversationData;

class OnDialogueEntryEvent extends EventBase {

	public final entry:DialogueEntryData;
	public final line:ConversationTextPiece;

	public function new(entry:DialogueEntryData, line:ConversationTextPiece) {
		super();
		this.entry = entry;
		this.line = line;
	}

}