@IsTest(IsParallel=true)
private class EUR_CRM_AccountListingTemplateBatchTest {

	private static final String IL_GB_RT = 'EUR_GB_PRS_Segmentation_Aspect_Image_Level';
	private static final String VP_GB_RT = 'EUR_GB_PRS_Segmentation_Aspect_Volume_Potential';
	private static final String GOT_GB_RT = 'EUR_GB_PRS_On_Trade_Group_Outlet_Type';
	private static final String OT_GB_RT = 'EUR_GB_PRS_On_Trade_Outlet_Type';
	private static final String TEMPLATE_GB_RT = 'EUR_GB_Template';
	private static final String TEMPLATE_CRITERIA_GB_RT = 'EUR_GB_Template_Criteria';
	private static final String TEMPLATE_CRITERIA_DB_RT = 'EUR_DB_On_Trade_Template_Criteria';
	private static final Set<String> ACC_GB_RTS =  new Set<String> {
		'EUR_GB_FS_Indirect'
	,	'EUR_GB_FS_RTM'
	};


	@IsTest
	private static void accountStatusActive_positiveTest() {
		EUR_CRM_PRS_Group_Outlet_Type__c got = makePrsGOT(GOT_GB_RT);
		insert got;

		EUR_CRM_PRS_Outlet_Type__c ot = makePrsOT(got.Id, OT_GB_RT);

		EUR_CRM_PRS_Seg_Aspect__c il = makePrsSA(IL_GB_RT);
		EUR_CRM_PRS_Seg_Aspect__c vp = makePrsSA(VP_GB_RT);

		Database.insert(new List<SObject>{ot, il, vp});

		EUR_CRM_JB_Template__c template = makeTemplate(TEMPLATE_GB_RT);
		insert template;

		EUR_CRM_JB_Template_Criteria__c templateCriteria = makeTemplateCriteria(TEMPLATE_CRITERIA_GB_RT);
		templateCriteria.EUR_JB_Template__c = template.Id;
		templateCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		templateCriteria.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_IL__c = il.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_VP__c = vp.Id;
		insert templateCriteria;

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		acc.EUR_CRM_Status__c = 'Active';
		acc.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		acc.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		acc.EUR_CRM_PRS_Image_Level__c = il.Id;
		acc.EUR_CRM_PRS_Volume_Potential__c = vp.Id;
		insert acc;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountListingTemplateBatch(new Map<String, String>{ 'EUR_GB_FS_Indirect' => TEMPLATE_CRITERIA_GB_RT}));
		Test.stopTest();

