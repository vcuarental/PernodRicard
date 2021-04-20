@IsTest(IsParallel = true)
private class EUR_CRM_OP_TemplateValidationServiceTest {

    @TestSetup
    static void setup() {
        insert makeTemplate();
    }

    @IsTest
    static void testSetup() {
        System.assertEquals(selectTemplates().size(), 1);
    }


    @IsTest
    static void updateTemplatePositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplates()[0];
        EUR_CRM_Objectives_Promotions__c objProm = makeObjProm(template.Id);
        objProm.EUR_CRM_Status__c = 'Draft';
        insert objProm;

        Test.startTest();
        template.Name = 'another name';
        Database.SaveResult result = Database.update(template, false);
        Test.stopTest();

        System.assertEquals(0, result.getErrors().size());
        System.assertEquals('another name', selectTemplates()[0].Name);
    }

    @IsTest
    static void updateTemplateNegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplates()[0];
        EUR_CRM_Objectives_Promotions__c objProm = makeObjProm(template.Id);
        objProm.EUR_CRM_Status__c = 'Active';
        insert objProm;

        Test.startTest();
        template.Name = 'another name';
        Database.SaveResult result = Database.update(template, false);
        Test.stopTest();

        System.assertEquals(1, result.getErrors().size());
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_OP_Template__c makeTemplate() {
        return new EUR_CRM_OP_Template__c(
            Name = 'test'
        ,   EUR_CRM_Has_Quota__c = true
        ,   EUR_CRM_Product_Level__c = 'Brand'
        );
    }

    private static EUR_CRM_Objectives_Promotions__c makeObjProm(Id templateId) {
        return new EUR_CRM_Objectives_Promotions__c(
            Name = 'test'
        ,   EUR_CRM_OP_Template__c = templateId
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_Objectives_Promotions__c.getRecordTypeInfosByName().get('EUR NL OP').getRecordTypeId()
        ,   EUR_CRM_Active_Start_Date__c = Date.today()
        ,   EUR_CRM_Active_End_Date__c = Date.today().addDays(1)
        );
    }

    
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_OP_Template__c> selectTemplates() {
        return [
            SELECT Id
            ,   Name
            FROM EUR_CRM_OP_Template__c
        ];
    }

}