@IsTest(IsParallel = true)
private class EUR_CRM_POSMaterialPIMImagesBatchTest {
	private static final Integer COUNT_OF_RECORDS = 5;

	@TestSetup
	private static void setupMethod() {
		insert makePOSMs();
	}

	@IsTest
	private static void setupTest() {
		Test.startTest();
		List<EUR_CRM_POS_Material__c> posms = selectPOSMs();
		System.assertEquals(COUNT_OF_RECORDS, posms.size());
		Test.stopTest();
	}

	@IsTest
	private static void allCountryTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
		Database.executeBatch(new EUR_CRM_POSMaterialPIMImagesBatch(), 10);
		Test.stopTest();

		List<EUR_CRM_POS_Material__c> posms = selectPOSMs();
		System.assertEquals(COUNT_OF_RECORDS, posms.size());

		for (EUR_CRM_POS_Material__c posm : posms) {
			System.assertEquals(1, posm.Attachments.size());
		}
	}

	@IsTest
	private static void specificCountryTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
		Database.executeBatch(new EUR_CRM_POSMaterialPIMImagesBatch('RU'), 10);
		Test.stopTest();

		List<EUR_CRM_POS_Material__c> posms = selectPOSMs();
		System.assertEquals(COUNT_OF_RECORDS, posms.size());

		for (EUR_CRM_POS_Material__c posm : posms) {
			System.assertEquals(1, posm.Attachments.size());
		}
	}

	@IsTest
	private static void overrideAttachmentsTest() {
		List<EUR_CRM_POS_Material__c> posms = selectPOSMs();
		List<Attachment> attachments = new List<Attachment>();
		for (EUR_CRM_POS_Material__c posm : posms) {
			attachments.add(makeAttachment(posm));
		}
		insert attachments;

		posms = selectPOSMs();
		System.assertEquals(COUNT_OF_RECORDS, posms.size());
		for (EUR_CRM_POS_Material__c posm : posms) {
			System.assertEquals(1, posm.Attachments.size());
		}

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
		Database.executeBatch(new EUR_CRM_POSMaterialPIMImagesBatch(), 10);
		Test.stopTest();

		posms = selectPOSMs();
		System.assertEquals(COUNT_OF_RECORDS, posms.size());

		for (EUR_CRM_POS_Material__c posm : posms) {
			System.assertEquals(1, posm.Attachments.size());
		}
	}


	/* ========================================================= */
	/*     High Level Makers
	/* ========================================================= */
	private static List<EUR_CRM_POS_Material__c> makePOSMs() {
		List<EUR_CRM_POS_Material__c> posms = new List<EUR_CRM_POS_Material__c>();
		for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
			posms.add(makePOSM());
		}
		return posms;
	}


	/* ========================================================= */
	/*     Low Level Makers
	/* ========================================================= */
	private static EUR_CRM_POS_Material__c makePOSM() {
		return new EUR_CRM_POS_Material__c(
			RecordTypeId = Schema.SObjectType.EUR_CRM_POS_Material__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_POS_Material').getRecordTypeId()
			,   EUR_CRM_POSM_Image_URL__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg?version=1518055414426'
		);
	}

	private static Attachment makeAttachment(EUR_CRM_POS_Material__c posm) {
		String name = posm.EUR_CRM_POSM_Image_URL__c.substringAfterLast('/').substringBeforeLast('.') + '.png';
		return new Attachment(
			ParentId = posm.Id
			,   Name = name
			,   Body = Blob.valueOf('String')
			,   ContentType = 'image/png'
		);
	}


	/* ========================================================= */
	/*     SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_POS_Material__c> selectPOSMs() {
		return [
			SELECT Id
				,   EUR_CRM_POSM_Image_URL__c
				,   (
				SELECT Id
					,   Name
				FROM Attachments
			)
			FROM EUR_CRM_POS_Material__c
		];
	}

}