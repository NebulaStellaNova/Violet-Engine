package violet.backend.api;

/**
 * This file is from Codename Engine's Source code, but I added `getLatestCommits` and `getCommitCount`
 */

import haxe.Json;
import haxe.Http;
import haxe.Exception;

// TODO: Document further and perhaps make this a Haxelib.
class GitHub {

	/**
	 * Gets the latest 30 commits from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Commits
	 */
	public static function getLatestCommits(user:String, repository:String, ?onError:Exception->Void):Array<GitHubRelease> {

		try {
			var data = Json.parse(requestText('https://api.github.com/repos/${user}/${repository}/commits'));
			if (!(data is Array))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}

		return [];
	}

	/**
	 * Gets all the releases from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Releases
	 */
	public static function getReleases(user:String, repository:String, ?onError:Exception->Void):Array<GitHubRelease> {

		try {
			var data = Json.parse(requestText('https://api.github.com/repos/${user}/${repository}/releases'));
			if (!(data is Array))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}

		return [];
	}

	/**
	 * Gets the contributors list from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Contributors List
	 */
	public static function getContributors(user:String, repository:String, ?onError:Exception->Void):Array<GitHubContributor> {

		try {
			var data = Json.parse(requestText('https://api.github.com/repos/${user}/${repository}/contributors'));
			if (!(data is Array))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}

		return [];
	}

	/**
	 * Gets the commit count from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Releases
	 */
	public static function getCommitCount(user:String, repository:String, ?onError:Exception->Void):Int {
		try {
			var commitCount = 0;
			var data = getContributors(user, repository, onError);
			if (!(data is Array))
				throw __parseGitHubException(data);
			for (contribution in data) {
				commitCount += contribution.contributions;
			}
			return commitCount;
		} catch(e) {
			if (onError != null)
				onError(e);
		}

		return 0;
	}


	/**
	 * Gets a specific GitHub organization using the GitHub API.
	 * @param org The organization to get
	 * @param onError Error Callback
	 * @return Organization
	 */
	public static function getOrganization(org:String, ?onError:Exception->Void):GitHubOrganization {

		try {
			var data = Json.parse(requestText('https://api.github.com/orgs/$org'));
			if (Reflect.hasField(data, "documentation_url"))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}

		return null;
	}

	/**
	 * Gets the members list from a specific GitHub organization using the GitHub API.
	 * NOTE: Members use Contributors' structure!
	 * @param org The organization to get the members from
	 * @param onError Error Callback
	 * @return Members List
	 */
	 public static function getOrganizationMembers(org:String, ?onError:Exception->Void):Array<GitHubContributor> {

		try {
			var data = Json.parse(requestText('https://api.github.com/orgs/$org/members'));
			if (Reflect.hasField(data, "documentation_url"))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}

		return [];
	}

	/**
	 * Gets a specific GitHub user/organization using the GitHub API.
	 * NOTE: If organization, it will be returned with the structure of a normal user; use `getOrganization` if you specifically want an organization!
	 * @param user The user/organization to get
	 * @param onError Error Callback
	 * @return User/Organization
	 */
	 public static function getUser(user:String, ?onError:Exception->Void):GitHubUser {

		try {
			var url = 'https://api.github.com/users/$user';

			var data = Json.parse(requestText(url));
			if (Reflect.hasField(data, "documentation_url"))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}

		return null;
	}

	/**
	 * Filters all releases gotten by `getReleases`
	 * @param releases Releases
	 * @param keepPrereleases Whenever to keep Pre-Releases.
	 * @param keepDrafts Whenever to keep Drafts.
	 * @return Filtered releases.
	 */
	/* public static inline function filterReleases(releases:Array<GitHubRelease>, keepPrereleases:Bool = true, keepDrafts:Bool = false)
		return  [for(release in releases) if (release != null && (!release.prerelease || (release.prerelease && keepPrereleases)) && (!release.draft || (release.draft && keepDrafts))) release] releases ; */

