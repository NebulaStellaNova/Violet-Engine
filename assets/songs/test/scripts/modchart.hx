import violet.backend.audio.Conductor;

function postUpdate(elapsed) {
	for(s in strumLines) {
		for(i=>n in s.strums) {
			n.angle = n.scrollAngle = Math.sin(Conductor.curBeatFloat + (i * 0.45)) * 35;
		}
		for (n in s.notes) {
			n.angle = n.parentStrum.angle;
		}
	}
}