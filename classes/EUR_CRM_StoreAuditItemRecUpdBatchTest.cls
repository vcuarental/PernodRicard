/***
 * SAI - Stock Activity Item
 * SA - Stock Activity
 * AAS - Activity Audit Settings
 */


@IsTest(IsParallel=true)
private class EUR_CRM_StoreAuditItemRecUpdBatchTest {

	private static final Map<String, String> SAI_RT_BY_ACC_RT = new Map<String, String>{
		'EUR_DE_Off_Trade_New_Business' =>  'EUR_DE_Off_Trade_Store_Audit_Item'
	,	'EUR_DE_On_Trade_B2B' =>  'EUR_DE_On_Trade_B2B_Store_Audit_Item'
	,	'EUR_DE_On_Trade_Gastronomy' =>  'EUR_DE_On_Trade_Gastronomy_Store_Audit_Item'
	,	'EUR_DE_On_Trade_Hotel' =>  'EUR_DE_On_Trade_Hotel_Store_Audit_Item'
	,	'EUR_DE_On_Trade_New_Business' =>  'EUR_DE_On_Trade_New_Business_Store_Audit_Item'
	,	'EUR_DE_On_Trade_Special_Stores' =>  'EUR_DE_On_Trade_Special_Stores_Store_Audit_Item'
	,	'EUR_DE_On_Trade_System_Gastronomy' =>  'EUR_DE_On_Trade_System_Gastronomy_Store_Audit_Item'
	,	'EUR_DE_On_Trade_Wholesaler' =>  'EUR_DE_Wholesaler_Store_Audit_Item'
	};

	private static List<EUR_CRM_CTM_ActivityAuditSettings__mdt> ACTIVITY_AUDIT_SETTINGS = new List<EUR_CRM_CTM_ActivityAuditSettings__mdt>();

	private static final Integer COUNT_OF_RECORDS = 5;


	@IsTest
	private static void insertData_test() {
		List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_DE_Off_Trade_New_Business');
		insert accounts;

		List<EUR_CRM_Store_Audit__c> sas = makeSAs(accounts);
		insert sas;

		List<EUR_CRM_Store_Audit_Item__c> sais = makeSAIs(sas, 'EUR_DE_Off_Trade_Store_Audit');
		insert sais;

		List<EUR_CRM_Account__c> accs = selectAccounts();
		System.assertEquals(COUNT_OF_RECORDS, accs.size());
		System.assertEquals('EUR_DE_Off_Trade_New_Business', accs[0].RecordType.DeveloperName);

		List<EUR_CRM_Store_Audit__c> insertedSAs = selectSAs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAs.size());

