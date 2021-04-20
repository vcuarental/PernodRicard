@isTest
private class EUR_CRM_BE_AccrueAchievementsTest {
    static testMethod void test1() {
        Id userid = UserInfo.getUserId();

        //Create Action List Template
        EUR_CRM_OP_Action_List_Template__c actionListTemp = new EUR_CRM_OP_Action_List_Template__c(name = 'Promo Action List Template 1', EUR_CRM_External_ID__c = 'BE_On_Trade_Promo_Kit_Activation');
        insert actionListTemp;

        //Create Action List
        EUR_CRM_ObjPromo_Action__c promoAction = new EUR_CRM_ObjPromo_Action__c(EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_CRM_OFF_Follow_Up', EUR_CRM_OP_Action_List_Template__c = actionListTemp.Id);
        insert promoAction;

        //Create AccList
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();

        //Create EUAccount
        EUR_CRM_Account__c acc = EUR_CRM_BE_TestClassHelper.createEUAccount('Tester1');
        insert acc;

        //Create objPromoList

        EUR_CRM_ObjPromo__c objAndProm = new EUR_CRM_ObjPromo__c();
        objAndProm.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + 'EUR_BE_On_Trade_Promo_Kit_Activation');
        objAndProm.Name = 'TestObjPromo';
        objAndProm.EUR_CRM_Active_Start_Date__c = Date.today().addDays(-1);
        objAndProm.EUR_CRM_Active_End_Date__c = Date.Today().addDays(360);
        objAndProm.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(20);

        insert objAndProm;

        EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMapping = EUR_CRM_BE_TestClassHelper.createobjPromoAccMapping('EUR_BE_O_P_Account_Mapping', acc.Id, objAndProm.Id);

        objPromoAccMapping.EUR_CRM_Is_Active__c = true;
        objPromoAccMapping.EUR_CRM_Evaluation_Required__c = false;
        insert objPromoAccMapping;

        objAndProm.Name = 'Test1';
        objAndProm.EUR_CRM_Status__c = 'Published';

        EUR_CRM_Brand__c testBrand = new EUR_CRM_Brand__c();
        testBrand.Name = 'TestBrand';
        insert testBrand;

        EUR_CRM_SKU__c testSku = new EUR_CRM_SKU__c(Name = 'test', EUR_CRM_Bottles_per_Case__c = 10);
        insert testSku;

        EUR_CRM_Quality__c testBrandQuality = new EUR_CRM_Quality__c();
        testBrandQuality.EUR_CRM_Brand__c = testBrand.Id;
        insert testBrandQuality;
        Test.startTest();
        RecordType targetRt1 = Global_RecordTypeCache.getRtRec('EUR_CRM_ObjPromo_Target__c' + 'EUR_BE_Objective_Volume_Target');
        EUR_CRM_ObjPromo_Target__c testTargetParent = new EUR_CRM_ObjPromo_Target__c();
        testTargetParent.RecordTypeId = targetRt1.Id;
        testTargetParent.EUR_CRM_ObjPromo__c = objAndProm.Id;
        testTargetParent.EUR_CRM_Target_Owner__c = userid;
        testTargetParent.EUR_CRM_Brand__c = testBrand.Id;
        testTargetParent.EUR_CRM_BQ__c = testBrandQuality.Id;
        insert testTargetParent;

        RecordType targetRt2 = Global_RecordTypeCache.getRtRec('EUR_CRM_ObjPromo_Target__c' + 'EUR_BE_SR_Volume_Target');
        List<EUR_CRM_ObjPromo_Target__c> targets = new List<EUR_CRM_ObjPromo_Target__c>();
        EUR_CRM_ObjPromo_Target__c testTarget = new EUR_CRM_ObjPromo_Target__c(
                RecordTypeId = targetRt2.Id,
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_O_P_Target__c = testTargetParent.Id,
                EUR_CRM_Target_Owner__c = null,
                EUR_CRM_Brand__c = testBrand.Id,
                EUR_CRM_BQ__c = testBrandQuality.Id);
        targets.add(testTarget);
        EUR_CRM_ObjPromo_Target__c testTarget2 = new EUR_CRM_ObjPromo_Target__c(
                RecordTypeId = targetRt2.Id,
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_O_P_Target__c = testTargetParent.Id,
                EUR_CRM_Target_Owner__c = null,
                EUR_CRM_SKU__c = testSku.Id);
        targets.add(testTarget2);
        insert targets;


        List<EUR_CRM_Visit_Action__c> listVisit = new List<EUR_CRM_Visit_Action__c>();
        RecordType visitAction = Global_RecordTypeCache.getRtRec('EUR_CRM_Visit_Action__c' + 'EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty');
        EUR_CRM_Visit_Action__c newVisit = new EUR_CRM_Visit_Action__c(
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_Stage__c = 'Execution',
                EUR_CRM_Status__c = 'Yes',
                RecordType = visitAction,
                EUR_CRM_Is_Accrued__c = false,
                EUR_CRM_Account__c = acc.id,
                EUR_CRM_Brand__c = testBrand.Id,
                EUR_CRM_Brand_Quality__c = testBrandQuality.Id,
                EUR_CRM_Sell_In_Volume_Bottles__c = 50);
        listVisit.add(newVisit);
        EUR_CRM_Visit_Action__c newVisit2 = new EUR_CRM_Visit_Action__c(
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_Stage__c = 'Execution',
                EUR_CRM_Status__c = 'Yes',
                RecordType = visitAction,
                EUR_CRM_Is_Accrued__c = false,
                EUR_CRM_Account__c = acc.id,
                EUR_CRM_SKU__c = testSku.Id,
                EUR_CRM_Sell_In_Volume_Displays__c = 1);
        listVisit.add(newVisit2);

        upsert objAndProm;
        insert listVisit;

        EUR_CRM_BE_AccrueAchievements batch1 = new EUR_CRM_BE_AccrueAchievements();
        Id job1 = Database.executeBatch(batch1, 200);
        EUR_CRM_BE_AccrueAchievements.accrue(listVisit);
        Test.stopTest();
    }
}