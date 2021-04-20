@IsTest(IsParallel = true)
private class EUR_CRM_SalesOrderAssignManagerTest {

	private static final Set<String> SO_RT_TO_UPDATE_MANAGER = new Set<String>{
		'EUR_ZA_Direct_Sales_Order',
		'EUR_ZA_Free_Goods_Order',
		'EUR_CH_Direct_Sales_Order',
		'EUR_CH_Indirect_Sales_Order',
		'EUR_DK_Free_Goods_Order_to_Customer'
	};

	@IsTest
	private static void simplePositiveTest() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_SalesOrderAssignManager', 'SO_RT_TO_UPDATE_MANAGER', SO_RT_TO_UPDATE_MANAGER));

		EUR_CRM_Account__c account = makeAccount();
		insert account;

		Test.startTest();
		EUR_CRM_Sales_Order__c so = makeSalesOrder(account.Id, 'EUR_ZA_Direct_Sales_Order', 'On hold');
		insert so;
		Test.stopTest();

		User u = [SELECT Id, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
		System.assertEquals(u.ManagerId, selectSOs()[0].EUR_CRM_Manager__c);
	}

	@IsTest
	private static void simpleNegativeTest() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_SalesOrderAssignManager', 'SO_RT_TO_UPDATE_MANAGER', SO_RT_TO_UPDATE_MANAGER));

		EUR_CRM_Account__c account = makeAccount();
		insert account;

		Test.startTest();
		EUR_CRM_Sales_Order__c so = makeSalesOrder(account.Id, 'EUR_AO_Direct_Sales_Order', 'On hold');
		insert so;
		Test.stopTest();

		System.assertEquals(null, selectSOs()[0].EUR_CRM_Manager__c);
	}


	/* ========================================================= */
	/*     Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount() {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_ZA_On_Trade_Direct').getRecordTypeId();
		return new EUR_CRM_Account__c(
			Name = 'Test Account'
		,   EUR_CRM_Postal_Code__c = '112233'
		,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Sales_Order__c makeSalesOrder(Id accId, String rt, String status) {
		Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Sales_Order__c(
			EUR_CRM_Account__c = accId
		,   RecordTypeId = rtId
		,   EUR_CRM_Status__c = status
		);
	}


	/* ========================================================= */
	/*     SOQL Wrappers
	/* ========================================================= */
	private static List<EUR_CRM_Sales_Order__c> selectSOs() {
		return [
			SELECT Id
			,	EUR_CRM_Manager__c
			FROM EUR_CRM_Sales_Order__c
		];
	}

}