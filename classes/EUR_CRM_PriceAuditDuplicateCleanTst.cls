@IsTest
private class EUR_CRM_PriceAuditDuplicateCleanTst {
	private static final String MOBILE_ID_1 = 'Mobile_Id_1';
	private static final String MOBILE_ID_2 = 'Mobile_Id_2';

	//Account RTs
	private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM';

	//Visit RTs
	private static final String EUR_RU_OFF_TRADE_VISIT = 'EUR_RU_Off_Trade_Visit';

	//Price Audit RTs
	private static final String EUR_RU_OFF_TRADE_PRICE_AUDIT = 'EUR_RU_Off_Trade_Price_Audit';

	//Price Audit Item RTs
	private static final String EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM = 'EUR_RU_Off_Trade_Price_Audit_Item';

	//Schedule tests
	@IsTest
	private static void scheduleCleanSAIsWhereRtDevNameAndDates_Test() {
		Test.startTest();
		String cronExpr = '0 0 1 * * ?';
		Set<String> rtDevName = new Set<String>{'EUR_RU_On_Trade_Store_Audit_Item'};
		String cronJobId = EUR_CRM_PriceAuditDuplicateClean.scheduleCleanRecordsWhereRtDevNameAndDates(cronExpr, rtDevName, null, null, 200);
		Test.stopTest();


		List<CronTrigger> cronTriggers = selectCronTriggers(cronJobId);
		System.assertEquals(1, selectCronTriggers(cronJobId).size());

		System.assertEquals('0 0 1 * * ?', cronTriggers[0].CronExpression);
		System.assertEquals(1, cronTriggers[0].NextFireTime.hour());
		System.assertEquals(0, cronTriggers[0].NextFireTime.minute());
		System.assert(cronTriggers[0].CronJobDetail.Name.containsIgnoreCase(EUR_CRM_PriceAuditDuplicateClean.EUR_CRM_PRICE_AUDIT_DUPLICATE_CLEAN));

		EUR_CRM_PriceAuditDuplicateClean.removeSchedules();
		System.assertEquals(0, selectCronTriggers(cronJobId).size());
	}

	//Unit tests
	@IsTest
	private static void buildSaisQuery_NoRtParameter() {
		Set<String> rtDevNames = new Set<String>();
		String query = new EUR_CRM_PriceAuditDuplicateClean().buildPasQuery(null, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_OneParameter() {
		Set<String> rtDevNames = new Set<String>{EUR_RU_OFF_TRADE_PRICE_AUDIT};
		String query = new EUR_CRM_PriceAuditDuplicateClean().buildPasQuery(rtDevNames, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_TwoParameters() {
		Set<String> rtDevNames = new Set<String>{EUR_RU_OFF_TRADE_PRICE_AUDIT};
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		String query = new EUR_CRM_PriceAuditDuplicateClean().buildPasQuery(rtDevNames, startDt, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_ThreeParameters() {
		Set<String> rtDevNames = new Set<String>{EUR_RU_OFF_TRADE_PRICE_AUDIT};
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		Datetime endDt = Datetime.newInstance(2020, 03, 01);
		String query = new EUR_CRM_PriceAuditDuplicateClean().buildPasQuery(rtDevNames, startDt, endDt);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert(query.contains('CreatedDate < :endDatetime'));
	}

	//Integration tests
	@IsTest
	private static void cleanPAsWhereRtDevName_1VisitWithSeveralPAsDuplicates_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_OFF_TRADE_VISIT);
		insert visit;

		EUR_CRM_Price_Audit__c pa1 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa2 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa3 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa4 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		pa1.EUR_CRM_Visit__c = visit.Id;
		pa2.EUR_CRM_Visit__c = visit.Id;
		pa3.EUR_CRM_Visit__c = visit.Id;
		pa4.EUR_CRM_Visit__c = visit.Id;

		pa1.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pa2.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pa3.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
		pa4.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Price_Audit__c>{ pa1, pa2, pa3, pa4 };

		//Assetion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Price_Check_EU__r.size());

		Test.startTest();
		EUR_CRM_PriceAuditDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT });
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');

		//Assertion after
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(2, visitsAfter[0].Price_Check_EU__r.size());
		for (EUR_CRM_Visit__c v : visitsAfter) {
			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[0].EUR_CRM_Mobile_Id__c);
			System.assertEquals(MOBILE_ID_2, v.Price_Check_EU__r[1].EUR_CRM_Mobile_Id__c);
		}
	}

	@IsTest
	private static void cleanPAsWhereRtDevName_1eVisitWithSeveralPAsDuplicates_NoMobileId_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_OFF_TRADE_VISIT);
		insert visit;

