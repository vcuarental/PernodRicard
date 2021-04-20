@IsTest(IsParallel = true)
private class EUR_CRM_CAIbeforeInsertServiceTest {

	private static final String CAI_DE_RT = 'EUR_DE_Contract_Activity_Item';
	private static final String CAI_NL_RT = 'EUR_NL_Contract_Activity_Item';
	private static final Integer COUNT_OF_RECORDS = 5;


	/* ========================================================= */
	/*      Positive Tests
	/* ========================================================= */
	@IsTest
	static void validRT_MTexist_NameIsNull_Test() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = new EUR_CRM_Mechanic_Type__c();
		mt.Name = 'Pouring Refund';
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(CAI_DE_RT);
		cai.EUR_CRM_Contract__c = contract.Id;
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;

		Test.startTest();
		insert cai;
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAI();
		System.assertEquals(1, cais.size());
		System.assert(cais[0].EUR_CRM_Name__c.contains('Pouring Refund'));
	}


	/* ========================================================= */
	/*      Negative Tests
	/* ========================================================= */
	@IsTest
	static void validRT_MTexist_NameIsNotNull_Test() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = new EUR_CRM_Mechanic_Type__c();
		mt.Name = 'Pouring Refund';
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(CAI_DE_RT);
		cai.EUR_CRM_Contract__c = contract.Id;
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;
		cai.EUR_CRM_Name__c = 'TestName';

		Test.startTest();
		insert cai;
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAI();
		System.assertEquals(1, cais.size());
		System.assertEquals('TestName', cais[0].EUR_CRM_Name__c);
	}

	@IsTest
	static void invalidRT_MTexist_NameIsNull_Test() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = new EUR_CRM_Mechanic_Type__c();
		mt.Name = 'Pouring Refund';
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(CAI_NL_RT);
		cai.EUR_CRM_Contract__c = contract.Id;
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;

		Test.startTest();
		insert cai;
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAI();
		System.assertEquals(1, cais.size());
		System.assertEquals(null, cais[0].EUR_CRM_Name__c);
	}

	@IsTest
	static void validRT_MTisNull_NameIsNull_Test() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(CAI_DE_RT);
		cai.EUR_CRM_Contract__c = contract.Id;

		Test.startTest();
		insert cai;
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAI();
		System.assertEquals(1, cais.size());
		System.assertEquals(null, cais[0].EUR_CRM_Name__c);
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount() {
		return new EUR_CRM_Account__c(
			EUR_CRM_Postal_Code__c = '112233'
		);
	}

	private static EUR_CRM_Contract__c makeContract() {
		return new EUR_CRM_Contract__c();
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAI(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Activity_Item__c(
			RecordTypeId = rtId
		);
	}

	private static List<EUR_CRM_Contract_Activity_Item__c> makeCAIs(EUR_CRM_Contract__c contract, String rt) {
		List<EUR_CRM_Contract_Activity_Item__c> cais = new List<EUR_CRM_Contract_Activity_Item__c>();
		for (Integer i; i < COUNT_OF_RECORDS; i++) {
			EUR_CRM_Contract_Activity_Item__c cai = makeCAI(rt);
			cai.EUR_CRM_Contract__c = contract.Id;
			cais.add(cai);
		}
		return cais;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Contract_Activity_Item__c> selectCAI() {
		return [
			SELECT Id
				, EUR_CRM_Mechanic_Type__c
				, EUR_CRM_Mechanic_Type_Name__c
				, EUR_CRM_Mechanic_Type__r.Name
				, EUR_CRM_Name__c
			FROM EUR_CRM_Contract_Activity_Item__c
		];
	}
}