		List<EUR_CRM_Account__c> accsAfterInsert = selectAccounts();
		System.assertEquals(1, accsAfterInsert.size());
		System.assertEquals(template.Id, accsAfterInsert[0].EUR_CRM_Listing_Template__c);
	}

	@IsTest
	private static void accountAndCriteriaWithNullPrs_positiveTest() {
		EUR_CRM_PRS_Group_Outlet_Type__c got = makePrsGOT(GOT_GB_RT);
		insert got;

		EUR_CRM_PRS_Outlet_Type__c ot = makePrsOT(got.Id, OT_GB_RT);

		EUR_CRM_PRS_Seg_Aspect__c il = makePrsSA(IL_GB_RT);
		EUR_CRM_PRS_Seg_Aspect__c vp = makePrsSA(VP_GB_RT);

		Database.insert(new List<SObject>{ot, il, vp});

		EUR_CRM_JB_Template__c template = makeTemplate(TEMPLATE_GB_RT);
		insert template;

		EUR_CRM_JB_Template_Criteria__c templateCriteria = makeTemplateCriteria(TEMPLATE_CRITERIA_GB_RT);
		templateCriteria.EUR_JB_Template__c = template.Id;
//		templateCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
//		templateCriteria.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
//		templateCriteria.EUR_CRM_PRS_Seg_Aspect_IL__c = il.Id;
//		templateCriteria.EUR_CRM_PRS_Seg_Aspect_VP__c = vp.Id;
		insert templateCriteria;

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		acc.EUR_CRM_Status__c = 'Active';
//		acc.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
//		acc.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
//		acc.EUR_CRM_PRS_Image_Level__c = il.Id;
//		acc.EUR_CRM_PRS_Volume_Potential__c = vp.Id;
		insert acc;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountListingTemplateBatch(new Map<String, String>{ 'EUR_GB_FS_Indirect' => TEMPLATE_CRITERIA_GB_RT}));
		Test.stopTest();

		List<EUR_CRM_Account__c> accsAfterInsert = selectAccounts();
		System.assertEquals(1, accsAfterInsert.size());
		System.assertEquals(template.Id, accsAfterInsert[0].EUR_CRM_Listing_Template__c);
	}

	@IsTest
	private static void incorrectBatchArguments_negativeTest() {
		EUR_CRM_PRS_Group_Outlet_Type__c got = makePrsGOT(GOT_GB_RT);
		insert got;

		EUR_CRM_PRS_Outlet_Type__c ot = makePrsOT(got.Id, OT_GB_RT);

		EUR_CRM_PRS_Seg_Aspect__c il = makePrsSA(IL_GB_RT);
		EUR_CRM_PRS_Seg_Aspect__c vp = makePrsSA(VP_GB_RT);

		Database.insert(new List<SObject>{ot, il, vp});

		EUR_CRM_JB_Template__c template = makeTemplate(TEMPLATE_GB_RT);
		insert template;

		EUR_CRM_JB_Template_Criteria__c templateCriteria = makeTemplateCriteria(TEMPLATE_CRITERIA_GB_RT);
		templateCriteria.EUR_JB_Template__c = template.Id;
		templateCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		templateCriteria.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_IL__c = il.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_VP__c = vp.Id;
		insert templateCriteria;

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		acc.EUR_CRM_Status__c = 'Active';
		acc.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		acc.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		acc.EUR_CRM_PRS_Image_Level__c = il.Id;
		acc.EUR_CRM_PRS_Volume_Potential__c = vp.Id;
		insert acc;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountListingTemplateBatch(new Map<String, String>{ 'EUR_GB_FS_RTM' => TEMPLATE_CRITERIA_GB_RT}));
		Test.stopTest();

		List<EUR_CRM_Account__c> accsAfterInsert = selectAccounts();
		System.assertEquals(1, accsAfterInsert.size());
		System.assertEquals(null, accsAfterInsert[0].EUR_CRM_Listing_Template__c);
	}

	@IsTest
	private static void incorrectBatchArguments_2_negativeTest() {
		EUR_CRM_PRS_Group_Outlet_Type__c got = makePrsGOT(GOT_GB_RT);
		insert got;

		EUR_CRM_PRS_Outlet_Type__c ot = makePrsOT(got.Id, OT_GB_RT);

		EUR_CRM_PRS_Seg_Aspect__c il = makePrsSA(IL_GB_RT);
		EUR_CRM_PRS_Seg_Aspect__c vp = makePrsSA(VP_GB_RT);

		Database.insert(new List<SObject>{ot, il, vp});

		EUR_CRM_JB_Template__c template = makeTemplate(TEMPLATE_GB_RT);
		insert template;

		EUR_CRM_JB_Template_Criteria__c templateCriteria = makeTemplateCriteria(TEMPLATE_CRITERIA_GB_RT);
		templateCriteria.EUR_JB_Template__c = template.Id;
		templateCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		templateCriteria.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_IL__c = il.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_VP__c = vp.Id;
		insert templateCriteria;

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		acc.EUR_CRM_Status__c = 'Active';
		acc.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		acc.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		acc.EUR_CRM_PRS_Image_Level__c = il.Id;
		acc.EUR_CRM_PRS_Volume_Potential__c = vp.Id;
		insert acc;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountListingTemplateBatch(new Map<String, String>{ 'EUR_GB_FS_Indirect' => TEMPLATE_CRITERIA_DB_RT}));
		Test.stopTest();

		List<EUR_CRM_Account__c> accsAfterInsert = selectAccounts();
		System.assertEquals(1, accsAfterInsert.size());
		System.assertEquals(null, accsAfterInsert[0].EUR_CRM_Listing_Template__c);
	}

	@IsTest
	private static void accountStatusNotActive_negativeTest() {
		EUR_CRM_PRS_Group_Outlet_Type__c got = makePrsGOT(GOT_GB_RT);
		insert got;

		EUR_CRM_PRS_Outlet_Type__c ot = makePrsOT(got.Id, OT_GB_RT);

		EUR_CRM_PRS_Seg_Aspect__c il = makePrsSA(IL_GB_RT);
		EUR_CRM_PRS_Seg_Aspect__c vp = makePrsSA(VP_GB_RT);

		Database.insert(new List<SObject>{ot, il, vp});

		EUR_CRM_JB_Template__c template = makeTemplate(TEMPLATE_GB_RT);
		insert template;

		EUR_CRM_JB_Template_Criteria__c templateCriteria = makeTemplateCriteria(TEMPLATE_CRITERIA_GB_RT);
		templateCriteria.EUR_JB_Template__c = template.Id;
		templateCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		templateCriteria.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_IL__c = il.Id;
		templateCriteria.EUR_CRM_PRS_Seg_Aspect_VP__c = vp.Id;
		insert templateCriteria;

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		acc.EUR_CRM_Status__c = 'Inactive';
		acc.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
		acc.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
		acc.EUR_CRM_PRS_Image_Level__c = il.Id;
		acc.EUR_CRM_PRS_Volume_Potential__c = vp.Id;
		insert acc;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_AccountListingTemplateBatch(new Map<String, String>{ 'EUR_GB_FS_Indirect' => TEMPLATE_CRITERIA_GB_RT}));
		Test.stopTest();

		List<EUR_CRM_Account__c> accsAfterInsert = selectAccounts();
		System.assertEquals(1, accsAfterInsert.size());
		System.assertEquals(null, accsAfterInsert[0].EUR_CRM_Listing_Template__c);
	}

