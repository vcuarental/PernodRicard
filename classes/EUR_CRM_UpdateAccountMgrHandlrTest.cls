/*********************************************************************************
 * Name: EUR_CRM_RU_UpdateAccountManagerTest
 * Description: Automatically update the field 'Manager of the Account Owner' in Account 
 				when the field 'Manager' is updated in User profile
 *
 * Version History
 * Date			Developer	Comments
 * ----------	----------	-------------------------------------------------------
 *	18-1-2017	Kevin Choi		Create the test class
 *  25-7-2017	Kevin Choi		Renamed to generic: EUR_CRM_UpdateAccountMgrHandlrTest
 *  12-Oct-2017 Jay Chau		Update user name in test setup
*********************************************************************************/
@IsTest
public class EUR_CRM_UpdateAccountMgrHandlrTest {

	@IsTest
	private static void testexecution1() {
		User originUser = makeUser('EUR System Admin', 'EUR_MA');
		User manager = makeUser('EUR System Admin', 'EUR_MA');
		insert new List<User>{originUser, manager};

		EUR_CRM_Account__c acct = makeAccount('EUR_MA_On_Trade');
		acct.OwnerId = originUser.Id;
		System.runAs(originUser){
			insert acct;
		}
		Test.startTest();
		originUser.ManagerId = manager.Id;
		update originUser;
		Test.stopTest();
	}

	@IsTest
	private static void testexecution2() {
		EUR_CRM_Account__c acct = makeAccount('EUR_MA_On_Trade');
		insert acct;
		Test.startTest();
		EUR_CRM_UpdateAccountMgrHandlr.createBatch(new List<EUR_CRM_Account__c>{acct});
		Test.stopTest();
	}

	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			RecordTypeId = rtId
		,	EUR_CRM_Postal_Code__c = '00000'
		);
	}

	private static User makeUser(String profileName, String roleDevName) {
		String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
		Profile p = [SELECT Id FROM Profile WHERE Name =:profileName];
		Id userRoleId = [SELECT Id FROM UserRole WHERE DeveloperName =: roleDevName LIMIT 1][0].Id;
		return new User(
			Alias = 'standt'
			,   Email = uniqueUserName
			,   EmailEncodingKey = 'UTF-8'
			,   LastName = 'Testing'
			,   LanguageLocaleKey = 'en_US'
			,   LocaleSidKey = 'en_US'
			,   TimeZoneSidKey = 'America/Los_Angeles'
			,   Username = uniqueUserName
			,   ProfileId = p.Id
			,	UserRoleId = userRoleId
		);
	}

}