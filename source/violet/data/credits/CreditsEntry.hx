package violet.data.credits;

typedef CreditsJSON = {
	credits:Array<CreditsEntry>
}

typedef CreditsEntry = {
	title:String,
	contributors:Array<CreditsContributor>
}

typedef CreditsContributor = {
	name:String,
	?role:String,

	?icon:String,
	?https_icon:String,

	?icon_scale:{?x:Float, ?y:Float},

	?url:String
}
