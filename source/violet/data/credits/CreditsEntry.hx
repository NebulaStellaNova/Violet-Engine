package violet.data.credits;

typedef CreditsJSON = {
	var credits:Array<CreditsEntry>;
}

typedef CreditsEntry = {
	var title:String;
	var contributors:Array<CreditsContributor>;
}

typedef CreditsContributor = {
	var name:String;
	var ?role:String;

	var ?icon:String;
	var ?https_icon:String;

	@:default([1, 1]) var ?icon_scale:Array<Float>;

	var ?url:String;
}
