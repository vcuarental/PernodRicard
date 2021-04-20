@IsTest
private class EUR_CRM_PriceAuditItemsDuplicateCleanTst {
	private static final String MOBILE_ID_1 = 'Mobile_Id_1';
	private static final String MOBILE_ID_2 = 'Mobile_Id_2';

	//Acc RTs
	private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM';

	//PA RTs
	private static final String EUR_RU_OFF_TRADE_PRICE_AUDIT = 'EUR_RU_Off_Trade_Price_Audit';

	//PAI RTs
	private static final String EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM = 'EUR_RU_Off_Trade_Price_Audit_Item';

	private static final String BAD_RECORD_TYPE_DEV_NAME = 'Bad_Record_Type_Dev_Name';

	//Schedule tests
	@IsTest
	private static void scheduleCleanSAIsWhereRtDevNameAndDates_Test() {
		Test.startTest();
		String cronExpr = '0 0 1 * * ?';
		Set<String> rtDevName = new Set<String>{EUR_RU_OFF_TRADE_PRICE_AUDIT};
		String cronJobId = EUR_CRM_PriceAuditItemsDuplicateClean.scheduleCleanRecordsWhereRtDevNameAndDates(cronExpr, rtDevName, null, null, 200);
		Test.stopTest();


		List<CronTrigger> cronTriggers = selectCronTriggers(cronJobId);
		System.assertEquals(1, selectCronTriggers(cronJobId).size());

		System.assertEquals('0 0 1 * * ?', cronTriggers[0].CronExpression);
		System.assertEquals(1, cronTriggers[0].NextFireTime.hour());
		System.assertEquals(0, cronTriggers[0].NextFireTime.minute());
		System.assert(cronTriggers[0].CronJobDetail.Name.containsIgnoreCase(EUR_CRM_PriceAuditItemsDuplicateClean.EUR_CRM_PRICE_AUDIT_ITEMS_DUPLICATE_CLEAN));

		EUR_CRM_PriceAuditItemsDuplicateClean.removeSchedules();
		System.assertEquals(0, selectCronTriggers(cronJobId).size());
	}

	@IsTest
	private static void buildPaisQuery_NoRtParameter() {
		Set<String> rtDevNames = new Set<String>();
		String query = new EUR_CRM_PriceAuditItemsDuplicateClean().buildPaisQuery(null, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildPaisQuery_OneParameter() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT };
		String query = new EUR_CRM_PriceAuditItemsDuplicateClean().buildPaisQuery(rtDevNames, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('EUR_CRM_Price_Audit__r.CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('EUR_CRM_Price_Audit__r.CreatedDate <= :endDatetime'));
	}

	@IsTest
	private static void buildPaisQuery_TwoParameters() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		String query = new EUR_CRM_PriceAuditItemsDuplicateClean().buildPaisQuery(rtDevNames, startDt, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('EUR_CRM_Price_Audit__r.CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('EUR_CRM_Price_Audit__r.CreatedDate <= :endDatetime'));
	}

	@IsTest
	private static void buildPaisQuery_ThreeParameters() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		Datetime endDt = Datetime.newInstance(2020, 03, 01);
		String query = new EUR_CRM_PriceAuditItemsDuplicateClean().buildPaisQuery(rtDevNames, startDt, endDt);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('EUR_CRM_Price_Audit__r.CreatedDate >= :startDatetime'));
		System.assert(query.contains('EUR_CRM_Price_Audit__r.CreatedDate <= :endDatetime'));
	}


	//Integration tests
	@IsTest
	private static void cleanPAIsWhereRtDevName_onePAwithSeveraPAIsDuplicates_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Price_Audit__c pa = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, account.Id);
		insert pa;

		EUR_CRM_Brand__c b = makeB('B_ExtId');
		insert b;
		EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_ExtId');
		insert bq;
		EUR_CRM_Size__c bqs1 = makeBQS(bq, 10);
		EUR_CRM_Size__c bqs2 = makeBQS(bq, 20);
		insert new List<EUR_CRM_Size__c>{bqs1, bqs2};

		EUR_CRM_Price_Audit_Item__c pai1 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		EUR_CRM_Price_Audit_Item__c pai2 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		EUR_CRM_Price_Audit_Item__c pai3 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		EUR_CRM_Price_Audit_Item__c pai4 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		pai1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		pai2.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		pai3.EUR_CRM_Brand_Quality_Size__c = bqs2.Id;
		pai4.EUR_CRM_Brand_Quality_Size__c = bqs2.Id;
		insert new List<EUR_CRM_Price_Audit_Item__c>{ pai1, pai2, pai3, pai4 };