//	@IsTest
//	private static void criteriaNotActive_NegativeTest() {
//		EUR_CRM_PRS_Group_Outlet_Type__c got = makePrsGOT(GOT_GB_RT);
//		insert got;
//
//		EUR_CRM_PRS_Outlet_Type__c ot = makePrsOT(got.Id, OT_GB_RT);
//
//		EUR_CRM_PRS_Seg_Aspect__c il = makePrsSA(IL_GB_RT);
//		EUR_CRM_PRS_Seg_Aspect__c vp = makePrsSA(VP_GB_RT);
//
//		Database.insert(new List<SObject>{ot, il, vp});
//
//		EUR_CRM_JB_Template__c template = makeTemplate(TEMPLATE_GB_RT);
//		insert template;
//
//		EUR_CRM_JB_Template_Criteria__c templateCriteria = makeTemplateCriteria(TEMPLATE_CRITERIA_GB_RT);
//		templateCriteria.EUR_JB_Template__c = template.Id;
//		templateCriteria.EUR_JB_Active__c = false;
//		templateCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
//		templateCriteria.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
//		templateCriteria.EUR_CRM_PRS_Seg_Aspect_IL__c = il.Id;
//		templateCriteria.EUR_CRM_PRS_Seg_Aspect_VP__c = vp.Id;
//		insert templateCriteria;
//
//		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
//		acc.EUR_CRM_Status__c = 'Active';
//		acc.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
//		acc.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
//		acc.EUR_CRM_PRS_Image_Level__c = il.Id;
//		acc.EUR_CRM_PRS_Volume_Potential__c = vp.Id;
//		insert acc;
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_AccountListingTemplateBatch(new Map<String, String>{ 'EUR_GB_FS_Indirect' => TEMPLATE_CRITERIA_GB_RT}));
//		Test.stopTest();
//
//		List<EUR_CRM_Account__c> accsAfterInsert = selectAccounts();
//		System.assertEquals(1, accsAfterInsert.size());
//		System.assertEquals(null, accsAfterInsert[0].EUR_CRM_Listing_Template__c);
//	}


