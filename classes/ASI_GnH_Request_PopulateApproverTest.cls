/*********************************************************************************
 * Name:ASI_GnH_Request_PopulateApproverTest
 * Description: Test class for ASI_GnH_Request_PopulateApprover
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-24       Laputa: Hugo Cheung     Created
*********************************************************************************/
@isTest
public class ASI_GnH_Request_PopulateApproverTest {

	@testSetup
	public static void setupTestData() {
		ASI_GnH_TW_TestClassHelper.UserData userData1 = new ASI_GnH_TW_TestClassHelper.UserData(false, 'testinguser1234');
		ASI_GnH_TW_TestClassHelper.UserData userData2 = new ASI_GnH_TW_TestClassHelper.UserData(false, 'testinguser2345');
		ASI_GnH_TW_TestClassHelper.UserData userData3 = new ASI_GnH_TW_TestClassHelper.UserData(false, 'testinguser3456');

		List<User> userList = new List<User>();

		userList.add(userData1.userObject);
		userList.add(userData2.userObject);
		userList.add(userData3.userObject);

		insert userList;

		ASI_GnH_TW_TestClassHelper.UserData userData4 = new ASI_GnH_TW_TestClassHelper.UserData(false, 'testinguser4567', userData1.userObject.Id);
		userData4.userObject.Department = 'TestingDepartment1';
		userData4.userObject.CompanyName = 'TestingCompany1';
		insert userData4.userObject;

		ASI_GnH_TW_TestClassHelper.GnHRouteTypeData GnHRouteTypeData = new ASI_GnH_TW_TestClassHelper.GnHRouteTypeData(true, userData4.userObject);
		ASI_GnH_TW_TestClassHelper.GnHRouteDetailData GnHRouteDetailData1 = new ASI_GnH_TW_TestClassHelper.GnHRouteDetailData(false, GnHRouteTypeData.GnHRouteType);
		ASI_GnH_TW_TestClassHelper.GnHRouteDetailData GnHRouteDetailData2 = new ASI_GnH_TW_TestClassHelper.GnHRouteDetailData(false, GnHRouteTypeData.GnHRouteType, userData2.userObject);
		ASI_GnH_TW_TestClassHelper.GnHRouteDetailData GnHRouteDetailData3 = new ASI_GnH_TW_TestClassHelper.GnHRouteDetailData(false, GnHRouteTypeData.GnHRouteType, userData1.userObject);

		List<ASI_GnH_Route_Rule_Detail__c> GnHRouteRuleDetailList = new List<ASI_GnH_Route_Rule_Detail__c>();

		GnHRouteRuleDetailList.add(GnHRouteDetailData1.GnHRouteDetail);
		GnHRouteRuleDetailList.add(GnHRouteDetailData2.GnHRouteDetail);
		GnHRouteRuleDetailList.add(GnHRouteDetailData3.GnHRouteDetail);

		insert GnHRouteRuleDetailList;
	}

	public static testmethod void testPopulateApprover() {

		User user3 = [SELECT Id FROM User WHERE UserName = 'testinguser3456@testorg.com' LIMIT 1];
		User user4 = [SELECT Id FROM User WHERE UserName = 'testinguser4567@testorg.com' LIMIT 1];

		Test.startTest();
			ASI_GnH_TW_TestClassHelper.GnHRequestData GnHRequestData = new ASI_GnH_TW_TestClassHelper.GnHRequestData(false, user4);

			System.runAs(user4) {
				insert GnHRequestData.GnHRequest;
			}

			GnHRequestData.GnHRequest.ASI_GnH_Applicant__c = user3.Id;
			update GnHRequestData.GnHRequest;

		Test.stopTest();
	}

}