@IsTest
private class EUR_CRM_StoreAuditItemsDuplicateCleanTst {

	private static final String MOBILE_ID_1 = 'Mobile_Id_1';
	private static final String MOBILE_ID_2 = 'Mobile_Id_2';

	//Account RTs
	private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM';

	//Store Audit RTs
	private static final String EUR_RU_ON_TRADE_STORE_AUDIT = 'EUR_RU_On_Trade_Store_Audit';
	private static final String EUR_RU_OFF_TRADE_STORE_AUDIT = 'EUR_RU_Off_Trade_Store_Audit';

	//Store Audit Item RTs
	private static final String EUR_RU_ON_TRADE_STORE_AUDIT_ITEM = 'EUR_RU_On_Trade_Store_Audit_Item';
	private static final String EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM = 'EUR_RU_Off_Trade_Store_Audit_Item';

	//Schedule tests
	@IsTest
	private static void scheduleCleanSAIsWhereRtDevNameAndDates_Test() {
		Test.startTest();
		String cronExpr = '0 0 1 * * ?';
		Set<String> rtDevName = new Set<String>{'EUR_RU_On_Trade_Store_Audit_Item'};
		String cronJobId = EUR_CRM_StoreAuditItemsDuplicateClean.scheduleCleanRecordsWhereRtDevNameAndDates(cronExpr, rtDevName, null, null, 200);
		Test.stopTest();


		List<CronTrigger> cronTriggers = selectCronTriggers(cronJobId);
		System.assertEquals(1, selectCronTriggers(cronJobId).size());

		System.assertEquals('0 0 1 * * ?', cronTriggers[0].CronExpression);
		System.assertEquals(1, cronTriggers[0].NextFireTime.hour());
		System.assertEquals(0, cronTriggers[0].NextFireTime.minute());
		System.assert(cronTriggers[0].CronJobDetail.Name.containsIgnoreCase(EUR_CRM_StoreAuditItemsDuplicateClean.EUR_CRM_STORE_AUDIT_ITEMS_DUPLICATE_CLEAN));

		EUR_CRM_StoreAuditItemsDuplicateClean.removeSchedules();
		System.assertEquals(0, selectCronTriggers(cronJobId).size());
	}


