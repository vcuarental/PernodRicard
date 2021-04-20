@IsTest (IsParallel = true)
private class EUR_CRM_ObjPromoToAccAssignAuraCtrlTest {

    private static final Integer COUNT_OF_RECORDS = 3;

    @TestSetup
    private static void setupMethod() {
        EUR_CRM_Region__c russia = new EUR_CRM_Region__c(
            Name = 'Russia'
        ,   EUR_CRM_Channel__c = 'ON TRADE'
        ,   EUR_CRM_Region_Owner__c = UserInfo.getUserId()
        );
        insert russia;

        EUR_CRM_Territory__c moscow = new EUR_CRM_Territory__c(
            Name = 'Moscow'
        ,   EUR_CRM_Region__c = russia.Id
        );
        insert moscow;

        EUR_CRM_Account__c hardRockCafeMoscowCity = new EUR_CRM_Account__c(
            Name = 'Hard Rock Cafe in Moscow City'
        ,   EUR_CRM_Territory__c = moscow.Id
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        ,   EUR_CRM_Channel__c = 'ON TRADE'
        ,   OwnerId = UserInfo.getUserId()
        );
        insert hardRockCafeMoscowCity;

        EUR_CRM_Account_Target_Group__c atg = new EUR_CRM_Account_Target_Group__c(Name = 'ATG Test');
        insert atg;

        EUR_CRM_Account_in_Target_Group__c accInATG = new EUR_CRM_Account_in_Target_Group__c(
            EUR_CRM_Account_Target_Group__c = atg.Id
        ,   EUR_CRM_Account__c = hardRockCafeMoscowCity.Id
        );
        insert accInATG;

        EUR_CRM_OP_Template__c opTemplate = makeOPTemplate(EUR_CRM_ObjPromoTargetMngmntCtrl.DEFAULT_SECTION_TO_DISPLAY);
        insert opTemplate;
        insert makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Listing__c');
        insert makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_People__c');
        insert makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Promo_Kits__c');
        insert makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Spyders__c');
        insert makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Sell_in_Amount_Bottle__c');

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(opTemplate.Id);
        op.EUR_CRM_Account_Target_Group__c = atg.Id;
        insert op;
    }

