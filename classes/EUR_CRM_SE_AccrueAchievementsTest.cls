@IsTest
private class EUR_CRM_SE_AccrueAchievementsTest {

    @IsTest
    private static void test1() {
        EUR_CRM_OP_Action_List_Template__c actionListTemp = new EUR_CRM_OP_Action_List_Template__c(Name = 'Promo Action List Template 1', EUR_CRM_External_ID__c = 'BE_On_Trade_Promo_Kit_Activation');
        insert actionListTemp;

        EUR_CRM_ObjPromo_Action__c promoAction = new EUR_CRM_ObjPromo_Action__c(EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_CRM_OFF_Follow_Up', EUR_CRM_OP_Action_List_Template__c = actionListTemp.Id);
        insert promoAction;

        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(Name = 'Tester1',   EUR_CRM_Postal_Code__c = '1122'
                ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade'));
        insert acc;

        EUR_CRM_ObjPromo__c objAndProm = new EUR_CRM_ObjPromo__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_ObjPromo__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_On_Trade_Promo_Kit_Activation').getRecordTypeId()
        ,   Name = 'TestObjPromo'
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addDays(-1)
        ,   EUR_CRM_Active_End_Date__c = Date.today().addDays(360)
        ,   EUR_CRM_Evaluation_Period_End_Date__c = Date.today().addDays(20)
        );
        insert objAndProm;

        EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMapping = new EUR_CRM_ObjPromo_Account_Mapping__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_ObjPromo_Account_Mapping__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_O_P_Account_Mapping').getRecordTypeId()
        ,   EUR_CRM_Account__c = acc.Id
        ,   EUR_CRM_ObjPromo__c = objAndProm.Id
        ,   EUR_CRM_Is_Active__c = true
        ,   EUR_CRM_Evaluation_Required__c = false
        );
        insert objPromoAccMapping;



        EUR_CRM_Brand__c testBrand = new EUR_CRM_Brand__c(Name = 'TestBrand');
        insert testBrand;

        EUR_CRM_Quality__c testBrandQuality = new EUR_CRM_Quality__c(EUR_CRM_Brand__c = testBrand.Id);
        insert testBrandQuality;

        Test.startTest();
        EUR_CRM_ObjPromo_Target__c testTargetParent = new EUR_CRM_ObjPromo_Target__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_Objective_Volume_Target').getRecordTypeId()
        ,   EUR_CRM_ObjPromo__c = objAndProm.Id
        ,   EUR_CRM_Target_Owner__c = UserInfo.getUserId()
        ,   EUR_CRM_Brand__c = testBrand.Id
        ,   EUR_CRM_BQ__c = testBrandQuality.Id
        );
        insert testTargetParent;

        EUR_CRM_ObjPromo_Target__c testTarget = new EUR_CRM_ObjPromo_Target__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId()
        ,   EUR_CRM_ObjPromo__c = objAndProm.Id
        ,   EUR_CRM_O_P_Target__c = testTargetParent.Id
        ,   EUR_CRM_Target_Owner__c = null
        ,   EUR_CRM_Brand__c = testBrand.Id
        ,   EUR_CRM_BQ__c = testBrandQuality.Id
        );
        insert testTarget;

        RecordType visitAction = [SELECT Id,SobjectType,Name,DeveloperName FROM RecordType WHERE SobjectType = 'EUR_CRM_Visit_Action__c' AND DeveloperName = 'EUR_SE_ON_Listing_Agree_To_List' LIMIT 1][0];
        EUR_CRM_Visit_Action__c newVisit = new EUR_CRM_Visit_Action__c(
            EUR_CRM_ObjPromo__c = objAndProm.Id
        ,   EUR_CRM_Stage__c = 'Execution'
        ,   EUR_CRM_Status__c = 'Yes'
        ,   RecordTypeId = visitAction.Id
        ,   EUR_CRM_Is_Accrued__c = false
        ,   EUR_CRM_Account__c = acc.Id
        ,   EUR_CRM_Brand__c = testBrand.Id
        ,   EUR_CRM_Brand_Quality__c = testBrandQuality.Id
        ,   EUR_CRM_Sell_In_Volume_Bottles__c = 50
        ,   EUR_CRM_ObjPromo_Target__c = testTarget.Id
        );

        objAndProm.Name = 'Test1';
        objAndProm.EUR_CRM_Status__c = 'Published';
        update objAndProm;

        insert newVisit;

        Database.executeBatch(new EUR_CRM_SE_AccrueAchievements(), 200);
//        EUR_CRM_SE_AccrueAchievements.accrue(new List<EUR_CRM_Visit_Action__c> { newVisit });
        Test.stopTest();
    }
}