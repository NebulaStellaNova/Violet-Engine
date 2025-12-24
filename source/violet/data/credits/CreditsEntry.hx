package violet.data.credits;

typedef CreditsEntry = {
	title:String,
	contributors:Array<CreditsContributor>
}

typedef CreditsContributor = {
    name:String,
    ?role:String,

    ?icon:String,
    ?https_icon:String,
}