    @IsTest
    private static void setupTest() {
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


    /* ========================================================= */
    /*     EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets()
    /* ========================================================= */
    @IsTest
    private static void getInitialTargetsSimpleStructureForBrandTest() {
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

        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets(op.Id);
        Test.stopTest();

        System.assertEquals(1, productWrappers.size());

        assertEmptyTree(productWrappers);
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForBrandQualityTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Quality__c quality = makeBrandQuality('ABSOLUT');
        insert quality;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand_Quality__c', quality.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets(op.Id);
        Test.stopTest();

        System.assertEquals(1, productWrappers.size());

        assertEmptyTree(productWrappers);
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForBrandQualitySizeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Size__c size = makeBrandQualitySize('ABSOLUT');
        insert size;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand_Quality_Size__c', size.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets(op.Id);
        Test.stopTest();

        System.assertEquals(1, productWrappers.size());

        assertEmptyTree(productWrappers);
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForSKUTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_SKU__c sku = makeSKU('ABSOLUT');
        insert sku;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_SKU_EU__c', sku.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets(op.Id);
        Test.stopTest();

        System.assertEquals(1, productWrappers.size());

        assertEmptyTree(productWrappers);
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForPOSMaterialsTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_POS_Material__c posMaterial = makePOSMaterial('ABSOLUT');
        insert posMaterial;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_POS_Material__c', posMaterial.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets(op.Id);
        Test.stopTest();

        System.assertEquals(1, productWrappers.size());

        assertEmptyTree(productWrappers);
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForProductToolkitTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Product_Toolkit__c productToolkit = makeProductToolkit('ABSOLUT');
        insert productToolkit;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Product_Toolkit__c', productToolkit.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c promoTarget = makePromoTarget(op.Id, product.Id);
        insert promoTarget;
        EUR_CRM_OP_Target_Manager__c targetManager = makeTargetManager(op.Id, product.Id, promoTarget.Id);
        insert targetManager;
        EUR_CRM_OP_Target_REP__c targetRep = makeTargetRep(op.Id, product.Id, targetManager.Id);
        insert targetRep;

        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets(op.Id);
        Test.stopTest();

        System.assertEquals(1, productWrappers.size());

        assertEmptyTree(productWrappers);
    }

    @IsTest
    private static void getInitialTargetsComplexStructureTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;
        List<EUR_CRM_OP_Product__c> products = makeProducts(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert products;
        List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(products).keySet()));
        insert promoTargets;
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(products).keySet()), new List<Id>(new Map<Id, EUR_CRM_OP_Promo_Target__c>(promoTargets).keySet()));
        insert targetManagers;
        List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, targetManagers);
        insert targetReps;

        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoToAccAssignAuraCtrl.getInitialTargets(op.Id);
        Test.stopTest();

        System.assertEquals(3, productWrappers.size());

        assertEmptyTree(productWrappers);
    }


    /* ================================================================================== */
    /*     EUR_CRM_ObjPromoToAccAssignAuraCtrl.getProductsWithManagersAndSalesReps()
    /* ================================================================================== */
    @IsTest
    private static void getProductsWithManagersAndSalesRepsSingleProductTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;

        Set<String> productIds = new Set<String> { brand.Id };

        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
        Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers =
            EUR_CRM_ObjPromoToAccAssignAuraCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(productIds), op.Id, JSON.serialize(accountById.keySet()));
        Test.stopTest();

        System.assertEquals(1, productWrappers.size());

        assertEmptyTree(productWrappers);
    }

    @IsTest
    private static void getProductsWithManagersAndSalesRepsMultipleProductsTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        List<EUR_CRM_Brand__c> brands = makeBrands(new List<String> { 'ABSOLUT', 'BEEFEATER', 'BUSNEL' });
        insert brands;

        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
        Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
        Test.startTest();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers =
            EUR_CRM_ObjPromoToAccAssignAuraCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(new Map<Id, EUR_CRM_Brand__c>(brands).keySet()), op.Id, JSON.serialize(accountById.keySet()));
        Test.stopTest();

        System.assertEquals(3, productWrappers.size());

        assertEmptyTree(productWrappers);
    }


    /* ========================================================= */
    /*     EUR_CRM_ObjPromoToAccAssignAuraCtrl.saveData()
    /* ========================================================= */
    @IsTest
    private static void saveDataAssignTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;

        Set<String> productIds = new Set<String> { brand.Id };

        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
        Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> pWs =
            EUR_CRM_ObjPromoToAccAssignAuraCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(productIds), op.Id, JSON.serialize(accountById.keySet()));
        populateProductWrappers(pWs);

        pWs[0].managers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper> {  pWs[0].managers[0] };
        pWs[0].managers[0].salesReps = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper> { pWs[0].managers[0].salesReps[0] };

        EUR_CRM_ObjPromoToAccAssignAuraCtrl.DataWrapper dw = new EUR_CRM_ObjPromoToAccAssignAuraCtrl.DataWrapper();
        EUR_CRM_Account_Target_Group__c atg = selectAccountTargetGroups()[0];
        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = selectAccountInTargetGroupsWhereAccountTargetGroupId(atg.Id);
        dw.accountTargetGroup = new EUR_CRM_ObjPromoToAccAssignAuraCtrl.AccountTargetGroupWrapper(atg, accountInTargetGroups);
        dw.accountTargetGroup.accountGroup.action = 'assign';
        dw.products = pWs;

        Test.startTest();
        String resultStatus = EUR_CRM_ObjPromoToAccAssignAuraCtrl.saveData(JSON.serialize(dw), op.Id);
        Test.stopTest();

        System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        System.assertEquals(atg.Id, ops[0].EUR_CRM_Account_Target_Group__c);
    }

    @IsTest
    private static void saveDataUpdateTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];
        EUR_CRM_Account_Target_Group__c atg = selectAccountTargetGroups()[0];
        op.EUR_CRM_Account_Target_Group__c = atg.Id;
        update op;

        EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
        insert brand;

        Set<String> productIds = new Set<String> { brand.Id };

        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
        Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
        List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> pWs =
            EUR_CRM_ObjPromoToAccAssignAuraCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(productIds), op.Id, JSON.serialize(accountById.keySet()));
        populateProductWrappers(pWs);

        pWs[0].managers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper> {  pWs[0].managers[0] };
        pWs[0].managers[0].salesReps = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper> { pWs[0].managers[0].salesReps[0] };

        EUR_CRM_ObjPromoToAccAssignAuraCtrl.DataWrapper dw = new EUR_CRM_ObjPromoToAccAssignAuraCtrl.DataWrapper();
        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = selectAccountInTargetGroupsWhereAccountTargetGroupId(atg.Id);
        dw.accountTargetGroup = new EUR_CRM_ObjPromoToAccAssignAuraCtrl.AccountTargetGroupWrapper(atg, accountInTargetGroups);
        dw.accountTargetGroup.accountGroup.action = 'update';
        dw.accountTargetGroup.accountGroup.IsDynamic = null;
        dw.accountTargetGroup.accountGroup.Name = 'Updated ATG Name';
        dw.products = pWs;

        Test.startTest();
        String resultStatus = EUR_CRM_ObjPromoToAccAssignAuraCtrl.saveData(JSON.serialize(dw), op.Id);
        Test.stopTest();

        System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

        List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
        System.assertEquals('Updated ATG Name', ops[0].EUR_CRM_Account_Target_Group__r.Name);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static void populateProductWrappers(List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> pWs) {
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';

        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';

        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].salesReps[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].salesReps[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].salesReps[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pWs[0].managers[0].salesReps[0].columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';
    }


    /* ========================================================= */
    /*     Assert Helpers
    /* ========================================================= */
    private static void assertEmptyTree(List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers) {
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper pw : productWrappers) {
            System.assertNotEquals(null, pw.targetSalesRep);
            System.assertNotEquals(null, pw.product);
            System.assertNotEquals(null, pw.productId);
            System.assertNotEquals(null, pw.productName);
            System.assertNotEquals(null, pw.promoTarget);
            System.assertNotEquals(0, pw.columnWrappers.size());

            for (EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper mw : pw.managers) {
                System.assertNotEquals(null, mw.targetSalesRep);
                System.assertNotEquals(null, mw.targetManager);
                System.assertNotEquals(null, mw.Id);
                System.assertNotEquals(null, mw.Name);
                System.assertNotEquals(0, mw.columnWrappers.size());

                for (EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper sw : mw.salesReps) {
                    System.assertNotEquals(null, sw.targetSalesRep);
                    System.assertNotEquals(null, sw.Id);
//                    System.assertNotEquals(null, sw.Name);
                    System.assertNotEquals(0, sw.columnWrappers.size());
                }
            }
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Brand__c> makeBrands(List<String> names) {
        List<EUR_CRM_Brand__c> brands = new List<EUR_CRM_Brand__c>();
        for (String name : names) {
            brands.add(makeBrand(name));
        }
        return brands;
    }

    private static List<EUR_CRM_OP_Product__c> makeProducts(Id opId, String productApiName, String productId) {
        List<EUR_CRM_OP_Product__c> products = new List<EUR_CRM_OP_Product__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            products.add(makeProduct(opId, productApiName, productId));
        }
        return products;
    }

    private static List<EUR_CRM_OP_Promo_Target__c> makePromoTargets(Id opId, List<Id> productIds) {
        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            promoTargets.add(makePromoTarget(opId, productIds[i]));
        }
        return promoTargets;
    }

    private static List<EUR_CRM_OP_Target_Manager__c> makeTargetManagers(Id opId, List<Id> productIds, List<Id> promoTargetIds) {
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        for (Integer i = 0; i < productIds.size(); i++) {
            for (Integer j = 0; j < COUNT_OF_RECORDS; j++) {
                targetManagers.add(makeTargetManager(opId, productIds[i], promoTargetIds[i]));
            }

        }
        return targetManagers;
    }

    private static List<EUR_CRM_OP_Target_REP__c> makeTargetReps(Id opId, List<EUR_CRM_OP_Target_Manager__c> targetManagers) {
        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        for (Integer i = 0; i < targetManagers.size(); i++) {
            for (Integer j = 0; j < COUNT_OF_RECORDS; j++) {
                targetReps.add(makeTargetRep(opId, targetManagers[i].EUR_CRM_OP_Product__c, targetManagers[i].Id));
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
        ,   EUR_CRM_Has_Target__c = true
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

    private static EUR_CRM_Brand__c makeBrand(String name) {
        return new EUR_CRM_Brand__c(
            Name = name
        );
    }

    private static EUR_CRM_Quality__c makeBrandQuality(String name) {
        return new EUR_CRM_Quality__c(
            Name = name
        );
    }

    private static EUR_CRM_Size__c makeBrandQualitySize(String name) {
        return new EUR_CRM_Size__c(
            Name = name
        );
    }

    private static EUR_CRM_SKU__c makeSKU(String name) {
        return new EUR_CRM_SKU__c(
            Name = name
        );
    }

    private static EUR_CRM_POS_Material__c makePOSMaterial(String name) {
        return new EUR_CRM_POS_Material__c(
            Name = name
        );
    }

    private static EUR_CRM_Product_Toolkit__c makeProductToolkit(String name) {
        return new EUR_CRM_Product_Toolkit__c(
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
    private static Map<Id, EUR_CRM_Account__c> selectAccountById() {
        return new Map<Id, EUR_CRM_Account__c>([
            SELECT Id
            FROM EUR_CRM_Account__c
        ]);
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
            ,   EUR_CRM_Account_Target_Group__c
            ,   EUR_CRM_Account_Target_Group__r.Name
            FROM EUR_CRM_Objectives_Promotions__c
        ];
    }

    private static List<EUR_CRM_Account_Target_Group__c> selectAccountTargetGroups() {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_IsDynamic__c
            ,   (
                SELECT Id
                ,   EUR_CRM_Account__c
                ,   EUR_CRM_Account__r.Name
                FROM Account_in_Target_Groups__r
            )
            FROM EUR_CRM_Account_Target_Group__c
        ];
    }

    private static List<EUR_CRM_Account_in_Target_Group__c> selectAccountInTargetGroupsWhereAccountTargetGroupId(Id atgId) {
        return [
            SELECT Id
                ,   EUR_CRM_Account__c
                ,   EUR_CRM_Account__r.Name
            FROM EUR_CRM_Account_in_Target_Group__c
            WHERE EUR_CRM_Account_Target_Group__c = :atgId
        ];
    }

}