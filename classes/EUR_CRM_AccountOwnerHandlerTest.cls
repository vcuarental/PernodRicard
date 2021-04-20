@IsTest (isParallel = true)
private class EUR_CRM_AccountOwnerHandlerTest {

    private static final Integer COUNT_OF_RECORDS = 5;

    @TestSetup
    private static void setupMethod() {
        Test.startTest();
        EUR_CRM_Region__c russia = makeRegion('Russia');
        insert russia;

        EUR_CRM_Territory__c moscow = makeTerritory(russia.Id, 'Moscow');
        insert moscow;

        EUR_CRM_Account__c hardRockCafeMoscowCity = makeAccount(moscow.Id, 'Hard Rock Cafe in Moscow City');
        insert hardRockCafeMoscowCity;

        EUR_CRM_Account_Target_Group__c atg = makeAccountTargetGroup();
        insert atg;

        EUR_CRM_Account_in_Target_Group__c accInATG = makeAccountInTargetGroup(atg.Id, hardRockCafeMoscowCity.Id);
        insert accInATG;

        EUR_CRM_OP_Template__c opTemplate = makeOPTemplate(EUR_CRM_ObjPromoTargetMngmntCtrl.DEFAULT_SECTION_TO_DISPLAY);
        insert opTemplate;

        List<EUR_CRM_OP_Action__c> opActions = new List<EUR_CRM_OP_Action__c>();
        opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Listing__c'));
        opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_People__c'));
        opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Promo_Kits__c'));
        opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Spyders__c'));
        opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Sell_in_Amount_Bottle__c'));
        insert opActions;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(opTemplate.Id, atg.Id);
        insert op;
        Test.stopTest();
    }

    @IsTest
    private static void setupTest() {
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].EUR_CRM_Territory__c);
        System.assertNotEquals(null, accounts[0].EUR_CRM_Territory__r.EUR_CRM_Region__c);
        System.assertNotEquals(null, accounts[0].EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c);

        List<EUR_CRM_OP_Template__c> opTemplates = selectOPTemplates();
        System.assertEquals(1, opTemplates.size());

        List<EUR_CRM_OP_Action__c> opActions = selectOPActions();
        System.assertEquals('EUR_CRM_Target_Quantity_Listing__c', opActions[0].EUR_CRM_MultiPLOpTarget__c);
        System.assertEquals('EUR_CRM_Target_Quantity_People__c', opActions[1].EUR_CRM_MultiPLOpTarget__c);
        System.assertEquals('EUR_CRM_Target_Quantity_Promo_Kits__c', opActions[2].EUR_CRM_MultiPLOpTarget__c);
        System.assertEquals('EUR_CRM_Target_Quantity_Spyders__c', opActions[3].EUR_CRM_MultiPLOpTarget__c);
        System.assertEquals('EUR_CRM_Target_Sell_in_Amount_Bottle__c', opActions[4].EUR_CRM_MultiPLOpTarget__c);
        System.assertEquals(5, opActions.size());

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        System.assertEquals(1, ops.size());
    }


//    ATG_1 : OP_1:
//      Account_1.Owner == Owner_1 && TargetRep_1.TargetOwner == Owner_1
//    Update Action:
//          => Account_1.Owner == Owner_2 ===> TargetRep_1.TargetOwner == Owner_2
    @IsTest
    private static void singleTargetRepForSingleAccountInOneATGPositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        accounts[0].OwnerId = newUserId;

        Test.startTest();
        update accounts;
        Test.stopTest();

        List<EUR_CRM_OP_Target_REP__c> targetReps = selectTargetRepsWhereOP(op.Id);
        System.assertEquals(1, targetReps.size());
        System.assertEquals(newUserId, targetReps[0].EUR_CRM_Target_Owner__c);
    }

    @IsTest
    private static void singleTargetRepForSingleAccountInOneATGButOPWithEndedStatusNegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        op.EUR_CRM_Status__c = 'Ended';
        update op;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        accounts[0].OwnerId = newUserId;

        Test.startTest();
        update accounts;
        Test.stopTest();

        List<EUR_CRM_OP_Target_REP__c> targetReps = selectTargetRepsWhereOP(op.Id);
        System.assertEquals(1, targetReps.size());
        System.assertEquals(UserInfo.getUserId(), targetReps[0].EUR_CRM_Target_Owner__c);
    }

    @IsTest
    private static void singleTargetRepForSingleAccountInOneATGButOPWithDeactivatedStatusNegativeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        op.EUR_CRM_Status__c = 'Deactivated';
        update op;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        accounts[0].OwnerId = newUserId;

        Test.startTest();
        update accounts;
        Test.stopTest();

        List<EUR_CRM_OP_Target_REP__c> targetReps = selectTargetRepsWhereOP(op.Id);
        System.assertEquals(1, targetReps.size());
        System.assertEquals(UserInfo.getUserId(), targetReps[0].EUR_CRM_Target_Owner__c);
    }


