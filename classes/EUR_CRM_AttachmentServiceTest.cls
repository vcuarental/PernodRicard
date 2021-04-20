@IsTest(IsParallel = true)
private class EUR_CRM_AttachmentServiceTest {
	private static final String ACCOUNT_GB_FS_INDIRECT_RT = 'EUR_GB_FS_Indirect';
	private static final String CONTRACT_GB_RT = 'EUR_GB_Contract';
	private static final String CONTRACT_DRAFT_STATUS = 'Draft';
	private static final String ATTACHMENT_SUITABLE_NAME = 'SOME_NAME.PNG';
	private static final String ATTACHMENT_NOT_SUITABLE_NAME = 'SOME_NAME';

	@TestSetup
	private static void setup() {
		EUR_CRM_Account__c account = makeAccount(ACCOUNT_GB_FS_INDIRECT_RT);
		insert account;

		EUR_CRM_Contract__c contract1 = makeContract(account.Id, CONTRACT_GB_RT, CONTRACT_DRAFT_STATUS);
		EUR_CRM_Contract__c contract2 = makeContract(account.Id, CONTRACT_GB_RT, CONTRACT_DRAFT_STATUS);
		insert new List<EUR_CRM_Contract__c>{ contract1, contract2 };
	}

	@IsTest
	private static void setupTest() {
		System.assertEquals(1, selectSObjectsByType('EUR_CRM_Account__c').size());

		List<EUR_CRM_Contract__c> contracts = selectContracts();
		System.assertEquals(2, contracts.size());
		System.assertEquals(false, contracts[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(false, contracts[1].EUR_CRM_Contract_Uploaded__c);

	}

	//Start ContractsUpdater tests

	@IsTest
	private static void ContractsUpdater_insertAttachment_PositiveTest() {
		List<EUR_CRM_Contract__c> contracts = selectContracts();
		Attachment attachment1 = makeAttachment(contracts[0].Id, contracts[0].EUR_CRM_Contract_Copy_File_Name__c);
		Attachment attachment2 = makeAttachment(contracts[1].Id, contracts[1].EUR_CRM_Contract_Copy_File_Name__c);

		Test.startTest();
		insert new List<Attachment>{ attachment1, attachment2 };
		Test.stopTest();


		List<EUR_CRM_Contract__c> contractsAfterUpdate = selectContracts();

		System.assertEquals(2, contracts.size());
		System.assertEquals(true, contractsAfterUpdate[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(true, contractsAfterUpdate[1].EUR_CRM_Contract_Uploaded__c);
	}

	@IsTest
	private static void ContractsUpdater_insertAttachment_NegativeTest() {
		List<EUR_CRM_Contract__c> contracts = selectContracts();
		Attachment attachment1 = makeAttachment(contracts[0].Id, 'Not suitable name 1');
		Attachment attachment2 = makeAttachment(contracts[1].Id, 'Not suitable name 2');

		Test.startTest();
		insert new List<Attachment>{ attachment1, attachment2 };
		Test.stopTest();


		List<EUR_CRM_Contract__c> contractsAfterUpdate = selectContracts();

		System.assertEquals(2, contractsAfterUpdate.size());
		System.assertEquals(false, contractsAfterUpdate[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(false, contractsAfterUpdate[1].EUR_CRM_Contract_Uploaded__c);
	}

	@IsTest
	private static void ContractsUpdater_updateAttachment1_PositiveTest() {
		List<EUR_CRM_Contract__c> contracts = selectContracts();
		Attachment attachment1 = makeAttachment(contracts[0].Id, 'Not suitable name 1');
		Attachment attachment2 = makeAttachment(contracts[1].Id, 'Not suitable name 2');

		insert new List<Attachment>{ attachment1, attachment2 };

		List<EUR_CRM_Contract__c> contractsAfterInsert = selectContracts();
		System.assertEquals(2, contracts.size());
		System.assertEquals(false, contractsAfterInsert[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(false, contractsAfterInsert[1].EUR_CRM_Contract_Uploaded__c);

		Test.startTest();
		attachment1.Name = contracts[0].EUR_CRM_Contract_Copy_File_Name__c;
		attachment2.Name = contracts[1].EUR_CRM_Contract_Copy_File_Name__c;
		update new List<Attachment>{attachment1, attachment2};
		Test.stopTest();

		List<EUR_CRM_Contract__c> contractsAfterUpdate = selectContracts();
		System.assertEquals(2, contractsAfterUpdate.size());
		System.assertEquals(true, contractsAfterUpdate[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(true, contractsAfterUpdate[1].EUR_CRM_Contract_Uploaded__c);
	}

	@IsTest
	private static void ContractsUpdater_updateAttachment2_PositiveTest() {
		List<EUR_CRM_Contract__c> contracts = selectContracts();
		Attachment attachment1 = makeAttachment(contracts[0].Id, contracts[0].EUR_CRM_Contract_Copy_File_Name__c);
		Attachment attachment2 = makeAttachment(contracts[1].Id, contracts[1].EUR_CRM_Contract_Copy_File_Name__c);

		insert new List<Attachment>{ attachment1, attachment2 };

		List<EUR_CRM_Contract__c> contractsAfterInsert = selectContracts();
		System.assertEquals(2, contracts.size());
		System.assertEquals(true, contractsAfterInsert[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(true, contractsAfterInsert[1].EUR_CRM_Contract_Uploaded__c);

		Test.startTest();
		attachment1.Name = 'Not suitable name 1';
		attachment2.Name = 'Not suitable name 2';
		update new List<Attachment>{attachment1, attachment2};
		Test.stopTest();

		List<EUR_CRM_Contract__c> contractsAfterUpdate = selectContracts();
		System.assertEquals(2, contractsAfterUpdate.size());
		System.assertEquals(false, contractsAfterUpdate[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(false, contractsAfterUpdate[1].EUR_CRM_Contract_Uploaded__c);
	}

	@IsTest
	private static void ContractsUpdater_deleteAttachment_PositiveTest() {
		List<EUR_CRM_Contract__c> contracts = selectContracts();
		Attachment attachment1 = makeAttachment(contracts[0].Id, contracts[0].EUR_CRM_Contract_Copy_File_Name__c);
		Attachment attachment2 = makeAttachment(contracts[1].Id, contracts[1].EUR_CRM_Contract_Copy_File_Name__c);

		insert new List<Attachment>{ attachment1, attachment2 };

		List<EUR_CRM_Contract__c> contractsAfterInsert = selectContracts();
		System.assertEquals(2, contracts.size());
		System.assertEquals(true, contractsAfterInsert[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(true, contractsAfterInsert[1].EUR_CRM_Contract_Uploaded__c);

		Test.startTest();
		delete new List<Attachment>{ attachment1, attachment2 };
		Test.stopTest();

		List<EUR_CRM_Contract__c> contractsAfterUpdate = selectContracts();
		System.assertEquals(2, contractsAfterUpdate.size());
		System.assertEquals(false, contractsAfterUpdate[0].EUR_CRM_Contract_Uploaded__c);
		System.assertEquals(false, contractsAfterUpdate[1].EUR_CRM_Contract_Uploaded__c);
	}

	//End ContractsUpdater tests


	//Start SObjectsUpdater tests
	@IsTest
	private static void SObjectsUpdater_Account_1_PositiveTest() {
		EUR_CRM_Account__c acc = ((List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c'))[0];
		System.assertEquals(false, acc.EUR_CRM_IsPhotoAttached__c);

		Attachment attachment1 = makeAttachment(acc.Id, ATTACHMENT_SUITABLE_NAME);

		Test.startTest();
		insert attachment1;
		Test.stopTest();

		List<EUR_CRM_Account__c> updatedAccs = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(true, updatedAccs[0].EUR_CRM_IsPhotoAttached__c);

		delete attachment1;

		List<EUR_CRM_Account__c> updatedAccs2 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs2.size());
		System.assertEquals(false, updatedAccs2[0].EUR_CRM_IsPhotoAttached__c);

		undelete attachment1;
		List<EUR_CRM_Account__c> updatedAccs3 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs3.size());
		System.assertEquals(true, updatedAccs3[0].EUR_CRM_IsPhotoAttached__c);
	}

	@IsTest
	private static void SObjectsUpdater_Account_2_PositiveTest() {
		EUR_CRM_Account__c acc = ((List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c'))[0];
		System.assertEquals(false, acc.EUR_CRM_IsPhotoAttached__c);

		Attachment attachment1 = makeAttachment(acc.Id, ATTACHMENT_SUITABLE_NAME);
		Attachment attachment2 = makeAttachment(acc.Id, ATTACHMENT_SUITABLE_NAME);

		Test.startTest();
		insert new List<SObject>{attachment1, attachment2};
		Test.stopTest();

		List<EUR_CRM_Account__c> updatedAccs = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(true, updatedAccs[0].EUR_CRM_IsPhotoAttached__c);

		delete attachment1;

		List<EUR_CRM_Account__c> updatedAccs2 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs2.size());
		System.assertEquals(true, updatedAccs2[0].EUR_CRM_IsPhotoAttached__c);

		delete attachment2;
		List<EUR_CRM_Account__c> updatedAccs3 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs3.size());
		System.assertEquals(false, updatedAccs3[0].EUR_CRM_IsPhotoAttached__c);
	}

	@IsTest
	private static void SObjectsUpdater_Account_3_NegativeTest() {
		EUR_CRM_Account__c acc = ((List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c'))[0];
		System.assertEquals(false, acc.EUR_CRM_IsPhotoAttached__c);

		Attachment attachment1 = makeAttachment(acc.Id, ATTACHMENT_NOT_SUITABLE_NAME);

		Test.startTest();
		insert attachment1;
		Test.stopTest();

		List<EUR_CRM_Account__c> updatedAccs = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(false, updatedAccs[0].EUR_CRM_IsPhotoAttached__c);

		Attachment attachment2 = makeAttachment(acc.Id, ATTACHMENT_SUITABLE_NAME);
		insert attachment2;

		List<EUR_CRM_Account__c> updatedAccs2 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs2.size());
		System.assertEquals(true, updatedAccs2[0].EUR_CRM_IsPhotoAttached__c);

		delete attachment1;
		List<EUR_CRM_Account__c> updatedAccs3 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs3.size());
		System.assertEquals(true, updatedAccs3[0].EUR_CRM_IsPhotoAttached__c);

		undelete attachment1;
		List<EUR_CRM_Account__c> updatedAccs4 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		System.assertEquals(1, updatedAccs4.size());
		System.assertEquals(true, updatedAccs4[0].EUR_CRM_IsPhotoAttached__c);
	}

	@IsTest
	private static void SObjectsUpdater_6SObjects_PositiveTest() {
		createSObjects();

		List<EUR_CRM_Account__c> accs = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		List<EUR_CRM_Brand_Security_Infringement__c> bsis = (List<EUR_CRM_Brand_Security_Infringement__c>) selectSObjectsByType('EUR_CRM_Brand_Security_Infringement__c');
		List<EUR_CRM_Competitor_Promo_Tracking_Item__c> cptis = (List<EUR_CRM_Competitor_Promo_Tracking_Item__c>) selectSObjectsByType('EUR_CRM_Competitor_Promo_Tracking_Item__c');
		List<EUR_CRM_GB_Objective__c> gbObjectives = (List<EUR_CRM_GB_Objective__c>) selectSObjectsByType('EUR_CRM_GB_Objective__c');
		List<EUR_CRM_POSM_Audit_Item__c> pais = (List<EUR_CRM_POSM_Audit_Item__c>) selectSObjectsByType('EUR_CRM_POSM_Audit_Item__c');
		List<EUR_CRM_OP_Visit_Action__c> vas = (List<EUR_CRM_OP_Visit_Action__c>) selectSObjectsByType('EUR_CRM_OP_Visit_Action__c');
		List<EUR_CRM_Visit_Action__c> visitActions = (List<EUR_CRM_Visit_Action__c>) selectSObjectsByType('EUR_CRM_Visit_Action__c');
		List<EUR_CRM_Visit_Sub_Action__c> visitSubActions = (List<EUR_CRM_Visit_Sub_Action__c>) selectSObjectsByType('EUR_CRM_Visit_Sub_Action__c');

		System.assertEquals(1, accs.size());
		System.assertEquals(1, bsis.size());
		System.assertEquals(1, cptis.size());
		System.assertEquals(1, gbObjectives.size());
		System.assertEquals(1, pais.size());
		System.assertEquals(1, vas.size());
		System.assertEquals(1, visitActions.size());
		System.assertEquals(1, visitSubActions.size());
		System.assertEquals(false, accs[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, bsis[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, cptis[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, gbObjectives[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, pais[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, vas[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, visitActions[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, visitSubActions[0].EUR_CRM_IsPhotoAttached__c);

		Attachment accAt = makeAttachment(accs[0].Id, ATTACHMENT_SUITABLE_NAME);
		Attachment bsiAt = makeAttachment(bsis[0].Id, ATTACHMENT_SUITABLE_NAME);
		Attachment cptiAt = makeAttachment(cptis[0].Id, ATTACHMENT_SUITABLE_NAME);
		Attachment gbObjAt = makeAttachment(gbObjectives[0].Id, ATTACHMENT_SUITABLE_NAME);
		Attachment paiAt = makeAttachment(pais[0].Id, ATTACHMENT_SUITABLE_NAME);
		Attachment vaAt = makeAttachment(vas[0].Id, ATTACHMENT_SUITABLE_NAME);
		Attachment va2At = makeAttachment(visitActions[0].Id, ATTACHMENT_SUITABLE_NAME);
		Attachment vsaAt = makeAttachment(visitSubActions[0].Id, ATTACHMENT_SUITABLE_NAME);
		Test.startTest();
		List<Attachment> attachments = new List<Attachment>{accAt, bsiAt, cptiAt, gbObjAt, paiAt, vaAt, va2At, vsaAt};
		insert attachments;
		Test.stopTest();

		List<EUR_CRM_Account__c> accsUpdated1 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		List<EUR_CRM_Brand_Security_Infringement__c> bsisUpdated1 = (List<EUR_CRM_Brand_Security_Infringement__c>) selectSObjectsByType('EUR_CRM_Brand_Security_Infringement__c');
		List<EUR_CRM_Competitor_Promo_Tracking_Item__c> cptisUpdated1 = (List<EUR_CRM_Competitor_Promo_Tracking_Item__c>) selectSObjectsByType('EUR_CRM_Competitor_Promo_Tracking_Item__c');
		List<EUR_CRM_GB_Objective__c> gbObjectivesUpdated1 = (List<EUR_CRM_GB_Objective__c>) selectSObjectsByType('EUR_CRM_GB_Objective__c');
		List<EUR_CRM_POSM_Audit_Item__c> paisUpdated1 = (List<EUR_CRM_POSM_Audit_Item__c>) selectSObjectsByType('EUR_CRM_POSM_Audit_Item__c');
		List<EUR_CRM_OP_Visit_Action__c> vasUpdated1 = (List<EUR_CRM_OP_Visit_Action__c>) selectSObjectsByType('EUR_CRM_OP_Visit_Action__c');
		List<EUR_CRM_Visit_Action__c> visitActionsUpdated = (List<EUR_CRM_Visit_Action__c>) selectSObjectsByType('EUR_CRM_Visit_Action__c');
		List<EUR_CRM_Visit_Sub_Action__c> visitSubActionsUpdated = (List<EUR_CRM_Visit_Sub_Action__c>) selectSObjectsByType('EUR_CRM_Visit_Sub_Action__c');

		System.assertEquals(1, accsUpdated1.size());
		System.assertEquals(1, bsisUpdated1.size());
		System.assertEquals(1, cptisUpdated1.size());
		System.assertEquals(1, gbObjectivesUpdated1.size());
		System.assertEquals(1, paisUpdated1.size());
		System.assertEquals(1, vasUpdated1.size());
		System.assertEquals(true, accsUpdated1[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, bsisUpdated1[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, cptisUpdated1[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, gbObjectivesUpdated1[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, paisUpdated1[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, vasUpdated1[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, visitActionsUpdated[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, visitSubActionsUpdated[0].EUR_CRM_IsPhotoAttached__c);

		delete attachments;

		List<EUR_CRM_Account__c> accsUpdated2 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		List<EUR_CRM_Brand_Security_Infringement__c> bsisUpdated2 = (List<EUR_CRM_Brand_Security_Infringement__c>) selectSObjectsByType('EUR_CRM_Brand_Security_Infringement__c');
		List<EUR_CRM_Competitor_Promo_Tracking_Item__c> cptisUpdated2 = (List<EUR_CRM_Competitor_Promo_Tracking_Item__c>) selectSObjectsByType('EUR_CRM_Competitor_Promo_Tracking_Item__c');
		List<EUR_CRM_GB_Objective__c> gbObjectivesUpdated2 = (List<EUR_CRM_GB_Objective__c>) selectSObjectsByType('EUR_CRM_GB_Objective__c');
		List<EUR_CRM_POSM_Audit_Item__c> paisUpdated2 = (List<EUR_CRM_POSM_Audit_Item__c>) selectSObjectsByType('EUR_CRM_POSM_Audit_Item__c');
		List<EUR_CRM_OP_Visit_Action__c> vasUpdated2 = (List<EUR_CRM_OP_Visit_Action__c>) selectSObjectsByType('EUR_CRM_OP_Visit_Action__c');

		System.assertEquals(1, accsUpdated2.size());
		System.assertEquals(1, bsisUpdated2.size());
		System.assertEquals(1, cptisUpdated2.size());
		System.assertEquals(1, gbObjectivesUpdated2.size());
		System.assertEquals(1, paisUpdated2.size());
		System.assertEquals(1, vasUpdated2.size());
		System.assertEquals(false, accsUpdated2[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, bsisUpdated2[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, cptisUpdated2[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, gbObjectivesUpdated2[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, paisUpdated2[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(false, vasUpdated2[0].EUR_CRM_IsPhotoAttached__c);


		undelete attachments;

		List<EUR_CRM_Account__c> accsUpdated3 = (List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c');
		List<EUR_CRM_Brand_Security_Infringement__c> bsisUpdated3 = (List<EUR_CRM_Brand_Security_Infringement__c>) selectSObjectsByType('EUR_CRM_Brand_Security_Infringement__c');
		List<EUR_CRM_Competitor_Promo_Tracking_Item__c> cptisUpdated3 = (List<EUR_CRM_Competitor_Promo_Tracking_Item__c>) selectSObjectsByType('EUR_CRM_Competitor_Promo_Tracking_Item__c');
		List<EUR_CRM_GB_Objective__c> gbObjectivesUpdated3 = (List<EUR_CRM_GB_Objective__c>) selectSObjectsByType('EUR_CRM_GB_Objective__c');
		List<EUR_CRM_POSM_Audit_Item__c> paisUpdated3 = (List<EUR_CRM_POSM_Audit_Item__c>) selectSObjectsByType('EUR_CRM_POSM_Audit_Item__c');
		List<EUR_CRM_OP_Visit_Action__c> vasUpdated3 = (List<EUR_CRM_OP_Visit_Action__c>) selectSObjectsByType('EUR_CRM_OP_Visit_Action__c');

		System.assertEquals(1, accsUpdated3.size());
		System.assertEquals(1, bsisUpdated3.size());
		System.assertEquals(1, cptisUpdated3.size());
		System.assertEquals(1, gbObjectivesUpdated3.size());
		System.assertEquals(1, paisUpdated3.size());
		System.assertEquals(1, vasUpdated3.size());
		System.assertEquals(true, accsUpdated3[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, bsisUpdated3[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, cptisUpdated3[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, gbObjectivesUpdated3[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, paisUpdated3[0].EUR_CRM_IsPhotoAttached__c);
		System.assertEquals(true, vasUpdated3[0].EUR_CRM_IsPhotoAttached__c);

	}

	//End SObjectsUpdater tests


	//Makers
	private static void createSObjects() {
		EUR_CRM_Account__c acc = ((List<EUR_CRM_Account__c>) selectSObjectsByType('EUR_CRM_Account__c'))[0];
		
		EUR_CRM_Competitor_Promo_Tracking__c cpt = makeCompetitorPromoTracking(acc.Id);
		EUR_CRM_POSM_Audit__c pa = makePOSMAudit(acc.Id);
		EUR_CRM_Visit__c visit = makeVisit(acc.Id);
		insert new List<SObject>{cpt, pa, visit};
		
		EUR_CRM_Brand_Security_Infringement__c bsi = makeBrandSecurityInfringement(acc.Id);
		EUR_CRM_Competitor_Promo_Tracking_Item__c cpti = makeCompetitorPromoTrackingItem(cpt.Id);
		EUR_CRM_GB_Objective__c gbObjective = makeObjective(acc.Id);
		EUR_CRM_POSM_Audit_Item__c pai = makePOSMAuditItem(pa.Id);
		EUR_CRM_OP_Visit_Action__c va = makeOPVisitAction(visit.Id);
		EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c(EUR_CRM_Visit_ID__c = visit.Id);
		insert new List<SObject>{bsi, cpti, gbObjective, pai, va, visitAction};

		EUR_CRM_Visit_Sub_Action__c visitSubAction = new EUR_CRM_Visit_Sub_Action__c(EUR_CRM_Visit_Action__c = visitAction.Id);
		insert visitSubAction;

	}

	private static EUR_CRM_Account__c makeAccount(String rt) {
		return new EUR_CRM_Account__c(
			RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId()
		,   EUR_CRM_Postal_Code__c = '012345'
		);
	}

	private static EUR_CRM_Contract__c makeContract(Id accId, String rt, String status) {
		return new EUR_CRM_Contract__c(
			RecordTypeId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId()
		,	EUR_CRM_Account__c = accId
		,	EUR_CRM_Status__c = status
		);
	}

	private static EUR_CRM_Brand_Security_Infringement__c makeBrandSecurityInfringement(Id accId) {
		return new EUR_CRM_Brand_Security_Infringement__c(
			EUR_CRM_Outlet_Name__c = accId
		);
	}

	private static EUR_CRM_Competitor_Promo_Tracking__c makeCompetitorPromoTracking(Id accId) {
		return new EUR_CRM_Competitor_Promo_Tracking__c(
			EUR_CRM_Account_Name__c = accId
		);
	}

	private static EUR_CRM_Competitor_Promo_Tracking_Item__c makeCompetitorPromoTrackingItem(Id cptId) {
		return new EUR_CRM_Competitor_Promo_Tracking_Item__c(
			EUR_CRM_Competitor_Promo_Tracking__c = cptId
		);
	}

	private static EUR_CRM_GB_Objective__c makeObjective(Id accId) {
		return new EUR_CRM_GB_Objective__c(
			EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_POSM_Audit__c makePOSMAudit(Id accId) {
		return new EUR_CRM_POSM_Audit__c(
			EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_POSM_Audit_Item__c makePOSMAuditItem(Id paId) {
		return new EUR_CRM_POSM_Audit_Item__c(
			EUR_CRM_POSM_Audit__c = paId
		);
	}

	private static EUR_CRM_Visit__c makeVisit(Id accId) {
		return new EUR_CRM_Visit__c(
			EUR_CRM_Start_Datetime__c = Datetime.now()
			,   EUR_CRM_End_Datetime__c = Datetime.now().addDays(1)
			,   EUR_CRM_Account__c = accId
		);
	}

	public static EUR_CRM_OP_Visit_Action__c makeOPVisitAction(Id visitId) {
		return new EUR_CRM_OP_Visit_Action__c(
			EUR_CRM_Visit__c = visitId
		);
	}

	private static Attachment makeAttachment(Id parentId, String name) {
		return new Attachment(
			ParentId = parentId
			,   Name = name
			,   Body = Blob.valueOf('String')
			,   ContentType = 'image/png'
		);
	}


	//Selectors
	private static List<EUR_CRM_Contract__c> selectContracts() {
		return [
			SELECT Id
			,   EUR_CRM_Contract_Copy_File_Name__c
			,   EUR_CRM_Contract_Uploaded__c
			FROM EUR_CRM_Contract__c
		];
	}

	private static List<SObject> selectSObjectsByType(String sObjectType) {
		return new EUR_CRM_QueryBuilder(sObjectType)
			.qbField('EUR_CRM_IsPhotoAttached__c')
			.toList();
	}

}