		EUR_CRM_Price_Audit__c pa1 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa2 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa3 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa4 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		pa1.EUR_CRM_Visit__c = visit.Id;
		pa2.EUR_CRM_Visit__c = visit.Id;
		pa3.EUR_CRM_Visit__c = visit.Id;
		pa4.EUR_CRM_Visit__c = visit.Id;

		pa1.EUR_CRM_Mobile_Id__c = null;
		pa2.EUR_CRM_Mobile_Id__c = null;
		pa3.EUR_CRM_Mobile_Id__c = null;
		pa4.EUR_CRM_Mobile_Id__c = null;
		insert new List<EUR_CRM_Price_Audit__c>{ pa1, pa2, pa3, pa4 };

		//Assetion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Price_Check_EU__r.size());

		Test.startTest();
		EUR_CRM_PriceAuditDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT });
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');

		//Assertion after
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(4, visitsAfter[0].Price_Check_EU__r.size());
//		for (EUR_CRM_Visit__c v : visitsAfter) {
//			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[0].EUR_CRM_Mobile_Id__c);
//			System.assertEquals(MOBILE_ID_2, v.Price_Check_EU__r[1].EUR_CRM_Mobile_Id__c);
//		}
	}

	@IsTest
	private static void cleanPAsWhereRtDevName_1VisitWwithSeveralPAsDuplicates_2PAhasChildren_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_OFF_TRADE_VISIT);
		insert visit;

		EUR_CRM_Price_Audit__c pa1 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa2 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		pa1.EUR_CRM_Visit__c = visit.Id;
		pa2.EUR_CRM_Visit__c = visit.Id;

		pa1.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pa2.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Price_Audit__c>{ pa1, pa2 };

		EUR_CRM_Price_Audit_Item__c pai11 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
		EUR_CRM_Price_Audit_Item__c pai21 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		insert new List<EUR_CRM_Price_Audit_Item__c>{ pai11, pai21 };

		//Assetion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(2, visitsBefore[0].Price_Check_EU__r.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-1);
		Datetime endDt = Datetime.now().addMinutes(1);
		EUR_CRM_PriceAuditDuplicateClean.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT },startDt, endDt);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');

		//Assertion after
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(2, visitsAfter[0].Price_Check_EU__r.size());
		for (EUR_CRM_Visit__c v : visitsAfter) {
			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[0].EUR_CRM_Mobile_Id__c);
			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[1].EUR_CRM_Mobile_Id__c);
		}
	}

	@IsTest
	private static void cleanPAsWhereRtDevName_1VisitWithSeveralPAsDuplicates_1PAhasChildren_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_OFF_TRADE_VISIT);
		insert visit;

		EUR_CRM_Price_Audit__c pa1 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa2 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		pa1.EUR_CRM_Visit__c = visit.Id;
		pa2.EUR_CRM_Visit__c = visit.Id;

		pa1.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pa2.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Price_Audit__c>{ pa1, pa2 };

		EUR_CRM_Price_Audit_Item__c pai11 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa1.Id);
//		EUR_CRM_Price_Audit_Item__c pai21 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa2.Id);
		insert new List<EUR_CRM_Price_Audit_Item__c>{ pai11 };

		//Assetion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(2, visitsBefore[0].Price_Check_EU__r.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-1);
		Datetime endDt = Datetime.now().addMinutes(1);
		EUR_CRM_PriceAuditDuplicateClean.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT }, startDt, endDt, 100);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');

//		List<EUR_CRM_Price_Audit__c> pasAfter = selectPas();
		//Assertion after
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Price_Check_EU__r.size());
		System.assertEquals(pa1.Id, visitsAfter[0].Price_Check_EU__r[0].Id);