//    ATG_1 : OP_1:
//      Account_1.Owner == Owner_1 && TargetRep_x.TargetOwner == Owner_1
//    Update Action:
//          => Account_1.Owner == Owner_2 ===> TargetRep_x.TargetOwner == Owner_2
    @IsTest
    private static void multipleTargetRepsForSingleAccountInOneATGPositiveTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        targetReps.add(makeTargetRep(op.Id, product.Id, targetManager.Id));
        targetReps.add(makeTargetRep(op.Id, product.Id, targetManager.Id));
        targetReps.add(makeTargetRep(op.Id, product.Id, targetManager.Id));
        targetReps.add(makeTargetRep(op.Id, product.Id, targetManager.Id));
        targetReps.add(makeTargetRep(op.Id, product.Id, targetManager.Id));
        insert targetReps;

        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        accounts[0].OwnerId = newUserId;

        Test.startTest();
        update accounts;
        Test.stopTest();

        List<EUR_CRM_OP_Target_REP__c> targetRepsAfter = selectTargetRepsWhereOP(op.Id);
        System.assertEquals(5, targetRepsAfter.size());
        for (EUR_CRM_OP_Target_REP__c targetRep : targetRepsAfter) {
            System.assertEquals(newUserId, targetRep.EUR_CRM_Target_Owner__c);
        }
    }


//    ATG_1 : OP_1:
//      Account_1.Owner == Owner_1 && TargetRep_1.TargetOwner == Owner_1
//      Account_2.Owner == Owner_1
//      Account_3.Owner == Owner_1
//    Update Action:
//          => Account_1.Owner == Owner_2 ===> TargetRep_1.TargetOwner == Owner_2
    @IsTest
    private static void singleTargetRepForMultipleAccountsInOneATGNegativeTest() {
        Test.startTest();
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        List<EUR_CRM_Territory__c> territories = selectTerritories();
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>();
        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 1'));
        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 2'));
        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 3'));
        insert accountsToInsert;

        List<EUR_CRM_Account_Target_Group__c> accountTargetGroups = selectAccountTargetGroups();
        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = new List<EUR_CRM_Account_in_Target_Group__c>();
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[0].Id, accountsToInsert[0].Id));
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[0].Id, accountsToInsert[1].Id));
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[0].Id, accountsToInsert[2].Id));
        insert accountInTargetGroups;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        Test.stopTest();

        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        targetReps.add(makeTargetRep(op.Id, product.Id, targetManager.Id));
        insert targetReps;

        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        accounts[0].OwnerId = newUserId;

        update accounts;

        List<EUR_CRM_OP_Target_REP__c> targetRepsAfter = selectTargetRepsWhereOP(op.Id);
        System.assertEquals(1, targetRepsAfter.size());
        for (EUR_CRM_OP_Target_REP__c targetRep : targetRepsAfter) {
            System.assertEquals(UserInfo.getUserId(), targetRep.EUR_CRM_Target_Owner__c);
        }
    }


