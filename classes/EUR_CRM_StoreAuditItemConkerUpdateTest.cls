@IsTest(IsParallel = true)
private class EUR_CRM_StoreAuditItemConkerUpdateTest {

	//Account RTs
	private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM';

	//Visit RTs
	private static final String EUR_GB_ON_TRADE_FS_VISIT = 'EUR_GB_On_Trade_FS_Visit';

	//Store Audit RTs
	private static final String EUR_GB_SA_RT = 'EUR_GB_Store_Audit';

	//Store Audit Item RTs
	private static final String EUR_GB_SAI_RT = 'EUR_GB_FS_Store_Audit';

	@IsTest
	private static void buildSaisQuery_NoRtParameter() {
		Set<String> rtDevNames = new Set<String>();
		String query = new EUR_CRM_StoreAuditItemConkerUpdate().buildSaisQuery(null, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_OneParameter() {
		Set<String> rtDevNames = new Set<String>{EUR_GB_SAI_RT};
		String query = new EUR_CRM_StoreAuditItemConkerUpdate().buildSaisQuery(rtDevNames, null, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert( ! query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_TwoParameters() {
		Set<String> rtDevNames = new Set<String>{EUR_GB_SAI_RT};
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		String query = new EUR_CRM_StoreAuditItemConkerUpdate().buildSaisQuery(rtDevNames, startDt, null);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert( ! query.contains('CreatedDate < :endDatetime'));
	}

	@IsTest
	private static void buildSaisQuery_ThreeParameters() {
		Set<String> rtDevNames = new Set<String>{EUR_GB_SAI_RT};
		Datetime startDt = Datetime.newInstance(2020, 01, 01);
		Datetime endDt = Datetime.newInstance(2020, 03, 01);
		String query = new EUR_CRM_StoreAuditItemConkerUpdate().buildSaisQuery(rtDevNames, startDt, endDt);
		System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
		System.assert(query.contains('CreatedDate >= :startDatetime'));
		System.assert(query.contains('CreatedDate < :endDatetime'));
	}

	//Integration tests
	@IsTest
	private static void cleanSAIsWhereRtDevName_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_GB_ON_TRADE_FS_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_GB_SA_RT);
		sa.EUR_CRM_Audit_Datetime__c = Datetime.now(); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa.EUR_CRM_Audit_Summary__c = '3 audits';
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3 };

		//Assertion before
		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.assertEquals(1, sasBefore.size());
		System.assertEquals(true, sasBefore[0].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		List<EUR_CRM_Store_Audit_Item__c> saisBefore = selectSais();
		System.assertEquals(3, saisBefore.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisBefore) {
			System.assertEquals(false, sai.EUR_JB_Listed__c);
		}

		Test.startTest();
		EUR_CRM_StoreAuditItemConkerUpdate.cleanRecordsWhereRtDevName(new Set<String>{ EUR_GB_SA_RT });
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(3, saisAfter.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisAfter) {
			System.assertEquals(true, sai.EUR_JB_Listed__c, 'Sai was been updated');
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_AuditSummaryBadValue_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_GB_ON_TRADE_FS_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_GB_SA_RT);
		sa.EUR_CRM_Audit_Datetime__c = Datetime.now(); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa.EUR_CRM_Audit_Summary__c = 'Three audits';
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3 };

		//Assertion before
		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.assertEquals(1, sasBefore.size());
		System.assertEquals(true, sasBefore[0].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		List<EUR_CRM_Store_Audit_Item__c> saisBefore = selectSais();
		System.assertEquals(3, saisBefore.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisBefore) {
			System.assertEquals(false, sai.EUR_JB_Listed__c);
		}

		Test.startTest();
		EUR_CRM_StoreAuditItemConkerUpdate.cleanRecordsWhereRtDevName(new Set<String>{ EUR_GB_SA_RT }, 200);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(3, saisAfter.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisAfter) {
			System.assertEquals(false, sai.EUR_JB_Listed__c, 'SAI wasnt been updated because of sa.EUR_CRM_Audit_Summary__c has not digit');
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_SaNotLatest_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_GB_ON_TRADE_FS_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_GB_SA_RT);
//		sa.EUR_CRM_Audit_Datetime__c = Datetime.now(); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa.EUR_CRM_Audit_Summary__c = '3 audits';
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3 };

		//Assertion before
		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.assertEquals(1, sasBefore.size());
		System.assertEquals(false, sasBefore[0].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		List<EUR_CRM_Store_Audit_Item__c> saisBefore = selectSais();
		System.assertEquals(3, saisBefore.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisBefore) {
			System.assertEquals(false, sai.EUR_JB_Listed__c);
		}

		Test.startTest();
		EUR_CRM_StoreAuditItemConkerUpdate.cleanRecordsWhereRtDevName(new Set<String>{ EUR_GB_SA_RT });
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(3, saisAfter.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisAfter) {
			System.assertEquals(false, sai.EUR_JB_Listed__c, 'SAI wasnt been updated because of sa.EUR_CRM_Is_Latest_Store_Audit_Formula__c = false has not digit');
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_AuditSummaryBadValue_2_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_GB_ON_TRADE_FS_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_GB_SA_RT);
		sa.EUR_CRM_Audit_Datetime__c = Datetime.now(); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa.EUR_CRM_Audit_Summary__c = '4 audits';
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3 };

		//Assertion before
		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.assertEquals(1, sasBefore.size());
		System.assertEquals(true, sasBefore[0].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		List<EUR_CRM_Store_Audit_Item__c> saisBefore = selectSais();
		System.assertEquals(3, saisBefore.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisBefore) {
			System.assertEquals(false, sai.EUR_JB_Listed__c);
		}

		Test.startTest();
		EUR_CRM_StoreAuditItemConkerUpdate.cleanRecordsWhereRtDevName(new Set<String>{ EUR_GB_SA_RT });
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(3, saisAfter.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisAfter) {
			System.assertEquals(false, sai.EUR_JB_Listed__c, 'SAI wasnt been updated because of sa.EUR_CRM_Audit_Summary__c!=3');
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_NotAllSaisHaveListedFalse_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_GB_ON_TRADE_FS_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_GB_SA_RT);
		sa.EUR_CRM_Audit_Datetime__c = Datetime.now(); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa.EUR_CRM_Audit_Summary__c = '3 audits';
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		sai1.EUR_JB_Listed__c = true;
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3 };

		//Assertion before
		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.assertEquals(1, sasBefore.size());
		System.assertEquals(true, sasBefore[0].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		List<EUR_CRM_Store_Audit_Item__c> saisBefore = selectSais();
		System.assertEquals(3, saisBefore.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisBefore) {
			if (sai.Id == sai1.Id) {
				System.assertEquals(true, sai.EUR_JB_Listed__c);
			} else {
				System.assertEquals(false, sai.EUR_JB_Listed__c);
			}
		}

		Test.startTest();
		EUR_CRM_StoreAuditItemConkerUpdate.cleanRecordsWhereRtDevName(new Set<String>{ EUR_GB_SA_RT });
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(3, saisAfter.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisAfter) {
			if (sai.Id == sai1.Id) {
				System.assertEquals(true, sai.EUR_JB_Listed__c, 'SAI wasnt been updated because of sa.EUR_CRM_Audit_Summary__c!=3');
			} else {
				System.assertEquals(false, sai.EUR_JB_Listed__c, 'SAI wasnt been updated because of sa.EUR_CRM_Audit_Summary__c!=3');
			}
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_WrongRecordType_Negative() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_GB_ON_TRADE_FS_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa = makeSA(acc.Id, EUR_GB_SA_RT);
		sa.EUR_CRM_Audit_Datetime__c = Datetime.now(); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa.EUR_CRM_Audit_Summary__c = '3 audits';
		insert sa;

		EUR_CRM_Store_Audit_Item__c sai1 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai2 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai3 = makeSAI(sa.Id, EUR_GB_SAI_RT);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai1, sai2, sai3 };

		//Assertion before
		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.assertEquals(1, sasBefore.size());
		System.assertEquals(true, sasBefore[0].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		List<EUR_CRM_Store_Audit_Item__c> saisBefore = selectSais();
		System.assertEquals(3, saisBefore.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisBefore) {
			System.assertEquals(false, sai.EUR_JB_Listed__c);
		}

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-2);
		Datetime endDt = Datetime.now().addMinutes(2);
		EUR_CRM_StoreAuditItemConkerUpdate.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ 'Bad_RecordType' }, startDt, endDt, 200);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Store_Audit_Item__c> saisAfter = selectSais();
		System.assertEquals(3, saisAfter.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisAfter) {
			System.assertEquals(false, sai.EUR_JB_Listed__c, 'SAI wasnt been updated because of wrong RT passed to batch constructor');
		}
	}

	@IsTest
	private static void cleanSAIsWhereRtDevName_severalSas_Positive() {
		EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
		insert acc;

		EUR_CRM_Visit__c visit = makeVisit(acc.Id, EUR_GB_ON_TRADE_FS_VISIT);
		insert visit;

		EUR_CRM_Store_Audit__c sa1 = makeSA(acc.Id, EUR_GB_SA_RT);
		sa1.EUR_CRM_Audit_Datetime__c = Datetime.now(); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa1.EUR_CRM_Audit_Summary__c = '3 audits';

		EUR_CRM_Store_Audit__c sa2 = makeSA(acc.Id, EUR_GB_SA_RT);
		sa1.EUR_CRM_Audit_Datetime__c = Datetime.now().addMinutes(-2); //to populate SA.EUR_CRM_Is_Latest_Store_Audit_Formula__c
		sa2.EUR_CRM_Audit_Summary__c = '3 audits';
		insert new List<EUR_CRM_Store_Audit__c>{ sa1, sa2 };

		EUR_CRM_Store_Audit_Item__c sai11 = makeSAI(sa1.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai12 = makeSAI(sa1.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai13 = makeSAI(sa1.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai21 = makeSAI(sa2.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai22 = makeSAI(sa2.Id, EUR_GB_SAI_RT);
		EUR_CRM_Store_Audit_Item__c sai23 = makeSAI(sa2.Id, EUR_GB_SAI_RT);
		insert new List<EUR_CRM_Store_Audit_Item__c>{ sai11, sai12, sai13, sai21, sai22, sai23 };

		//Assertion before
		List<EUR_CRM_Store_Audit__c> sasBefore = selectSAs();
		System.assertEquals(2, sasBefore.size());
		System.assertEquals(true, sasBefore[0].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		System.assertEquals(false, sasBefore[1].EUR_CRM_Is_Latest_Store_Audit_Formula__c);
		List<EUR_CRM_Store_Audit_Item__c> saisBefore = selectSais();
		System.assertEquals(6, saisBefore.size());

		for (EUR_CRM_Store_Audit_Item__c sai : saisBefore) {
			System.assertEquals(false, sai.EUR_JB_Listed__c);
		}

		Test.startTest();
		Datetime startDt = Datetime.now().addMinutes(-5);
		Datetime endDt = Datetime.now().addMinutes(5);
		EUR_CRM_StoreAuditItemConkerUpdate.cleanRecordsWhereRtDevNameAndDates(new Set<String>{ EUR_GB_SA_RT }, startDt, endDt);
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Store_Audit__c> sasAfter = selectSAs();

		for (EUR_CRM_Store_Audit__c sa : sasAfter) {
			for (EUR_CRM_Store_Audit_Item__c sai : sa.Store_Audit_Items__r) {
				if (sa.Id == sa1.Id) {
					System.assertEquals(true, sai.EUR_JB_Listed__c, 'Sai was been updated');
				} else {
					System.assertEquals(false, sai.EUR_JB_Listed__c, 'Sai was not been updated');
				}
			}
		}
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


	//Selectors
	private static List<EUR_CRM_Store_Audit_Item__c> selectSais() {
		return [
			SELECT Id
				,   EUR_JB_Listed__c
			FROM EUR_CRM_Store_Audit_Item__c
		];
	}

	private static List<EUR_CRM_Store_Audit__c> selectSAs() {
		return [
			SELECT Id
			,   EUR_CRM_Is_Latest_Store_Audit_Formula__c
			,   EUR_CRM_Audit_Summary__c
			,   (
				SELECT Id, EUR_JB_Listed__c
				FROM Store_Audit_Items__r
				ORDER BY EUR_CRM_Mobile_ID__c
			)
			FROM EUR_CRM_Store_Audit__c
		];
	}
}