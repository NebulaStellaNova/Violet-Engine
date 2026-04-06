package violet.data.credits;

typedef CreditsEntry = {
	var title:String;
	var contributors:Array<CreditsContributor>;
}

typedef CreditsContributor = {
	var name:String;
	var ?role:String;

	var ?icon:String;

	var ?icon_scale:Array<Float>;

	var ?url:String;
}