//    ATG_1 : OP_1:
//      Account_1.Owner == Owner_1 && TargetRep_1.TargetOwner == Owner_1
//    ATG_2 : OP_2:
//      Account_1.Owner == Owner_1 && TargetRep_2.TargetOwner == Owner_1
//    ATG_3 : OP_3:
//      Account_1.Owner == Owner_1 && TargetRep_3.TargetOwner == Owner_1
//    Update Action:
//          => Account_1.Owner == Owner_2 ===> TargetRep_1.TargetOwner == Owner_2
//                                        ===> TargetRep_2.TargetOwner == Owner_2
//                                        ===> TargetRep_3.TargetOwner == Owner_2
    @IsTest
    private static void singleTargetRepForOneAccountInMultipleATGsPositiveTest() {
        List<EUR_CRM_Account_Target_Group__c> accountTargetGroupsToInsert = new List<EUR_CRM_Account_Target_Group__c>();
        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
        insert accountTargetGroupsToInsert;

        List<EUR_CRM_Account_Target_Group__c> accountTargetGroups = selectAccountTargetGroups();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = new List<EUR_CRM_Account_in_Target_Group__c>();
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[1].Id, accounts[0].Id));
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[2].Id, accounts[0].Id));
        insert accountInTargetGroups;

        EUR_CRM_OP_Template__c opTemplate = selectOPTemplates()[0];
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = new List<EUR_CRM_Objectives_Promotions__c>();
        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[1].Id));
        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[2].Id));
        insert opsToInsert;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();

        List<EUR_CRM_OP_Product__c> products = new List<EUR_CRM_OP_Product__c>();
        products.add(makeProduct(ops[0].Id, 'EUR_CRM_Brand__c', brand.Id));
        products.add(makeProduct(ops[1].Id, 'EUR_CRM_Brand__c', brand.Id));
        products.add(makeProduct(ops[2].Id, 'EUR_CRM_Brand__c', brand.Id));
        insert products;

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        promoTargets.add(makePromoTarget(ops[0].Id, products[0].Id));
        promoTargets.add(makePromoTarget(ops[1].Id, products[1].Id));
        promoTargets.add(makePromoTarget(ops[2].Id, products[2].Id));
        insert promoTargets;

        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        targetManagers.add(makeTargetManager(ops[0].Id, products[0].Id, promoTargets[0].Id));
        targetManagers.add(makeTargetManager(ops[1].Id, products[1].Id, promoTargets[1].Id));
        targetManagers.add(makeTargetManager(ops[2].Id, products[2].Id, promoTargets[2].Id));
        insert targetManagers;

        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        targetReps.add(makeTargetRep(ops[0].Id, products[0].Id, targetManagers[0].Id));
        targetReps.add(makeTargetRep(ops[1].Id, products[1].Id, targetManagers[1].Id));
        targetReps.add(makeTargetRep(ops[2].Id, products[2].Id, targetManagers[2].Id));
        insert targetReps;

        Test.startTest();
        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;
        accounts[0].OwnerId = newUserId;

        update accounts[0];
        Test.stopTest();

        List<EUR_CRM_OP_Target_REP__c> targetRepsAfter = selectTargetRepsWhereOP(ops[0].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(newUserId, targetRepsAfter[0].EUR_CRM_Target_Owner__c);

        targetRepsAfter = selectTargetRepsWhereOP(ops[1].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(newUserId, targetRepsAfter[0].EUR_CRM_Target_Owner__c);

        targetRepsAfter = selectTargetRepsWhereOP(ops[2].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(newUserId, targetRepsAfter[0].EUR_CRM_Target_Owner__c);
    }


//    ATG_1 : OP_1:
//      Account_1.Owner == Owner_1 && TargetRep_1.TargetOwner == Owner_1
//    ATG_2 : OP_2:
//      Account_2.Owner == Owner_1 && TargetRep_2.TargetOwner == Owner_1
//    ATG_3 : OP_3:
//      Account_3.Owner == Owner_1 && TargetRep_3.TargetOwner == Owner_1
//    Update Action:
//          => Account_1.Owner == Owner_2 ===> TargetRep_1.TargetOwner == Owner_2
    @IsTest
    private static void singleTargetRepForMultipleAccountInMultipleATGsPartialPositiveTest() {
        Test.startTest();
        List<EUR_CRM_Territory__c> territories = selectTerritories();
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>();
        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 1'));
        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 2'));
        insert accountsToInsert;

        List<EUR_CRM_Account_Target_Group__c> accountTargetGroupsToInsert = new List<EUR_CRM_Account_Target_Group__c>();
        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
        insert accountTargetGroupsToInsert;

        List<EUR_CRM_Account_Target_Group__c> accountTargetGroups = selectAccountTargetGroups();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = new List<EUR_CRM_Account_in_Target_Group__c>();
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[1].Id, accounts[1].Id));
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[2].Id, accounts[2].Id));
        insert accountInTargetGroups;

        EUR_CRM_OP_Template__c opTemplate = selectOPTemplates()[0];
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = new List<EUR_CRM_Objectives_Promotions__c>();
        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[1].Id));
        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[2].Id));
        insert opsToInsert;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        Test.stopTest();

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();

        List<EUR_CRM_OP_Product__c> products = new List<EUR_CRM_OP_Product__c>();
        products.add(makeProduct(ops[0].Id, 'EUR_CRM_Brand__c', brand.Id));
        products.add(makeProduct(ops[1].Id, 'EUR_CRM_Brand__c', brand.Id));
        products.add(makeProduct(ops[2].Id, 'EUR_CRM_Brand__c', brand.Id));
        insert products;

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        promoTargets.add(makePromoTarget(ops[0].Id, products[0].Id));
        promoTargets.add(makePromoTarget(ops[1].Id, products[1].Id));
        promoTargets.add(makePromoTarget(ops[2].Id, products[2].Id));
        insert promoTargets;

        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        targetManagers.add(makeTargetManager(ops[0].Id, products[0].Id, promoTargets[0].Id));
        targetManagers.add(makeTargetManager(ops[1].Id, products[1].Id, promoTargets[1].Id));
        targetManagers.add(makeTargetManager(ops[2].Id, products[2].Id, promoTargets[2].Id));
        insert targetManagers;

        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        targetReps.add(makeTargetRep(ops[0].Id, products[0].Id, targetManagers[0].Id));
        targetReps.add(makeTargetRep(ops[1].Id, products[1].Id, targetManagers[1].Id));
        targetReps.add(makeTargetRep(ops[2].Id, products[2].Id, targetManagers[2].Id));
        insert targetReps;

        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;
        accounts[0].OwnerId = newUserId;

        update accounts[0];

        List<EUR_CRM_OP_Target_REP__c> targetRepsAfter = selectTargetRepsWhereOP(ops[0].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(newUserId, targetRepsAfter[0].EUR_CRM_Target_Owner__c);

        targetRepsAfter = selectTargetRepsWhereOP(ops[1].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(UserInfo.getUserId(), targetRepsAfter[0].EUR_CRM_Target_Owner__c);

        targetRepsAfter = selectTargetRepsWhereOP(ops[2].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(UserInfo.getUserId(), targetRepsAfter[0].EUR_CRM_Target_Owner__c);
    }


//    ATG_1 : OP_1:
//      Account_1.Owner == Owner_1 && TargetRep_1.TargetOwner == Owner_1
//    ATG_2 : OP_2:
//      Account_2.Owner == Owner_1 && TargetRep_2.TargetOwner == Owner_1
//    ATG_3 : OP_3:
//      Account_3.Owner == Owner_1 && TargetRep_3.TargetOwner == Owner_1
//    Update Action:
//          => Account_1.Owner == Owner_2 ===> TargetRep_1.TargetOwner == Owner_2
//          => Account_2.Owner == Owner_2 ===> TargetRep_2.TargetOwner == Owner_2
//          => Account_3.Owner == Owner_2 ===> TargetRep_3.TargetOwner == Owner_2
    @IsTest
    private static void singleTargetRepForMultipleAccountInMultipleATGsFullPositiveTest() {
        Test.startTest();
        List<EUR_CRM_Territory__c> territories = selectTerritories();
        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>();
        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 1'));
        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 2'));
        insert accountsToInsert;

        List<EUR_CRM_Account_Target_Group__c> accountTargetGroupsToInsert = new List<EUR_CRM_Account_Target_Group__c>();
        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
        insert accountTargetGroupsToInsert;

        List<EUR_CRM_Account_Target_Group__c> accountTargetGroups = selectAccountTargetGroups();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = new List<EUR_CRM_Account_in_Target_Group__c>();
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[1].Id, accounts[1].Id));
        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[2].Id, accounts[2].Id));
        insert accountInTargetGroups;

        EUR_CRM_OP_Template__c opTemplate = selectOPTemplates()[0];
        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = new List<EUR_CRM_Objectives_Promotions__c>();
        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[1].Id));
        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[2].Id));
        insert opsToInsert;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        Test.stopTest();

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();

        List<EUR_CRM_OP_Product__c> products = new List<EUR_CRM_OP_Product__c>();
        products.add(makeProduct(ops[0].Id, 'EUR_CRM_Brand__c', brand.Id));
        products.add(makeProduct(ops[1].Id, 'EUR_CRM_Brand__c', brand.Id));
        products.add(makeProduct(ops[2].Id, 'EUR_CRM_Brand__c', brand.Id));
        insert products;

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        promoTargets.add(makePromoTarget(ops[0].Id, products[0].Id));
        promoTargets.add(makePromoTarget(ops[1].Id, products[1].Id));
        promoTargets.add(makePromoTarget(ops[2].Id, products[2].Id));
        insert promoTargets;

        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        targetManagers.add(makeTargetManager(ops[0].Id, products[0].Id, promoTargets[0].Id));
        targetManagers.add(makeTargetManager(ops[1].Id, products[1].Id, promoTargets[1].Id));
        targetManagers.add(makeTargetManager(ops[2].Id, products[2].Id, promoTargets[2].Id));
        insert targetManagers;

        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        targetReps.add(makeTargetRep(ops[0].Id, products[0].Id, targetManagers[0].Id));
        targetReps.add(makeTargetRep(ops[1].Id, products[1].Id, targetManagers[1].Id));
        targetReps.add(makeTargetRep(ops[2].Id, products[2].Id, targetManagers[2].Id));
        insert targetReps;

        Id newUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;
        for (EUR_CRM_Account__c account : accounts) {
            account.OwnerId = newUserId;
        }

        update accounts;


        List<EUR_CRM_OP_Target_REP__c> targetRepsAfter = selectTargetRepsWhereOP(ops[0].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(newUserId, targetRepsAfter[0].EUR_CRM_Target_Owner__c);

        targetRepsAfter = selectTargetRepsWhereOP(ops[1].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(newUserId, targetRepsAfter[0].EUR_CRM_Target_Owner__c);

        targetRepsAfter = selectTargetRepsWhereOP(ops[2].Id);
        System.assertEquals(1, targetRepsAfter.size());
        System.assertEquals(newUserId, targetRepsAfter[0].EUR_CRM_Target_Owner__c);
    }


//    ATG_1 : OP_1:
//      Account_1.Owner == Owner_1 && TargetRep_1.TargetOwner == Owner_1
//    ATG_2 : OP_2:
//      Account_2.Owner == Owner_1 && TargetRep_2.TargetOwner == Owner_1
//    ATG_3 : OP_3:
//      Account_3.Owner == Owner_1 && TargetRep_3.TargetOwner == Owner_1
//    Update Action:
//          => Account_1.Owner == Owner_2 ===> TargetRep_1.TargetOwner == Owner_2
//          => Account_2.Owner == Owner_3 ===> TargetRep_2.TargetOwner == Owner_3
//          => Account_3.Owner == Owner_4 ===> TargetRep_3.TargetOwner == Owner_4
//    TODO: not covered case. Reason: impossible scenario.
//    @IsTest
//    private static void singleTargetRepForMultipleAccountInMultipleATGsUpdateSeveralAccountOwnerPartialPositiveTest() {
//        List<EUR_CRM_Territory__c> territories = selectTerritories();
//        List<EUR_CRM_Account__c> accountsToInsert = new List<EUR_CRM_Account__c>();
//        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 1'));
//        accountsToInsert.add(makeAccount(territories[0].Id, 'New Cafe 2'));
//        insert accountsToInsert;
//
//        List<EUR_CRM_Account_Target_Group__c> accountTargetGroupsToInsert = new List<EUR_CRM_Account_Target_Group__c>();
//        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
//        accountTargetGroupsToInsert.add(makeAccountTargetGroup());
//        insert accountTargetGroupsToInsert;
//
//        List<EUR_CRM_Account_Target_Group__c> accountTargetGroups = selectAccountTargetGroups();
//
//        List<EUR_CRM_Account__c> accounts = selectAccounts();
//        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = new List<EUR_CRM_Account_in_Target_Group__c>();
//        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[1].Id, accounts[1].Id));
//        accountInTargetGroups.add(makeAccountInTargetGroup(accountTargetGroups[2].Id, accounts[2].Id));
//        insert accountInTargetGroups;
//
//        EUR_CRM_OP_Template__c opTemplate = selectOPTemplates()[0];
//        List<EUR_CRM_Objectives_Promotions__c> opsToInsert = new List<EUR_CRM_Objectives_Promotions__c>();
//        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[1].Id));
//        opsToInsert.add(makeObjectivesPromotions(opTemplate.Id, accountTargetGroups[2].Id));
//        insert opsToInsert;
//
//        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
//        insert brand;
//
//        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
//
//        List<EUR_CRM_OP_Product__c> products = new List<EUR_CRM_OP_Product__c>();
//        products.add(makeProduct(ops[0].Id, 'EUR_CRM_Brand__c', brand.Id));
//        products.add(makeProduct(ops[1].Id, 'EUR_CRM_Brand__c', brand.Id));
//        products.add(makeProduct(ops[2].Id, 'EUR_CRM_Brand__c', brand.Id));
//        insert products;
//
//        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
//        promoTargets.add(makePromoTarget(ops[0].Id, products[0].Id));
//        promoTargets.add(makePromoTarget(ops[1].Id, products[1].Id));
//        promoTargets.add(makePromoTarget(ops[2].Id, products[2].Id));
//        insert promoTargets;
//
//        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
//        targetManagers.add(makeTargetManager(ops[0].Id, products[0].Id, promoTargets[0].Id));
//        targetManagers.add(makeTargetManager(ops[1].Id, products[1].Id, promoTargets[1].Id));
//        targetManagers.add(makeTargetManager(ops[2].Id, products[2].Id, promoTargets[2].Id));
//        insert targetManagers;
//
//        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
//        targetReps.add(makeTargetRep(ops[0].Id, products[0].Id, targetManagers[0].Id));
//        targetReps.add(makeTargetRep(ops[1].Id, products[1].Id, targetManagers[1].Id));
//        targetReps.add(makeTargetRep(ops[2].Id, products[2].Id, targetManagers[2].Id));
//        insert targetReps;
//
//        Test.startTest();
//        Id newUserId1 = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1][0].Id;
//        accounts[0].OwnerId = newUserId1;
//
//        Id newUserId2 = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1 OFFSET 1][0].Id;
//        accounts[1].OwnerId = newUserId2;
//
//        Id newUserId3 = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1 OFFSET 2][0].Id;
//        accounts[1].OwnerId = newUserId3;
//
//        update accounts;
//        Test.stopTest();
//
//        List<EUR_CRM_OP_Target_REP__c> targetRepsAfter = selectTargetRepsWhereOP(ops[0].Id);
//        System.assertEquals(1, targetRepsAfter.size());
//        System.assertEquals(newUserId1, targetRepsAfter[0].EUR_CRM_Target_Owner__c);
//
//        targetRepsAfter = selectTargetRepsWhereOP(ops[1].Id);
//        System.assertEquals(1, targetRepsAfter.size());
//        System.assertEquals(newUserId2, targetRepsAfter[0].EUR_CRM_Target_Owner__c);
//
//        targetRepsAfter = selectTargetRepsWhereOP(ops[2].Id);
//        System.assertEquals(1, targetRepsAfter.size());
//        System.assertEquals(newUserId3, targetRepsAfter[0].EUR_CRM_Target_Owner__c);
//    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Region__c makeRegion(String name) {
        return new EUR_CRM_Region__c(
            Name = name
        ,   EUR_CRM_Channel__c = 'ON TRADE'
        ,   EUR_CRM_Region_Owner__c = UserInfo.getUserId()
        );
    }

    private static EUR_CRM_Territory__c makeTerritory(Id regionId, String name) {
        return new EUR_CRM_Territory__c(
            EUR_CRM_Region__c = regionId
        ,   Name = name
        );
    }

    private static EUR_CRM_Account__c makeAccount(Id terrId, String name) {
        return new EUR_CRM_Account__c(
            Name = name
        ,   EUR_CRM_Territory__c = terrId
        ,   EUR_CRM_Postal_Code__c = '1122'
        , RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        ,   EUR_CRM_Channel__c = 'ON TRADE'
        ,   OwnerId = UserInfo.getUserId()
        );
    }

    private static EUR_CRM_Account_Target_Group__c makeAccountTargetGroup() {
        return new EUR_CRM_Account_Target_Group__c(Name = 'ATG Test');
    }

    private static EUR_CRM_Account_in_Target_Group__c makeAccountInTargetGroup(Id atgId, Id accId) {
        return new EUR_CRM_Account_in_Target_Group__c(
            EUR_CRM_Account_Target_Group__c = atgId
        ,   EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_OP_Template__c makeOPTemplate(String level) {
        return new EUR_CRM_OP_Template__c(
            Name = 'OP Template Test'
        ,   EUR_CRM_Target_Quota_Levels__c = level
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

    private static EUR_CRM_Objectives_Promotions__c makeObjectivesPromotions(Id templateId) {
        return new EUR_CRM_Objectives_Promotions__c(
            EUR_CRM_OP_Template__c = templateId
        ,   Name = 'OP Test'
        );
    }

    private static EUR_CRM_Objectives_Promotions__c makeObjectivesPromotions(Id templateId, Id atgId) {
        return new EUR_CRM_Objectives_Promotions__c(
            EUR_CRM_OP_Template__c = templateId
        ,   Name = 'OP Test'
        ,   EUR_CRM_Account_Target_Group__c = atgId
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

    private static EUR_CRM_OP_Promo_Target__c makePromoTarget(Id opId, Id productId) {
        return new EUR_CRM_OP_Promo_Target__c(
            EUR_CRM_Objectives_Promotions__c = opId
        ,   EUR_CRM_OP_Product__c = productId
        );
    }

    private static EUR_CRM_OP_Target_Manager__c makeTargetManager(Id opId, Id productId, Id promoTargetId) {
        return new EUR_CRM_OP_Target_Manager__c(
            EUR_CRM_Objectives_Promotions__c = opId
        ,   EUR_CRM_OP_Product__c = productId
        ,   EUR_CRM_OP_Promo_Target__c = promoTargetId
        ,   EUR_CRM_Target_Owner__c = UserInfo.getUserId()
        );
    }

    private static EUR_CRM_OP_Target_REP__c makeTargetRep(Id opId, Id productId, Id targetManagerId) {
        return new EUR_CRM_OP_Target_REP__c(
            EUR_CRM_Objectives_Promotions__c = opId
        ,   EUR_CRM_OP_Product__c = productId
        ,   EUR_CRM_OP_Target_Manager__c = targetManagerId
        ,   EUR_CRM_Target_Owner__c = UserInfo.getUserId()
        );
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static List<EUR_CRM_Territory__c> selectTerritories() {
        return [
            SELECT Id
            FROM EUR_CRM_Territory__c
        ];
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   EUR_CRM_Territory__c
            ,   EUR_CRM_Territory__r.EUR_CRM_Region__c
            ,   EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_OP_Template__c> selectOPTemplates() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Template__c
        ];
    }

    private static List<EUR_CRM_OP_Action__c> selectOPActions() {
        return [
            SELECT Id
                ,   EUR_CRM_MultiPLOpTarget__c
            FROM EUR_CRM_OP_Action__c
        ];
    }

    private static List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions() {
        return [
            SELECT Id
            FROM EUR_CRM_Objectives_Promotions__c
        ];
    }

    private static List<EUR_CRM_OP_Target_REP__c> selectTargetRepsWhereOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Product__c
            ,   EUR_CRM_OP_Target_Manager__c
            ,   EUR_CRM_Target_Owner__c
            ,   EUR_CRM_Target_Quantity_Listing__c
            ,   EUR_CRM_Target_Quantity_People__c
            ,   EUR_CRM_Target_Quantity_Promo_Kits__c
            ,   EUR_CRM_Target_Quantity_Spyders__c
            FROM EUR_CRM_OP_Target_REP__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
        ];
    }

    private static List<EUR_CRM_Account_Target_Group__c> selectAccountTargetGroups() {
        return [
            SELECT Id
            ,   Name
            FROM EUR_CRM_Account_Target_Group__c
        ];
    }

}