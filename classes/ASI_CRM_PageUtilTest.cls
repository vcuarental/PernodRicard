@isTest
public class ASI_CRM_PageUtilTest {

	static final String MESSAGE = 'message text';

	@isTest
	static void TestShowConfirm() {

		ASI_CRM_PageUtil.showConfirm(MESSAGE);

		System.assertEquals(MESSAGE, ApexPages.getMessages().get(0).getDetail());
	}

	@isTest
	static void TestShowInfo() {

		ASI_CRM_PageUtil.showInfo(MESSAGE);

	}

	@isTest
	static void TestShowWarning() {

		ASI_CRM_PageUtil.showWarning(MESSAGE);

	}

	@isTest
	static void TestShowError() {

		ASI_CRM_PageUtil.showError(MESSAGE);

	}

}