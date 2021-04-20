@IsTest (IsParallel = true)
private class EUR_CRM_OPPromTargDistToHandlerTest {

    @TestSetup
    private static void setupMethod() {
        EUR_CRM_OP_Template__c opTemplate = makeOPTemplate(EUR_CRM_ObjPromoTargetMngmntCtrl.DEFAULT_SECTION_TO_DISPLAY);
        insert opTemplate;

        List<EUR_CRM_OP_Action__c> opActions = new List<EUR_CRM_OP_Action__c>();
        opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Sell_in_Amount_Bottle__c'));
        opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Sell_in_Amount_Display__c'));
        insert opActions;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotion(opTemplate.Id);
        insert op;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert product;
    }

    @IsTest
    private static void setupTest() {
        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        System.assertEquals(1, ops.size());
    }


//    @IsTest
//    private static void t_1_OP_1_PT_1_TM_1_TR_HasTargetNegativeTest() {
//        EUR_CRM_OP_Template__c opTemplate = selectTemplate();
//        opTemplate.EUR_CRM_Has_Quota__c = false;
//        opTemplate.EUR_CRM_Has_Target__c = true;
//        update opTemplate;
//
//        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
//        EUR_CRM_OP_Product__c product = selectProduct();
//
//        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
//        insert promoTarget;
//        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
//        insert targetManager;
//        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
//        insert targetRep;
//
//        checkNegative();
//
//        Test.startTest();
//        update changeFieldsTo(targetRep, 10, 10);
//        Test.stopTest();
//
//        checkNegative();
//    }


