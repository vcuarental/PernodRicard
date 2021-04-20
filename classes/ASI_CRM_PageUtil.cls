public class ASI_CRM_PageUtil {

	public static void showMessage(ApexPages.Severity severity, String message) {
		ApexPages.Message apexPageMessage = new ApexPages.Message(severity, message);
		ApexPages.addMessage(apexPageMessage);
	}

	public static void showConfirm(Object conf) {
		showMessage(ApexPages.Severity.CONFIRM, String.Valueof(conf));
	}

	public static void showInfo(Object info) {
		showMessage(ApexPages.Severity.INFO, String.Valueof(info));
	}

	public static void showWarning(Object warning) {
		showMessage(ApexPages.Severity.WARNING, String.Valueof(warning));
	}

	public static void showError(Object error) {
		showMessage(ApexPages.Severity.ERROR, String.Valueof(error));
	}
}