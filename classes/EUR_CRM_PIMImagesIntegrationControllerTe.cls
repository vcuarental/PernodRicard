@IsTest (isParallel = true)
private class EUR_CRM_PIMImagesIntegrationControllerTe {
    private static final Integer COUNT_OF_RECORDS = 5;

    @IsTest
    private static void gettersBQSTest() {
        EUR_CRM_Size__c bqs = new EUR_CRM_Size__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByName().get('EUR RU Size').getRecordTypeId()
        ,   EUR_CRM_Size_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg?version=1518055384134'
        );
        insert bqs;

        Attachment att = new Attachment(
            ParentId = bqs.Id
        ,   Body = Blob.valueOf('String')
        ,   Name = 'G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg'
        );
        insert att;

        Document doc = new Document(
            Name = 'EUR_CRM_RU_BQS_Logos.zip'
        ,   Body = Blob.valueOf('String')
        ,   FolderId = UserInfo.getUserId()
        );
        insert doc;

        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        List<EUR_CRM_PIMImagesIntegrationController.DocumentWrapper> documentWrappers = controller.documentsBQS;
        System.assertEquals(1, documentWrappers.size());
        List<EUR_CRM_PIMImagesIntegrationController.StatisticWrapper> statisticWrappers = controller.attachmentStatisticWrapperBQS;
        System.assertEquals(1, statisticWrappers.size());

        documentWrappers = controller.documentsBQ;
        statisticWrappers = controller.attachmentStatisticWrapperBQ;

        documentWrappers = controller.documentsB;
        statisticWrappers = controller.attachmentStatisticWrapperB;

        System.assertEquals(null, controller.disableReDownloadImagesForAllCountriesBQS);
        System.assertEquals(null, controller.disableReDownloadImagesForAllCountriesBQ);
        System.assertEquals(null, controller.disableReDownloadImagesForAllCountriesB);
        Test.stopTest();
    }

    @IsTest
    private static void gettersBQTest() {
        EUR_CRM_Quality__c bq = new EUR_CRM_Quality__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByName().get('EUR RU Quality').getRecordTypeId()
        ,   EUR_CRM_Quality_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg?version=1518055384134'
        );
        insert bq;

        Attachment att = new Attachment(
            ParentId = bq.Id
        ,   Body = Blob.valueOf('String')
        ,   Name = 'G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg'
        );
        insert att;

        Document doc = new Document(
            Name = 'EUR_CRM_RU_BQ_Logos.zip'
        ,   Body = Blob.valueOf('String')
        ,   FolderId = UserInfo.getUserId()
        );
        insert doc;

        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        List<EUR_CRM_PIMImagesIntegrationController.DocumentWrapper> documentWrappers = controller.documentsBQ;
        System.assertEquals(1, documentWrappers.size());
        List<EUR_CRM_PIMImagesIntegrationController.StatisticWrapper> statisticWrappers = controller.attachmentStatisticWrapperBQ;
        System.assertEquals(1, statisticWrappers.size());
        Test.stopTest();
    }

    @IsTest
    private static void gettersBTest() {
        EUR_CRM_Brand__c b = new EUR_CRM_Brand__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByName().get('EUR RU Brand').getRecordTypeId()
        ,   EUR_CRM_Brand_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg?version=1518055384134'
        );
        insert b;

        Attachment att = new Attachment(
            ParentId = b.Id
        ,   Body = Blob.valueOf('String')
        ,   Name = 'G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg'
        );
        insert att;

        Document doc = new Document(
            Name = 'EUR_CRM_RU_B_Logos.zip'
        ,   Body = Blob.valueOf('String')
        ,   FolderId = UserInfo.getUserId()
        );
        insert doc;

        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        List<EUR_CRM_PIMImagesIntegrationController.DocumentWrapper> documentWrappers = controller.documentsB;
        System.assertEquals(1, documentWrappers.size());
        List<EUR_CRM_PIMImagesIntegrationController.StatisticWrapper> statisticWrappers = controller.attachmentStatisticWrapperB;
        System.assertEquals(1, statisticWrappers.size());
        Test.stopTest();
    }

    @IsTest
    private static void getAttachmentsTest() {
        EUR_CRM_Size__c bqs = new EUR_CRM_Size__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByName().get('EUR RU Size').getRecordTypeId()
        ,   EUR_CRM_Size_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg?version=1518055384134'
        );
        insert bqs;

        Attachment att = new Attachment(
            ParentId = bqs.Id
        ,   Body = Blob.valueOf('String')
        ,   Name = 'G.H.Mumm_Champagne_France_Cuvee_R.Lalou_2002_75Cl_Bottle_1_forsightPreview.jpg'
        );
        insert att;

        Document doc = new Document(
            Name = 'EUR_CRM_RU_BQS_Logos.zip'
        ,   Body = Blob.valueOf('String')
        ,   FolderId = UserInfo.getUserId()
        );
        insert doc;
        List<Document> documents = [SELECT Id, CreatedDate FROM Document];
        System.assertEquals(1, documents.size());
        Id docId = documents[0].Id;

        Test.startTest();
        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);
        List<EUR_CRM_PIMImagesIntegrationController.AttachmentWrapper> attachmentWrappers = EUR_CRM_PIMImagesIntegrationController.getAttachments('BQS', 'RU');
        System.assertEquals(1, attachmentWrappers.size());

        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        controller.sObjectType = 'BQS';
        controller.countryCode = 'RU';
        controller.zipContentLong = 'zipString';
        controller.uploadZipActionFunction();

        documents = [SELECT Id, CreatedDate FROM Document];
        System.assertEquals(1, documents.size());
        System.assert(docId != documents[0].Id);
        Test.stopTest();
    }

    @IsTest
    private static void reDownloadBQSAttachmentForAllCountriesTest() {
        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        controller.reDownloadBQSAttachmentForAllCountries();
        Test.stopTest();
    }

    @IsTest
    private static void reDownloadBQAttachmentForAllCountriesTest() {
        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        controller.reDownloadBQAttachmentForAllCountries();
        Test.stopTest();
    }

    @IsTest
    private static void reDownloadBAttachmentForAllCountriesTest() {
        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        controller.reDownloadBAttachmentForAllCountries();
        Test.stopTest();
    }

    @IsTest
    private static void reDownloadBQSAttachmentForSpecificCountryTest() {
        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        System.currentPageReference().getParameters().put('countryCode', 'RU');
        controller.reDownloadBQSAttachmentForSpecificCountry();
        Test.stopTest();
    }

    @IsTest
    private static void reDownloadBQAttachmentForSpecificCountryTest() {
        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        System.currentPageReference().getParameters().put('countryCode', 'RU');
        controller.reDownloadBQAttachmentForSpecificCountry();
        Test.stopTest();
    }

    @IsTest
    private static void reDownloadBAttachmentForSpecificCountryTest() {
        Test.setCurrentPageReference(Page.EUR_CRM_PIMImagesIntegration);

        Test.startTest();
        EUR_CRM_PIMImagesIntegrationController controller = new EUR_CRM_PIMImagesIntegrationController();
        System.currentPageReference().getParameters().put('countryCode', 'RU');
        controller.reDownloadBAttachmentForSpecificCountry();
        Test.stopTest();
    }
}