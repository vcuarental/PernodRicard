@IsTest (IsParallel = true)
private class EUR_CRM_PRS_ForceImageLevelHandlerTest {
    private static Set<String> euAccountRecordTypeSet = new Set<String>{
        'EUR_DB_On_Trade_Account',
        'EUR_IDL_On_Trade_Account',
        'EUR_SE_On_Trade',
        'EUR_IT_On_Trade_Account',
        'EUR_NL_On_Trade',
        'EUR_RU_On_Trade'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(
            EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_PRS_ForceImageLevelHandler', 'euAccountRecordTypeSet', euAccountRecordTypeSet));
    }

    @IsTest
    private static void firstTest() {
        initCMT();

        EUR_CRM_PRS_Seg_Aspect__c segAspect = new EUR_CRM_PRS_Seg_Aspect__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_DB_PRS_Segmentation_Aspect_Image_Level').getRecordTypeId()
        ,   EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic'
        );
        insert segAspect;

        EUR_CRM_Account__c account = new EUR_CRM_Account__c(
            Name = 'Name'
        ,   EUR_CRM_Postal_Code__c = '112233'
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DB_On_Trade_Account').getRecordTypeId()
        );
        insert account;

        Test.startTest();
        account.EUR_CRM_Force_PRS_Image_Level__c = 'Iconic';
        update account;
        Test.stopTest();

        account = [SELECT Id, EUR_CRM_PRS_Image_Level__c FROM EUR_CRM_Account__c LIMIT 1][0];
        System.assertEquals(account.EUR_CRM_PRS_Image_Level__c, segAspect.Id);

        delete account;
    }

}