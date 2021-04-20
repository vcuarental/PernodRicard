@IsTest
private class EUR_CRM_StoreAuditDuplicateCleanTest {

	private static final String MOBILE_ID_1 = 'Mobile_Id_1';
	private static final String MOBILE_ID_2 = 'Mobile_Id_2';

	//Account RTs
	private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM';

	//Visit RTs
	private static final String EUR_RU_ON_TRADE_VISIT = 'EUR_RU_On_Trade_Visit';

	//Store Audit RTs
	private static final String EUR_RU_ON_TRADE_STORE_AUDIT = 'EUR_RU_On_Trade_Store_Audit';
	private static final String EUR_RU_OFF_TRADE_STORE_AUDIT = 'EUR_RU_Off_Trade_Store_Audit';

	//Store Audit Item RTs
	private static final String EUR_RU_ON_TRADE_STORE_AUDIT_ITEM = 'EUR_RU_On_Trade_Store_Audit_Item';
	private static final String EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM = 'EUR_RU_Off_Trade_Store_Audit_Item';
	private static final String EUR_RU_OFF_TRADE_VISIT = 'EUR_RU_Off_Trade_Visit';

	//Schedule tests
	@IsTest
	private static void scheduleCleanSAIsWhereRtDevNameAndDates_Test() {
		Test.startTest();
		String cronExpr = '0 0 1 * * ?';
		Set<String> rtDevName = new Set<String>{'EUR_RU_On_Trade_Store_Audit_Item'};
		String cronJobId = EUR_CRM_StoreAuditDuplicateClean.scheduleCleanRecordsWhereRtDevNameAndDates(cronExpr, rtDevName, null, null, 200);
		Test.stopTest();


		List<CronTrigger> cronTriggers = selectCronTriggers(cronJobId);
		System.assertEquals(1, selectCronTriggers(cronJobId).size());

		System.assertEquals('0 0 1 * * ?', cronTriggers[0].CronExpression);
		System.assertEquals(1, cronTriggers[0].NextFireTime.hour());
		System.assertEquals(0, cronTriggers[0].NextFireTime.minute());
		System.assert(cronTriggers[0].CronJobDetail.Name.containsIgnoreCase(EUR_CRM_StoreAuditDuplicateClean.EUR_CRM_STORE_AUDIT_DUPLICATE_CLEAN));

		EUR_CRM_StoreAuditDuplicateClean.removeSchedules();
		System.assertEquals(0, selectCronTriggers(cronJobId).size());
	}

