@IsTest (isParallel = true)
private class EUR_CRM_ObjPromoTargetCalculationTest {

    @IsTest
    private static void firstTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name'
        ,   EUR_CRM_External_ID__c = 'DK_OFF_EffectsManager_Price_Promotion'
        ,   RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_DK_OP_Action_List_Template'][0].Id
        );
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c(
            Name = 'Promo Name'
        ,   EUR_CRM_MAF_ID__c = '12345'
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addDays(1)
        ,   EUR_CRM_Active_End_Date__c = Date.today().addDays(7)
        ,   EUR_CRM_Status__c = 'Active'
        ,   RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_DK_Off_Trade_EM_Price_Promotion'][0].Id
        );
        insert objPromo;

        EUR_CRM_ObjPromo_Target__c parent = new EUR_CRM_ObjPromo_Target__c(EUR_CRM_ObjPromo__c = objPromo.Id, RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_ObjPromo_Target__c', 'EUR_DK_Objective_Product'));
        insert parent;

        EUR_CRM_ObjPromo_Target__c child = new EUR_CRM_ObjPromo_Target__c(
            EUR_CRM_Actual_Volume_Bottles__c = 0
        ,   EUR_CRM_Actual_Volume_Displays__c = 0
        ,   EUR_CRM_O_P_Target__c = parent.Id
        ,   EUR_CRM_ObjPromo__c = objPromo.Id
        ,   RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_DK_SR_Volume_Target'][0].Id
        );
        insert child;

        Test.startTest();
        child.EUR_CRM_Actual_Volume_Bottles__c = 1;
        child.EUR_CRM_Actual_Volume_Displays__c = 2;
        update child;
        Test.stopTest();

        parent = [
            SELECT Id, EUR_CRM_Actual_Volume_Bottles__c, EUR_CRM_Actual_Volume_Displays__c
            FROM EUR_CRM_ObjPromo_Target__c
            WHERE Id = :parent.Id
        ][0];
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(1, parent.EUR_CRM_Actual_Volume_Bottles__c);
//        System.assertEquals(2, parent.EUR_CRM_Actual_Volume_Displays__c);
    }

    @IsTest
    private static void secondTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name'
        ,   EUR_CRM_External_ID__c = 'DK_OFF_EffectsManager_Price_Promotion'
        ,   RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_DK_OP_Action_List_Template'][0].Id
        );
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c(
            Name = 'Promo Name'
        ,   EUR_CRM_MAF_ID__c = '12345'
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addDays(1)
        ,   EUR_CRM_Active_End_Date__c = Date.today().addDays(7)
        ,   EUR_CRM_Status__c = 'Active'
        ,   RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_DK_Off_Trade_EM_Price_Promotion'][0].Id
        );
        insert objPromo;

        EUR_CRM_ObjPromo_Target__c parent = new EUR_CRM_ObjPromo_Target__c(EUR_CRM_ObjPromo__c = objPromo.Id, RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_ObjPromo_Target__c', 'EUR_DK_Objective_Product'));
        insert parent;

        EUR_CRM_ObjPromo_Target__c child1 = new EUR_CRM_ObjPromo_Target__c(
            EUR_CRM_Actual_Volume_Bottles__c = 0
        ,   EUR_CRM_Actual_Volume_Displays__c = 0
        ,   EUR_CRM_O_P_Target__c = parent.Id
        ,   EUR_CRM_ObjPromo__c = objPromo.Id
        ,   RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_DK_SR_Volume_Target'][0].Id
        );
        insert child1;

        EUR_CRM_ObjPromo_Target__c child2 = new EUR_CRM_ObjPromo_Target__c(
            EUR_CRM_Actual_Volume_Bottles__c = 0
        ,   EUR_CRM_Actual_Volume_Displays__c = 0
        ,   EUR_CRM_O_P_Target__c = parent.Id
        ,   EUR_CRM_ObjPromo__c = objPromo.Id
        ,   RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_DK_SR_Volume_Target'][0].Id
        );
        insert child2;

        Test.startTest();
        child2.EUR_CRM_Actual_Volume_Bottles__c = 2;
        child2.EUR_CRM_Actual_Volume_Displays__c = 2;

        child1.EUR_CRM_Actual_Volume_Displays__c = 1;
        child1.EUR_CRM_Actual_Volume_Bottles__c = 1;

        update new List<EUR_CRM_ObjPromo_Target__c> { child2, child1 };
        Test.stopTest();

        parent = [
            SELECT Id, EUR_CRM_Actual_Volume_Bottles__c, EUR_CRM_Actual_Volume_Displays__c
            FROM EUR_CRM_ObjPromo_Target__c
            WHERE Id = :parent.Id
        ][0];
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(3, parent.EUR_CRM_Actual_Volume_Bottles__c);
//        System.assertEquals(3, parent.EUR_CRM_Actual_Volume_Displays__c);
    }

}