//		System.assertEquals(1, pasAfter.size());
//		System.assertEquals(1, pasAfter[0].Price_Check_Item_EU__r.size());
//		for (EUR_CRM_Visit__c v : visitsAfter) {
//			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[0].EUR_CRM_Mobile_Id__c);
//			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[1].EUR_CRM_Mobile_Id__c);
//		}
	}

	@IsTest
	private static void cleanPAsWhereRtDevName_2VisitsWithSeveralPAsDuplicates_1PAhasChildren_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit1 = makeVisit(acc.Id, EUR_RU_OFF_TRADE_VISIT);
		EUR_CRM_Visit__c visit2 = makeVisit(acc.Id, EUR_RU_OFF_TRADE_VISIT);
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Price_Audit__c pa11 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa12 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		pa11.EUR_CRM_Visit__c = visit1.Id;
		pa12.EUR_CRM_Visit__c = visit1.Id;
		pa11.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pa12.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;

		EUR_CRM_Price_Audit__c pa21 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		EUR_CRM_Price_Audit__c pa22 = makePA(EUR_RU_OFF_TRADE_PRICE_AUDIT, acc.Id);
		pa21.EUR_CRM_Visit__c = visit2.Id;
		pa22.EUR_CRM_Visit__c = visit2.Id;
		pa21.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
		pa22.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;

		insert new List<EUR_CRM_Price_Audit__c>{ pa11, pa12, pa21, pa22 };

		EUR_CRM_Price_Audit_Item__c pai11 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa11.Id);
		EUR_CRM_Price_Audit_Item__c pai21 = makePAI(EUR_RU_OFF_TRADE_PRICE_AUDIT_ITEM, pa21.Id);
		insert new List<EUR_CRM_Price_Audit_Item__c>{ pai11, pai21 };

		//Assetion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());
		System.assertEquals(2, visitsBefore[0].Price_Check_EU__r.size());
		System.assertEquals(2, visitsBefore[1].Price_Check_EU__r.size());

		Test.startTest();
		EUR_CRM_PriceAuditDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_PRICE_AUDIT }, 100);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');

//		List<EUR_CRM_Price_Audit__c> pasAfter = selectPas();
		//Assertion after
		System.assertEquals(2, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Price_Check_EU__r.size());
		System.assertEquals(1, visitsAfter[1].Price_Check_EU__r.size());
		System.assertEquals(pa11.Id, visitsAfter[0].Price_Check_EU__r[0].Id);
		System.assertEquals(pa21.Id, visitsAfter[1].Price_Check_EU__r[0].Id);
//		System.assertEquals(1, pasAfter.size());
//		System.assertEquals(1, pasAfter[0].Price_Check_Item_EU__r.size());
//		for (EUR_CRM_Visit__c v : visitsAfter) {
//			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[0].EUR_CRM_Mobile_Id__c);
//			System.assertEquals(MOBILE_ID_1, v.Price_Check_EU__r[1].EUR_CRM_Mobile_Id__c);
//		}
	}


	//Makers
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			Name = 'Test Name'
			,   EUR_CRM_Postal_Code__c = '1122'
			,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Visit__c makeVisit(Id accId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Visit__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Visit__c(
			EUR_CRM_Account__c = accId
			,   EUR_CRM_Start_Datetime__c = Datetime.now()
			,   EUR_CRM_End_Datetime__c = Datetime.now().addDays(1)
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

	//Selectors
	private static List<EUR_CRM_Visit__c> selectVisits() {
		return [
			SELECT Id
				,   (
				SELECT Id
				,   EUR_CRM_Mobile_Id__c
				FROM Price_Check_EU__r
				ORDER BY EUR_CRM_Mobile_Id__c ASC
			)
			FROM EUR_CRM_Visit__c
		];
	}

	private static List<EUR_CRM_Price_Audit__c> selectPas() {
		return [
			SELECT Id
				,   (
				SELECT Id
					,   EUR_CRM_Mobile_Id__c
				FROM Price_Check_Item_EU__r
				ORDER BY EUR_CRM_Mobile_Id__c ASC
			)
			FROM EUR_CRM_Price_Audit__c
		];
	}

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

}