	//Unit tests
	@IsTest
	private static void buildSaisQuery_NoRtParameter() {
		Set<String> rtDevNames = new Set<String>();
		String query = new EUR_CRM_StoreAuditDuplicateClean().buildSaisQuery(null, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_OneParameter() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT };
		String query = new EUR_CRM_StoreAuditDuplicateClean().buildSaisQuery(rtDevNames, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_TwoParameters() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		String query = new EUR_CRM_StoreAuditDuplicateClean().buildSaisQuery(rtDevNames, startDt, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_ThreeParameters() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		Datetime endDt = Datetime.newInstance(2020, 03, 01);
		String query = new EUR_CRM_StoreAuditDuplicateClean().buildSaisQuery(rtDevNames, startDt, endDt);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert(query.contains('CreatedDate < :endDatetime'));
	}

	//Integration tests
	@IsTest
	private static void first_cleanSAsWhereRtDevName_oneVisitwithSeveralSAsDuplicates_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT });
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Store_Audits__r.size());
		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.assertEquals(1, sas[0].Store_Audit_Items__r.size());
	}

	@IsTest
	private static void second_cleanSAsWhereRtDevName_oneVisitwithSeveralSAsDuplicates_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa5 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sa4.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sa5.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4, sa5 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai21 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(5, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT }, 200);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(3, visitsAfter[0].Store_Audits__r.size());
		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.assertEquals(1, sas[0].Store_Audit_Items__r.size());
		System.assertEquals(1, sas[1].Store_Audit_Items__r.size());
		System.assertEquals(0, sas[2].Store_Audit_Items__r.size());
	}

	@IsTest
	private static void third_cleanSAsWhereRtDevName_oneVisitwithSeveralSAsDuplicates_WithNoMobileId_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = null;
		sa4.EUR_CRM_Mobile_ID__c = null;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai21 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT });
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(4, visitsAfter[0].Store_Audits__r.size());
		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.assertEquals(1, sas[0].Store_Audit_Items__r.size());
		System.assertEquals(1, sas[1].Store_Audit_Items__r.size());
		System.assertEquals(0, sas[2].Store_Audit_Items__r.size());
		System.assertEquals(0, sas[3].Store_Audit_Items__r.size());
	}

	@IsTest
	private static void fourth_cleanSAsWhereRtDevName_oneVisitwithSeveralSAsDuplicates_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT });
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(4, visitsAfter[0].Store_Audits__r.size());
	}

	@IsTest
	private static void first_cleanRecordsWhereRtDevNameAndDates_oneVisitwithSeveralSAsDuplicates_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-5);
		Datetime endDt = Datetime.now().addMinutes(2);
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT }, startDt, endDt);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Store_Audits__r.size());
		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.assertEquals(1, sas[0].Store_Audit_Items__r.size());
	}

	@IsTest
	private static void second_cleanRecordsWhereRtDevNameAndDates_oneVisitwithSeveralSAsDuplicates_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa5 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sa4.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sa5.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4, sa5 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai21 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(5, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-5);
		Datetime endDt = Datetime.now().addMinutes(2);
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT }, startDt, endDt, 200);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(3, visitsAfter[0].Store_Audits__r.size());
		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.assertEquals(1, sas[0].Store_Audit_Items__r.size());
		System.assertEquals(1, sas[1].Store_Audit_Items__r.size());
		System.assertEquals(0, sas[2].Store_Audit_Items__r.size());
	}

	@IsTest
	private static void third_cleanRecordsWhereRtDevNameAndDates_oneVisitwithSeveralSAsDuplicates_WithNoMobileId_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = null;
		sa4.EUR_CRM_Mobile_ID__c = null;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai21 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-5);
		Datetime endDt = Datetime.now().addMinutes(2);
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT }, startDt, endDt);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(4, visitsAfter[0].Store_Audits__r.size());
		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.assertEquals(1, sas[0].Store_Audit_Items__r.size());
		System.assertEquals(1, sas[1].Store_Audit_Items__r.size());
		System.assertEquals(0, sas[2].Store_Audit_Items__r.size());
		System.assertEquals(0, sas[3].Store_Audit_Items__r.size());
	}

	@IsTest
	private static void fourth_cleanRecordsWhereRtDevNameAndDates_oneVisitwithSeveralSAsDuplicates_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa3 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa4 = makeSA(acc.Id, visit.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2, sa3, sa4 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(1, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Store_Audits__r.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-5);
		Datetime endDt = Datetime.now().addMinutes(2);
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT }, startDt, endDt);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(4, visitsAfter[0].Store_Audits__r.size());
	}

	@IsTest
	private static void severalVisitwithSeveralSAsDuplicates_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit1 = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
		EUR_CRM_Visit__c visit2 = makeVisit(acc.Id, EUR_RU_OFF_TRADE_VISIT);
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Store_Audit__c sa11 = makeSA(acc.Id, visit1.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa12 = makeSA(acc.Id, visit1.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa13 = makeSA(acc.Id, visit1.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa14 = makeSA(acc.Id, visit1.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		sa11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa12.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa14.EUR_CRM_Mobile_ID__c = null;

		EUR_CRM_Store_Audit__c sa21 = makeSA(acc.Id, visit2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa22 = makeSA(acc.Id, visit2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa23 = makeSA(acc.Id, visit2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa24 = makeSA(acc.Id, visit2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		sa21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa22.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sa24.EUR_CRM_Mobile_ID__c = null;
		insert new List<EUR_CRM_Store_Audit__c>{ sa11, sa12, sa13, sa14, sa21, sa22, sa23, sa24 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa11.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa21.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai21 };

		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.debug('\n visitsBefore.size() => ' + visitsBefore.size() + '\n');
		System.debug('\n visitsBefore => ' + JSON.serializePretty(visitsBefore) + '\n');
		System.assertEquals(2, visitsBefore.size());
		System.assertEquals(4, visitsBefore[0].Store_Audits__r.size());
		System.assertEquals(4, visitsBefore[1].Store_Audits__r.size());

		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.debug('\n sasBefore.size() => ' + sasBefore.size() + '\n');
		System.debug('\n sasBefore => ' + JSON.serializePretty(sasBefore) + '\n');
		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-5);
		Datetime endDt = Datetime.now().addMinutes(2);
		EUR_CRM_StoreAuditDuplicateClean.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT, EUR_RU_OFF_TRADE_STORE_AUDIT }, startDt, endDt);
		Test.stopTest();

		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.debug('\n visitsAfter.size() => ' + visitsAfter.size() + '\n');
		System.debug('\n visitsAfter => ' + JSON.serializePretty(visitsAfter) + '\n');
		System.assertEquals(2, visitsAfter.size());
		List<EUR_CRM_Store_Audit__c> sasAfter = selectSAs();
		System.debug('\n sasAfter.size() => ' + sasAfter.size() + '\n');
		System.debug('\n sasAfter => ' + JSON.serializePretty(sasAfter) + '\n');
		System.assertEquals(2, visitsAfter[0].Store_Audits__r.size());
		System.assertEquals(2, visitsAfter[1].Store_Audits__r.size());
		System.assertEquals(4, sasAfter.size());
		System.assertEquals(1, sasAfter[0].Store_Audit_Items__r.size());
		System.assertEquals(0, sasAfter[1].Store_Audit_Items__r.size());

		System.assertEquals(1, sasAfter[2].Store_Audit_Items__r.size());
		System.assertEquals(0, sasAfter[3].Store_Audit_Items__r.size());
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

	private static EUR_CRM_Store_Audit__c makeSA(Id accId, Id vId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Store_Audit__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Store_Audit__c(
			EUR_CRM_Account__c = accId
			,   EUR_CRM_Visit__c = vId
			,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Store_Audit_Item__c makeSAI(Id saId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Store_Audit_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Store_Audit_Item__c(
			EUR_CRM_Store_Audit__c = saId
			,	RecordTypeId = rtId
		);
	}


	//Selectors
	private static List<EUR_CRM_Visit__c> selectVisits() {
		return [
			SELECT Id
				,   (
				SELECT Id
				,   EUR_CRM_Mobile_ID__c
				FROM Store_Audits__r)
			FROM EUR_CRM_Visit__c
		];
	}

	private static List<EUR_CRM_Store_Audit__c> selectSAs() {
		return [
			SELECT Id
				,   (
				SELECT Id, EUR_CRM_Mobile_ID__c
				FROM Store_Audit_Items__r
				ORDER BY EUR_CRM_Mobile_ID__c
			)
			FROM EUR_CRM_Store_Audit__c
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