/*********************************************************************************
 * Name:ASI_TnE_GnH_TW_ValidTest
 * Description: Test class for ASI_TnE_GnH_TW_Validation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-07-26       Laputa: Hugo Cheung     Created
*********************************************************************************/
@isTest
public class ASI_TnE_GnH_TW_ValidTest {

	@testSetup
	public static void setupTestData() {
		ASI_GnH_TW_TestClassHelper.UserData userData = new ASI_GnH_TW_TestClassHelper.UserData(true, 'testinguser5678', 'TestingDepartment1', 'TestingCompany1');
		ASI_GnH_TW_TestClassHelper.GnHRequestData GnHRequestData = new ASI_GnH_TW_TestClassHelper.GnHRequestData(false, userData.userObject);
		System.runAs(userData.userObject) {
			GnHRequestData.GnHRequest.ASI_GnH_Status__c = 'Approved';
			insert GnHRequestData.GnHRequest;
            
            ASI_GnH_TW_TestClassHelper.ClaimHeaderData claimHeaderData = new ASI_GnH_TW_TestClassHelper.ClaimHeaderData(true);
			ASI_GnH_TW_TestClassHelper.ExpenseCategoryAndClassificationData expenseCategoryAndClassificationData = new ASI_GnH_TW_TestClassHelper.ExpenseCategoryAndClassificationData();

			ASI_GnH_TW_TestClassHelper.ClaimDetailData claimDetailData1 = new ASI_GnH_TW_TestClassHelper.ClaimDetailData(true, claimHeaderData.claimHeader, GnHRequestData.GnHRequest, 
			                                                                                                         	expenseCategoryAndClassificationData.expenseCategory, expenseCategoryAndClassificationData.expenseClassification,
			                                                                                                         	10000, 1, 50, 'Public Official');
		}
	}

	public static testmethod void testValidation() {

		ASI_GnH_Request__c GnHRequest = [SELECT Id, ASI_GnH_Status__c FROM ASI_GnH_Request__c LIMIT 1];

		Test.startTest();

		try{
			GnHRequest.ASI_GnH_Status__c = 'Draft';
			update GnHRequest;
		} catch (Exception e) {
			System.debug(e);
		}

		Test.stopTest();

	}

}