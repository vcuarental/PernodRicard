@IsTest
private class EUR_CRM_AccrueAchievementsBatchTest {

    @TestSetup
    private static void setupMethod() {
        insert makeAccount();
        insert makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert makeObjPromo(Schema.SObjectType.EUR_CRM_ObjPromo__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_Off_Trade_EM_Price_Promotion').getRecordTypeId());
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccounts()[0];
        System.assertNotEquals(null, account);

        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];
        System.assertNotEquals(null, objPromo);
        Test.stopTest();
    }

    @IsTest
    private static void schedulerTest() {
        Test.startTest();
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_AccrueAchievementsBatch scheduledJob = new EUR_CRM_AccrueAchievementsBatch();
        String jobId = System.schedule('EUR_CRM_AccrueAchievementsBatch: Accrue Achievements Scheduled Job', cronExpression, scheduledJob);
        Test.stopTest();

        List<CronTrigger> cronTriggers = selectCronTriggers(jobId);
        System.assertEquals(1, cronTriggers.size());
    }


    /* ========================================================= */
    /*     Tests for BE
    /* ========================================================= */
    @IsTest
    private static void EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_Actual_Quantity_Spyder__c = 10;
        objPromoTargetParent.EUR_CRM_Target_Quantity_Spyders__c = 10;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }

        List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
        System.assertEquals(1, objPromos.size());
        System.assertEquals('Under Evaluation', objPromos[0].EUR_CRM_Status__c);
    }

    @IsTest
    private static void EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Displays_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        EUR_CRM_SKU__c sku = makeSKU();
        insert sku;

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_Actual_Quantity_Spyder__c = 10;
        objPromoTargetParent.EUR_CRM_Target_Quantity_Spyders__c = 10;
        objPromoTargetParent.EUR_CRM_SKU__c = sku.Id;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        objPromoTargetChild.EUR_CRM_SKU__c = sku.Id;
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Displays__c = 1;
        visitAction.EUR_CRM_SKU__c = sku.Id;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Displays__c);
            System.assertEquals(6, target.EUR_CRM_Actual_Volume_Bottles__c);
        }

        List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
        System.assertEquals(1, objPromos.size());
        System.assertEquals('Under Evaluation', objPromos[0].EUR_CRM_Status__c);
    }

    @IsTest
    private static void EUR_BE_OFF_Secondary_Placement_ConfParticipation_And_EUR_CRM_No_of_Spyder_Displays_Placed_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_Actual_Quantity_Spyder__c = 10;
        objPromoTargetParent.EUR_CRM_Target_Quantity_Spyders__c = 10;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Secondary_Placement_ConfParticipation').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_No_of_Spyder_Displays_Placed__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        System.assertEquals(11, objPromoTargets[0].EUR_CRM_Actual_Quantity_Spyder__c);
        System.assertEquals(1, objPromoTargets[1].EUR_CRM_Actual_Quantity_Spyder__c);

        List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
        System.assertEquals(1, objPromos.size());
        System.assertEquals('Under Evaluation', objPromos[0].EUR_CRM_Status__c);
    }

    @IsTest
    private static void EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_Actual_Quantity_Spyder__c = 10;
        objPromoTargetParent.EUR_CRM_Target_Quantity_Spyders__c = 10;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }

        List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
        System.assertEquals(1, objPromos.size());
        System.assertEquals('Under Evaluation', objPromos[0].EUR_CRM_Status__c);
    }

    @IsTest
    private static void EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty_And_EUR_CRM_Quantity_of_Kits_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_Actual_Quantity_Spyder__c = 10;
        objPromoTargetParent.EUR_CRM_Target_Quantity_Spyders__c = 10;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Quantity_of_Kits__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_Promo_Kits__c);
        }

        List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
        System.assertEquals(1, objPromos.size());
        System.assertEquals('Under Evaluation', objPromos[0].EUR_CRM_Status__c);
    }


    @IsTest
    private static void EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Bottles_c_multipleVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(5, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(5, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Displays_c_multipleVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        EUR_CRM_SKU__c sku = makeSKU();
        insert sku;

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_SKU__c = sku.Id;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        objPromoTargetChild.EUR_CRM_SKU__c = sku.Id;
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Displays__c = 1;
        visitAction.EUR_CRM_SKU__c = sku.Id;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Displays__c = 1;
        visitAction.EUR_CRM_SKU__c = sku.Id;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Displays__c = 1;
        visitAction.EUR_CRM_SKU__c = sku.Id;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Displays__c = 1;
        visitAction.EUR_CRM_SKU__c = sku.Id;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Displays__c = 1;
        visitAction.EUR_CRM_SKU__c = sku.Id;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(5, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(5, target.EUR_CRM_Actual_Volume_Displays__c);
            System.assertEquals(5 * 6, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_BE_OFF_Secondary_Placement_ConfParticipation_And_EUR_CRM_No_of_Spyder_Displays_Placed_c_multipleVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_Actual_Quantity_Spyder__c = 10;
        objPromoTargetParent.EUR_CRM_Target_Quantity_Spyders__c = 10;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Secondary_Placement_ConfParticipation').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_No_of_Spyder_Displays_Placed__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Secondary_Placement_ConfParticipation').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_No_of_Spyder_Displays_Placed__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Secondary_Placement_ConfParticipation').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_No_of_Spyder_Displays_Placed__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Secondary_Placement_ConfParticipation').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_No_of_Spyder_Displays_Placed__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Secondary_Placement_ConfParticipation').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_No_of_Spyder_Displays_Placed__c = 1;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(5, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        System.assertEquals(15, objPromoTargets[0].EUR_CRM_Actual_Quantity_Spyder__c);
        System.assertEquals(5, objPromoTargets[1].EUR_CRM_Actual_Quantity_Spyder__c);

        List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
        System.assertEquals(1, objPromos.size());
        System.assertEquals('Under Evaluation', objPromos[0].EUR_CRM_Status__c);
    }

    @IsTest
    private static void EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Bottles_c_multipleVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(5, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(5, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty_And_EUR_CRM_Quantity_of_Kits_c_multipleVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Quantity_of_Kits__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Quantity_of_Kits__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Quantity_of_Kits__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Quantity_of_Kits__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Quantity_of_Kits__c = 1;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(5, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(5, target.EUR_CRM_Actual_Quantity_Promo_Kits__c);
        }
    }


    @IsTest
    private static void EUR_BE_multipleDifferentVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        EUR_CRM_SKU__c sku = makeSKU();
        insert sku;

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        objPromoTargetParent.EUR_CRM_SKU__c = sku.Id;
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        objPromoTargetChild.EUR_CRM_SKU__c = sku.Id;
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Displays__c = 1;
        visitAction.EUR_CRM_SKU__c = sku.Id;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_OFF_Secondary_Placement_ConfParticipation').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_No_of_Spyder_Displays_Placed__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Quantity_of_Kits__c = 1;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(5, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(8, target.EUR_CRM_Actual_Volume_Bottles__c);
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_Spyder__c);
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_Promo_Kits__c);
        }
    }


    /* ========================================================= */
    /*     Tests for DK
    /* ========================================================= */
    @IsTest
    private static void EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles_And_EUR_CRM_Sell_In_Volume_SKUs_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_SKUs__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons_And_EUR_CRM_Sell_In_Volume_SKUs_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_SKUs__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays_And_EUR_CRM_Sell_In_Volume_SKUs_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_SKUs__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_DK_multipleVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_SR_Volume_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_SKUs__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_SKUs__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_SKUs__c = 1;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(8, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(8, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }


    /* ========================================================= */
    /*     Tests for SE
    /* ========================================================= */
    @IsTest
    private static void EUR_SE_ON_Listing_Agree_To_List_And_EUR_CRM_Number_of_Listing_c_PositiveStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Listing_Agree_To_List').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_Listing__c = 1;
        visitAction.EUR_CRM_Status__c = 'Yes';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_Listing__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Listing_Agree_To_List_And_EUR_CRM_Number_of_Listing_c_NegativeStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Listing_Agree_To_List').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_Listing__c = 1;
        visitAction.EUR_CRM_Status__c = 'Other';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(null, target.EUR_CRM_Actual_Quantity_Listing__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Volume_Campaign_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Volume_Campaign_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Pallets_Bundles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Pallets_Bundles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Slow_Moving_Sell_In_Qty_And_EUR_CRM_Sell_In_Volume_Bottles_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Slow_Moving_Sell_In_Qty').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Events_Agree_To_Participate_And_EUR_CRM_Number_of_People_c_PositiveStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Events_Agree_To_Participate').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_People__c = 1;
        visitAction.EUR_CRM_Status__c = 'Participating';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Number_of_Commitments__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Events_Agree_To_Participate_And_EUR_CRM_Number_of_People_c_NegativeStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Events_Agree_To_Participate').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_People__c = 1;
        visitAction.EUR_CRM_Status__c = 'Other';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(null, target.EUR_CRM_Actual_Number_of_Commitments__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Education_Nb_of_People_And_EUR_CRM_Number_of_People_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Education_Nb_of_People').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_People__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_People__c);
        }
    }

    @IsTest
    private static void EUR_SE_ON_Staff_Communication_Nb_of_People_And_EUR_CRM_Number_of_People_c_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Staff_Communication_Nb_of_People').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_People__c = 1;
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_People__c);
        }
    }

    @IsTest
    private static void EUR_SE_multipleVAsTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_Objective_Listing_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Listing_Agree_To_List').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_Listing__c = 1;
        visitAction.EUR_CRM_Status__c = 'Yes';
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Volume_Campaign_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Pallets_Bundles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Slow_Moving_Sell_In_Qty').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Sell_In_Volume_Bottles__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Events_Agree_To_Participate').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_People__c = 1;
        visitAction.EUR_CRM_Status__c = 'Participating';
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Education_Nb_of_People').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_People__c = 1;
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_SE_ON_Staff_Communication_Nb_of_People').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Number_of_People__c = 1;
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(7, visitActionsAfter.size());
        for (EUR_CRM_Visit_Action__c action : visitActionsAfter) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_Listing__c);
            System.assertEquals(3, target.EUR_CRM_Actual_Volume_Bottles__c);
            System.assertEquals(1, target.EUR_CRM_Actual_Number_of_Commitments__c);
            System.assertEquals(2, target.EUR_CRM_Actual_Quantity_People__c);
        }
    }


    /* ========================================================= */
    /*     Tests for RU
    /* ========================================================= */
    @IsTest
    private static void EUR_RU_ON_Enter_Promo_Kit_Quantity_And_EUR_CRM_Promo_Kit_Quantity_c_PositiveStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Manager_POSM_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_ON_Enter_Promo_Kit_Quantity').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Yes';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Quantity_Promo_Kits__c);
        }
    }

    @IsTest
    private static void EUR_RU_ON_Enter_Promo_Kit_Quantity_And_EUR_CRM_Promo_Kit_Quantity_c_NegativeStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Objective_POSM_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_ON_Enter_Promo_Kit_Quantity').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Other';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(false, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assert(target.EUR_CRM_Actual_Quantity_Promo_Kits__c == null || target.EUR_CRM_Actual_Quantity_Promo_Kits__c == 0);
        }
    }

    @IsTest
    private static void EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement_And_nothing_PositiveStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Objective_Product').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Status__c = 'Participating';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(true, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(1, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }

    @IsTest
    private static void EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement_And_nothing_NegativeStatus_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Sales_Rep_POSM_Target').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Status__c = 'Other';
        insert visitAction;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActions = selectVisitActions();
        System.assertEquals(1, visitActions.size());
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            System.assertEquals(false, action.EUR_CRM_Is_Accrued__c);
        }

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assert(target.EUR_CRM_Actual_Quantity_Promo_Kits__c == null || target.EUR_CRM_Actual_Quantity_Promo_Kits__c == 0);
        }
    }

    @IsTest
    private static void EUR_RU_singleVATest() {
        EUR_CRM_Account__c account = selectAccounts()[0];
        EUR_CRM_ObjPromo__c objPromo = selectObjPromos()[0];

        Id optRTId = Schema.SObjectType.EUR_CRM_ObjPromo_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Objective_Product').getRecordTypeId();
        EUR_CRM_ObjPromo_Target__c objPromoTargetParent = makeObjPromoTarget(optRTId, objPromo.Id, null);
        insert objPromoTargetParent;

        EUR_CRM_ObjPromo_Target__c objPromoTargetChild = makeObjPromoTarget(optRTId, objPromo.Id, objPromoTargetParent.Id);
        objPromoTargetChild.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert objPromoTargetChild;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        Id vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_ON_Enter_Promo_Kit_Quantity').getRecordTypeId();
        EUR_CRM_Visit_Action__c visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Yes';
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_ON_Enter_Promo_Kit_Quantity').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Other';
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Participating';
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Other';
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_ON_Enter_Promo_Kit_Quantity').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Yes';
        visitActions.add(visitAction);

        vaRTId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement').getRecordTypeId();
        visitAction = makeVisitAction(vaRTId, account.Id, objPromo.Id, objPromoTargetChild.Id);
        visitAction.EUR_CRM_Entitle_Achievement__c = true;
        visitAction.EUR_CRM_Promo_Kit_Quantity__c = '1';
        visitAction.EUR_CRM_Status__c = 'Participating';
        visitActions.add(visitAction);
        insert visitActions;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_Visit_Action__c> visitActionsAfter = selectVisitActions();
        System.assertEquals(6, visitActionsAfter.size());
        System.assertEquals(true, visitActionsAfter[0].EUR_CRM_Is_Accrued__c);
        System.assertEquals(false, visitActionsAfter[1].EUR_CRM_Is_Accrued__c);
        System.assertEquals(true, visitActionsAfter[2].EUR_CRM_Is_Accrued__c);
        System.assertEquals(false, visitActionsAfter[3].EUR_CRM_Is_Accrued__c);
        System.assertEquals(true, visitActionsAfter[4].EUR_CRM_Is_Accrued__c);
        System.assertEquals(true, visitActionsAfter[5].EUR_CRM_Is_Accrued__c);

        List<EUR_CRM_ObjPromo_Target__c> objPromoTargets = selectObjPromoTargets();
        System.assertEquals(2, objPromoTargets.size());
        for (EUR_CRM_ObjPromo_Target__c target : objPromoTargets) {
            System.assertEquals(2, target.EUR_CRM_Actual_Quantity_Promo_Kits__c);
            System.assertEquals(2, target.EUR_CRM_Actual_Volume_Bottles__c);
        }
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'Account Name'
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplate(String recordTypeDevName, String externalId) {
        EUR_CRM_OP_Action_List_Template__c actionListTemplate = makeActionListTemplateSkeleton(externalId);
        actionListTemplate.RecordTypeId = Schema.SObjectType.EUR_CRM_OP_Action_List_Template__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        return actionListTemplate;
    }

    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplateSkeleton(String externalId) {
        return new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name'
        ,   EUR_CRM_External_ID__c = externalId
        );
    }

    private static EUR_CRM_ObjPromo__c makeObjPromo(Id rtId) {
        return new EUR_CRM_ObjPromo__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_ObjPromo_Target__c makeObjPromoTarget(Id rtId, Id objPromoId, Id parentObjPromoTargetId) {
        return new EUR_CRM_ObjPromo_Target__c(
            RecordTypeId = rtId
        ,   EUR_CRM_ObjPromo__c = objPromoId
        ,   EUR_CRM_O_P_Target__c = parentObjPromoTargetId
        );
    }

    private static EUR_CRM_Visit_Action__c makeVisitAction(Id rtId, Id accId, Id objPromoId, Id objPromoTargetId) {
        return new EUR_CRM_Visit_Action__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Account__c = accId
        ,   EUR_CRM_ObjPromo__c = objPromoId
        ,   EUR_CRM_ObjPromo_Target__c = objPromoTargetId
        );
    }

    private static EUR_CRM_SKU__c makeSKU() {
        return new EUR_CRM_SKU__c(
            EUR_CRM_Bottles_per_Case__c = 6
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
            LIMIT 1
        ];
    }

    private static List<EUR_CRM_Visit_Action__c> selectVisitActions() {
        return [
            SELECT Id
            ,   EUR_CRM_Is_Accrued__c
            FROM EUR_CRM_Visit_Action__c
        ];
    }

    private static List<EUR_CRM_ObjPromo_Target__c> selectObjPromoTargets() {
        return [
            SELECT Id
            ,   EUR_CRM_Actual_Volume_Bottles__c
            ,   EUR_CRM_Actual_Volume_Displays__c
            ,   EUR_CRM_Actual_Quantity_Spyder__c
            ,   EUR_CRM_Actual_Quantity_Promo_Kits__c
            ,   EUR_CRM_Actual_Quantity_Listing__c
            ,   EUR_CRM_Actual_Quantity_People__c
            ,   EUR_CRM_Actual_Number_of_Commitments__c
            FROM EUR_CRM_ObjPromo_Target__c
        ];
    }

    private static List<EUR_CRM_ObjPromo__c> selectObjPromos() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_ObjPromo__c
        ];
    }

    private static List<CronTrigger> selectCronTriggers(String jobId){
        return [
            SELECT Id
            FROM CronTrigger
            WHERE Id = :jobId
        ];
    }

}