    /* ========================================================= */
    /*     1) 1 OP - 1 PT - 1 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_1_PT_1_TM_1_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        checkNegative();

        Test.startTest();
        update changeFieldsTo(targetRep, 10, 10);
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_1_PT_1_TM_1_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        checkNegative();

        Test.startTest();
        update changeFieldsTo(targetRep, 9, 9);
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_1_PT_1_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        checkNegative();

        Test.startTest();
        update changeFieldsTo(targetRep, 3, 3);
        checkNegative();

        update changeFieldsTo(targetRep, 6, 6);
        checkNegative();

        update changeFieldsTo(targetRep, 9, 9);
        checkNegative();

        update changeFieldsTo(targetRep, 10, 10);
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     2) 1 OP - 1 PT - 1 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_1_PT_1_TM_3_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, product.Id, targetManager.Id);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_1_PT_1_TM_3_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, product.Id, targetManager.Id);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_1_PT_1_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, product.Id, targetManager.Id);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     3) 1 OP - 1 PT - 3 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_1_PT_3_TM_1_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, product.Id, promoTarget.Id);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_1_PT_3_TM_1_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, product.Id, promoTarget.Id);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_1_PT_3_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, product.Id, promoTarget.Id);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     4) 1 OP - 1 PT - 3 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_1_PT_3_TM_3_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, product.Id, promoTarget.Id);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_1_PT_3_TM_3_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, product.Id, promoTarget.Id);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_1_PT_3_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id, 10, 10);
        insert promoTarget;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, product.Id, promoTarget.Id);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 0, 0);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     5) 1 OP - 3 PT - 1 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_3_PT_1_TM_1_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 10, 10);
        targetReps[1] = changeFieldsTo(targetReps[1], 10, 10);
        targetReps[2] = changeFieldsTo(targetReps[2], 10, 10);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_3_PT_1_TM_1_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 9, 9);
        targetReps[1] = changeFieldsTo(targetReps[1], 9, 9);
        targetReps[2] = changeFieldsTo(targetReps[2], 9, 9);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_3_PT_1_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 6, 6);
        targetReps[1] = changeFieldsTo(targetReps[1], 6, 6);
        targetReps[2] = changeFieldsTo(targetReps[2], 6, 6);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 9, 9);
        targetReps[1] = changeFieldsTo(targetReps[1], 9, 9);
        targetReps[2] = changeFieldsTo(targetReps[2], 9, 9);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 10, 10);
        targetReps[1] = changeFieldsTo(targetReps[1], 10, 10);
        targetReps[2] = changeFieldsTo(targetReps[2], 10, 10);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     6) 1 OP - 3 PT - 1 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_3_PT_1_TM_3_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_3_PT_1_TM_3_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_3_PT_1_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 2, 2);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 2, 2);
        targetReps[4] = changeFieldsTo(targetReps[4], 2, 2);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 2, 2);
        targetReps[7] = changeFieldsTo(targetReps[7], 2, 2);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     7) 1 OP - 3 PT - 3 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_3_PT_3_TM_1_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_3_PT_3_TM_1_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_3_PT_3_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 2, 2);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 2, 2);
        targetReps[4] = changeFieldsTo(targetReps[4], 2, 2);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 2, 2);
        targetReps[7] = changeFieldsTo(targetReps[7], 2, 2);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     8) 1 OP - 3 PT - 3 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_1_OP_3_PT_3_TM_3_TR_PositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_1_OP_3_PT_3_TM_3_TR_NegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_1_OP_3_PT_3_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, product.Id, 10, 10);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 0, 0);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 0, 0);

        targetReps[12] = changeFieldsTo(targetReps[12], 0, 0);
        targetReps[13] = changeFieldsTo(targetReps[13], 0, 0);
        targetReps[14] = changeFieldsTo(targetReps[14], 0, 0);

        targetReps[15] = changeFieldsTo(targetReps[15], 0, 0);
        targetReps[16] = changeFieldsTo(targetReps[16], 0, 0);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 0, 0);

        targetReps[21] = changeFieldsTo(targetReps[21], 0, 0);
        targetReps[22] = changeFieldsTo(targetReps[22], 0, 0);
        targetReps[23] = changeFieldsTo(targetReps[23], 0, 0);

        targetReps[24] = changeFieldsTo(targetReps[24], 0, 0);
        targetReps[25] = changeFieldsTo(targetReps[25], 0, 0);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 0, 0);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 0, 0);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     9) 3 OP - 1 PT - 1 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_1_PT_1_TM_1_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 10, 10);
        targetReps[1] = changeFieldsTo(targetReps[1], 10, 10);
        targetReps[2] = changeFieldsTo(targetReps[2], 10, 10);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_3_OP_1_PT_1_TM_1_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 9, 9);
        targetReps[1] = changeFieldsTo(targetReps[1], 9, 9);
        targetReps[2] = changeFieldsTo(targetReps[2], 9, 9);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_1_PT_1_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 6, 6);
        targetReps[1] = changeFieldsTo(targetReps[1], 6, 6);
        targetReps[2] = changeFieldsTo(targetReps[2], 6, 6);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 9, 9);
        targetReps[1] = changeFieldsTo(targetReps[1], 9, 9);
        targetReps[2] = changeFieldsTo(targetReps[2], 9, 9);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 10, 10);
        targetReps[1] = changeFieldsTo(targetReps[1], 10, 10);
        targetReps[2] = changeFieldsTo(targetReps[2], 10, 10);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     10) 3 OP - 1 PT - 1 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_1_PT_1_TM_3_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_3_OP_1_PT_1_TM_3_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_1_PT_1_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 2, 2);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 2, 2);
        targetReps[4] = changeFieldsTo(targetReps[4], 2, 2);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 2, 2);
        targetReps[7] = changeFieldsTo(targetReps[7], 2, 2);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     11) 3 OP - 1 PT - 3 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_1_PT_3_TM_1_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_3_OP_1_PT_3_TM_1_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_1_PT_3_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 2, 2);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 2, 2);
        targetReps[4] = changeFieldsTo(targetReps[4], 2, 2);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 2, 2);
        targetReps[7] = changeFieldsTo(targetReps[7], 2, 2);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     12) 3 OP - 1 PT - 3 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_1_PT_3_TM_3_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_3_OP_1_PT_3_TM_3_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_1_PT_3_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 1);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 0, 0);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 0, 0);

        targetReps[12] = changeFieldsTo(targetReps[12], 0, 0);
        targetReps[13] = changeFieldsTo(targetReps[13], 0, 0);
        targetReps[14] = changeFieldsTo(targetReps[14], 0, 0);

        targetReps[15] = changeFieldsTo(targetReps[15], 0, 0);
        targetReps[16] = changeFieldsTo(targetReps[16], 0, 0);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 0, 0);

        targetReps[21] = changeFieldsTo(targetReps[21], 0, 0);
        targetReps[22] = changeFieldsTo(targetReps[22], 0, 0);
        targetReps[23] = changeFieldsTo(targetReps[23], 0, 0);

        targetReps[24] = changeFieldsTo(targetReps[24], 0, 0);
        targetReps[25] = changeFieldsTo(targetReps[25], 0, 0);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 0, 0);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 0, 0);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     13) 3 OP - 3 PT - 1 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_3_PT_1_TM_1_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 10, 10);
        targetReps[1] = changeFieldsTo(targetReps[1], 10, 10);
        targetReps[2] = changeFieldsTo(targetReps[2], 10, 10);

        targetReps[3] = changeFieldsTo(targetReps[3], 10, 10);
        targetReps[4] = changeFieldsTo(targetReps[4], 10, 10);
        targetReps[5] = changeFieldsTo(targetReps[5], 10, 10);

        targetReps[6] = changeFieldsTo(targetReps[6], 10, 10);
        targetReps[7] = changeFieldsTo(targetReps[7], 10, 10);
        targetReps[8] = changeFieldsTo(targetReps[8], 10, 10);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_3_OP_3_PT_1_TM_1_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 9, 9);
        targetReps[1] = changeFieldsTo(targetReps[1], 9, 9);
        targetReps[2] = changeFieldsTo(targetReps[2], 9, 9);

        targetReps[3] = changeFieldsTo(targetReps[3], 9, 9);
        targetReps[4] = changeFieldsTo(targetReps[4], 9, 9);
        targetReps[5] = changeFieldsTo(targetReps[5], 9, 9);

        targetReps[6] = changeFieldsTo(targetReps[6], 9, 9);
        targetReps[7] = changeFieldsTo(targetReps[7], 9, 9);
        targetReps[8] = changeFieldsTo(targetReps[8], 9, 9);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_3_PT_1_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 6, 6);
        targetReps[1] = changeFieldsTo(targetReps[1], 6, 6);
        targetReps[2] = changeFieldsTo(targetReps[2], 6, 6);

        targetReps[3] = changeFieldsTo(targetReps[3], 6, 6);
        targetReps[4] = changeFieldsTo(targetReps[4], 6, 6);
        targetReps[5] = changeFieldsTo(targetReps[5], 6, 6);

        targetReps[6] = changeFieldsTo(targetReps[6], 6, 6);
        targetReps[7] = changeFieldsTo(targetReps[7], 6, 6);
        targetReps[8] = changeFieldsTo(targetReps[8], 6, 6);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 9, 9);
        targetReps[1] = changeFieldsTo(targetReps[1], 9, 9);
        targetReps[2] = changeFieldsTo(targetReps[2], 9, 9);

        targetReps[3] = changeFieldsTo(targetReps[3], 9, 9);
        targetReps[4] = changeFieldsTo(targetReps[4], 9, 9);
        targetReps[5] = changeFieldsTo(targetReps[5], 9, 9);

        targetReps[6] = changeFieldsTo(targetReps[6], 9, 9);
        targetReps[7] = changeFieldsTo(targetReps[7], 9, 9);
        targetReps[8] = changeFieldsTo(targetReps[8], 9, 9);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 10, 10);
        targetReps[1] = changeFieldsTo(targetReps[1], 10, 10);
        targetReps[2] = changeFieldsTo(targetReps[2], 10, 10);

        targetReps[3] = changeFieldsTo(targetReps[3], 10, 10);
        targetReps[4] = changeFieldsTo(targetReps[4], 10, 10);
        targetReps[5] = changeFieldsTo(targetReps[5], 10, 10);

        targetReps[6] = changeFieldsTo(targetReps[6], 10, 10);
        targetReps[7] = changeFieldsTo(targetReps[7], 10, 10);
        targetReps[8] = changeFieldsTo(targetReps[8], 10, 10);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     14) 3 OP - 3 PT - 1 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_3_PT_1_TM_3_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);

        targetReps[9] = changeFieldsTo(targetReps[9], 3, 3);
        targetReps[10] = changeFieldsTo(targetReps[10], 3, 3);
        targetReps[11] = changeFieldsTo(targetReps[11], 4, 4);

        targetReps[12] = changeFieldsTo(targetReps[12], 3, 3);
        targetReps[13] = changeFieldsTo(targetReps[13], 3, 3);
        targetReps[14] = changeFieldsTo(targetReps[14], 4, 4);

        targetReps[15] = changeFieldsTo(targetReps[15], 3, 3);
        targetReps[16] = changeFieldsTo(targetReps[16], 3, 3);
        targetReps[17] = changeFieldsTo(targetReps[17], 4, 4);


        targetReps[18] = changeFieldsTo(targetReps[18], 3, 3);
        targetReps[19] = changeFieldsTo(targetReps[19], 3, 3);
        targetReps[20] = changeFieldsTo(targetReps[20], 4, 4);

        targetReps[21] = changeFieldsTo(targetReps[21], 3, 3);
        targetReps[22] = changeFieldsTo(targetReps[22], 3, 3);
        targetReps[23] = changeFieldsTo(targetReps[23], 4, 4);

        targetReps[24] = changeFieldsTo(targetReps[24], 3, 3);
        targetReps[25] = changeFieldsTo(targetReps[25], 3, 3);
        targetReps[26] = changeFieldsTo(targetReps[26], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_3_OP_3_PT_1_TM_3_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);

        targetReps[9] = changeFieldsTo(targetReps[9], 3, 3);
        targetReps[10] = changeFieldsTo(targetReps[10], 3, 3);
        targetReps[11] = changeFieldsTo(targetReps[11], 3, 3);

        targetReps[12] = changeFieldsTo(targetReps[12], 3, 3);
        targetReps[13] = changeFieldsTo(targetReps[13], 3, 3);
        targetReps[14] = changeFieldsTo(targetReps[14], 3, 3);

        targetReps[15] = changeFieldsTo(targetReps[15], 3, 3);
        targetReps[16] = changeFieldsTo(targetReps[16], 3, 3);
        targetReps[17] = changeFieldsTo(targetReps[17], 3, 3);


        targetReps[18] = changeFieldsTo(targetReps[18], 3, 3);
        targetReps[19] = changeFieldsTo(targetReps[19], 3, 3);
        targetReps[20] = changeFieldsTo(targetReps[20], 3, 3);

        targetReps[21] = changeFieldsTo(targetReps[21], 3, 3);
        targetReps[22] = changeFieldsTo(targetReps[22], 3, 3);
        targetReps[23] = changeFieldsTo(targetReps[23], 3, 3);

        targetReps[24] = changeFieldsTo(targetReps[24], 3, 3);
        targetReps[25] = changeFieldsTo(targetReps[25], 3, 3);
        targetReps[26] = changeFieldsTo(targetReps[26], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_3_PT_1_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 1);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);

        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 0, 0);
        targetReps[13] = changeFieldsTo(targetReps[13], 0, 0);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 0, 0);
        targetReps[16] = changeFieldsTo(targetReps[16], 0, 0);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 0, 0);
        targetReps[22] = changeFieldsTo(targetReps[22], 0, 0);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 0, 0);
        targetReps[25] = changeFieldsTo(targetReps[25], 0, 0);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 2, 2);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);

        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 2, 2);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 2, 2);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 2, 2);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 2, 2);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 2, 2);
        targetReps[4] = changeFieldsTo(targetReps[4], 2, 2);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 2, 2);
        targetReps[7] = changeFieldsTo(targetReps[7], 2, 2);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);

        targetReps[9] = changeFieldsTo(targetReps[9], 2, 2);
        targetReps[10] = changeFieldsTo(targetReps[10], 2, 2);
        targetReps[11] = changeFieldsTo(targetReps[11], 3, 3);

        targetReps[12] = changeFieldsTo(targetReps[12], 2, 2);
        targetReps[13] = changeFieldsTo(targetReps[13], 2, 2);
        targetReps[14] = changeFieldsTo(targetReps[14], 3, 3);

        targetReps[15] = changeFieldsTo(targetReps[15], 2, 2);
        targetReps[16] = changeFieldsTo(targetReps[16], 2, 2);
        targetReps[17] = changeFieldsTo(targetReps[17], 3, 3);


        targetReps[18] = changeFieldsTo(targetReps[18], 2, 2);
        targetReps[19] = changeFieldsTo(targetReps[19], 2, 2);
        targetReps[20] = changeFieldsTo(targetReps[20], 3, 3);

        targetReps[21] = changeFieldsTo(targetReps[21], 2, 2);
        targetReps[22] = changeFieldsTo(targetReps[22], 2, 2);
        targetReps[23] = changeFieldsTo(targetReps[23], 3, 3);

        targetReps[24] = changeFieldsTo(targetReps[24], 2, 2);
        targetReps[25] = changeFieldsTo(targetReps[25], 2, 2);
        targetReps[26] = changeFieldsTo(targetReps[26], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);

        targetReps[9] = changeFieldsTo(targetReps[9], 3, 3);
        targetReps[10] = changeFieldsTo(targetReps[10], 3, 3);
        targetReps[11] = changeFieldsTo(targetReps[11], 4, 4);

        targetReps[12] = changeFieldsTo(targetReps[12], 3, 3);
        targetReps[13] = changeFieldsTo(targetReps[13], 3, 3);
        targetReps[14] = changeFieldsTo(targetReps[14], 4, 4);

        targetReps[15] = changeFieldsTo(targetReps[15], 3, 3);
        targetReps[16] = changeFieldsTo(targetReps[16], 3, 3);
        targetReps[17] = changeFieldsTo(targetReps[17], 4, 4);


        targetReps[18] = changeFieldsTo(targetReps[18], 3, 3);
        targetReps[19] = changeFieldsTo(targetReps[19], 3, 3);
        targetReps[20] = changeFieldsTo(targetReps[20], 4, 4);

        targetReps[21] = changeFieldsTo(targetReps[21], 3, 3);
        targetReps[22] = changeFieldsTo(targetReps[22], 3, 3);
        targetReps[23] = changeFieldsTo(targetReps[23], 4, 4);

        targetReps[24] = changeFieldsTo(targetReps[24], 3, 3);
        targetReps[25] = changeFieldsTo(targetReps[25], 3, 3);
        targetReps[26] = changeFieldsTo(targetReps[26], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     15) 3 OP - 3 PT - 3 TM - 1 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_3_PT_3_TM_1_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);

        targetReps[9] = changeFieldsTo(targetReps[9], 3, 3);
        targetReps[10] = changeFieldsTo(targetReps[10], 3, 3);
        targetReps[11] = changeFieldsTo(targetReps[11], 4, 4);

        targetReps[12] = changeFieldsTo(targetReps[12], 3, 3);
        targetReps[13] = changeFieldsTo(targetReps[13], 3, 3);
        targetReps[14] = changeFieldsTo(targetReps[14], 4, 4);

        targetReps[15] = changeFieldsTo(targetReps[15], 3, 3);
        targetReps[16] = changeFieldsTo(targetReps[16], 3, 3);
        targetReps[17] = changeFieldsTo(targetReps[17], 4, 4);


        targetReps[18] = changeFieldsTo(targetReps[18], 3, 3);
        targetReps[19] = changeFieldsTo(targetReps[19], 3, 3);
        targetReps[20] = changeFieldsTo(targetReps[20], 4, 4);

        targetReps[21] = changeFieldsTo(targetReps[21], 3, 3);
        targetReps[22] = changeFieldsTo(targetReps[22], 3, 3);
        targetReps[23] = changeFieldsTo(targetReps[23], 4, 4);

        targetReps[24] = changeFieldsTo(targetReps[24], 3, 3);
        targetReps[25] = changeFieldsTo(targetReps[25], 3, 3);
        targetReps[26] = changeFieldsTo(targetReps[26], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }

    @IsTest
    private static void t_3_OP_3_PT_3_TM_1_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);

        targetReps[9] = changeFieldsTo(targetReps[9], 3, 3);
        targetReps[10] = changeFieldsTo(targetReps[10], 3, 3);
        targetReps[11] = changeFieldsTo(targetReps[11], 3, 3);

        targetReps[12] = changeFieldsTo(targetReps[12], 3, 3);
        targetReps[13] = changeFieldsTo(targetReps[13], 3, 3);
        targetReps[14] = changeFieldsTo(targetReps[14], 3, 3);

        targetReps[15] = changeFieldsTo(targetReps[15], 3, 3);
        targetReps[16] = changeFieldsTo(targetReps[16], 3, 3);
        targetReps[17] = changeFieldsTo(targetReps[17], 3, 3);


        targetReps[18] = changeFieldsTo(targetReps[18], 3, 3);
        targetReps[19] = changeFieldsTo(targetReps[19], 3, 3);
        targetReps[20] = changeFieldsTo(targetReps[20], 3, 3);

        targetReps[21] = changeFieldsTo(targetReps[21], 3, 3);
        targetReps[22] = changeFieldsTo(targetReps[22], 3, 3);
        targetReps[23] = changeFieldsTo(targetReps[23], 3, 3);

        targetReps[24] = changeFieldsTo(targetReps[24], 3, 3);
        targetReps[25] = changeFieldsTo(targetReps[25], 3, 3);
        targetReps[26] = changeFieldsTo(targetReps[26], 3, 3);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_3_PT_3_TM_1_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 1);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);

        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 0, 0);
        targetReps[13] = changeFieldsTo(targetReps[13], 0, 0);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 0, 0);
        targetReps[16] = changeFieldsTo(targetReps[16], 0, 0);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 0, 0);
        targetReps[22] = changeFieldsTo(targetReps[22], 0, 0);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 0, 0);
        targetReps[25] = changeFieldsTo(targetReps[25], 0, 0);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 2, 2);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 2, 2);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);

        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 2, 2);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 2, 2);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 2, 2);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 2, 2);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 2, 2);
        targetReps[1] = changeFieldsTo(targetReps[1], 2, 2);
        targetReps[2] = changeFieldsTo(targetReps[2], 3, 3);

        targetReps[3] = changeFieldsTo(targetReps[3], 2, 2);
        targetReps[4] = changeFieldsTo(targetReps[4], 2, 2);
        targetReps[5] = changeFieldsTo(targetReps[5], 3, 3);

        targetReps[6] = changeFieldsTo(targetReps[6], 2, 2);
        targetReps[7] = changeFieldsTo(targetReps[7], 2, 2);
        targetReps[8] = changeFieldsTo(targetReps[8], 3, 3);

        targetReps[9] = changeFieldsTo(targetReps[9], 2, 2);
        targetReps[10] = changeFieldsTo(targetReps[10], 2, 2);
        targetReps[11] = changeFieldsTo(targetReps[11], 3, 3);

        targetReps[12] = changeFieldsTo(targetReps[12], 2, 2);
        targetReps[13] = changeFieldsTo(targetReps[13], 2, 2);
        targetReps[14] = changeFieldsTo(targetReps[14], 3, 3);

        targetReps[15] = changeFieldsTo(targetReps[15], 2, 2);
        targetReps[16] = changeFieldsTo(targetReps[16], 2, 2);
        targetReps[17] = changeFieldsTo(targetReps[17], 3, 3);


        targetReps[18] = changeFieldsTo(targetReps[18], 2, 2);
        targetReps[19] = changeFieldsTo(targetReps[19], 2, 2);
        targetReps[20] = changeFieldsTo(targetReps[20], 3, 3);

        targetReps[21] = changeFieldsTo(targetReps[21], 2, 2);
        targetReps[22] = changeFieldsTo(targetReps[22], 2, 2);
        targetReps[23] = changeFieldsTo(targetReps[23], 3, 3);

        targetReps[24] = changeFieldsTo(targetReps[24], 2, 2);
        targetReps[25] = changeFieldsTo(targetReps[25], 2, 2);
        targetReps[26] = changeFieldsTo(targetReps[26], 3, 3);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 3, 3);
        targetReps[1] = changeFieldsTo(targetReps[1], 3, 3);
        targetReps[2] = changeFieldsTo(targetReps[2], 4, 4);

        targetReps[3] = changeFieldsTo(targetReps[3], 3, 3);
        targetReps[4] = changeFieldsTo(targetReps[4], 3, 3);
        targetReps[5] = changeFieldsTo(targetReps[5], 4, 4);

        targetReps[6] = changeFieldsTo(targetReps[6], 3, 3);
        targetReps[7] = changeFieldsTo(targetReps[7], 3, 3);
        targetReps[8] = changeFieldsTo(targetReps[8], 4, 4);

        targetReps[9] = changeFieldsTo(targetReps[9], 3, 3);
        targetReps[10] = changeFieldsTo(targetReps[10], 3, 3);
        targetReps[11] = changeFieldsTo(targetReps[11], 4, 4);

        targetReps[12] = changeFieldsTo(targetReps[12], 3, 3);
        targetReps[13] = changeFieldsTo(targetReps[13], 3, 3);
        targetReps[14] = changeFieldsTo(targetReps[14], 4, 4);

        targetReps[15] = changeFieldsTo(targetReps[15], 3, 3);
        targetReps[16] = changeFieldsTo(targetReps[16], 3, 3);
        targetReps[17] = changeFieldsTo(targetReps[17], 4, 4);


        targetReps[18] = changeFieldsTo(targetReps[18], 3, 3);
        targetReps[19] = changeFieldsTo(targetReps[19], 3, 3);
        targetReps[20] = changeFieldsTo(targetReps[20], 4, 4);

        targetReps[21] = changeFieldsTo(targetReps[21], 3, 3);
        targetReps[22] = changeFieldsTo(targetReps[22], 3, 3);
        targetReps[23] = changeFieldsTo(targetReps[23], 4, 4);

        targetReps[24] = changeFieldsTo(targetReps[24], 3, 3);
        targetReps[25] = changeFieldsTo(targetReps[25], 3, 3);
        targetReps[26] = changeFieldsTo(targetReps[26], 4, 4);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     16) 3 OP - 3 PT - 3 TM - 3 TR
    /* ========================================================= */
    @IsTest
    private static void t_3_OP_3_PT_3_TM_3_TR_PositiveTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        System.debug('\n\n targetReps.size() => ' + JSON.serializePretty(targetReps.size()) + '\n');
        System.debug('\n\n targetReps => ' + JSON.serializePretty(targetReps) + '\n');
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);


        targetReps[27] = changeFieldsTo(targetReps[27], 1, 1);
        targetReps[28] = changeFieldsTo(targetReps[28], 1, 1);
        targetReps[29] = changeFieldsTo(targetReps[29], 1, 1);

        targetReps[30] = changeFieldsTo(targetReps[30], 1, 1);
        targetReps[31] = changeFieldsTo(targetReps[31], 1, 1);
        targetReps[32] = changeFieldsTo(targetReps[32], 1, 1);

        targetReps[33] = changeFieldsTo(targetReps[33], 1, 1);
        targetReps[34] = changeFieldsTo(targetReps[34], 1, 1);
        targetReps[35] = changeFieldsTo(targetReps[35], 2, 2);


        targetReps[36] = changeFieldsTo(targetReps[36], 1, 1);
        targetReps[37] = changeFieldsTo(targetReps[37], 1, 1);
        targetReps[38] = changeFieldsTo(targetReps[38], 1, 1);

        targetReps[39] = changeFieldsTo(targetReps[39], 1, 1);
        targetReps[40] = changeFieldsTo(targetReps[40], 1, 1);
        targetReps[41] = changeFieldsTo(targetReps[41], 1, 1);

        targetReps[42] = changeFieldsTo(targetReps[42], 1, 1);
        targetReps[43] = changeFieldsTo(targetReps[43], 1, 1);
        targetReps[44] = changeFieldsTo(targetReps[44], 2, 2);


        targetReps[45] = changeFieldsTo(targetReps[45], 1, 1);
        targetReps[46] = changeFieldsTo(targetReps[46], 1, 1);
        targetReps[47] = changeFieldsTo(targetReps[47], 1, 1);

        targetReps[48] = changeFieldsTo(targetReps[48], 1, 1);
        targetReps[49] = changeFieldsTo(targetReps[49], 1, 1);
        targetReps[50] = changeFieldsTo(targetReps[50], 1, 1);

        targetReps[51] = changeFieldsTo(targetReps[51], 1, 1);
        targetReps[52] = changeFieldsTo(targetReps[52], 1, 1);
        targetReps[53] = changeFieldsTo(targetReps[53], 2, 2);


        targetReps[54] = changeFieldsTo(targetReps[54], 1, 1);
        targetReps[55] = changeFieldsTo(targetReps[55], 1, 1);
        targetReps[56] = changeFieldsTo(targetReps[56], 1, 1);

        targetReps[57] = changeFieldsTo(targetReps[57], 1, 1);
        targetReps[58] = changeFieldsTo(targetReps[58], 1, 1);
        targetReps[59] = changeFieldsTo(targetReps[59], 1, 1);

        targetReps[60] = changeFieldsTo(targetReps[60], 1, 1);
        targetReps[61] = changeFieldsTo(targetReps[61], 1, 1);
        targetReps[62] = changeFieldsTo(targetReps[62], 2, 2);


        targetReps[63] = changeFieldsTo(targetReps[63], 1, 1);
        targetReps[64] = changeFieldsTo(targetReps[64], 1, 1);
        targetReps[65] = changeFieldsTo(targetReps[65], 1, 1);

        targetReps[66] = changeFieldsTo(targetReps[66], 1, 1);
        targetReps[67] = changeFieldsTo(targetReps[67], 1, 1);
        targetReps[68] = changeFieldsTo(targetReps[68], 1, 1);

        targetReps[69] = changeFieldsTo(targetReps[69], 1, 1);
        targetReps[70] = changeFieldsTo(targetReps[70], 1, 1);
        targetReps[71] = changeFieldsTo(targetReps[71], 2, 2);


        targetReps[72] = changeFieldsTo(targetReps[72], 1, 1);
        targetReps[73] = changeFieldsTo(targetReps[73], 1, 1);
        targetReps[74] = changeFieldsTo(targetReps[74], 1, 1);

        targetReps[75] = changeFieldsTo(targetReps[75], 1, 1);
        targetReps[76] = changeFieldsTo(targetReps[76], 1, 1);
        targetReps[77] = changeFieldsTo(targetReps[77], 1, 1);

        targetReps[78] = changeFieldsTo(targetReps[78], 1, 1);
        targetReps[79] = changeFieldsTo(targetReps[79], 1, 1);
        targetReps[80] = changeFieldsTo(targetReps[80], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive(ops[0].Id);
    }

    @IsTest
    private static void t_3_OP_3_PT_3_TM_3_TR_NegativeTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);


        targetReps[27] = changeFieldsTo(targetReps[27], 1, 1);
        targetReps[28] = changeFieldsTo(targetReps[28], 1, 1);
        targetReps[29] = changeFieldsTo(targetReps[29], 1, 1);

        targetReps[30] = changeFieldsTo(targetReps[30], 1, 1);
        targetReps[31] = changeFieldsTo(targetReps[31], 1, 1);
        targetReps[32] = changeFieldsTo(targetReps[32], 1, 1);

        targetReps[33] = changeFieldsTo(targetReps[33], 1, 1);
        targetReps[34] = changeFieldsTo(targetReps[34], 1, 1);
        targetReps[35] = changeFieldsTo(targetReps[35], 1, 1);


        targetReps[36] = changeFieldsTo(targetReps[36], 1, 1);
        targetReps[37] = changeFieldsTo(targetReps[37], 1, 1);
        targetReps[38] = changeFieldsTo(targetReps[38], 1, 1);

        targetReps[39] = changeFieldsTo(targetReps[39], 1, 1);
        targetReps[40] = changeFieldsTo(targetReps[40], 1, 1);
        targetReps[41] = changeFieldsTo(targetReps[41], 1, 1);

        targetReps[42] = changeFieldsTo(targetReps[42], 1, 1);
        targetReps[43] = changeFieldsTo(targetReps[43], 1, 1);
        targetReps[44] = changeFieldsTo(targetReps[44], 1, 1);


        targetReps[45] = changeFieldsTo(targetReps[45], 1, 1);
        targetReps[46] = changeFieldsTo(targetReps[46], 1, 1);
        targetReps[47] = changeFieldsTo(targetReps[47], 1, 1);

        targetReps[48] = changeFieldsTo(targetReps[48], 1, 1);
        targetReps[49] = changeFieldsTo(targetReps[49], 1, 1);
        targetReps[50] = changeFieldsTo(targetReps[50], 1, 1);

        targetReps[51] = changeFieldsTo(targetReps[51], 1, 1);
        targetReps[52] = changeFieldsTo(targetReps[52], 1, 1);
        targetReps[53] = changeFieldsTo(targetReps[53], 1, 1);


        targetReps[54] = changeFieldsTo(targetReps[54], 1, 1);
        targetReps[55] = changeFieldsTo(targetReps[55], 1, 1);
        targetReps[56] = changeFieldsTo(targetReps[56], 1, 1);

        targetReps[57] = changeFieldsTo(targetReps[57], 1, 1);
        targetReps[58] = changeFieldsTo(targetReps[58], 1, 1);
        targetReps[59] = changeFieldsTo(targetReps[59], 1, 1);

        targetReps[60] = changeFieldsTo(targetReps[60], 1, 1);
        targetReps[61] = changeFieldsTo(targetReps[61], 1, 1);
        targetReps[62] = changeFieldsTo(targetReps[62], 1, 1);


        targetReps[63] = changeFieldsTo(targetReps[63], 1, 1);
        targetReps[64] = changeFieldsTo(targetReps[64], 1, 1);
        targetReps[65] = changeFieldsTo(targetReps[65], 1, 1);

        targetReps[66] = changeFieldsTo(targetReps[66], 1, 1);
        targetReps[67] = changeFieldsTo(targetReps[67], 1, 1);
        targetReps[68] = changeFieldsTo(targetReps[68], 1, 1);

        targetReps[69] = changeFieldsTo(targetReps[69], 1, 1);
        targetReps[70] = changeFieldsTo(targetReps[70], 1, 1);
        targetReps[71] = changeFieldsTo(targetReps[71], 1, 1);


        targetReps[72] = changeFieldsTo(targetReps[72], 1, 1);
        targetReps[73] = changeFieldsTo(targetReps[73], 1, 1);
        targetReps[74] = changeFieldsTo(targetReps[74], 1, 1);

        targetReps[75] = changeFieldsTo(targetReps[75], 1, 1);
        targetReps[76] = changeFieldsTo(targetReps[76], 1, 1);
        targetReps[77] = changeFieldsTo(targetReps[77], 1, 1);

        targetReps[78] = changeFieldsTo(targetReps[78], 1, 1);
        targetReps[79] = changeFieldsTo(targetReps[79], 1, 1);
        targetReps[80] = changeFieldsTo(targetReps[80], 1, 1);
        update targetReps;
        Test.stopTest();

        checkNegative();
    }

    @IsTest
    private static void t_3_OP_3_PT_3_TM_3_TR_NegativeToPositiveStepByStepTest() {
        EUR_CRM_OP_Template__c template = selectTemplate();
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = makeObjectivesPromotions(template.Id);
        insert opsToInsert;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        EUR_CRM_OP_Product__c product = selectProduct();

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(ops, product.Id, 10, 10, 3);
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(product.Id, promoTargets, 3);
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(product.Id, targetManagers, 3);
        insert targetReps;

        checkNegative();

        Test.startTest();
        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 0, 0);

        targetReps[6] = changeFieldsTo(targetReps[6], 0, 0);
        targetReps[7] = changeFieldsTo(targetReps[7], 0, 0);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 0, 0);

        targetReps[12] = changeFieldsTo(targetReps[12], 0, 0);
        targetReps[13] = changeFieldsTo(targetReps[13], 0, 0);
        targetReps[14] = changeFieldsTo(targetReps[14], 0, 0);

        targetReps[15] = changeFieldsTo(targetReps[15], 0, 0);
        targetReps[16] = changeFieldsTo(targetReps[16], 0, 0);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 0, 0);

        targetReps[21] = changeFieldsTo(targetReps[21], 0, 0);
        targetReps[22] = changeFieldsTo(targetReps[22], 0, 0);
        targetReps[23] = changeFieldsTo(targetReps[23], 0, 0);

        targetReps[24] = changeFieldsTo(targetReps[24], 0, 0);
        targetReps[25] = changeFieldsTo(targetReps[25], 0, 0);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);


        targetReps[27] = changeFieldsTo(targetReps[27], 0, 0);
        targetReps[28] = changeFieldsTo(targetReps[28], 0, 0);
        targetReps[29] = changeFieldsTo(targetReps[29], 0, 0);

        targetReps[30] = changeFieldsTo(targetReps[30], 0, 0);
        targetReps[31] = changeFieldsTo(targetReps[31], 0, 0);
        targetReps[32] = changeFieldsTo(targetReps[32], 0, 0);

        targetReps[33] = changeFieldsTo(targetReps[33], 0, 0);
        targetReps[34] = changeFieldsTo(targetReps[34], 0, 0);
        targetReps[35] = changeFieldsTo(targetReps[35], 1, 1);


        targetReps[36] = changeFieldsTo(targetReps[36], 0, 0);
        targetReps[37] = changeFieldsTo(targetReps[37], 0, 0);
        targetReps[38] = changeFieldsTo(targetReps[38], 0, 0);

        targetReps[39] = changeFieldsTo(targetReps[39], 0, 0);
        targetReps[40] = changeFieldsTo(targetReps[40], 0, 0);
        targetReps[41] = changeFieldsTo(targetReps[41], 0, 0);

        targetReps[42] = changeFieldsTo(targetReps[42], 0, 0);
        targetReps[43] = changeFieldsTo(targetReps[43], 0, 0);
        targetReps[44] = changeFieldsTo(targetReps[44], 1, 1);


        targetReps[45] = changeFieldsTo(targetReps[45], 0, 0);
        targetReps[46] = changeFieldsTo(targetReps[46], 0, 0);
        targetReps[47] = changeFieldsTo(targetReps[47], 0, 0);

        targetReps[48] = changeFieldsTo(targetReps[48], 0, 0);
        targetReps[49] = changeFieldsTo(targetReps[49], 0, 0);
        targetReps[50] = changeFieldsTo(targetReps[50], 0, 0);

        targetReps[51] = changeFieldsTo(targetReps[51], 0, 0);
        targetReps[52] = changeFieldsTo(targetReps[52], 0, 0);
        targetReps[53] = changeFieldsTo(targetReps[53], 1, 1);


        targetReps[54] = changeFieldsTo(targetReps[54], 0, 0);
        targetReps[55] = changeFieldsTo(targetReps[55], 0, 0);
        targetReps[56] = changeFieldsTo(targetReps[56], 0, 0);

        targetReps[57] = changeFieldsTo(targetReps[57], 0, 0);
        targetReps[58] = changeFieldsTo(targetReps[58], 0, 0);
        targetReps[59] = changeFieldsTo(targetReps[59], 0, 0);

        targetReps[60] = changeFieldsTo(targetReps[60], 0, 0);
        targetReps[61] = changeFieldsTo(targetReps[61], 0, 0);
        targetReps[62] = changeFieldsTo(targetReps[62], 1, 1);


        targetReps[63] = changeFieldsTo(targetReps[63], 0, 0);
        targetReps[64] = changeFieldsTo(targetReps[64], 0, 0);
        targetReps[65] = changeFieldsTo(targetReps[65], 0, 0);

        targetReps[66] = changeFieldsTo(targetReps[66], 0, 0);
        targetReps[67] = changeFieldsTo(targetReps[67], 0, 0);
        targetReps[68] = changeFieldsTo(targetReps[68], 0, 0);

        targetReps[69] = changeFieldsTo(targetReps[69], 0, 0);
        targetReps[70] = changeFieldsTo(targetReps[70], 0, 0);
        targetReps[71] = changeFieldsTo(targetReps[71], 1, 1);


        targetReps[72] = changeFieldsTo(targetReps[72], 0, 0);
        targetReps[73] = changeFieldsTo(targetReps[73], 0, 0);
        targetReps[74] = changeFieldsTo(targetReps[74], 0, 0);

        targetReps[75] = changeFieldsTo(targetReps[75], 0, 0);
        targetReps[76] = changeFieldsTo(targetReps[76], 0, 0);
        targetReps[77] = changeFieldsTo(targetReps[77], 0, 0);

        targetReps[78] = changeFieldsTo(targetReps[78], 0, 0);
        targetReps[79] = changeFieldsTo(targetReps[79], 0, 0);
        targetReps[80] = changeFieldsTo(targetReps[80], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 0, 0);
        targetReps[4] = changeFieldsTo(targetReps[4], 0, 0);
        targetReps[5] = changeFieldsTo(targetReps[5], 0, 0);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 1, 1);


        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 0, 0);

        targetReps[12] = changeFieldsTo(targetReps[12], 0, 0);
        targetReps[13] = changeFieldsTo(targetReps[13], 0, 0);
        targetReps[14] = changeFieldsTo(targetReps[14], 0, 0);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 1, 1);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 0, 0);

        targetReps[21] = changeFieldsTo(targetReps[21], 0, 0);
        targetReps[22] = changeFieldsTo(targetReps[22], 0, 0);
        targetReps[23] = changeFieldsTo(targetReps[23], 0, 0);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 1, 1);


        targetReps[27] = changeFieldsTo(targetReps[27], 0, 0);
        targetReps[28] = changeFieldsTo(targetReps[28], 0, 0);
        targetReps[29] = changeFieldsTo(targetReps[29], 0, 0);

        targetReps[30] = changeFieldsTo(targetReps[30], 0, 0);
        targetReps[31] = changeFieldsTo(targetReps[31], 0, 0);
        targetReps[32] = changeFieldsTo(targetReps[32], 0, 0);

        targetReps[33] = changeFieldsTo(targetReps[33], 1, 1);
        targetReps[34] = changeFieldsTo(targetReps[34], 1, 1);
        targetReps[35] = changeFieldsTo(targetReps[35], 1, 1);


        targetReps[36] = changeFieldsTo(targetReps[36], 0, 0);
        targetReps[37] = changeFieldsTo(targetReps[37], 0, 0);
        targetReps[38] = changeFieldsTo(targetReps[38], 0, 0);

        targetReps[39] = changeFieldsTo(targetReps[39], 0, 0);
        targetReps[40] = changeFieldsTo(targetReps[40], 0, 0);
        targetReps[41] = changeFieldsTo(targetReps[41], 0, 0);

        targetReps[42] = changeFieldsTo(targetReps[42], 1, 1);
        targetReps[43] = changeFieldsTo(targetReps[43], 1, 1);
        targetReps[44] = changeFieldsTo(targetReps[44], 1, 1);


        targetReps[45] = changeFieldsTo(targetReps[45], 0, 0);
        targetReps[46] = changeFieldsTo(targetReps[46], 0, 0);
        targetReps[47] = changeFieldsTo(targetReps[47], 0, 0);

        targetReps[48] = changeFieldsTo(targetReps[48], 0, 0);
        targetReps[49] = changeFieldsTo(targetReps[49], 0, 0);
        targetReps[50] = changeFieldsTo(targetReps[50], 0, 0);

        targetReps[51] = changeFieldsTo(targetReps[51], 1, 1);
        targetReps[52] = changeFieldsTo(targetReps[52], 1, 1);
        targetReps[53] = changeFieldsTo(targetReps[53], 1, 1);


        targetReps[54] = changeFieldsTo(targetReps[54], 0, 0);
        targetReps[55] = changeFieldsTo(targetReps[55], 0, 0);
        targetReps[56] = changeFieldsTo(targetReps[56], 0, 0);

        targetReps[57] = changeFieldsTo(targetReps[57], 0, 0);
        targetReps[58] = changeFieldsTo(targetReps[58], 0, 0);
        targetReps[59] = changeFieldsTo(targetReps[59], 0, 0);

        targetReps[60] = changeFieldsTo(targetReps[60], 1, 1);
        targetReps[61] = changeFieldsTo(targetReps[61], 1, 1);
        targetReps[62] = changeFieldsTo(targetReps[62], 1, 1);


        targetReps[63] = changeFieldsTo(targetReps[63], 0, 0);
        targetReps[64] = changeFieldsTo(targetReps[64], 0, 0);
        targetReps[65] = changeFieldsTo(targetReps[65], 0, 0);

        targetReps[66] = changeFieldsTo(targetReps[66], 0, 0);
        targetReps[67] = changeFieldsTo(targetReps[67], 0, 0);
        targetReps[68] = changeFieldsTo(targetReps[68], 0, 0);

        targetReps[69] = changeFieldsTo(targetReps[69], 1, 1);
        targetReps[70] = changeFieldsTo(targetReps[70], 1, 1);
        targetReps[71] = changeFieldsTo(targetReps[71], 1, 1);


        targetReps[72] = changeFieldsTo(targetReps[72], 0, 0);
        targetReps[73] = changeFieldsTo(targetReps[73], 0, 0);
        targetReps[74] = changeFieldsTo(targetReps[74], 0, 0);

        targetReps[75] = changeFieldsTo(targetReps[75], 0, 0);
        targetReps[76] = changeFieldsTo(targetReps[76], 0, 0);
        targetReps[77] = changeFieldsTo(targetReps[77], 0, 0);

        targetReps[78] = changeFieldsTo(targetReps[78], 1, 1);
        targetReps[79] = changeFieldsTo(targetReps[79], 1, 1);
        targetReps[80] = changeFieldsTo(targetReps[80], 1, 1);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 0, 0);
        targetReps[1] = changeFieldsTo(targetReps[1], 0, 0);
        targetReps[2] = changeFieldsTo(targetReps[2], 0, 0);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);


        targetReps[9] = changeFieldsTo(targetReps[9], 0, 0);
        targetReps[10] = changeFieldsTo(targetReps[10], 0, 0);
        targetReps[11] = changeFieldsTo(targetReps[11], 0, 0);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 0, 0);
        targetReps[19] = changeFieldsTo(targetReps[19], 0, 0);
        targetReps[20] = changeFieldsTo(targetReps[20], 0, 0);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);


        targetReps[27] = changeFieldsTo(targetReps[27], 0, 0);
        targetReps[28] = changeFieldsTo(targetReps[28], 0, 0);
        targetReps[29] = changeFieldsTo(targetReps[29], 0, 0);

        targetReps[30] = changeFieldsTo(targetReps[30], 1, 1);
        targetReps[31] = changeFieldsTo(targetReps[31], 1, 1);
        targetReps[32] = changeFieldsTo(targetReps[32], 1, 1);

        targetReps[33] = changeFieldsTo(targetReps[33], 1, 1);
        targetReps[34] = changeFieldsTo(targetReps[34], 1, 1);
        targetReps[35] = changeFieldsTo(targetReps[35], 2, 2);


        targetReps[36] = changeFieldsTo(targetReps[36], 0, 0);
        targetReps[37] = changeFieldsTo(targetReps[37], 0, 0);
        targetReps[38] = changeFieldsTo(targetReps[38], 0, 0);

        targetReps[39] = changeFieldsTo(targetReps[39], 1, 1);
        targetReps[40] = changeFieldsTo(targetReps[40], 1, 1);
        targetReps[41] = changeFieldsTo(targetReps[41], 1, 1);

        targetReps[42] = changeFieldsTo(targetReps[42], 1, 1);
        targetReps[43] = changeFieldsTo(targetReps[43], 1, 1);
        targetReps[44] = changeFieldsTo(targetReps[44], 2, 2);


        targetReps[45] = changeFieldsTo(targetReps[45], 0, 0);
        targetReps[46] = changeFieldsTo(targetReps[46], 0, 0);
        targetReps[47] = changeFieldsTo(targetReps[47], 0, 0);

        targetReps[48] = changeFieldsTo(targetReps[48], 1, 1);
        targetReps[49] = changeFieldsTo(targetReps[49], 1, 1);
        targetReps[50] = changeFieldsTo(targetReps[50], 1, 1);

        targetReps[51] = changeFieldsTo(targetReps[51], 1, 1);
        targetReps[52] = changeFieldsTo(targetReps[52], 1, 1);
        targetReps[53] = changeFieldsTo(targetReps[53], 2, 2);


        targetReps[54] = changeFieldsTo(targetReps[54], 0, 0);
        targetReps[55] = changeFieldsTo(targetReps[55], 0, 0);
        targetReps[56] = changeFieldsTo(targetReps[56], 0, 0);

        targetReps[57] = changeFieldsTo(targetReps[57], 1, 1);
        targetReps[58] = changeFieldsTo(targetReps[58], 1, 1);
        targetReps[59] = changeFieldsTo(targetReps[59], 1, 1);

        targetReps[60] = changeFieldsTo(targetReps[60], 1, 1);
        targetReps[61] = changeFieldsTo(targetReps[61], 1, 1);
        targetReps[62] = changeFieldsTo(targetReps[62], 2, 2);


        targetReps[63] = changeFieldsTo(targetReps[63], 0, 0);
        targetReps[64] = changeFieldsTo(targetReps[64], 0, 0);
        targetReps[65] = changeFieldsTo(targetReps[65], 0, 0);

        targetReps[66] = changeFieldsTo(targetReps[66], 1, 1);
        targetReps[67] = changeFieldsTo(targetReps[67], 1, 1);
        targetReps[68] = changeFieldsTo(targetReps[68], 1, 1);

        targetReps[69] = changeFieldsTo(targetReps[69], 1, 1);
        targetReps[70] = changeFieldsTo(targetReps[70], 1, 1);
        targetReps[71] = changeFieldsTo(targetReps[71], 2, 2);


        targetReps[72] = changeFieldsTo(targetReps[72], 0, 0);
        targetReps[73] = changeFieldsTo(targetReps[73], 0, 0);
        targetReps[74] = changeFieldsTo(targetReps[74], 0, 0);

        targetReps[75] = changeFieldsTo(targetReps[75], 1, 1);
        targetReps[76] = changeFieldsTo(targetReps[76], 1, 1);
        targetReps[77] = changeFieldsTo(targetReps[77], 1, 1);

        targetReps[78] = changeFieldsTo(targetReps[78], 1, 1);
        targetReps[79] = changeFieldsTo(targetReps[79], 1, 1);
        targetReps[80] = changeFieldsTo(targetReps[80], 2, 2);
        update targetReps;
        checkNegative();

        targetReps[0] = changeFieldsTo(targetReps[0], 1, 1);
        targetReps[1] = changeFieldsTo(targetReps[1], 1, 1);
        targetReps[2] = changeFieldsTo(targetReps[2], 1, 1);

        targetReps[3] = changeFieldsTo(targetReps[3], 1, 1);
        targetReps[4] = changeFieldsTo(targetReps[4], 1, 1);
        targetReps[5] = changeFieldsTo(targetReps[5], 1, 1);

        targetReps[6] = changeFieldsTo(targetReps[6], 1, 1);
        targetReps[7] = changeFieldsTo(targetReps[7], 1, 1);
        targetReps[8] = changeFieldsTo(targetReps[8], 2, 2);


        targetReps[9] = changeFieldsTo(targetReps[9], 1, 1);
        targetReps[10] = changeFieldsTo(targetReps[10], 1, 1);
        targetReps[11] = changeFieldsTo(targetReps[11], 1, 1);

        targetReps[12] = changeFieldsTo(targetReps[12], 1, 1);
        targetReps[13] = changeFieldsTo(targetReps[13], 1, 1);
        targetReps[14] = changeFieldsTo(targetReps[14], 1, 1);

        targetReps[15] = changeFieldsTo(targetReps[15], 1, 1);
        targetReps[16] = changeFieldsTo(targetReps[16], 1, 1);
        targetReps[17] = changeFieldsTo(targetReps[17], 2, 2);


        targetReps[18] = changeFieldsTo(targetReps[18], 1, 1);
        targetReps[19] = changeFieldsTo(targetReps[19], 1, 1);
        targetReps[20] = changeFieldsTo(targetReps[20], 1, 1);

        targetReps[21] = changeFieldsTo(targetReps[21], 1, 1);
        targetReps[22] = changeFieldsTo(targetReps[22], 1, 1);
        targetReps[23] = changeFieldsTo(targetReps[23], 1, 1);

        targetReps[24] = changeFieldsTo(targetReps[24], 1, 1);
        targetReps[25] = changeFieldsTo(targetReps[25], 1, 1);
        targetReps[26] = changeFieldsTo(targetReps[26], 2, 2);


        targetReps[27] = changeFieldsTo(targetReps[27], 1, 1);
        targetReps[28] = changeFieldsTo(targetReps[28], 1, 1);
        targetReps[29] = changeFieldsTo(targetReps[29], 1, 1);

        targetReps[30] = changeFieldsTo(targetReps[30], 1, 1);
        targetReps[31] = changeFieldsTo(targetReps[31], 1, 1);
        targetReps[32] = changeFieldsTo(targetReps[32], 1, 1);

        targetReps[33] = changeFieldsTo(targetReps[33], 1, 1);
        targetReps[34] = changeFieldsTo(targetReps[34], 1, 1);
        targetReps[35] = changeFieldsTo(targetReps[35], 2, 2);


        targetReps[36] = changeFieldsTo(targetReps[36], 1, 1);
        targetReps[37] = changeFieldsTo(targetReps[37], 1, 1);
        targetReps[38] = changeFieldsTo(targetReps[38], 1, 1);

        targetReps[39] = changeFieldsTo(targetReps[39], 1, 1);
        targetReps[40] = changeFieldsTo(targetReps[40], 1, 1);
        targetReps[41] = changeFieldsTo(targetReps[41], 1, 1);

        targetReps[42] = changeFieldsTo(targetReps[42], 1, 1);
        targetReps[43] = changeFieldsTo(targetReps[43], 1, 1);
        targetReps[44] = changeFieldsTo(targetReps[44], 2, 2);


        targetReps[45] = changeFieldsTo(targetReps[45], 1, 1);
        targetReps[46] = changeFieldsTo(targetReps[46], 1, 1);
        targetReps[47] = changeFieldsTo(targetReps[47], 1, 1);

        targetReps[48] = changeFieldsTo(targetReps[48], 1, 1);
        targetReps[49] = changeFieldsTo(targetReps[49], 1, 1);
        targetReps[50] = changeFieldsTo(targetReps[50], 1, 1);

        targetReps[51] = changeFieldsTo(targetReps[51], 1, 1);
        targetReps[52] = changeFieldsTo(targetReps[52], 1, 1);
        targetReps[53] = changeFieldsTo(targetReps[53], 2, 2);


        targetReps[54] = changeFieldsTo(targetReps[54], 1, 1);
        targetReps[55] = changeFieldsTo(targetReps[55], 1, 1);
        targetReps[56] = changeFieldsTo(targetReps[56], 1, 1);

        targetReps[57] = changeFieldsTo(targetReps[57], 1, 1);
        targetReps[58] = changeFieldsTo(targetReps[58], 1, 1);
        targetReps[59] = changeFieldsTo(targetReps[59], 1, 1);

        targetReps[60] = changeFieldsTo(targetReps[60], 1, 1);
        targetReps[61] = changeFieldsTo(targetReps[61], 1, 1);
        targetReps[62] = changeFieldsTo(targetReps[62], 2, 2);


        targetReps[63] = changeFieldsTo(targetReps[63], 1, 1);
        targetReps[64] = changeFieldsTo(targetReps[64], 1, 1);
        targetReps[65] = changeFieldsTo(targetReps[65], 1, 1);

        targetReps[66] = changeFieldsTo(targetReps[66], 1, 1);
        targetReps[67] = changeFieldsTo(targetReps[67], 1, 1);
        targetReps[68] = changeFieldsTo(targetReps[68], 1, 1);

        targetReps[69] = changeFieldsTo(targetReps[69], 1, 1);
        targetReps[70] = changeFieldsTo(targetReps[70], 1, 1);
        targetReps[71] = changeFieldsTo(targetReps[71], 2, 2);


        targetReps[72] = changeFieldsTo(targetReps[72], 1, 1);
        targetReps[73] = changeFieldsTo(targetReps[73], 1, 1);
        targetReps[74] = changeFieldsTo(targetReps[74], 1, 1);

        targetReps[75] = changeFieldsTo(targetReps[75], 1, 1);
        targetReps[76] = changeFieldsTo(targetReps[76], 1, 1);
        targetReps[77] = changeFieldsTo(targetReps[77], 1, 1);

        targetReps[78] = changeFieldsTo(targetReps[78], 1, 1);
        targetReps[79] = changeFieldsTo(targetReps[79], 1, 1);
        targetReps[80] = changeFieldsTo(targetReps[80], 2, 2);
        update targetReps;
        Test.stopTest();

        checkPositive();
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static Boolean isCheckable() {
//        List<EUR_CRM_OP_Target_Confirmation_Fields__mdt> dependedFieldsRelatedTo = selectDependedFieldsRelatedTo();
        return true;
    }

    private static EUR_CRM_OP_Target_REP__c changeFieldsTo(EUR_CRM_OP_Target_REP__c targetRep, Integer targetBottles, Integer targetDisplays) {
        targetRep.EUR_CRM_Actual_Volume_Bottles__c = targetBottles;
        targetRep.EUR_CRM_Actual_Volume_Displays__c = targetDisplays;
        return targetRep;
    }

