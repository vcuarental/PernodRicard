@IsTest
private class EUR_CRM_VisitDuplicateCleanTest {

	private static final String MOBILE_ID_1 = 'Mobile_Id_1';
	private static final String MOBILE_ID_2 = 'Mobile_Id_2';

	//Account RTs
	private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM';
	private static final String EUR_RU_ON_TRADE = 'EUR_RU_On_Trade';


	//Country Codes
	private static final String RU = 'RU';
	private static final String GB = 'GB';


	//Schedule tests
	@IsTest
	private static void scheduleCleanSAIsWhereRtDevNameAndDates_Test() {
		Test.startTest();
		String cronExpr = '0 0 1 * * ?';
		Set<String> rtDevName = new Set<String>{RU};
		String cronJobId = EUR_CRM_VisitDuplicateClean.scheduleCleanRecordsWhereCountryCodesAndDates(cronExpr, rtDevName, null, null, true, 200);
		Test.stopTest();


		List<CronTrigger> cronTriggers = selectCronTriggers(cronJobId);
		System.assertEquals(1, selectCronTriggers(cronJobId).size());

		System.assertEquals('0 0 1 * * ?', cronTriggers[0].CronExpression);
		System.assertEquals(1, cronTriggers[0].NextFireTime.hour());
		System.assertEquals(0, cronTriggers[0].NextFireTime.minute());
		System.assert(cronTriggers[0].CronJobDetail.Name.containsIgnoreCase(EUR_CRM_VisitDuplicateClean.EUR_CRM_VISIT_DUPLICATE_CLEAN));

		EUR_CRM_VisitDuplicateClean.removeSchedules();
		System.assertEquals(0, selectCronTriggers(cronJobId).size());
	}