	private static function __parseGitHubException(obj:Dynamic):GitHubException {
		var msg:String = "(No message)";
		var url:String = "(No API url)";
		if (Reflect.hasField(obj, "message"))
			msg = Reflect.field(obj, "message");
		if (Reflect.hasField(obj, "documentation_url"))
			url = Reflect.field(obj, "documentation_url");
		return new GitHubException(msg, url);
	}

	public static function requestText(url:String):String {
		var result:String = null;
		var error:HttpError = null;
		var redirected:Bool = false;

		var h = new Http(url);
		h.setHeader("User-Agent", 'request');

		h.onStatus = function(status)
		{
			redirected = isRedirect(status);
			if (redirected)
			{
				var loc = h.responseHeaders.get("Location");
				if (loc != null)
					result = requestText(loc);
				else
					error = new HttpError("Missing Location header in redirect", url, status, true);
			}
		};

		h.onData = function(data)
		{
			if (result == null)
				result = data;
		};

		h.onError = function(msg)
		{
			error = new HttpError(msg, url);
		};

		h.request(false);

		if (error != null)
			throw error;

		if (result == null)
			throw new HttpError("Unknown error or empty response", url);

		return result;
	}

	private static function isRedirect(status:Int):Bool {
		switch (status)
		{
			// 301: Moved Permanently, 302: Found (Moved Temporarily), 307: Temporary Redirect, 308: Permanent Redirect  - Nex
			case 301 | 302 | 307 | 308:
				// Logs.traceColored([Logs.logText('[Connection Status] ', BLUE), Logs.logText('Redirected with status code: ', YELLOW), Logs.logText('$status', GREEN)], VERBOSE);
				return true;
		}
		return false;
	}

}

typedef GitHubRelease = {
	/**
	 * Body of the GitHub request (Markdown)
	 */
	var body:String;

	/**
	 * Url of the release (GitHub API)
	 */
	var url:String;

	/**
	 * Url for the assets JSON. Also accessible via `GitHubRelease.assets`
	 */
	var assets_url:String;

	/**
	 * Template URL for asset download link.
	 */
	var upload_url:String;

	/**
	 * Link to the release on the GitHub website.
	 */
	var html_url:String;

	/**
	 * ID of the release.
	 */
	var id:Int;

	/**
	 * Author of the release
	 */
	var author:GitHubUser;

	var node_id:String;

	var tag_name:String;

	var target_commitish:String;

	var name:String;

	var draft:Bool;

	var prerelease:Bool;

	var created_at:String;

	var published_at:String;

	var assets:Array<GitHubAsset>;

	var tarball_url:String;

	var zipball_url:String;

	var reactions:GitHubReactions;
}

typedef GitHubAsset = {
	var url:String;
	var id:Int;
	var node_id:String;
	var name:String;
	var label:String;
	var uploader:GitHubUser;
	var content_type:String;
	var state:String;
	var size:UInt;
	var download_count:Int;
	var created_at:String;
	var updated_at:String;
	var browser_download_url:String;
}

typedef GitHubContributor = {
	var login:String;
	var id:Int;
	var node_id:String;
	var avatar_url:String;
	var gravatar_id:String;
	var url:String;
	var html_url:String;
	var followers_url:String;
	var following_url:String;
	var gists_url:String;
	var starred_url:String;
	var subscriptions_url:String;
	var organizations_url:String;
	var repos_url:String;
	var events_url:String;
	var received_events_url:String;
	var type:String;
	var site_admin:Bool;
	var contributions:Int;
}

typedef CreditsGitHubContributor = {
	var login:String;
	var avatar_url:String;
	var html_url:String;
	var ?id:Int; // Not available in the avatar part
	var ?contributions:Int; // Not available in the avatar part
}


class GitHubException extends Exception {

	public var apiMessage:String;

	public var documentationUrl:String;

	public function new(apiMessage:String, documentationUrl:String) {
		super('[GitHubException] ${apiMessage} (Check ${documentationUrl})');
		this.apiMessage = apiMessage;
		this.documentationUrl = documentationUrl;
	}

}


