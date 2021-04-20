@IsTest(IsParallel = true)
private class EUR_CRM_AccountGroupCreationBatchTest {

	/* ========================================================= */
	/*     Integration tests
	/* ========================================================= */
	@IsTest
	static void givenNewAccountWithoutAG_createAG_PositiveTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect', 'accExtId');
		insert acc;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountGroupCreationBatch());
		Test.stopTest();

		List<EUR_CRM_AccountGroup__c> insertedAGs = selectAGs();

		System.assertEquals(1, insertedAGs.size());
		System.assertEquals(acc.Id, insertedAGs[0].EUR_CRM_Account__c);
		System.assertEquals('GB', insertedAGs[0].EUR_CRM_Country_Code__c);
		System.assertEquals(acc.EUR_CRM_External_ID__c, insertedAGs[0].EUR_CRM_External_ID__c);
	}

	@IsTest
	static void givenNewAccountWithAG_noCreateAG_NegativeTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect', 'accExtId');
		insert acc;

		EUR_CRM_AccountGroup__c ag = makeAGs(acc.Id);
		insert ag;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountGroupCreationBatch());
		Test.stopTest();

		List<EUR_CRM_AccountGroup__c> insertedAGs = selectAGs();

		System.assertEquals(1, insertedAGs.size());
	}


	/* ========================================================= */
	/*     Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt, String extId) {
		Id rtId = EUR_CRM_Account__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			RecordTypeId = rtId
		,   EUR_CRM_Postal_Code__c = '11223'
		,   EUR_CRM_External_ID__c = extId
		);
	}

	private static EUR_CRM_AccountGroup__c makeAGs(Id accId) {
		return new EUR_CRM_AccountGroup__c(
			EUR_CRM_Account__c = accId
		);
	}


	/* ========================================================= */
	/*     SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_AccountGroup__c> selectAGs() {
		return [
			SELECT Id
			,   EUR_CRM_Account__c
			,   EUR_CRM_External_ID__c
			,   EUR_CRM_Country_Code__c
			FROM EUR_CRM_AccountGroup__c
		];
	}
}