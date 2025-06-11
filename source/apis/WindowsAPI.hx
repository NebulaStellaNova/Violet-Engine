package apis;

import backend.filesystem.Paths;
import sys.io.Process;

using StringTools;

class WindowsAPI {

	public static var enableToast:Bool = false;

    public static function sendWindowsNotification(title:String, desc:String) {
		if (!enableToast) return;
		desc = "‎      " + desc;
		desc = desc.replace('"', "\'\'");
		var powershellCommand = "powershell -Command \"& {$ErrorActionPreference = 'Stop';"
			+ "$description = '" + desc + "';"
			+ "[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null;"
			+ "$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText01);"
			+ "$toastXml = [xml] $template.GetXml();"
			+ "$toastXml.GetElementsByTagName('text').AppendChild($toastXml.CreateTextNode($description)) > $null;"
			+ "$xml = New-Object Windows.Data.Xml.Dom.XmlDocument;"
			+ "$xml.LoadXml($toastXml.OuterXml);"
			+ "$toast = [Windows.UI.Notifications.ToastNotification]::new($xml);"
			+ "$toast.Tag = 'Test1';"
			+ "$toast.Group = 'Test2';"
			+ "$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('" + title + "');"
			+ "$notifier.Show($toast);}\"";

		if (title != null && title != "" && desc != null && desc != "")
			new Process(powershellCommand);
	}

    private static function sendWindowsNotificationXml(xmlPath:String, title:String, desc:String) {
        return /* This doesn't work :( */;
        var xmlString = Paths.readStringFromPath(xmlPath);

		var powershellCommand = "powershell -Command \"& {$ErrorActionPreference = 'Stop';"
            + "$xml = @'" + xmlString + "'@;"
            + "$XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New();"
            + "$XmlDocument.loadXml($xml);"
            + "$AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe';"
            + "[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($XmlDocument);";

		if (title != null && title != "" && desc != null && desc != "")
			new Process(powershellCommand);
	}
}