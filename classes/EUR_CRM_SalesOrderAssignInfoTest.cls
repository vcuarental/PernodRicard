@IsTest
private class EUR_CRM_SalesOrderAssignInfoTest {

	private static final String CLASS_NAME = 'EUR_CRM_SalesOrderAssignInfo';

	private static final Set<String> SO_RT_TO_UPDATE_KEY_DISTRIBUTOR = new Set<String>{
		'EUR_NG_On_Trade_Reminder',
		'EUR_RU_On_Trade_Sales_Order'
	};

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest
			.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'SO_RT_TO_UPDATE_KEY_DISTRIBUTOR', SO_RT_TO_UPDATE_KEY_DISTRIBUTOR));
	}

	@IsTest
	private static void onBeforeInsert_soWith_EUR_NG_On_Trade_Reminder_recType_positiveTest() {
		initCMT();

		User u = makeUser('standarduser@testorg.com');
		insert u;

		EUR_CRM_Region__c region = makeRegion('Test Region');
		region.EUR_CRM_Channel__c = 'ON TRADE';
		insert region;

		EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'Test Territory');
		territory.EUR_CRM_KD_Owner__c = u.Id;
		insert territory;

		EUR_CRM_Account__c acc = makeAccount('EUR_NG_On_Trade');
		acc.EUR_CRM_Territory__c = territory.Id;
		acc.EUR_CRM_Channel__c = 'ON TRADE';
		insert acc;

		Test.startTest();
		EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_NG_On_Trade_Reminder');
		insert so;
		Test.stopTest();
		List<EUR_CRM_Sales_Order__c> sos = selectSalesOrders();
		System.assertEquals(1, sos.size());
		System.assertEquals(u.Id, sos[0].EUR_CRM_Key_Distributor_Sales_Rep__c);
		System.assertEquals('standarduser@testorg.com', sos[0].EUR_CRM_Key_Distributor_Sales_Rep_Email__c);
	}

//	@IsTest
//	private static void onBeforeInsert_soWith_EUR_RU_On_Trade_Sales_Order_recType_positiveTest() {
//		initCMT();
//
//		User u = makeUser('standarduser@testorg.com');
//		insert u;
//
//		EUR_CRM_Region__c region = makeRegion('Test Region');
//		region.EUR_CRM_Channel__c = 'ON TRADE';
//		insert region;
//
//		EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'Test Territory');
//		territory.EUR_CRM_KD_Owner__c = u.Id;
//		insert territory;
//
////		EUR_CRM_Account__c acc = makeAccount('EUR_RU_On_Trade');
//		EUR_CRM_Account__c acc = makeAccount('EUR_RU_Distributor');
//		acc.EUR_CRM_Territory__c = territory.Id;
//		acc.EUR_CRM_Channel__c = 'Independent';
//		System.debug('\n acc => ' + JSON.serializePretty(acc) + '\n');
//		insert acc;
//
//		Test.startTest();
//		EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_RU_On_Trade_Sales_Order');
//		insert so;
//		Test.stopTest();
//		List<EUR_CRM_Sales_Order__c> sos = selectSalesOrders();
//		System.assertEquals(1, sos.size());
//		System.assertEquals(u.Id, sos[0].EUR_CRM_Key_Distributor_Sales_Rep__c);
//		System.assertEquals('standarduser@testorg.com', sos[0].EUR_CRM_Key_Distributor_Sales_Rep_Email__c);
//	}

	@IsTest
	private static void onBeforeInsert_negativeTest() {
		initCMT();

		User u = makeUser('standarduser@testorg.com');
		insert u;

		EUR_CRM_Region__c region = makeRegion('Test Region');
		region.EUR_CRM_Channel__c = 'OFF TRADE';
		insert region;

		EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'Test Territory');
		territory.EUR_CRM_KD_Owner__c = u.Id;
		insert territory;

		EUR_CRM_Account__c acc = makeAccount('EUR_NG_Off_Trade_Bulk_Breaker');
		acc.EUR_CRM_Territory__c = territory.Id;
		acc.EUR_CRM_Channel__c = 'OFF TRADE';
		insert acc;

		Test.startTest();
		EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_NG_Off_Trade_Bulk_Breaker_Sales_Order');
		insert so;
		Test.stopTest();
		List<EUR_CRM_Sales_Order__c> sos = selectSalesOrders();
		System.assertEquals(1, sos.size());
		System.assertEquals(null, sos[0].EUR_CRM_Key_Distributor_Sales_Rep__c);
		System.assertEquals(null, sos[0].EUR_CRM_Key_Distributor_Sales_Rep_Email__c);
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			Name = 'Account'
		,   EUR_CRM_Postal_Code__c = '12345'
		,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Sales_Order__c makeSalesOrder(Id accId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Sales_Order__c(
			EUR_CRM_Account__c = accId
		,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Region__c makeRegion(String name) {
		return new EUR_CRM_Region__c(
			Name = name
		,   EUR_CRM_Region_Owner__c = UserInfo.getUserId()
		);
	}

	private static EUR_CRM_Territory__c makeTerritory(Id regionId, String name) {
		return new EUR_CRM_Territory__c(
			EUR_CRM_Region__c = regionId
		,   Name = name
		);
	}

	private static User makeUser(String email) {
		String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
		Profile p = [SELECT Id FROM Profile WHERE Name = 'EUR System Admin'];
		return new User(
			Alias = 'standt'
		,   Email = email
		,   EmailEncodingKey = 'UTF-8'
		,   LastName = 'Testing'
		,   LanguageLocaleKey = 'en_US'
		,   LocaleSidKey = 'en_US'
		,   ProfileId = p.Id
		,   TimeZoneSidKey = 'America/Los_Angeles'
		,   Username = uniqueUserName
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Sales_Order__c> selectSalesOrders() {
		return [
			SELECT Id
			,	RecordTypeId
			,	EUR_CRM_Key_Distributor_Sales_Rep__c
			,	EUR_CRM_Key_Distributor_Sales_Rep_Email__c
			FROM EUR_CRM_Sales_Order__c
		];
	}
}