		//Assertion before
		List<EUR_CRM_Price_Audit_Item__c> paisBefore = selectPais();
		System.assertEquals(4, paisBefore.size());

		Test.startTest();
		EUR_CRM_PriceAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM });
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Price_Audit_Item__c> paisAfter = selectPais();
		System.assertEquals(2, paisAfter.size());
		System.assertEquals(bqs1.Id, paisAfter[0].EUR_CRM_Brand_Quality_Size__c);
		System.assertEquals(bqs2.Id, paisAfter[1].EUR_CRM_Brand_Quality_Size__c);
	}

	@IsTest
	private static void cleanPAIsWhereRtDevName_onePAwithSeveralPAIsDuplicates_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Price_Audit__c pa = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, account.Id);
		insert pa;

		EUR_CRM_Price_Audit_Item__c pai1 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		EUR_CRM_Price_Audit_Item__c pai2 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		EUR_CRM_Price_Audit_Item__c pai3 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		EUR_CRM_Price_Audit_Item__c pai4 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa.Id);
		pai1.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pai2.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
		pai3.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
		pai4.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Price_Audit_Item__c>{ pai1, pai2, pai3, pai4 };

		//Assertion before
		List<EUR_CRM_Price_Audit_Item__c> paisBefore = selectPais();
		System.assertEquals(4, paisBefore.size());

		Test.startTest();
		EUR_CRM_PriceAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ }, 200);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Price_Audit_Item__c> paisAfter = selectPais();
		System.assertEquals(4, paisAfter.size());
	}

	@IsTest
	private static void cleanPAIsWhereRtDevNameAndDates_twoPAwithSeveralPAIsDuplicates_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Price_Audit__c pa1 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, account.Id);
		EUR_CRM_Price_Audit__c pa2 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, account.Id);
		insert new List<EUR_CRM_Price_Audit__c>{ pa1, pa2 };

		EUR_CRM_Brand__c b = makeB('B_ExtId');
		insert b;
		EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_ExtId');
		insert bq;
		EUR_CRM_Size__c bqs1 = makeBQS(bq, 10);
		EUR_CRM_Size__c bqs2 = makeBQS(bq, 20);
		insert new List<EUR_CRM_Size__c>{bqs1, bqs2};

		EUR_CRM_Price_Audit_Item__c pai11 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		EUR_CRM_Price_Audit_Item__c pai12 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		EUR_CRM_Price_Audit_Item__c pai13 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		EUR_CRM_Price_Audit_Item__c pai14 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		pai11.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		pai11.EUR_CRM_Retail_Sales_Price__c = 100.00;

		pai12.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;

		pai13.EUR_CRM_Brand_Quality_Size__c = bqs2.Id;
		pai13.EUR_CRM_Retail_Sales_Price__c = 200.00;

		pai14.EUR_CRM_Brand_Quality_Size__c = bqs2.Id;

		EUR_CRM_Price_Audit_Item__c pai21 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		EUR_CRM_Price_Audit_Item__c pai22 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		EUR_CRM_Price_Audit_Item__c pai23 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		EUR_CRM_Price_Audit_Item__c pai24 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		pai21.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		pai21.EUR_CRM_Retail_Sales_Price__c = 100.00;

		pai22.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;

		pai23.EUR_CRM_Brand_Quality_Size__c = bqs2.Id;
		pai23.EUR_CRM_Retail_Sales_Price__c = 200.00;

		pai24.EUR_CRM_Brand_Quality_Size__c = bqs2.Id;

		insert new List<EUR_CRM_Price_Audit_Item__c>{ pai11, pai12, pai13, pai14, pai21, pai22, pai23, pai24 };

		//Assertion before
		List<EUR_CRM_Price_Audit_Item__c> paisBefore = selectPais();
		System.assertEquals(8, paisBefore.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-1);
		Datetime endDt = Datetime.now().addMinutes(1);
		EUR_CRM_PriceAuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
			new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM }, startDt, endDt
		);
		Test.stopTest();

		List<EUR_CRM_Price_Audit__c> pas = selectPas();
		System.assertEquals(2, pas.size());
		for (EUR_CRM_Price_Audit__c pa : pas) {
			System.assertEquals(2, pa.Price_Check_Item_EU__r.size());
			System.assertEquals(bqs1.Id, pa.Price_Check_Item_EU__r[0].EUR_CRM_Brand_Quality_Size__c);
			System.assertEquals(100.00, pa.Price_Check_Item_EU__r[0].EUR_CRM_Retail_Sales_Price__c);
			System.assertEquals(bqs2.Id, pa.Price_Check_Item_EU__r[1].EUR_CRM_Brand_Quality_Size__c);
			System.assertEquals(200.00, pa.Price_Check_Item_EU__r[1].EUR_CRM_Retail_Sales_Price__c);
		}
	}

	@IsTest
	private static void cleanPAIsWhereRtDevNameAndDates_twoPAwithSeveralPAIsDuplicates_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Price_Audit__c pa1 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, account.Id);
		EUR_CRM_Price_Audit__c pa2 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, account.Id);
		insert new List<EUR_CRM_Price_Audit__c>{ pa1, pa2 };

		EUR_CRM_Price_Audit_Item__c pai11 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		EUR_CRM_Price_Audit_Item__c pai12 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		EUR_CRM_Price_Audit_Item__c pai13 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		EUR_CRM_Price_Audit_Item__c pai14 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		pai11.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pai12.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pai13.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
		pai14.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;

		EUR_CRM_Price_Audit_Item__c pai21 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		EUR_CRM_Price_Audit_Item__c pai22 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		EUR_CRM_Price_Audit_Item__c pai23 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		EUR_CRM_Price_Audit_Item__c pai24 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		pai21.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pai22.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pai23.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
		pai24.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;


		insert new List<EUR_CRM_Price_Audit_Item__c>{ pai11, pai12, pai13, pai14, pai21, pai22, pai23, pai24 };

		//Assertion before
		List<EUR_CRM_Price_Audit_Item__c> paisBefore = selectPais();
		System.assertEquals(8, paisBefore.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-1);
		Datetime endDt = Datetime.now().addMinutes(1);
		EUR_CRM_PriceAuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
			new Set<String>{ BAD_RECORD_TYPE_DEV_NAME }, startDt, endDt, 200
		);
		Test.stopTest();

		List<EUR_CRM_Price_Audit__c> pas = selectPas();
		System.assertEquals(2, pas.size());
		for (EUR_CRM_Price_Audit__c pa : pas) {
			System.assertEquals(4, pa.Price_Check_Item_EU__r.size());
		}
	}



	//Makers
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			Name = 'Test Name'
			,   EUR_CRM_Postal_Code__c = '1122'
			,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Price_Audit__c makePA(String rt, Id accId) {
		Id rtId = SObjectType.EUR_CRM_Price_Audit__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Price_Audit__c(
			RecordTypeId = rtId
		,   EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_Price_Audit_Item__c makePAI(String rt, Id paId) {
		Id rtId = SObjectType.EUR_CRM_Price_Audit_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Price_Audit_Item__c(
			RecordTypeId = rtId
		,   EUR_CRM_Price_Audit__c = paId
		);
	}

	private static EUR_CRM_Brand__c makeB(String extId) {
		return new EUR_CRM_Brand__c(
			EUR_CRM_External_ID__c = extId
		);
	}

	private static EUR_CRM_Quality__c makeBQ(Id bId, String extId) {
		return new EUR_CRM_Quality__c(
			EUR_CRM_Brand__c = bId
			,	EUR_CRM_External_ID__c = extId
		);
	}

	private static EUR_CRM_Size__c makeBQS(EUR_CRM_Quality__c bq, Decimal bottleSizeCl) {
		return new EUR_CRM_Size__c(
			EUR_CRM_Brand_Quality__c = bq.Id
			,	EUR_CRM_Bottle_Size_cl__c = bottleSizeCl
			,	EUR_CRM_External_ID__c = bq.EUR_CRM_External_ID__c + '_' + Integer.valueOf(bottleSizeCl)
			,   EUR_CRM_Price_Check__c = true
		);
	}


	//Selectors
	private static List<CronTrigger> selectCronTriggers(String cronJobId) {
		return [
			SELECT Id
				,   CronJobDetail.Name
				,   CronExpression
				,   NextFireTime
			FROM CronTrigger
			WHERE Id = :cronJobId
		];
	}

	private static List<EUR_CRM_Price_Audit_Item__c> selectPais() {
		return [
			SELECT Id
			,   EUR_CRM_Brand_Quality_Size__c
			,   EUR_CRM_Mobile_Id__c
			,   EUR_CRM_Retail_Sales_Price__c
			FROM EUR_CRM_Price_Audit_Item__c
		];
	}

	private static List<EUR_CRM_Price_Audit__c> selectPas() {
		return [
			SELECT Id
			,   (
				SELECT Id
				,   EUR_CRM_Brand_Quality_Size__c
				,   EUR_CRM_Retail_Sales_Price__c
				FROM Price_Check_Item_EU__r
				ORDER BY EUR_CRM_Brand_Quality_Size__c ASC
			)
			FROM EUR_CRM_Price_Audit__c
		];
	}

}