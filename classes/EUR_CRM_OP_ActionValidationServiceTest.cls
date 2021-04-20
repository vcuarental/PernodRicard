@IsTest(IsParallel = true)
private class EUR_CRM_OP_ActionValidationServiceTest {

    @TestSetup
    static void setup() {
        insert makeTemplate();
    }

    @IsTest
    static void testSetup() {
        System.assertEquals(selectTemplates().size(), 1);
    }


    @IsTest
    static void updateTemplatePositiveCreateActionTest() {
        EUR_CRM_OP_Template__c template = selectTemplates()[0];
        EUR_CRM_Objectives_Promotions__c objProm = makeObjProm(template.Id);
        objProm.EUR_CRM_Status__c = 'Draft';
        insert objProm;

        Test.startTest();
        Database.SaveResult result = Database.insert(makeAction(template.Id), false);
        Test.stopTest();

        System.assertEquals(0, result.getErrors().size());
        System.assertEquals(1, selectActions().size());
    }

    @IsTest
    static void updateTemplateNegativeCreateActionTest() {
        EUR_CRM_OP_Template__c template = selectTemplates()[0];
        EUR_CRM_Objectives_Promotions__c objProm = makeObjProm(template.Id);
        objProm.EUR_CRM_Status__c = 'Active';
        insert objProm;

        Test.startTest();
        Database.SaveResult result = Database.insert(makeAction(template.Id), false);
        Test.stopTest();

        System.assertEquals(1, result.getErrors().size());
        System.assertEquals(0, selectActions().size());
    }

    @IsTest
    static void updateTemplateNegativeDeleteActionTest() {
        EUR_CRM_OP_Template__c template = selectTemplates()[0];
        EUR_CRM_Objectives_Promotions__c objProm = makeObjProm(template.Id);
        objProm.EUR_CRM_Status__c = 'Draft';
        insert objProm;
        EUR_CRM_OP_Action__c action = makeAction(template.Id);
        insert action;
        System.assertEquals(1, selectActions().size());
        objProm.EUR_CRM_Status__c = 'Active';
        update objProm;

        Test.startTest();
        Database.DeleteResult result = Database.delete(action, false);
        Test.stopTest();

        System.assertEquals(1, result.getErrors().size());
//        System.assertEquals(0, selectActions().size());
    }

    @IsTest
    static void updateTemplateNegativeUpdateActionTest() {
        EUR_CRM_OP_Template__c template = selectTemplates()[0];
        EUR_CRM_Objectives_Promotions__c objProm = makeObjProm(template.Id);
        objProm.EUR_CRM_Status__c = 'Draft';
        insert objProm;
        EUR_CRM_OP_Action__c action = makeAction(template.Id);
        insert action;
        System.assertEquals(1, selectActions().size());
        objProm.EUR_CRM_Status__c = 'Active';
        update objProm;

        Test.startTest();
        action.Name = 'new name';
        Database.SaveResult result = Database.update(action, false);
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

    private static EUR_CRM_OP_Action__c makeAction(Id templateId) {
        return new EUR_CRM_OP_Action__c(
            Name = 'test'
            ,   EUR_CRM_OP_Template__c = templateId
            ,   RecordTypeId = Schema.SObjectType.EUR_CRM_OP_Action__c.getRecordTypeInfosByName().get('General').getRecordTypeId()
            ,   EUR_CRM_Reoccuring_Type__c = 'Repeat all time'
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_OP_Template__c> selectTemplates() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Template__c
        ];
    }

    private static List<EUR_CRM_OP_Action__c> selectActions() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Action__c
        ];
    }

}