	@IsTest
	private static void buildSaisQuery_NoRtParameter() {
		Set<String> rtDevNames = new Set<String>();
		String query = new EUR_CRM_StoreAuditItemsDuplicateClean().buildSaisQueryRegardlessMobileId(null, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_OneParameter() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT_ITEM };
		String query = new EUR_CRM_StoreAuditItemsDuplicateClean().buildSaisQueryRegardlessMobileId(rtDevNames, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_TwoParameters() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT_ITEM };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		String query = new EUR_CRM_StoreAuditItemsDuplicateClean().buildSaisQueryRegardlessMobileId(rtDevNames, startDt, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_ThreeParameters() {
		Set<String> rtDevNames = new Set<String>{ EUR_RU_ON_TRADE_STORE_AUDIT_ITEM };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		Datetime endDt = Datetime.newInstance(2020, 03, 01);
		String query = new EUR_CRM_StoreAuditItemsDuplicateClean().buildSaisQueryRegardlessMobileId(rtDevNames, startDt, endDt);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert(query.contains('CreatedDate < :endDatetime'));
	}
	//End Unit tests

	//Integration tests
	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_1_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> sais = selectSais();
		System.assertEquals(4, sais.size());
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_2_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

//		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_RU_ON_TRADE_VISIT);
//		insert visit;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ }, 100);
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> sais = selectSais();
		System.assertEquals(4, sais.size());
	}

	// Start - one SA, duplicated SAI by Brand Quality
	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandQuality_1_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Quality__c bq1 = makeBQ();
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality__c = bq1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandQuality_2_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Quality__c bq1 = makeBQ();
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality__c = bq1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality__c = bq1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality__c = bq1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality__c = bq1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(null, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandQuality_3_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Quality__c bq1 = makeBQ();
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality__c = bq1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality__c = bq1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality__c = bq1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality__c = bq1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}
	//End - one SA, duplicated SAI by Brand Quality


	// Start - one SA, duplicated SAI by Brand
	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrand_1_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		insert b1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand__c = b1.Id;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand__c = b1.Id;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand__c = b1.Id;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand__c = b1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrand_2_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		insert b1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand__c = b1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand__c = b1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand__c = b1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand__c = b1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(null, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrand_3_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		insert b1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand__c = b1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand__c = b1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand__c = b1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand__c = b1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}
	//End - one SA, duplicated SAI by Brand

	// Start - one SA, duplicated SAI by Brand Quality Size
	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandQualitySize_1_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Size__c bqs1 = makeBQS();
		insert bqs1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandQualitySize_2_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Size__c bqs1 = makeBQS();
		insert bqs1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(null, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandQualitySize_3_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Size__c bqs1 = makeBQS();
		insert bqs1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}
	//End - one SA, duplicated SAI by Brand Quality Size

	// Start - one SA, duplicated SAI by GB Brand Quality
	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByGBBrandQuality_1_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

//		EUR_CRM_Brand__c b = makeB();
//		b.EUR_CRM_Is_Competitor__c = false;
//		insert b;

		EUR_CRM_Quality__c bq1 = makeBQ();
//		bq1.EUR_CRM_Brand__c = b.Id;
		bq1.EUR_CRM_Le_Cercle__c = true;
//		bq1.EUR_CRM_Quality_Is_Competitor__c = false;
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByGBBrandQuality_2_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Quality__c bq1 = makeBQ();
		bq1.EUR_CRM_Le_Cercle__c = true;
//		bq1.EUR_CRM_Quality_Is_Competitor__c = false;
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(null, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByGBBrandQuality_3_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Quality__c bq1 = makeBQ();
		bq1.EUR_CRM_Le_Cercle__c = true;
//		bq1.EUR_CRM_Quality_Is_Competitor__c = false;
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_GB_Brand_Quality__c = bq1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}
	//End - one SA, duplicated SAI by GB Brand Quality

	// Start - one SA, duplicated SAI by B + BQ
	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandAndBrandQuality_1_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		insert b1;
		EUR_CRM_Quality__c bq1 = makeBQ();
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai1.EUR_CRM_Brand__c = b1.Id;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai2.EUR_CRM_Brand__c = b1.Id;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai3.EUR_CRM_Brand__c = b1.Id;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai4.EUR_CRM_Brand__c = b1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandAndBrandQuality_2_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		insert b1;
		EUR_CRM_Quality__c bq1 = makeBQ();
		insert bq1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai1.EUR_CRM_Brand__c = b1.Id;
		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai2.EUR_CRM_Brand__c = b1.Id;
		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality__c = bq1.Id;
//		sai3.EUR_CRM_Brand__c = b1.Id;
		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
//		sai4.EUR_CRM_Brand_Quality__c = bq1.Id;
		sai4.EUR_CRM_Brand__c = b1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		Map<Id, EUR_CRM_Store_Audit_Item__c> saiAfterById = new Map<Id, EUR_CRM_Store_Audit_Item__c>(selectSais());
		System.assertEquals(3, saiAfterById.size());
		System.assert(saiAfterById.containsKey(sai2.Id) || saiAfterById.containsKey(sai1.Id));
		System.assert(saiAfterById.containsKey(sai3.Id));
		System.assert(saiAfterById.containsKey(sai4.Id));
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_oneSAwithSeveralSAIsDuplicates_DuplesByBrandAndBrandQuality_3_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Size__c bqs1 = makeBQS();
		insert bqs1;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai4 = makeSAI(sa.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai2.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai3.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		sai4.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai4.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3, sai4 };

		System.assertEquals(4, selectSais().size());

		Test.startTest();
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM});
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(1, saisAfter.size());
		System.assertEquals(MOBILE_ID_1, saisAfter[0].EUR_CRM_Mobile_ID__c);
	}
	//End - one SA, duplicated SAI by B + BQ


	//Several SA, duplicates by Brand
	@IsTest
	private static void cleanSAIsWhereRtDevNameAndDates_twoSAwithSeveralSAIsDuplicates_DuplesByBrand_1_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		EUR_CRM_Brand__c b2 = makeB();
		insert new List<EUR_CRM_Brand__c>{ b1, b2 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai12 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai13 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai14 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		sai11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai11.EUR_CRM_Brand__c = b1.Id;
		sai13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai13.EUR_CRM_Brand__c = b1.Id;

		sai12.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai12.EUR_CRM_Brand__c = b2.Id;
		sai14.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai14.EUR_CRM_Brand__c = b2.Id;

		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai22 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai23 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai24 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai21.EUR_CRM_Brand__c = b1.Id;
		sai23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai23.EUR_CRM_Brand__c = b1.Id;

		sai22.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai22.EUR_CRM_Brand__c = b2.Id;
		sai24.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai24.EUR_CRM_Brand__c = b2.Id;

		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai12, sai13, sai14, sai21, sai22, sai23, sai24 };
		List<EUR_CRM_Store_Audit_Item__c> insertedSais = selectSais();
		System.assertEquals(8, insertedSais.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-1);
		Datetime endDt = Datetime.now().addMinutes(1);
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
			new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM}, startDt, endDt
		);
		Test.stopTest();

		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.debug('\n sas.size() => ' + sas.size() + '\n');
		System.debug('\n sas => ' + JSON.serializePretty(sas) + '\n');
		System.assertEquals(2, sas.size());
		for (EUR_CRM_Store_Audit__c sa : sas) {
			System.assertEquals(2, sa.Store_Audit_Items__r.size());
			System.assertEquals(MOBILE_ID_1, sa.Store_Audit_Items__r[0].EUR_CRM_Mobile_ID__c);
			System.assertEquals(b1.Id, sa.Store_Audit_Items__r[0].EUR_CRM_Brand__c);
			System.assertEquals(MOBILE_ID_2, sa.Store_Audit_Items__r[1].EUR_CRM_Mobile_ID__c);
			System.assertEquals(b2.Id, sa.Store_Audit_Items__r[1].EUR_CRM_Brand__c);
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevNameAndDates_twoSAwithSeveralSAIsDuplicates_DuplesByBrand_2_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		EUR_CRM_Brand__c b2 = makeB();
		insert new List<EUR_CRM_Brand__c>{ b1, b2 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai12 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai13 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai14 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
//		sai11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai11.EUR_CRM_Brand__c = b1.Id;
//		sai13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai13.EUR_CRM_Brand__c = b1.Id;

//		sai12.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai12.EUR_CRM_Brand__c = b2.Id;
//		sai14.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai14.EUR_CRM_Brand__c = b2.Id;

		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai22 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai23 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai24 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		sai21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai21.EUR_CRM_Brand__c = b1.Id;
//		sai23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai23.EUR_CRM_Brand__c = b1.Id;

//		sai22.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai22.EUR_CRM_Brand__c = b2.Id;
//		sai24.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai24.EUR_CRM_Brand__c = b2.Id;

		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai12, sai13, sai14, sai21, sai22, sai23, sai24 };
		List<EUR_CRM_Store_Audit_Item__c> insertedSais = selectSais();
		System.assertEquals(8, insertedSais.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-1);
		Datetime endDt = Datetime.now().addMinutes(1);
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
			new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM}, startDt, endDt
		);
		Test.stopTest();

		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.debug('\n sas.size() => ' + sas.size() + '\n');
		System.debug('\n sas => ' + JSON.serializePretty(sas) + '\n');
		System.assertEquals(2, sas.size());
		for (EUR_CRM_Store_Audit__c sa : sas) {
			System.assertEquals(2, sa.Store_Audit_Items__r.size());
//			System.assertEquals(MOBILE_ID_1, sa.Store_Audit_Items__r[0].EUR_CRM_Mobile_ID__c);
			System.assertEquals(b2.Id, sa.Store_Audit_Items__r[0].EUR_CRM_Brand__c);
//			System.assertEquals(MOBILE_ID_2, sa.Store_Audit_Items__r[1].EUR_CRM_Mobile_ID__c);
			System.assertEquals(b1.Id, sa.Store_Audit_Items__r[1].EUR_CRM_Brand__c);
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevNameAndDates_twoSAwithSeveralSAIsDuplicates_DuplesByBrand_3_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Brand__c b1 = makeB();
		EUR_CRM_Brand__c b2 = makeB();
		insert new List<EUR_CRM_Brand__c>{ b1, b2 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai12 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai13 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai14 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		sai11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai11.EUR_CRM_Brand__c = b1.Id;
//		sai13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai13.EUR_CRM_Brand__c = b1.Id;

		sai12.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai12.EUR_CRM_Brand__c = b2.Id;
//		sai14.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai14.EUR_CRM_Brand__c = b2.Id;

		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai22 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai23 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai24 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai21.EUR_CRM_Brand__c = b1.Id;
//		sai23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai23.EUR_CRM_Brand__c = b1.Id;

		sai22.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai22.EUR_CRM_Brand__c = b2.Id;
//		sai24.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai24.EUR_CRM_Brand__c = b2.Id;

		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai12, sai13, sai14, sai21, sai22, sai23, sai24 };
		List<EUR_CRM_Store_Audit_Item__c> insertedSais = selectSais();
		System.assertEquals(8, insertedSais.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-1);
		Datetime endDt = Datetime.now().addMinutes(1);
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
			new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM}, startDt, endDt
		);
		Test.stopTest();

		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
		System.debug('\n sas.size() => ' + sas.size() + '\n');
		System.debug('\n sas => ' + JSON.serializePretty(sas) + '\n');
		System.assertEquals(2, sas.size());
		for (EUR_CRM_Store_Audit__c sa : sas) {
			System.assertEquals(2, sa.Store_Audit_Items__r.size());
			System.assertEquals(MOBILE_ID_1, sa.Store_Audit_Items__r[0].EUR_CRM_Mobile_ID__c);
			System.assertEquals(b1.Id, sa.Store_Audit_Items__r[0].EUR_CRM_Brand__c);
			System.assertEquals(MOBILE_ID_2, sa.Store_Audit_Items__r[1].EUR_CRM_Mobile_ID__c);
			System.assertEquals(b2.Id, sa.Store_Audit_Items__r[1].EUR_CRM_Brand__c);
		}
	}



	@IsTest
	private static void cleanSAIsWhereRtDevNameAndDates_severalSAwithSeveralSAIsDuplicates_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai12 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai13 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai14 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
		sai11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai12.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai14.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;

		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai22 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai23 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		EUR_CRM_Store_Audit_Item__c sai24 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
		sai21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai22.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		sai23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		sai24.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;

		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai12, sai13, sai14, sai21, sai22, sai23, sai24 };
		List<EUR_CRM_Store_Audit_Item__c> insertedSais = selectSais();
		System.assertEquals(8, insertedSais.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(1);
		Datetime endDt = Datetime.now().addMinutes(10);
		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
			new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM}, startDt, endDt, 100
		);
		Test.stopTest();

		List<EUR_CRM_Store_Audit_Item__c> sais = selectSais();
		System.assertEquals(8, sais.size());
	}

