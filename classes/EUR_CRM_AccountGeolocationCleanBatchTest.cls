@IsTest
private class EUR_CRM_AccountGeolocationCleanBatchTest {
	@IsTest
	private static void testBehavior() {
		EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect');
		account.EUR_CRM_Outlet_Geolocation__Latitude__s = 51.00;
		account.EUR_CRM_Outlet_Geolocation__Longitude__s = 31.00;
		account.EUR_CRM_OutletGeolocationRecalculation__c = false;
		insert account;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountGeolocationCleanBatch('GB'));
		Test.stopTest();

		List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
		System.assertEquals(1, updatedAccounts.size());
		System.assertEquals(null, updatedAccounts[0].EUR_CRM_Outlet_Geolocation__Latitude__s);
		System.assertEquals(null, updatedAccounts[0].EUR_CRM_Outlet_Geolocation__Longitude__s);
		System.assertEquals(true, updatedAccounts[0].EUR_CRM_OutletGeolocationRecalculation__c);

	}

	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			EUR_CRM_Postal_Code__c = '12345'
			,	RecordTypeId = rtId
		);
	}

	private static List<EUR_CRM_Account__c> selectAccounts() {
		return [
			SELECT Id
				, Name
				, EUR_CRM_Country_Code__c
				, EUR_CRM_Outlet_Geolocation__Latitude__s
				, EUR_CRM_Outlet_Geolocation__Longitude__s
				, EUR_CRM_Outlet_Geolocation__c
				, EUR_CRM_OutletGeolocationRecalculation__c
			FROM EUR_CRM_Account__c
		];
	}
}