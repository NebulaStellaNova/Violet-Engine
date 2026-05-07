package violet.backend.online;

class RoomTestState extends StateBackend {
	override function create() {
		super.create();
		new NetworkManager();
	}
}