//	@IsTest
//	private static void cleanSAIsWhereRtDevNameAndDates_severalSAwithSeveralSAIsDuplicates_Positive() {
//		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
//		insert acc;
//
//		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, EUR_RU_ON_TRADE_STORE_AUDIT);
//		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, EUR_RU_OFF_TRADE_STORE_AUDIT);
//		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };
//
//		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai12 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai13 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai14 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai15 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai16 = makeSAI(sa1.Id, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM);
//		sai11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
//		sai12.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
//		sai13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
//		sai14.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
//		sai15.EUR_CRM_Mobile_ID__c = null;
//		sai16.EUR_CRM_Mobile_ID__c = null;
//
//		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai22 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai23 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai24 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai25 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		EUR_CRM_Store_Audit_Item__c sai26 = makeSAI(sa2.Id, EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM);
//		sai21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
//		sai22.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
//		sai23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
//		sai24.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
//		sai25.EUR_CRM_Mobile_ID__c = null;
//		sai26.EUR_CRM_Mobile_ID__c = null;
//
//		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai12, sai13, sai14, sai15, sai16, sai21, sai22, sai23, sai24, sai25, sai26 };
//		List<EUR_CRM_Store_Audit_Item__c> insertedSais = selectSais();
//		System.assertEquals(12, insertedSais.size());
//
//		Test.startTest();
//		Datetime startDt = Datetime.now().addMinutes(-1);
//		Datetime endDt = Datetime.now().addMinutes(10);
//		EUR_CRM_StoreAuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
//			new Set<String>{ EUR_RU_OFF_TRADE_STORE_AUDIT_ITEM, EUR_RU_ON_TRADE_STORE_AUDIT_ITEM}, startDt, endDt, 100
//		);
//		Test.stopTest();
//
//		List<EUR_CRM_Store_Audit_Item__c> sais = selectSais();
//		System.assertEquals(8, sais.size());
//		List<EUR_CRM_Store_Audit__c> sas = selectSAs();
//		System.debug('\n sas.size() => ' + sas.size() + '\n');
//		System.debug('\n sas => ' + JSON.serializePretty(sas) + '\n');
//		System.assertEquals(2, sas.size());
//		System.assertEquals(4, sas[0].Store_Audit_Items__r.size());
//		System.assertEquals(4, sas[1].Store_Audit_Items__r.size());
//
//		System.assertEquals(null, sas[0].Store_Audit_Items__r[0].EUR_CRM_Mobile_ID__c);
//		System.assertEquals(null, sas[0].Store_Audit_Items__r[1].EUR_CRM_Mobile_ID__c);
//		System.assertEquals(MOBILE_ID_1, sas[0].Store_Audit_Items__r[2].EUR_CRM_Mobile_ID__c);
//		System.assertEquals(MOBILE_ID_2, sas[0].Store_Audit_Items__r[3].EUR_CRM_Mobile_ID__c);
//
//		System.assertEquals(null, sas[1].Store_Audit_Items__r[0].EUR_CRM_Mobile_ID__c);
//		System.assertEquals(null, sas[1].Store_Audit_Items__r[1].EUR_CRM_Mobile_ID__c);
//		System.assertEquals(MOBILE_ID_1, sas[1].Store_Audit_Items__r[2].EUR_CRM_Mobile_ID__c);
//		System.assertEquals(MOBILE_ID_2, sas[1].Store_Audit_Items__r[3].EUR_CRM_Mobile_ID__c);
//
//	}


	//Makers
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			Name = 'Test Name'
		,   EUR_CRM_Postal_Code__c = '1122'
		,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Store_Audit__c makeSA(Id accId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Store_Audit__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Store_Audit__c(
			EUR_CRM_Account__c = accId
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

	private static EUR_CRM_Brand__c makeB() {
		Id rtId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Brand').getRecordTypeId();
		return new EUR_CRM_Brand__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Quality__c makeBQ() {
		Id rtId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Quality').getRecordTypeId();
		return new EUR_CRM_Quality__c(
			RecordTypeId = rtId,
				EUR_CRM_Active__c = true
		);
	}

	private static EUR_CRM_Size__c makeBQS() {
		Id rtId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Size').getRecordTypeId();
		EUR_CRM_Size__c bqs = new EUR_CRM_Size__c();
		bqs.RecordTypeId = rtId;
		bqs.EUR_CRM_Active__c = true;
		return bqs;
	}


	//Selectors
	private static List<EUR_CRM_Store_Audit_Item__c> selectSais() {
		return [
			SELECT Id
			,   EUR_CRM_Store_Audit__c
			,   EUR_CRM_Mobile_ID__c
			FROM EUR_CRM_Store_Audit_Item__c
		];
	}

	private static List<EUR_CRM_Store_Audit__c> selectSAs() {
		return [
			SELECT Id
			,   (
				SELECT Id, EUR_CRM_Mobile_ID__c
				,   EUR_CRM_Brand__c
				,   EUR_CRM_Brand_Quality__c
				,   EUR_CRM_Brand_Quality_Size__c
				,   EUR_CRM_GB_Brand_Quality__c
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