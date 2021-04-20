/*********************************************************************************
 * Name:ASI_TnE_GnH_TW_ClaimsDetailValidTest
 * Description: Test class for ASI_TnE_GnH_TW_ClaimsDetailValidation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-24       Laputa: Hugo Cheung     Created
*********************************************************************************/
@isTest
public class ASI_TnE_GnH_TW_ClaimsDetailValidTest {

	@testSetup
	public static void setupTestData() {

	}
	
	public static testmethod void testValidation() {

		ASI_GnH_TW_TestClassHelper.UserData userData = new ASI_GnH_TW_TestClassHelper.UserData(true, 'testinguser5678', 'TestingDepartment1', 'TestingCompany1');
		ASI_GnH_TW_TestClassHelper.GnHRequestData GnHRequestData = new ASI_GnH_TW_TestClassHelper.GnHRequestData(false, userData.userObject);
		System.runAs(userData.userObject) {
			insert GnHRequestData.GnHRequest;
		}

		ASI_GnH_TW_TestClassHelper.ClaimHeaderData claimHeaderData = new ASI_GnH_TW_TestClassHelper.ClaimHeaderData(true);
		ASI_GnH_TW_TestClassHelper.ExpenseCategoryAndClassificationData expenseCategoryAndClassificationData = new ASI_GnH_TW_TestClassHelper.ExpenseCategoryAndClassificationData();

		ASI_GnH_TW_TestClassHelper.ClaimDetailData claimDetailData1 = new ASI_GnH_TW_TestClassHelper.ClaimDetailData(false, claimHeaderData.claimHeader, GnHRequestData.GnHRequest, 
			                                                                                                         expenseCategoryAndClassificationData.expenseCategory, expenseCategoryAndClassificationData.expenseClassification,
			                                                                                                         10000, 1, 50, 'Public Official');

		ASI_GnH_TW_TestClassHelper.ClaimDetailData claimDetailData2 = new ASI_GnH_TW_TestClassHelper.ClaimDetailData(false, claimHeaderData.claimHeader, GnHRequestData.GnHRequest, 
			                                                                                                         expenseCategoryAndClassificationData.expenseCategory, expenseCategoryAndClassificationData.expenseClassification,
			                                                                                                         100, 1, 150, 'Public Official');

		ASI_GnH_TW_TestClassHelper.ClaimDetailData claimDetailData3 = new ASI_GnH_TW_TestClassHelper.ClaimDetailData(false, claimHeaderData.claimHeader, GnHRequestData.GnHRequest, 
			                                                                                                         expenseCategoryAndClassificationData.expenseCategory, expenseCategoryAndClassificationData.expenseClassification,
			                                                                                                         100, 1, 50, 'Non Public Official');

		List<ASI_TnE_ClaimDetail__c> claimDetailList = new List<ASI_TnE_ClaimDetail__c>();

		claimDetailList.add(claimDetailData1.claimDetail);
		claimDetailList.add(claimDetailData2.claimDetail);
		claimDetailList.add(claimDetailData3.claimDetail);

		Test.startTest();

		try{
			insert claimDetailList;
		} catch (Exception e) {
			System.debug(e);
		}

		Test.stopTest();

	}

}