//    private static List<EUR_CRM_OP_Target_REP__c> changeFieldsTo(List<EUR_CRM_OP_Target_REP__c> targetReps, Integer targetBottles, Integer targetDisplays) {
//        for (EUR_CRM_OP_Target_REP__c targetRep : targetReps) {
//            targetRep.EUR_CRM_Actual_Volume_Bottles__c = targetBottles;
//            targetRep.EUR_CRM_Actual_Volume_Displays__c = targetDisplays;
//        }
//        return targetReps;
//    }

    private static void checkPositive() {
        if ( ! isCheckable()) { return; }
        checkPositive(selectObjectivesPromotions());
    }

    private static void checkNegative() {
        if ( ! isCheckable()) { return; }
        checkNegative(selectObjectivesPromotions());
    }

    private static void checkPositive(Id opId) {
        if ( ! isCheckable()) { return; }
        checkPositive(selectObjectivesPromotions(opId));
    }

    private static void checkNegative(Id opId) {
        if ( ! isCheckable()) { return; }
        checkNegative(selectObjectivesPromotions(opId));
    }

    private static void checkPositive(List<EUR_CRM_Objectives_Promotions__c> ops) {
        System.assertNotEquals(0, ops.size());
        for (EUR_CRM_Objectives_Promotions__c op : ops) {
            System.assertEquals(EUR_CRM_OPPromTargDistToHandler.OP_COMPLETED_STATUS, op.EUR_CRM_Status__c);
        }
    }

    private static void checkNegative(List<EUR_CRM_Objectives_Promotions__c> ops) {
        System.assertNotEquals(0, ops.size());
        for (EUR_CRM_Objectives_Promotions__c op : ops) {
            System.assertNotEquals(EUR_CRM_OPPromTargDistToHandler.OP_COMPLETED_STATUS, op.EUR_CRM_Status__c);
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private static List<EUR_CRM_Objectives_Promotions__c> makeObjectivesPromotions(Id templateId) {
        List<EUR_CRM_Objectives_Promotions__c> objectivesPromotions = new List<EUR_CRM_Objectives_Promotions__c>();
        for (Integer i = 0; i < 2; i++) {
            objectivesPromotions.add(makeObjectivesPromotion(templateId));
        }
        return objectivesPromotions;
    }

    private static List<EUR_CRM_OP_Promo_Target__c> makePromoTargets(Id opId, Id productId, Integer targetBottles, Integer targetDisplays) {
        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        for (Integer i = 0; i < 3; i++) {
            promoTargets.add(makePromoTarget(opId, productId, targetBottles, targetDisplays));
        }
        return promoTargets;
    }

    private static List<EUR_CRM_OP_Promo_Target__c> makePromoTargets(List<EUR_CRM_Objectives_Promotions__c> ops, Id productId, Integer targetBottles, Integer targetDisplays, Integer countOfRecords) {
        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        for (EUR_CRM_Objectives_Promotions__c op : ops) {
            for (Integer i = 0; i < countOfRecords; i++) {
                promoTargets.add(makePromoTarget(op.Id, productId, targetBottles, targetDisplays));
            }
        }
        return promoTargets;
    }

    private static List<EUR_CRM_OP_Target_Manager__c> makeTargetManagers(Id opId, Id productId, Id promoTargetId) {
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        for (Integer i = 0; i < 3; i++) {
            targetManagers.add(makeTargetManager(opId, productId, promoTargetId));
        }
        return targetManagers;
    }

    private static List<EUR_CRM_OP_Target_Manager__c> makeTargetManagers(Id productId, List<EUR_CRM_OP_Promo_Target__c> promoTargets, Integer countOfRecords) {
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        for (EUR_CRM_OP_Promo_Target__c promoTarget : promoTargets) {
            for (Integer i = 0; i < countOfRecords; i++) {
                targetManagers.add(makeTargetManager(promoTarget.EUR_CRM_Objectives_Promotions__c, productId, promoTarget.Id));
            }
        }
        return targetManagers;
    }

    private static List<EUR_CRM_OP_Target_REP__c> makeTargetReps(Id opId, Id productId, Id targetManagerId) {
        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        for (Integer i = 0; i < 3; i++) {
            targetReps.add(makeTargetRep(opId, productId, targetManagerId));
        }
        return targetReps;
    }

    private static List<EUR_CRM_OP_Target_REP__c> makeTargetReps(Id productId, List<EUR_CRM_OP_Target_Manager__c> targetManagers, Integer countOfRecords) {
        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        for (EUR_CRM_OP_Target_Manager__c targetManager : targetManagers) {
            for (Integer i = 0; i < countOfRecords; i++) {
                targetReps.add(makeTargetRep(targetManager.EUR_CRM_Objectives_Promotions__c, productId, targetManager.Id));
            }
        }
        return targetReps;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_OP_Template__c makeOPTemplate(String level) {
        return new EUR_CRM_OP_Template__c(
            Name = 'OP Template Test'
        ,   EUR_CRM_Target_Quota_Levels__c = level
        ,   EUR_CRM_Has_Quota__c = true
        );
    }

    private static EUR_CRM_OP_Action__c makeOPAction(Id templateId, String fieldName) {
        return new EUR_CRM_OP_Action__c(
            Name = 'OP Action Test'
        ,   EUR_CRM_OP_Template__c = templateId
        ,   EUR_CRM_MultiPLOpTarget__c = fieldName
        ,   EUR_CRM_Reoccuring_Type__c = 'Repeat all time'
        );
    }

    private static EUR_CRM_Objectives_Promotions__c makeObjectivesPromotion(Id templateId) {
        return new EUR_CRM_Objectives_Promotions__c(
            EUR_CRM_OP_Template__c = templateId
        ,   Name = 'OP Test'
        ,   EUR_CRM_Status__c = 'Active'
        );
    }

    private static EUR_CRM_Brand__c makeBrand(String name) {
        return new EUR_CRM_Brand__c(
            Name = name
        );
    }

    private static EUR_CRM_OP_Product__c makeProduct(Id opId, String productApiName, String productId) {
        EUR_CRM_OP_Product__c product = new EUR_CRM_OP_Product__c(
            EUR_CRM_Objectives_Promotions__c = opId
        );
        product.put(productApiName, productId);
        return product;
    }

    private static EUR_CRM_OP_Promo_Target__c makePromoTarget(Id opId, Id productId, Integer targetBottles, Integer targetDisplays) {
        return new EUR_CRM_OP_Promo_Target__c(
            EUR_CRM_Objectives_Promotions__c = opId
        ,   EUR_CRM_OP_Product__c = productId
        ,   EUR_CRM_Target_Sell_in_Amount_Bottle__c = targetBottles
        ,   EUR_CRM_Target_Sell_in_Amount_Display__c = targetDisplays
        );
    }

    private static EUR_CRM_OP_Target_Manager__c makeTargetManager(Id opId, Id productId, Id promoTargetId) {
        return new EUR_CRM_OP_Target_Manager__c(
            EUR_CRM_Objectives_Promotions__c = opId
        ,   EUR_CRM_OP_Promo_Target__c = promoTargetId
        ,   EUR_CRM_OP_Product__c = productId
        );
    }

    private static EUR_CRM_OP_Target_REP__c makeTargetRep(Id opId, Id productId, Id targetManagerId) {
        return new EUR_CRM_OP_Target_REP__c(
            EUR_CRM_Objectives_Promotions__c = opId
        ,   EUR_CRM_OP_Target_Manager__c = targetManagerId
        ,   EUR_CRM_OP_Product__c = productId
        );
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static EUR_CRM_OP_Template__c selectTemplate() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Template__c
            LIMIT 1
        ][0];
    }

    private static List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_Objectives_Promotions__c
        ];
    }

    private static List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE Id = :opId
        ];
    }

    private static EUR_CRM_OP_Product__c selectProduct() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Product__c
            LIMIT 1
        ][0];
    }

}