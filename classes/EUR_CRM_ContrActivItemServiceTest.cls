@IsTest(IsParallel = true)
private class EUR_CRM_ContrActivItemServiceTest {

	@TestSetup
	private static void setup() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract');
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT('EUR_GB_Mechanic_Type', 'Lump Sum');
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Contract__c = contract.Id;
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;
		cai.EUR_CRM_Amount__c = 10;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		insert cpi;
	}

	@IsTest
	private static void deleteCpiForLumpSumCai_Positive() {
		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCais();
		cais[0].EUR_CRM_Amount__c = 0;

		Test.startTest();
		update cais[0];
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCpis();
		System.assertEquals(true, cpis.isEmpty());
	}

	private static List<EUR_CRM_Contract_Product_Item__c> selectCpis() {
		return [SELECT Id FROM EUR_CRM_Contract_Product_Item__c];
	}

	private static List<EUR_CRM_Contract_Activity_Item__c> selectCais() {
		return [SELECT Id, EUR_CRM_Amount__c FROM EUR_CRM_Contract_Activity_Item__c];
	}

	@IsTest
	private static void deleteCpiForLumpSumCai_Negative() {
		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCais();
		cais[0].EUR_CRM_Amount__c = 11;

		Test.startTest();
		update cais[0];
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCpis();
		System.assertEquals(false, cpis.isEmpty());
	}

	@IsTest
	private static void EUR_CRM_ContrActivItemTriggerHandler_test() {
		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCais();
		delete cais;
		undelete cais;

	}





	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			EUR_CRM_Postal_Code__c = '112233'
		,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract__c makeContract(Id accId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract__c(
			RecordTypeId = rtId,
			EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_Mechanic_Type__c makeMT(String rt, String mtName) {
		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Mechanic_Type__c(
			RecordTypeId = rtId
		,	Name = mtName
		);
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id contrId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Activity_Item__c(
			RecordTypeId = rtId,
			EUR_CRM_Contract__c = contrId
		);
	}

	private static EUR_CRM_Contract_Product_Item__c makeCPI(Id caiId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Product_Item__c(
			RecordTypeId = rtId,
			EUR_CRM_Contract_Activity_Item__c = caiId
		);
	}

}