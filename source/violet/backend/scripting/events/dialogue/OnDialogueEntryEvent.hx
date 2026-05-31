package violet.backend.scripting.events.dialogue;

import violet.data.dialogue.ConversationData;

class OnDialogueEntryEvent extends EventBase {

	public var entry:DialogueEntryData;

	public function new(entry:DialogueEntryData) {
		super();
		this.entry = entry;
	}

}