//	@IsTest
//	private static void accountMassUpdate_positiveTest() {
//		EUR_CRM_PRS_Group_Outlet_Type__c got = makePrsGOT(GOT_GB_RT);
//		insert got;
//
//		EUR_CRM_PRS_Outlet_Type__c ot = makePrsOT(got.Id, OT_GB_RT);
//
//		EUR_CRM_PRS_Seg_Aspect__c il = makePrsSA(IL_GB_RT);
//		EUR_CRM_PRS_Seg_Aspect__c vp = makePrsSA(VP_GB_RT);
//
//		Database.insert(new List<SObject>{ot, il, vp});
//
//		EUR_CRM_JB_Template__c template = makeTemplate(TEMPLATE_GB_RT);
//		insert template;
//
//		EUR_CRM_JB_Template_Criteria__c templateCriteria = makeTemplateCriteria(TEMPLATE_CRITERIA_GB_RT);
//		templateCriteria.EUR_JB_Template__c = template.Id;
//		templateCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
//		templateCriteria.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
//		templateCriteria.EUR_CRM_PRS_Seg_Aspect_IL__c = il.Id;
//		templateCriteria.EUR_CRM_PRS_Seg_Aspect_VP__c = vp.Id;
//		insert templateCriteria;
//
//		List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//		for (Integer i = 0; i < 5; i++) {
//			EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
//			acc.EUR_CRM_Status__c = 'Active';
//			acc.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
//			acc.EUR_CRM_PRS_Outlet_Type__c = ot.Id;
//			acc.EUR_CRM_PRS_Image_Level__c = il.Id;
//			acc.EUR_CRM_PRS_Volume_Potential__c = vp.Id;
//			accounts.add(acc);
//		}
//
//		insert accounts;
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_AccountListingTemplateBatch(new Map<String, String>{ 'EUR_GB_FS_Indirect' => TEMPLATE_CRITERIA_GB_RT}));
//		Test.stopTest();
//
//		List<EUR_CRM_Account__c> accsAfterInsert = selectAccounts();
//		System.assertEquals(5, accsAfterInsert.size());
//		for (EUR_CRM_Account__c acc : accsAfterInsert) {
//			System.assertEquals(template.Id, acc.EUR_CRM_Listing_Template__c);
//		}
//	}

	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			EUR_CRM_Postal_Code__c = '12345'
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_PRS_Group_Outlet_Type__c makePrsGOT(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_PRS_Group_Outlet_Type__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_PRS_Outlet_Type__c makePrsOT(Id gotId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_PRS_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_PRS_Outlet_Type__c(
			EUR_CRM_PRS_Group_Outlet_Type__c = gotId
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_PRS_Seg_Aspect__c makePrsSA(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_PRS_Seg_Aspect__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_JB_Template__c makeTemplate(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_JB_Template__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_JB_Template_Criteria__c makeTemplateCriteria(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_JB_Template_Criteria__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_JB_Template_Criteria__c(
			EUR_JB_Active__c = true
		,	RecordTypeId = rtId
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Account__c> selectAccounts() {
		return [
			SELECT Id
			,	EUR_CRM_PRS_Group_Outlet_Type__c
			,	EUR_CRM_PRS_Outlet_Type__c
			,	EUR_CRM_PRS_Image_Level__c
			,	EUR_CRM_PRS_Volume_Potential__c
			,	EUR_CRM_Listing_Template__c
			FROM EUR_CRM_Account__c
		];
	}
}