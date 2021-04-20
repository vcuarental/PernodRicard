@IsTest(IsParallel = true)
private class EUR_CRM_SalesOrderUpdateInfoTest {

	private static final String CLASS_NAME = 'EUR_CRM_SalesOrderUpdateInfo';

	private static final Set<String> validCC_WholesalerEmail = new Set<String>{ 'BG' };
	private static final Set<String> validCC_KDEmailAddress = new Set<String>{ 'RU' };

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'validCC_WholesalerEmail', validCC_WholesalerEmail));
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'validCC_KDEmailAddress', validCC_KDEmailAddress));
	}

	@IsTest
	private static void beforeInsert_BGContract_positiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_BG_On_Trade');
		EUR_CRM_Account__c distributor = makeAccount('EUR_BG_On_Trade');
		distributor.EUR_CRM_Email__c = 'distributor@email.com';
		EUR_CRM_Account__c wholesaler = makeAccount('EUR_BG_On_Trade');
		wholesaler.EUR_CRM_Email__c = 'wholesaller@email.com';
		insert new List<EUR_CRM_Account__c>{ acc, distributor, wholesaler };

		Test.startTest();
		EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id);
		so.EUR_CRM_Distributor__c = distributor.Id;
		so.EUR_CRM_Wholesaler__c = wholesaler.Id;
		insert so;
		Test.stopTest();

		List<EUR_CRM_Sales_Order__c> insertedSOs = selectSalesOrders();
		System.assertEquals(1, insertedSOs.size());
		System.assertEquals('distributor@email.com', insertedSOs[0].EUR_CRM_Distributor_Email__c);
		System.assertEquals('wholesaller@email.com', insertedSOs[0].EUR_CRM_Wholesaler_Email__c);
	}

	@IsTest
	private static void beforeInsert_RUContract_positiveTest() {
		initCMT();

		insert createApexConfig('EUR_RU_Direct_Off_Trade');

		EUR_CRM_Account__c acc = makeAccount('EUR_RU_Direct_Off_Trade');
		EUR_CRM_Account__c distributor = makeAccount('EUR_RU_Direct_Off_Trade');
		distributor.EUR_CRM_Email__c = 'distributor@email.com';
		EUR_CRM_Account__c wholesaler = makeAccount('EUR_RU_Direct_Off_Trade');
		wholesaler.EUR_CRM_Email__c = 'wholesaller@email.com';
		insert new List<EUR_CRM_Account__c>{ acc, distributor, wholesaler };

		EUR_CRM_CISLink__c cisLink = makeCISLink();
		cisLink.EUR_CRM_Distributor_Account__c = distributor.Id;
		insert cisLink;

		Test.startTest();
		EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id);
//		so.EUR_CRM_Distributor__c = distributor.Id;
		so.EUR_CRM_Wholesaler__c = wholesaler.Id;
		so.EUR_CRM_CIS_Link__c = cisLink.Id;
		insert so;
		Test.stopTest();

		List<EUR_CRM_Sales_Order__c> insertedSOs = selectSalesOrders();
		System.assertEquals(1, insertedSOs.size());
		System.assertEquals('distributor@email.com', insertedSOs[0].EUR_CRM_Distributor_Email__c);
		System.assertEquals(null, insertedSOs[0].EUR_CRM_Wholesaler_Email__c);
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

	private static EUR_CRM_Sales_Order__c makeSalesOrder(Id accId) {
//		Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Sales_Order__c(
			EUR_CRM_Account__c = accId
//			,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_CISLink__c makeCISLink() {
		return new EUR_CRM_CISLink__c();
	}

	public static EUR_CRM_Apex_Configuration__c createApexConfig(String accRtDevName){
		return new EUR_CRM_Apex_Configuration__c(
			EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number'
		,	EUR_CRM_Country_Code__c ='RU'
		,	EUR_CRM_Account_RecordType_DevName__c = accRtDevName
		,	EUR_CRM_Prefix__c = 'f'
		);

	}

	private static User makeUser(String email) {
		String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		String userEmail = 'standarduser@testorg.com';
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
			,	EUR_CRM_Distributor_Email__c
			,	EUR_CRM_Wholesaler_Email__c
			,	EUR_CRM_KD_CS_Email__c
			FROM EUR_CRM_Sales_Order__c
		];
	}
}