typedef GitHubOrganization = {
	var login:String;
	var id:Int;
	var node_id:String;
	var url:String;
	var repos_url:String;
	var events_url:String;
	var hooks_url:String;
	var issues_url:String;
	var members_url:String;
	var public_members_url:String;
	var avatar_url:String;
	var description:String;
	var name:String;
	var company:String;
	var blog:String;
	var location:String;
	var email:String;
	var twitter_username:String;
	var is_verified:Bool;
	var has_organization_projects:Bool;
	var has_repository_projects:Bool;
	var public_repos:Int;
	var public_gists:Int;
	var followers:Int;
	var following:Int;
	var html_url:String;
	var created_at:String;
	var updated_at:String;
	var archived_at:String;
	var type:GitHubUserType;
}

typedef GitHubReactions = {
	var url:String;
	var total_count:Int;
	// +1 and -1 cant be added, you need to use Reflect.field
	var laugh:Int;
	var hooray:Int;
	var confused:Int;
	var heart:Int;
	var rocket:Int;
	var eyes:Int;
}

typedef GitHubUser = {
	/**
	 * Username of the user.
	 */
	var login:String;

	/**
	 * ID of the user.
	 */
	var id:Int;

	/**
	 * ID of the current node on the GitHub database.
	 */
	var node_id:String;

	/**
	 * Link to the avatar (profile picture).
	 */
	var avatar_url:String;

	/**
	 * Unknown
	 */
	var gravatar_id:String;

	/**
	 * URL to the user on GitHub's servers.
	 */
	var url:String;

	/**
	 * URL to the user on GitHub's website.
	 */
	var html_url:String;

	/**
	 * URL on GitHub's API to access this user's followers.
	 */
	var followers_url:String;

	/**
	 * URL on GitHub's API to access the accounts this user is following.
	 */
	var following_url:String;

	/**
	 * URL on GitHub's API to access this user's gists.
	 */
	var gists_url:String;

	/**
	 * URL on GitHub's API to access this user's starred repositories.
	 */
	var starred_url:String;

	// NOT COMPLETE: MISSING repos_url, organizations_url, subscriptions_url, events_url, received_events_url.

	/**
	 * Type of the user.
	 */
	var type:GitHubUserType;

	/**
	 * Whenever the user is a GitHub administrator.
	 */
	var site_admin:Bool;

	/**
	 * Name of the user.
	 */
	var name:String;

	/**
	 * The company this user belongs to. Can be `null`.
	 */
	var company:String;

	var blog:String;

	var location:String;

	var email:String;

	var hireable:Null<Bool>;

	var bio:String;

	/**
	 * Twitter username of the user. Can be null.
	 */
	var twitter_username:String;

	/**
	 * Number of public repos this user own.
	 */
	var public_repos:Int;

	/**
	 * Number of public gists this user own.
	 */
	var public_gists:Int;

	/**
	 * Number of followers this user have
	 */
	var followers:Int;

	/**
	 * Number of accounts this user follows.
	 */
	var following:Int;

	/**
	 * Date of creation of the account
	 */
	var created_at:String;

	/**
	 * Date of last account update.
	 */
	var updated_at:String;
}

enum abstract GitHubUserType(String) {
	var USER = "User";
	var ORGANIZATION = "Organization";
}

private class HttpError {

	public var message:String;
	public var url:String;
	public var status:Int;
	public var redirected:Bool;

	public function new(message:String, url:String, ?status:Int = -1, ?redirected:Bool = false) {
		this.message = message;
		this.url = url;
		this.status = status;
		this.redirected = redirected;
	}

	public function toString():String {
		var parts:Array<String> = ['[HttpError]'];

		if (status != -1)
			parts.push('Status: $status');

		if (redirected)
			parts.push('(Redirected)');

		parts.push('URL: $url');
		parts.push('Message: $message');

		return parts.join(' | ');
	}

}