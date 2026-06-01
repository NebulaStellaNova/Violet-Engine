package violet.data.dialogue;

import violet.backend.scripting.ScriptPack;
import violet.backend.utils.NovaUtils;

class Speaker extends NovaSprite {

	public var scripts:ScriptPack = new ScriptPack();

	public var convo:Null<Conversation>;

	public final id:String;
	public final _data:SpeakerData;

	private var faceLeftCache:Bool = false;
	private var initialFlipX:Bool = false;

	public function new(id:String, ?convo:Conversation) {
		this.id = id;
		this.convo = convo;
		this.initialFlipX = this.flipX;
		this._data = SpeakerRegistry.fetchEntry(id) ?? SpeakerRegistry.fetchEntry('bf');
		super(Paths.image(this._data.assetPath));

		ModdingAPI.checkForScripts('data/dialogue/speakers', id, scripts);
		scripts.parent = this;
		scripts.callVariants('create');

		if (SpeakerRegistry.fetchEntry(id) == null)
			NovaUtils.addNotification('Speaker not found!', 'Could not find speaker with ID "$id" using default speaker "bf".', ERROR);

		this.doFlipCheck = !(_data.disableFlipCheck ?? false);
		this.flipX = this.initialFlipX;
		if (faceLeftCache) flipX = !flipX;
		if (this._data.flipX ?? false) flipX = !flipX;
		__baseFlipped = flipX;

		NullChecker.checkAnimations(this._data.animations);
		for (data in this._data.animations) addFrames(Paths.image(data.assetPath));
		for (data in this._data.animations) {
			// were so funny
			data.offsets[0] *= -1;
			data.offsets[1] *= -1;
			this.addAnimFromData(data);
			data.offsets[0] *= -1;
			data.offsets[1] *= -1;
		}

		this.scale.set(this._data.scale ?? 1, this._data.scale ?? 1);
		if (this._data.offsets != null) this.globalOffset.set(this._data.offsets[0] ?? 0, this._data.offsets[1] ?? 0);
		this.antialiasing = !(this._data.isPixel ?? false);
		this.updateHitbox();

		scripts.callVariants('postCreate');
	}

}