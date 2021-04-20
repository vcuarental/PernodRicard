@IsTest(IsParallel = true)
private class EUR_CRM_AccountListingTemplateHandlerTst {

    private static Map<String, String> validListingTemplateRTByAccountRT = new Map<String, String>{
        'EUR_IT_Enoteca_Account' => 'EUR_IT_Enoteca_Template'
        , 'EUR_IT_Wholesaler_Account' => 'EUR_IT_Wholesaler_Template'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
            'EUR_CRM_AccountListingTemplateHandler', 'validListingTemplateRTByAccountRT', validListingTemplateRTByAccountRT));
    }

    @IsTest
    static void onBeforeInsertPositiveTest() {
        initCMT();

        EUR_CRM_JB_Template__c template = makeTemplate('EUR_IT_Wholesaler_Template', 'Keeper');
        insert template;

        EUR_CRM_Account__c acc = makeAccount('EUR_IT_Wholesaler_Account', 'Keeper');
        insert acc;

        List<EUR_CRM_JB_Template__c> templates = selectTemplates();
        List<EUR_CRM_Account__c> insertedAccs = selectAccounts();
        System.assertEquals(1, templates.size());
        System.assertEquals(1, insertedAccs.size());

        System.assertEquals(templates[0].Id, insertedAccs[0].EUR_CRM_Listing_Template__c);
    }

    @IsTest
    static void onBeforeInsertNegativeTest() {
        initCMT();

        EUR_CRM_JB_Template__c template = makeTemplate('EUR_IT_Wholesaler_Template', 'Flyer');
        insert template;

        EUR_CRM_Account__c acc = makeAccount('EUR_IT_Wholesaler_Account', 'Keeper');
        Test.startTest();
        insert acc;
        Test.stopTest();
        List<EUR_CRM_Account__c> insertedAccs = selectAccounts();
        System.assertEquals(1, insertedAccs.size());
        System.assertEquals(null, insertedAccs[0].EUR_CRM_Listing_Template__c);
    }

    @IsTest
    static void onBeforeUpdatePositiveTest() {
        initCMT();

        EUR_CRM_JB_Template__c template = makeTemplate('EUR_IT_Wholesaler_Template', 'Keeper');
        insert template;

        EUR_CRM_Account__c acc = makeAccount('EUR_IT_Wholesaler_Account', 'Mover');
        insert acc;

        EUR_CRM_Account__c insertedAcc = selectAccounts()[0];
        insertedAcc.EUR_CRM_Segmentation__c = 'Keeper';

        Test.startTest();
        update insertedAcc;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
        List<EUR_CRM_JB_Template__c> templates = selectTemplates();
        System.assertEquals(1, templates.size());
        System.assertEquals(1, updatedAccs.size());

        System.assertEquals(templates[0].Id, updatedAccs[0].EUR_CRM_Listing_Template__c);
    }

    @IsTest
    static void onBeforeUpdateNegativeTest() {
        initCMT();

        EUR_CRM_JB_Template__c template = makeTemplate('EUR_IT_Wholesaler_Template', 'Keeper');
        insert template;

        EUR_CRM_Account__c acc = makeAccount('EUR_IT_Wholesaler_Account', 'Mover');
        insert acc;

        EUR_CRM_Account__c insertedAcc = selectAccounts()[0];
        insertedAcc.EUR_CRM_Segmentation__c = 'Flyer On';

        Test.startTest();
        update insertedAcc;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
        List<EUR_CRM_JB_Template__c> templates = selectTemplates();
        System.assertEquals(1, templates.size());
        System.assertEquals(1, updatedAccs.size());

        System.assertEquals(null, updatedAccs[0].EUR_CRM_Listing_Template__c);
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String rt, String segm) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
                Name = 'Test Account'
        , EUR_CRM_Segmentation__c = segm
        , EUR_CRM_Postal_Code__c = '112233'
        , RecordTypeId = rtId
        );
    }

    private static EUR_CRM_JB_Template__c makeTemplate(String rt, String segm) {
        Id rtId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_JB_Template__c(
                Name = 'Test Template'
        , EUR_CRM_Segmentation__c = segm
        , RecordTypeId = rtId
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
                SELECT Id
                        , EUR_CRM_Listing_Template__c
                FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_JB_Template__c> selectTemplates() {
        return [
                SELECT Id
                FROM EUR_CRM_JB_Template__c
        ];
    }
}