		List<EUR_CRM_Store_Audit_Item__c> insertedSAIs = selectSAIs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAIs.size());
		System.assertEquals('EUR_DE_Off_Trade_Store_Audit', insertedSAIs[0].RecordType.DeveloperName);
		System.assertEquals('EUR_DE_Off_Trade_New_Business', insertedSAIs[0].EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName);

		System.assertEquals(8, SAI_RT_BY_ACC_RT.size());
	}

	@IsTest
	private static void old_EUR_DE_Off_Trade_Store_Audit_updateToNewRT_positiveTest() {
		List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_DE_Off_Trade_New_Business');
		insert accounts;

		List<EUR_CRM_Store_Audit__c> sas = makeSAs(accounts);
		insert sas;

		List<EUR_CRM_Store_Audit_Item__c> sais = makeSAIs(sas, 'EUR_DE_Off_Trade_Store_Audit');
		insert sais;

		List<EUR_CRM_Account__c> accs = selectAccounts();
		System.assertEquals(COUNT_OF_RECORDS, accs.size());
		System.assertEquals('EUR_DE_Off_Trade_New_Business', accs[0].RecordType.DeveloperName);

		List<EUR_CRM_Store_Audit__c> insertedSAs = selectSAs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAs.size());

		List<EUR_CRM_Store_Audit_Item__c> insertedSAIs = selectSAIs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAIs.size());
		System.assertEquals('EUR_DE_Off_Trade_Store_Audit', insertedSAIs[0].RecordType.DeveloperName);
		System.assertEquals('EUR_DE_Off_Trade_New_Business', insertedSAIs[0].EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName);

		Test.startTest();
		Database.executeBatch(new EUR_CRM_StoreAuditItemRecordsUpdateBatch());
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> updatedSAIs = selectSAIs();
		for (EUR_CRM_Store_Audit_Item__c sai : updatedSAIs) {
			System.assertEquals('EUR_DE_Off_Trade_Store_Audit_Item', sai.RecordType.DeveloperName);
		}
	}

	@IsTest
	private static void old_EUR_DE_On_Trade_Store_Audit_updateToNewRT_positiveTest() {
		List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_DE_On_Trade_Hotel');
		insert accounts;

		List<EUR_CRM_Store_Audit__c> sas = makeSAs(accounts);
		insert sas;

		List<EUR_CRM_Store_Audit_Item__c> sais = makeSAIs(sas, 'EUR_DE_On_Trade_Store_Audit');
		insert sais;

		List<EUR_CRM_Account__c> accs = selectAccounts();
		System.assertEquals(COUNT_OF_RECORDS, accs.size());
		System.assertEquals('EUR_DE_On_Trade_Hotel', accs[0].RecordType.DeveloperName);

		List<EUR_CRM_Store_Audit__c> insertedSAs = selectSAs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAs.size());

		List<EUR_CRM_Store_Audit_Item__c> insertedSAIs = selectSAIs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAIs.size());
		System.assertEquals('EUR_DE_On_Trade_Store_Audit', insertedSAIs[0].RecordType.DeveloperName);
		System.assertEquals('EUR_DE_On_Trade_Hotel', insertedSAIs[0].EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName);

		Test.startTest();
		Database.executeBatch(new EUR_CRM_StoreAuditItemRecordsUpdateBatch());
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> updatedSAIs = selectSAIs();
		for (EUR_CRM_Store_Audit_Item__c sai : updatedSAIs) {
			System.assertEquals('EUR_DE_On_Trade_Hotel_Store_Audit_Item', sai.RecordType.DeveloperName);
		}
	}

	@IsTest
	private static void old_EUR_DE_On_Trade_Store_Audit_updateToNewRT_negativeTest() {
		List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_DE_On_Trade_Hotel');
		insert accounts;

		List<EUR_CRM_Store_Audit__c> sas = makeSAs(accounts);
		insert sas;

		List<EUR_CRM_Store_Audit_Item__c> sais = makeSAIs(sas, 'EUR_DE_On_Trade_B2B_Store_Audit_Item');
		insert sais;

		List<EUR_CRM_Account__c> accs = selectAccounts();
		System.assertEquals(COUNT_OF_RECORDS, accs.size());
		System.assertEquals('EUR_DE_On_Trade_Hotel', accs[0].RecordType.DeveloperName);

		List<EUR_CRM_Store_Audit__c> insertedSAs = selectSAs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAs.size());

		List<EUR_CRM_Store_Audit_Item__c> insertedSAIs = selectSAIs();
		System.assertEquals(COUNT_OF_RECORDS, insertedSAIs.size());
		System.assertEquals('EUR_DE_On_Trade_B2B_Store_Audit_Item', insertedSAIs[0].RecordType.DeveloperName);
		System.assertEquals('EUR_DE_On_Trade_Hotel', insertedSAIs[0].EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName);

		Test.startTest();
		Database.executeBatch(new EUR_CRM_StoreAuditItemRecordsUpdateBatch());
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> updatedSAIs = selectSAIs();
		for (EUR_CRM_Store_Audit_Item__c sai : updatedSAIs) {
			System.assertEquals('EUR_DE_On_Trade_B2B_Store_Audit_Item', sai.RecordType.DeveloperName);
		}
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static List<EUR_CRM_Account__c> makeAccounts(String rt) {
		List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
		for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
			accounts.add(makeAccount(rt));
		}
		return accounts;
	}

	private static List<EUR_CRM_Store_Audit__c> makeSAs(List<EUR_CRM_Account__c> accs) {
		List<EUR_CRM_Store_Audit__c> sas = new List<EUR_CRM_Store_Audit__c>();
		for (EUR_CRM_Account__c acc : accs) {
			sas.add(makeSA(acc.Id));
		}
		return sas;
	}

	private static List<EUR_CRM_Store_Audit_Item__c> makeSAIs(List<EUR_CRM_Store_Audit__c> sas, String saiRT) {
		List<EUR_CRM_Store_Audit_Item__c> sais = new List<EUR_CRM_Store_Audit_Item__c>();
		for (EUR_CRM_Store_Audit__c sa : sas) {
			sais.add(makeSAI(sa.Id, saiRT));
		}
		return sais;
	}

	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			RecordTypeId = rtId
		,	EUR_CRM_Postal_Code__c = '112233'
		);
	}

	private static EUR_CRM_Store_Audit__c makeSA(Id accId) {
		return new EUR_CRM_Store_Audit__c(
			EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_Store_Audit_Item__c makeSAI(Id saId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Store_Audit_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
	    return new EUR_CRM_Store_Audit_Item__c(
	    	EUR_CRM_Store_Audit__c = saId
		,	RecordTypeId = rtId
	    );
	}

	private static EUR_CRM_CTM_ActivityAuditSettings__mdt makeAAS(String accRT, String saiRT) {
	    return new EUR_CRM_CTM_ActivityAuditSettings__mdt(
			EUR_CRM_Account_Record_Type__c = accRT
		,	StoreAuditItemRecordType__c = saiRT
	    );
	}

	private static List<EUR_CRM_CTM_ActivityAuditSettings__mdt> makeAASs() {
		for (String saiRT : SAI_RT_BY_ACC_RT.keySet()) {
			ACTIVITY_AUDIT_SETTINGS.add(makeAAS(SAI_RT_BY_ACC_RT.get(saiRT), saiRT));
		}
		return ACTIVITY_AUDIT_SETTINGS;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Account__c> selectAccounts() {
		return [
			SELECT Id
			,	RecordType.DeveloperName
			FROM EUR_CRM_Account__c
		];
	}

	private static List<EUR_CRM_Store_Audit__c> selectSAs() {
		return [
			SELECT Id
			,	RecordType.DeveloperName
			,	EUR_CRM_Account__c
			FROM EUR_CRM_Store_Audit__c
		];
	}

	private static List<EUR_CRM_Store_Audit_Item__c> selectSAIs() {
		return [
			SELECT Id
			,	RecordType.DeveloperName
			,	EUR_CRM_Account__r.RecordType.DeveloperName
			,	EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName
			FROM EUR_CRM_Store_Audit_Item__c
		];
	}

}