	@IsTest
	private static void buildQuery_IncludeMobileId_NoRtParameter() {
		Set<String> countryCodes = null;
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, true);
		String query = batch.buildStartQuery();
		System.assert( ! query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildQuery_IncludeMobileId_OneParameter() {
		Set<String> countryCodes = new Set<String>{ RU };
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, true);
		String query = batch.buildStartQuery();
		System.assert(query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildQuery_IncludeMobileId_TwoParameters() {
		Set<String> countryCodes = new Set<String>{ RU };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, startDt, null, true);
		String query = batch.buildStartQuery();
		System.assert(query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildQuery_IncludeMobileId_ThreeParameters() {
		Set<String> countryCodes = new Set<String>{ RU };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		Datetime endDt = Datetime.newInstance(2020, 03, 01);
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, startDt, endDt, true);
		String query = batch.buildStartQuery();
		System.assert(query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert(query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildQuery_ExcludeMobileId_NoRtParameter() {
		Set<String> countryCodes = null;
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, false);
		String query = batch.buildStartQuery();
		System.assert( ! query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildQuery_ExcludeMobileId_OneParameter() {
		Set<String> countryCodes = new Set<String>{ RU };
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, false);
		String query = batch.buildStartQuery();
		System.assert(query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildQuery_ExcludeMobileId_TwoParameters() {
		Set<String> countryCodes = new Set<String>{ RU };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, startDt, null, false);
		String query = batch.buildStartQuery();
		System.assert(query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildQuery_ExcludeMobileId_ThreeParameters() {
		Set<String> countryCodes = new Set<String>{ RU };
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		Datetime endDt = Datetime.newInstance(2020, 03, 01);
		EUR_CRM_VisitDuplicateClean batch = new EUR_CRM_VisitDuplicateClean(countryCodes, startDt, endDt, false);
		String query = batch.buildStartQuery();
		System.assert(query.contains('EUR_CRM_Country_Code__c IN :countryCodes'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert(query.contains('CreatedDate < :endDatetime'));
	}
	//End Unit tests

	//Integration tests

	//START Tests to clean up visits duplicates WITH Mobile Id
	@IsTest
	private static void visitsHasNoMobileId_case0_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
//		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
//		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visitsHasNoMobileId_case0_AccountParameter_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
//		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
//		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereAccountIds(new List<Id>{ account.Id }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	// Visit can have Store Audits
	@IsTest
	private static void visitHasNoDuplicate_SA_case0_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case1_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-3);
		Datetime endDt = Datetime.now().addMinutes(-2);
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodesAndDates(new Set<String>{ GB }, startDt, endDt, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case2_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
		EUR_CRM_Store_Audit__c sa2 = makeSA(account.Id, visit2.Id);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case3_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ 'RU' }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case4_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(1, visitsAfter.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case5_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-3);
		Datetime endDt = Datetime.now().addMinutes(2);
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodesAndDates(new Set<String>{ GB }, startDt, endDt, true, 100);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(1, visitsAfter.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case6_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Store_Audit__c sa = makeSA(account.Id, visit1.Id);
		insert sa;

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Store_Audits__r.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case7_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit3 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit3.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2, visit3 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
		EUR_CRM_Store_Audit__c sa2 = makeSA(account.Id, visit2.Id);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(3, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Store_Audits__r.size());
		System.assertEquals(1, visitsAfter[1].Store_Audits__r.size());
	}

	@IsTest
	private static void visitHasDuplicate_SA_case8_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit3 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit4 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit3.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		visit4.EUR_CRM_Mobile_ID__c = MOBILE_ID_2;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2, visit3, visit4 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(4, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true, 100);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
		System.assertEquals(MOBILE_ID_1, visitsAfter[0].EUR_CRM_Mobile_ID__c);
		System.assertEquals(MOBILE_ID_2, visitsAfter[1].EUR_CRM_Mobile_ID__c);
	}

	//Visit can have other children
	@IsTest
	private static void visitHasDuplicate_BSI_case0_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Brand_Security_Infringement__c bsi = makeBrandSecurityInfringement(visit1.Id);
		insert new List<EUR_CRM_Brand_Security_Infringement__c>{ bsi };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Brand_Security_Infringements__r.size());
	}

	@IsTest
	private static void visitHasDuplicate_differentChildren_case1_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

		EUR_CRM_Brand_Security_Infringement__c bsi = makeBrandSecurityInfringement(visit1.Id);
		insert new List<EUR_CRM_Brand_Security_Infringement__c>{ bsi };

		EUR_CRM_Fair_Share_Audit__c fShA = makeFairShareAudit(account.Id, visit2.Id);
		insert new List<EUR_CRM_Fair_Share_Audit__c>{ fShA };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	//Mass tests
	@IsTest
	private static void manyAccounts_visitHasDuplicatesWithMobileId_noChildren_case0_Positive() {
		EUR_CRM_Account__c account1 = makeAccount(EUR_GB_FS_RTM);
		EUR_CRM_Account__c account2 = makeAccount(EUR_GB_FS_RTM);
		insert new List<EUR_CRM_Account__c>{ account1, account2 };

		EUR_CRM_Visit__c visit11 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit12 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit13 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit14 = makeVisit(account1.Id);

		EUR_CRM_Visit__c visit21 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit22 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit23 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit24 = makeVisit(account2.Id);

		visit11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit12.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit14.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;

		visit21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit22.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit24.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit11, visit12, visit13, visit14, visit21, visit22, visit23, visit24 };

//		EUR_CRM_Brand_Security_Infringement__c bsi = makeBrandSecurityInfringement(visit11.Id);
//		insert new List<EUR_CRM_Brand_Security_Infringement__c>{ bsi };
//
//		EUR_CRM_Fair_Share_Audit__c fShA = makeFairShareAudit(account1.Id, visit12.Id);
//		insert new List<EUR_CRM_Fair_Share_Audit__c>{ fShA };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(8, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
		System.assertEquals(account1.Id, visitsAfter[0].EUR_CRM_Account__c);
		System.assertEquals(account2.Id, visitsAfter[1].EUR_CRM_Account__c);
	}

	@IsTest
	private static void manyAccounts_visitHasDuplicatesWithMobileId_haveChildren_case1_Positive() {
		EUR_CRM_Account__c account1 = makeAccount(EUR_GB_FS_RTM);
		EUR_CRM_Account__c account2 = makeAccount(EUR_GB_FS_RTM);
		insert new List<EUR_CRM_Account__c>{ account1, account2 };

		EUR_CRM_Visit__c visit11 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit12 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit13 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit14 = makeVisit(account1.Id);

		EUR_CRM_Visit__c visit21 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit22 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit23 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit24 = makeVisit(account2.Id);

		visit11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit12.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit14.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;

		visit21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit22.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit24.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit11, visit12, visit13, visit14, visit21, visit22, visit23, visit24 };

		EUR_CRM_Brand_Security_Infringement__c bsi111 = makeBrandSecurityInfringement(visit11.Id);
		EUR_CRM_Brand_Security_Infringement__c bsi21 = makeBrandSecurityInfringement(visit12.Id);
		insert new List<EUR_CRM_Brand_Security_Infringement__c>{ bsi111, bsi21 };

		EUR_CRM_Fair_Share_Audit__c fShA211 = makeFairShareAudit(account2.Id, visit21.Id);
		EUR_CRM_Fair_Share_Audit__c fShA221 = makeFairShareAudit(account2.Id, visit22.Id);
		insert new List<EUR_CRM_Fair_Share_Audit__c>{ fShA211, fShA221 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(8, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, true);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(4, visitsAfter.size());
		System.assertEquals(account1.Id, visitsAfter[0].EUR_CRM_Account__c);
		System.assertEquals(account1.Id, visitsAfter[1].EUR_CRM_Account__c);
		System.assertEquals(account2.Id, visitsAfter[2].EUR_CRM_Account__c);
		System.assertEquals(account2.Id, visitsAfter[3].EUR_CRM_Account__c);
		System.assertEquals(1, visitsAfter[0].Brand_Security_Infringements__r.size());
		System.assertEquals(1, visitsAfter[1].Brand_Security_Infringements__r.size());
		System.assertEquals(1, visitsAfter[2].Fair_Share_EU__r.size());
		System.assertEquals(1, visitsAfter[3].Fair_Share_EU__r.size());
	}

	@IsTest
	private static void manyAccounts_visitHasDuplicatesWithMobileId_AllWithChildren_Negative() {
		EUR_CRM_Account__c account1 = makeAccount(EUR_GB_FS_RTM);
		EUR_CRM_Account__c account2 = makeAccount(EUR_GB_FS_RTM);
		insert new List<EUR_CRM_Account__c>{ account1, account2 };

		EUR_CRM_Visit__c visit11 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit12 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit13 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit14 = makeVisit(account1.Id);

		EUR_CRM_Visit__c visit21 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit22 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit23 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit24 = makeVisit(account2.Id);

		visit11.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit12.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit13.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit14.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;

		visit21.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit22.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit23.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit24.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;

		insert new List<EUR_CRM_Visit__c>{ visit11, visit12, visit13, visit14, visit21, visit22, visit23, visit24 };

		EUR_CRM_Brand_Security_Infringement__c bsi111 = makeBrandSecurityInfringement(visit11.Id);
		EUR_CRM_Contract_Audit__c ca121 = makeContractAudit(visit12.Id);
		EUR_CRM_Visit_Action__c va131 = makeVisitAction(visit13);
		EUR_CRM_Competitor_Promo_Tracking__c cpt141 = makeCompetitorPromoTracking(visit14.Id);
		insert new List<SObject>{bsi111, ca121, va131, cpt141};

		EUR_CRM_Fair_Share_Audit__c fShA211 = makeFairShareAudit(account2.Id, visit21.Id);
		EUR_CRM_Contract_Tracker__c ct221 = makeContractTracker(account2.Id, visit22.Id);
		EUR_CRM_POSM_Audit__c posma231 = makePosmAudit(account2.Id, visit23.Id);
		EUR_CRM_Price_Audit__c pricea241 = makePA(account2.Id, visit24.Id);

		insert new List<SObject>{fShA211, ct221, posma231, pricea241};

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(8, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(8, visitsAfter.size());
	}

	//END Tests to clean up visits duplicates WITH Mobile Id


	//START Tests to clean up visits duplicates WITHOUT Mobile Id
	@IsTest
	private static void visitsWithMobileId_NoChildren_DuplicatesByStartEndDate_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

//		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
//		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visitsWithMobileId_NoChildren_AccountParameter_DuplicatesByStartEndDate_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		visit1.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		visit2.EUR_CRM_Mobile_ID__c = MOBILE_ID_1;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

//		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
//		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereAccountIds(new List<Id>{ account.Id }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visits_NoChildren_DuplicatesByStartEndDate_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

//		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
//		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(1, visitsAfter.size());
	}

	@IsTest
	private static void visits_NoChildren_NoDuplicatesByStartEndDate_Negative() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		Datetime st1 = Datetime.now();
		Datetime end1 = Datetime.now().addDays(1);
		Datetime st2 = Datetime.now().addMinutes(1);
		Datetime end2 = Datetime.now().addDays(1).addMinutes(1);
		visit1.EUR_CRM_Start_Datetime__c = st1;
		visit2.EUR_CRM_Start_Datetime__c = st2;
		visit1.EUR_CRM_End_Datetime__c = end1;
		visit2.EUR_CRM_End_Datetime__c = end2;
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2 };

//		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
//		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(2, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
	}

	@IsTest
	private static void visits_WithChildren_DuplicatesByStartEndDate_Positive() {
		EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
		insert account;

		EUR_CRM_Visit__c visit1 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit2 = makeVisit(account.Id);
		EUR_CRM_Visit__c visit3 = makeVisit(account.Id);
		insert new List<EUR_CRM_Visit__c>{ visit1, visit2, visit3 };

		EUR_CRM_Store_Audit__c sa1 = makeSA(account.Id, visit1.Id);
		insert new List<EUR_CRM_Store_Audit__c>{ sa1 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(3, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(1, visitsAfter.size());
		System.assertEquals(1, visitsAfter[0].Store_Audits__r.size());
	}

	//Mass tests
	@IsTest
	private static void manyAccounts_visitHasDuplicates_WithChildren_Positive() {
		EUR_CRM_Account__c account1 = makeAccount(EUR_GB_FS_RTM);
		EUR_CRM_Account__c account2 = makeAccount(EUR_GB_FS_RTM);
		insert new List<EUR_CRM_Account__c>{ account1, account2 };

		EUR_CRM_Visit__c visit11 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit12 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit13 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit14 = makeVisit(account1.Id);

		EUR_CRM_Visit__c visit21 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit22 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit23 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit24 = makeVisit(account2.Id);

		insert new List<EUR_CRM_Visit__c>{ visit11, visit12, visit13, visit14, visit21, visit22, visit23, visit24 };

//		EUR_CRM_Brand_Security_Infringement__c bsi = makeBrandSecurityInfringement(visit11.Id);
//		insert new List<EUR_CRM_Brand_Security_Infringement__c>{ bsi };
//
//		EUR_CRM_Fair_Share_Audit__c fShA = makeFairShareAudit(account1.Id, visit12.Id);
//		insert new List<EUR_CRM_Fair_Share_Audit__c>{ fShA };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(8, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(2, visitsAfter.size());
		System.assertEquals(account1.Id, visitsAfter[0].EUR_CRM_Account__c);
		System.assertEquals(account2.Id, visitsAfter[1].EUR_CRM_Account__c);
	}

	@IsTest
	private static void manyAccounts_visitHasDuplicates_SomeWithChildren_Positive() {
		EUR_CRM_Account__c account1 = makeAccount(EUR_GB_FS_RTM);
		EUR_CRM_Account__c account2 = makeAccount(EUR_GB_FS_RTM);
		insert new List<EUR_CRM_Account__c>{ account1, account2 };

		EUR_CRM_Visit__c visit11 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit12 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit13 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit14 = makeVisit(account1.Id);

		EUR_CRM_Visit__c visit21 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit22 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit23 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit24 = makeVisit(account2.Id);

		insert new List<EUR_CRM_Visit__c>{ visit11, visit12, visit13, visit14, visit21, visit22, visit23, visit24 };

		EUR_CRM_Brand_Security_Infringement__c bsi111 = makeBrandSecurityInfringement(visit11.Id);
		EUR_CRM_Brand_Security_Infringement__c bsi21 = makeBrandSecurityInfringement(visit12.Id);
		insert new List<EUR_CRM_Brand_Security_Infringement__c>{ bsi111, bsi21 };

		EUR_CRM_Fair_Share_Audit__c fShA211 = makeFairShareAudit(account2.Id, visit21.Id);
		EUR_CRM_Fair_Share_Audit__c fShA221 = makeFairShareAudit(account2.Id, visit22.Id);
		insert new List<EUR_CRM_Fair_Share_Audit__c>{ fShA211, fShA221 };

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(8, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(4, visitsAfter.size());
		System.assertEquals(account1.Id, visitsAfter[0].EUR_CRM_Account__c);
		System.assertEquals(account1.Id, visitsAfter[1].EUR_CRM_Account__c);
		System.assertEquals(account2.Id, visitsAfter[2].EUR_CRM_Account__c);
		System.assertEquals(account2.Id, visitsAfter[3].EUR_CRM_Account__c);
		System.assertEquals(1, visitsAfter[0].Brand_Security_Infringements__r.size());
		System.assertEquals(1, visitsAfter[1].Brand_Security_Infringements__r.size());
		System.assertEquals(1, visitsAfter[2].Fair_Share_EU__r.size());
		System.assertEquals(1, visitsAfter[3].Fair_Share_EU__r.size());
	}

	@IsTest
	private static void manyAccounts_visitHasDuplicates_AllWithChildren_Negative() {
		EUR_CRM_Account__c account1 = makeAccount(EUR_GB_FS_RTM);
		EUR_CRM_Account__c account2 = makeAccount(EUR_GB_FS_RTM);
		insert new List<EUR_CRM_Account__c>{ account1, account2 };

		EUR_CRM_Visit__c visit11 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit12 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit13 = makeVisit(account1.Id);
		EUR_CRM_Visit__c visit14 = makeVisit(account1.Id);

		EUR_CRM_Visit__c visit21 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit22 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit23 = makeVisit(account2.Id);
		EUR_CRM_Visit__c visit24 = makeVisit(account2.Id);

		insert new List<EUR_CRM_Visit__c>{ visit11, visit12, visit13, visit14, visit21, visit22, visit23, visit24 };

		EUR_CRM_Brand_Security_Infringement__c bsi111 = makeBrandSecurityInfringement(visit11.Id);
		EUR_CRM_Contract_Audit__c ca121 = makeContractAudit(visit12.Id);
		EUR_CRM_Visit_Action__c va131 = makeVisitAction(visit13);
		EUR_CRM_Competitor_Promo_Tracking__c cpt141 = makeCompetitorPromoTracking(visit14.Id);
		insert new List<SObject>{bsi111, ca121, va131, cpt141};

		EUR_CRM_Fair_Share_Audit__c fShA211 = makeFairShareAudit(account2.Id, visit21.Id);
		EUR_CRM_Contract_Tracker__c ct221 = makeContractTracker(account2.Id, visit22.Id);
		EUR_CRM_POSM_Audit__c posma231 = makePosmAudit(account2.Id, visit23.Id);
		EUR_CRM_Price_Audit__c pricea241 = makePA(account2.Id, visit24.Id);

		insert new List<SObject>{fShA211, ct221, posma231, pricea241};

		//Assertion before
		List<EUR_CRM_Visit__c> visitsBefore = selectVisits();
		System.assertEquals(8, visitsBefore.size());

		Test.startTest();
		EUR_CRM_VisitDuplicateClean.cleanRecordsWhereCountryCodes(new Set<String>{ GB }, false);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Visit__c> visitsAfter = selectVisits();
		System.assertEquals(8, visitsAfter.size());
	}
	//END Tests to clean up visits duplicates WITHOUT Mobile Id

	//Makers
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			Name = 'Test Name'
		,   EUR_CRM_Postal_Code__c = '1122'
		,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Visit__c makeVisit(Id accId) {
		return new EUR_CRM_Visit__c(
			EUR_CRM_Account__c = accId
		,   EUR_CRM_Start_Datetime__c = Datetime.now()
		,   EUR_CRM_End_Datetime__c = Datetime.now().addDays(1)
		);
	}

	private static EUR_CRM_Store_Audit__c makeSA(Id accId, Id vId) {
		return new EUR_CRM_Store_Audit__c(
			EUR_CRM_Account__c = accId
		,   EUR_CRM_Visit__c = vId
		);
	}

	private static EUR_CRM_Price_Audit__c makePA(Id accId, Id visitId) {
		return new EUR_CRM_Price_Audit__c(
		    EUR_CRM_Visit__c = visitId
		,   EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_POSM_Audit__c makePosmAudit(Id accId, Id visitId) {
		return new EUR_CRM_POSM_Audit__c(
		   EUR_CRM_Visit__c = visitId
		,   EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_Fair_Share_Audit__c makeFairShareAudit(Id accId, Id visitId) {
		return new EUR_CRM_Fair_Share_Audit__c(
			EUR_CRM_Account__c = accId
		,	EUR_CRM_Visit__c = visitId
		);
	}

	private static EUR_CRM_Contract_Tracker__c makeContractTracker(Id accId, Id visitId) {
		return new EUR_CRM_Contract_Tracker__c(
			EUR_CRM_Visit__c = visitId
		,   EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_Contract_Audit__c makeContractAudit(Id visitId) {
		return new EUR_CRM_Contract_Audit__c(
			EUR_CRM_Visit__c = visitId
		);
	}

	private static EUR_CRM_Competitor_Promo_Tracking__c makeCompetitorPromoTracking(Id visitId) {
		return new EUR_CRM_Competitor_Promo_Tracking__c(
			EUR_CRM_Visit_ID__c = visitId
		);
	}

	private static EUR_CRM_Brand_Security_Infringement__c makeBrandSecurityInfringement(Id visitId) {
		return new EUR_CRM_Brand_Security_Infringement__c(
			EUR_CRM_Visit_ID__c = visitId
		);
	}

	private static EUR_CRM_Visit_Action__c makeVisitAction(EUR_CRM_Visit__c visit) {
		return new EUR_CRM_Visit_Action__c(
			EUR_CRM_Account__c = visit.EUR_CRM_Account__c
		,   EUR_CRM_Visit_ID__c = visit.Id
		,   EUR_CRM_Status__c = 'Completed'
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

	private static List<EUR_CRM_Account__c> selectAccounts() {
		return [
			SELECT Id
			,   (SELECT Id, EUR_CRM_Mobile_ID__c FROM Visits__r)
			FROM EUR_CRM_Account__c
		];
	}

	private static List<EUR_CRM_Visit__c> selectVisits() {
		return [
			SELECT Id
			,   EUR_CRM_Mobile_ID__c
			,   EUR_CRM_Account__c
			,   (SELECT Id FROM Store_Audits__r)
			,   (SELECT Id FROM Price_Check_EU__r)
			,   (SELECT Id FROM POSM_Audit_EU__r)
			,   (SELECT Id FROM EUR_CRM_Contract_Audits__r)
			,   (SELECT Id FROM Fair_Share_EU__r)
			,   (SELECT Id FROM Competitor_Promo_Tracking_EU__r)
			,   (SELECT Id FROM Contracts_Tracker_EU__r)
			,   (SELECT Id FROM Brand_Security_Infringements__r)
			,   (SELECT Id FROM EUR_CRM_Visit_Actions__r)
			FROM EUR_CRM_Visit__c
		];
	}

}