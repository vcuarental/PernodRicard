@IsTest (IsParallel = true)
private class EUR_CRM_ObjPromoTargetMngmntCtrlTest {

    private static final Integer COUNT_OF_RECORDS = 3;

    @TestSetup
    private static void setupMethod() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Region__c russia = new EUR_CRM_Region__c(
                Name = 'Russia'
                , EUR_CRM_Channel__c = 'ON TRADE'
                , EUR_CRM_Region_Owner__c = UserInfo.getUserId()
            );
            insert russia;

            EUR_CRM_Territory__c moscow = new EUR_CRM_Territory__c(
                Name = 'Moscow'
                , EUR_CRM_Region__c = russia.Id
            );
            insert moscow;

            EUR_CRM_Account__c hardRockCafeMoscowCity = new EUR_CRM_Account__c(
                Name = 'Hard Rock Cafe in Moscow City'
                , EUR_CRM_Territory__c = moscow.Id
                , EUR_CRM_Postal_Code__c = '1122'
                , RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
                , EUR_CRM_Channel__c = 'ON TRADE'
                , OwnerId = UserInfo.getUserId()
            );
            insert hardRockCafeMoscowCity;

            EUR_CRM_Account_Target_Group__c atg = new EUR_CRM_Account_Target_Group__c(Name = 'ATG Test');
            insert atg;

            EUR_CRM_Account_in_Target_Group__c accInATG = new EUR_CRM_Account_in_Target_Group__c(
                EUR_CRM_Account_Target_Group__c = atg.Id
                , EUR_CRM_Account__c = hardRockCafeMoscowCity.Id
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
    }

    @IsTest
    private static void setupTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_OP_Template__c> opTemplates = selectOPTemplates();
            System.assertEquals(1, opTemplates.size());

            List<EUR_CRM_OP_Action__c> opActions = selectOPActions();
            System.assertEquals('EUR_CRM_Target_Quantity_Listing__c', opActions[0].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_People__c', opActions[1].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_Promo_Kits__c', opActions[2].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_Spyders__c', opActions[3].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals(5, opActions.size());

            List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
            System.assertEquals(1, ops.size());
        }
    }


    @IsTest
    private static void getSectionsToDisplayTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            Test.startTest();
            String level = EUR_CRM_ObjPromoTargetMngmntCtrl.getSectionsToDisplay(op.Id);
            Test.stopTest();

            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.DEFAULT_SECTION_TO_DISPLAY, level);
        }
    }

    @IsTest
    private static void getSectionsToDisplayDefaultTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_OP_Template__c opTemplate = selectOPTemplates()[0];
            opTemplate.EUR_CRM_Target_Quota_Levels__c = null;
            update opTemplate;

            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            Test.startTest();
            String level = EUR_CRM_ObjPromoTargetMngmntCtrl.getSectionsToDisplay(op.Id);
            Test.stopTest();

            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.DEFAULT_SECTION_TO_DISPLAY, level);
        }
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForBrandTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            Test.stopTest();

            System.assertEquals(1, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForBrandQualityTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            Test.stopTest();

            System.assertEquals(1, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForBrandQualitySizeTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            Test.stopTest();

            System.assertEquals(1, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForSKUTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            Test.stopTest();

            System.assertEquals(1, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForPOSMaterialsTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            Test.stopTest();

            System.assertEquals(1, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getInitialTargetsSimpleStructureForProductToolkitTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            Test.stopTest();

            System.assertEquals(1, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getInitialTargetsComplexStructureTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            Test.stopTest();

            System.assertEquals(3, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getProductsWithManagersAndSalesRepsSingleProductTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
            insert brand;

            Set<String> productIds = new Set<String> {
                brand.Id
            };

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
            Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
            Test.startTest();
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers =
                EUR_CRM_ObjPromoTargetMngmntCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(productIds), op.Id, JSON.serialize(accountById.keySet()));
            Test.stopTest();

            System.assertEquals(1, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void getProductsWithManagersAndSalesRepsMultipleProductsTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            List<EUR_CRM_Brand__c> brands = makeBrands(new List<String> {
                'ABSOLUT', 'BEEFEATER', 'BUSNEL'
            });
            insert brands;

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
            Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
            Test.startTest();
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers =
                EUR_CRM_ObjPromoTargetMngmntCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(new Map<Id, EUR_CRM_Brand__c>(brands).keySet()), op.Id, JSON.serialize(accountById.keySet()));
            Test.stopTest();

            System.assertEquals(3, productWrappers.size());

            assertEmptyTree(productWrappers);
        }
    }

    @IsTest
    private static void updateFormulaFieldsTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);

            productWrappers[0].columnWrappers[0].data = '1';
            productWrappers[0].columnWrappers[1].data = '2';

            Test.startTest();
            try {
                productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.updateFormulaFields(JSON.serialize(productWrappers));
            } catch (Exception le) {
                System.assertNotEquals(null, le);
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void createTargetsSingleCreationTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
            insert brand;

            Set<String> productIds = new Set<String> {
                brand.Id
            };

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
            Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> pWs =
                EUR_CRM_ObjPromoTargetMngmntCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(productIds), op.Id, JSON.serialize(accountById.keySet()));

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

            pWs[0].managers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper> {
                pWs[0].managers[0]
            };
            pWs[0].managers[0].salesReps = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper> {
                pWs[0].managers[0].salesReps[0]
            };

            Test.startTest();
            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(pWs), op.Id);
            Test.stopTest();

            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> products = selectProductsWhereOP(op.Id);
            System.assertEquals(1, products.size());

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(1, promoTargets.size());
            System.assertEquals(products[0].Id, promoTargets[0].EUR_CRM_OP_Product__c);
            System.assertEquals(1, promoTargets[0].EUR_CRM_Target_Quantity_Listing__c);
            System.assertEquals(2, promoTargets[0].EUR_CRM_Target_Quantity_People__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(3, promoTargets[0].EUR_CRM_Target_Quantity_Promo_Kits__c);
            System.assertEquals(4, promoTargets[0].EUR_CRM_Target_Quantity_Spyders__c);

            List<EUR_CRM_OP_Target_Manager__c> targetManagers = selectTargetManagersWhereOP(op.Id);
            System.assertEquals(1, targetManagers.size());
            System.assertEquals(products[0].Id, targetManagers[0].EUR_CRM_OP_Product__c);
            System.assertEquals(promoTargets[0].Id, targetManagers[0].EUR_CRM_OP_Promo_Target__c);
            System.assertNotEquals(null, targetManagers[0].EUR_CRM_Target_Owner__c);
            System.assertEquals(1, targetManagers[0].EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(2, targetManagers[0].EUR_CRM_Target_Quantity_People__c);
//        System.assertEquals(3, targetManagers[0].EUR_CRM_Target_Quantity_Promo_Kits__c);
//        System.assertEquals(4, targetManagers[0].EUR_CRM_Target_Quantity_Spyders__c);

            List<EUR_CRM_OP_Target_REP__c> targetReps = selectTargetRepsWhereOP(op.Id);
            System.assertEquals(1, targetReps.size());
            System.assertEquals(products[0].Id, targetReps[0].EUR_CRM_OP_Product__c);
            System.assertEquals(targetManagers[0].Id, targetReps[0].EUR_CRM_OP_Target_Manager__c);
            System.assertNotEquals(null, targetReps[0].EUR_CRM_Target_Owner__c);
            System.assertEquals(1, targetReps[0].EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(2, targetReps[0].EUR_CRM_Target_Quantity_People__c);
//        System.assertEquals(3, targetReps[0].EUR_CRM_Target_Quantity_Promo_Kits__c);
//        System.assertEquals(4, targetReps[0].EUR_CRM_Target_Quantity_Spyders__c);
        }
    }

    @IsTest
    private static void createTargetsMassCreationTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            List<EUR_CRM_Brand__c> brands = makeBrands(new List<String> {
                'ABSOLUT', 'BEEFEATER', 'BUSNEL'
            });
            insert brands;

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> wrappers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper>();
            Map<Id, EUR_CRM_Account__c> accountById = selectAccountById();
            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> pWs =
                EUR_CRM_ObjPromoTargetMngmntCtrl.getProductsWithManagersAndSalesReps(JSON.serialize(wrappers), JSON.serialize(new Map<Id, EUR_CRM_Brand__c>(brands).keySet()), op.Id, JSON.serialize(accountById.keySet()));

            for (EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper pw : pWs) {
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';

                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper mw : pw.managers) {
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';

                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper sw : mw.salesReps) {
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';
                    }
                }
            }

            Test.startTest();
            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(pWs), op.Id);
            Test.stopTest();

            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> products = selectProductsWhereOP(op.Id);
            System.assertEquals(3, products.size());

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = selectPromoTargetsWhereOP(op.Id);
            System.debug('\n promoTargets.size() => ' + promoTargets.size() + '\n');
            System.debug('\n promoTargets => ' + JSON.serializePretty(promoTargets) + '\n');
            System.assertEquals(3, promoTargets.size());
            for (EUR_CRM_OP_Promo_Target__c promoTarget : promoTargets) {
                System.assertEquals(1, promoTarget.EUR_CRM_Target_Quantity_Listing__c);
                System.assertEquals(2, promoTarget.EUR_CRM_Target_Quantity_People__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//            System.assertEquals(3, promoTarget.EUR_CRM_Target_Quantity_Promo_Kits__c);
                System.assertEquals(4, promoTarget.EUR_CRM_Target_Quantity_Spyders__c);
            }

            List<EUR_CRM_OP_Target_Manager__c> targetManagers = selectTargetManagersWhereOP(op.Id);
            System.debug('\n targetManagers.size() => ' + targetManagers.size() + '\n');
            System.debug('\n targetManagers => ' + JSON.serializePretty(targetManagers) + '\n');
            for (EUR_CRM_OP_Target_Manager__c targetManager : targetManagers) {
                System.assertNotEquals(null, targetManager.EUR_CRM_Target_Owner__c);
                System.assertEquals(1, targetManager.EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//            System.assertEquals(2, targetManager.EUR_CRM_Target_Quantity_People__c);
//            System.assertEquals(3, targetManager.EUR_CRM_Target_Quantity_Promo_Kits__c);
//            System.assertEquals(4, targetManager.EUR_CRM_Target_Quantity_Spyders__c);
            }

            List<EUR_CRM_OP_Target_REP__c> targetReps = selectTargetRepsWhereOP(op.Id);
			System.debug('\n targetReps.size() => ' + targetReps.size() + '\n');
			System.debug('\n targetReps => ' + JSON.serializePretty(targetReps) + '\n');
            for (EUR_CRM_OP_Target_REP__c targetRep : targetReps) {
                System.assertNotEquals(null, targetRep.EUR_CRM_Target_Owner__c);
                System.assertEquals(1, targetRep.EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//            System.assertEquals(2, targetRep.EUR_CRM_Target_Quantity_People__c);
//            System.assertEquals(3, targetRep.EUR_CRM_Target_Quantity_Promo_Kits__c);
//            System.assertEquals(4, targetRep.EUR_CRM_Target_Quantity_Spyders__c);
            }
        }
    }

    @IsTest
    private static void createTargetsSingleUpdateTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
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

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> pWs = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);

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

            pWs[0].managers = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper> {
                pWs[0].managers[0]
            };
            pWs[0].managers[0].salesReps = new List<EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper> {
                pWs[0].managers[0].salesReps[0]
            };

            Test.startTest();
            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(pWs), op.Id);
            Test.stopTest();

            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> products = selectProductsWhereOP(op.Id);
            System.assertEquals(1, products.size());

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(1, promoTargets.size());
            System.assertEquals(products[0].Id, promoTargets[0].EUR_CRM_OP_Product__c);
            System.assertEquals(1, promoTargets[0].EUR_CRM_Target_Quantity_Listing__c);
            System.assertEquals(2, promoTargets[0].EUR_CRM_Target_Quantity_People__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(3, promoTargets[0].EUR_CRM_Target_Quantity_Promo_Kits__c);
            System.assertEquals(4, promoTargets[0].EUR_CRM_Target_Quantity_Spyders__c);

            List<EUR_CRM_OP_Target_Manager__c> targetManagers = selectTargetManagersWhereOP(op.Id);
            System.assertEquals(1, targetManagers.size());
            System.assertEquals(products[0].Id, targetManagers[0].EUR_CRM_OP_Product__c);
            System.assertEquals(promoTargets[0].Id, targetManagers[0].EUR_CRM_OP_Promo_Target__c);
            System.assertNotEquals(null, targetManagers[0].EUR_CRM_Target_Owner__c);
            System.assertEquals(1, targetManagers[0].EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(2, targetManagers[0].EUR_CRM_Target_Quantity_People__c);
//        System.assertEquals(3, targetManagers[0].EUR_CRM_Target_Quantity_Promo_Kits__c);
//        System.assertEquals(4, targetManagers[0].EUR_CRM_Target_Quantity_Spyders__c);

            List<EUR_CRM_OP_Target_REP__c> targetReps = selectTargetRepsWhereOP(op.Id);
            System.assertEquals(1, targetReps.size());
            System.assertEquals(products[0].Id, targetReps[0].EUR_CRM_OP_Product__c);
            System.assertEquals(targetManagers[0].Id, targetReps[0].EUR_CRM_OP_Target_Manager__c);
            System.assertNotEquals(null, targetReps[0].EUR_CRM_Target_Owner__c);
            System.assertEquals(1, targetReps[0].EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
//        System.assertEquals(2, targetReps[0].EUR_CRM_Target_Quantity_People__c);
//        System.assertEquals(3, targetReps[0].EUR_CRM_Target_Quantity_Promo_Kits__c);
//        System.assertEquals(4, targetReps[0].EUR_CRM_Target_Quantity_Spyders__c);
        }
    }

    @IsTest
    private static void createTargetsMassUpdateTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            List<EUR_CRM_Brand__c> brands = makeBrands(new List<String> {
                'ABSOLUT', 'BEEFEATER', 'BUSNEL'
            });
            insert brands;
            List<EUR_CRM_OP_Product__c> products = new List<EUR_CRM_OP_Product__c>();
            for (EUR_CRM_Brand__c brand : brands) {
                products.add(makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id));
            }
            insert products;
            List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(products).keySet()));
            insert promoTargets;
            List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(products).keySet()), new List<Id>(new Map<Id, EUR_CRM_OP_Promo_Target__c>(promoTargets).keySet()));
            insert targetManagers;
            List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, targetManagers);
            insert targetReps;

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> pWs = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);

            for (EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper pw : pWs) {
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : pw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';

                for (EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper mw : pw.managers) {
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : mw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';

                    for (EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper sw : mw.salesReps) {
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Listing__c') w.data = '1';
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_People__c') w.data = '2';
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Promo_Kits__c') w.data = '3';
                        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ColumnWrapper w : sw.columnWrappers) if (w.fieldName == 'EUR_CRM_Target_Quantity_Spyders__c') w.data = '4';
                    }
                }
            }

            Test.startTest();
            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(pWs), op.Id);
            Test.stopTest();

            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            products = selectProductsWhereOP(op.Id);
            System.assertEquals(3, products.size());

            promoTargets = selectPromoTargetsWhereOP(op.Id);
            System.debug('\n promoTargets.size() => ' + promoTargets.size() + '\n');
            System.debug('\n promoTargets => ' + JSON.serializePretty(promoTargets) + '\n');
            System.assertEquals(3, promoTargets.size());
            for (EUR_CRM_OP_Promo_Target__c promoTarget : promoTargets) {
                System.assertEquals(9, promoTarget.EUR_CRM_Target_Quantity_Listing__c);
                System.assertEquals(18, promoTarget.EUR_CRM_Target_Quantity_People__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
                System.assertEquals(27, promoTarget.EUR_CRM_Target_Quantity_Promo_Kits__c);
                System.assertEquals(36, promoTarget.EUR_CRM_Target_Quantity_Spyders__c);
            }

            targetManagers = selectTargetManagersWhereOP(op.Id);
            System.assert(! targetManagers.isEmpty());
            for (EUR_CRM_OP_Target_Manager__c targetManager : targetManagers) {
                System.assertNotEquals(null, targetManager.EUR_CRM_Target_Owner__c);
            System.assertEquals(3, targetManager.EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
            System.assertEquals(6, targetManager.EUR_CRM_Target_Quantity_People__c);
            System.assertEquals(9, targetManager.EUR_CRM_Target_Quantity_Promo_Kits__c);
            System.assertEquals(12, targetManager.EUR_CRM_Target_Quantity_Spyders__c);
            }

            targetReps = selectTargetRepsWhereOP(op.Id);
            System.assert(! targetReps.isEmpty());
            for (EUR_CRM_OP_Target_REP__c targetRep : targetReps) {
                System.assertNotEquals(null, targetRep.EUR_CRM_Target_Owner__c);
            System.assertEquals(1, targetRep.EUR_CRM_Target_Quantity_Listing__c);
//TODO: have to be corrected with runAs specific User because of hidden fields visibility for System Administrator profile
            System.assertEquals(2, targetRep.EUR_CRM_Target_Quantity_People__c);
            System.assertEquals(3, targetRep.EUR_CRM_Target_Quantity_Promo_Kits__c);
            System.assertEquals(4, targetRep.EUR_CRM_Target_Quantity_Spyders__c);
            }
        }
    }

    @IsTest
    private static void deletePromoTargetsOnceTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            EUR_CRM_Brand__c brand = makeBrand('Some brand');
            insert brand;
            EUR_CRM_Quality__c quality = makeBrandQuality('Some quality');
            insert quality;
            EUR_CRM_Size__c size = makeBrandQualitySize('Some size');
            insert size;

            List<EUR_CRM_OP_Product__c> opProducts = new List<EUR_CRM_OP_Product__c>();
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality__c', quality.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality_Size__c', size.Id));
            insert opProducts;

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()));
            insert promoTargets;
            List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()), new List<Id>(new Map<Id, EUR_CRM_OP_Promo_Target__c>(promoTargets).keySet()));
            insert targetManagers;
            List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, targetManagers);
            insert targetReps;

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            productWrappers = populateProductWrappers(productWrappers);

            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(productWrappers), op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsInitial = selectProductsWhereOP(op.Id);
            List<EUR_CRM_OP_Promo_Target__c> promoTargetsInitial = selectPromoTargetsWhereOP(op.Id);
            List<EUR_CRM_OP_Target_Manager__c> targetManagersInitial = selectTargetManagersWhereOP(op.Id);
            List<EUR_CRM_OP_Target_REP__c> targetRepsInitial = selectTargetRepsWhereOP(op.Id);

            System.assertEquals(3, opProductsInitial.size());

            resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.deletePromoTargets(productWrappers[0].promoTarget.Id, op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsAfterDeletion = selectProductsWhereOP(op.Id);
            System.assertEquals(2, opProductsAfterDeletion.size());

            List<EUR_CRM_OP_Promo_Target__c> promoTargetsAfterDeletion = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(2, promoTargetsAfterDeletion.size());

            List<EUR_CRM_OP_Target_Manager__c> targetManagersAfterDeletion = selectTargetManagersWhereOP(op.Id);
            System.assert(targetManagersInitial.size() > targetManagersAfterDeletion.size());

            List<EUR_CRM_OP_Target_REP__c> targetRepsAfterDeletion = selectTargetRepsWhereOP(op.Id);
            System.assert(targetRepsInitial.size() > targetRepsAfterDeletion.size());
        }
    }

    @IsTest
    private static void deletePromoTargetsMultipleTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            EUR_CRM_Brand__c brand = makeBrand('Some brand');
            insert brand;
            EUR_CRM_Quality__c quality = makeBrandQuality('Some quality');
            insert quality;
            EUR_CRM_Size__c size = makeBrandQualitySize('Some size');
            insert size;

            List<EUR_CRM_OP_Product__c> opProducts = new List<EUR_CRM_OP_Product__c>();
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality__c', quality.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality_Size__c', size.Id));
            insert opProducts;

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()));
            insert promoTargets;
            List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()), new List<Id>(new Map<Id, EUR_CRM_OP_Promo_Target__c>(promoTargets).keySet()));
            insert targetManagers;
            List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, targetManagers);
            insert targetReps;

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            productWrappers = populateProductWrappers(productWrappers);

            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(productWrappers), op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsInitial = selectProductsWhereOP(op.Id);
            List<EUR_CRM_OP_Promo_Target__c> promoTargetsInitial = selectPromoTargetsWhereOP(op.Id);
            List<EUR_CRM_OP_Target_Manager__c> targetManagersInitial = selectTargetManagersWhereOP(op.Id);
            List<EUR_CRM_OP_Target_REP__c> targetRepsInitial = selectTargetRepsWhereOP(op.Id);

            System.assertEquals(3, opProductsInitial.size());


            resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.deletePromoTargets(productWrappers[0].promoTarget.Id, op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsAfterDeletion = selectProductsWhereOP(op.Id);
            System.assertEquals(2, opProductsAfterDeletion.size());

            List<EUR_CRM_OP_Promo_Target__c> promoTargetsAfterDeletion = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(2, promoTargetsAfterDeletion.size());

            List<EUR_CRM_OP_Target_Manager__c> targetManagersAfterDeletion = selectTargetManagersWhereOP(op.Id);
            System.assert(targetManagersInitial.size() > targetManagersAfterDeletion.size());

            List<EUR_CRM_OP_Target_REP__c> targetRepsAfterDeletion = selectTargetRepsWhereOP(op.Id);
            System.assert(targetRepsInitial.size() > targetRepsAfterDeletion.size());
            opProductsInitial = opProductsAfterDeletion;
            promoTargetsInitial = promoTargetsAfterDeletion;
            targetManagersInitial = targetManagersAfterDeletion;
            targetRepsInitial = targetRepsAfterDeletion;


            resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.deletePromoTargets(productWrappers[1].promoTarget.Id, op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            opProductsAfterDeletion = selectProductsWhereOP(op.Id);
            System.assertEquals(1, opProductsAfterDeletion.size());

            promoTargetsAfterDeletion = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(1, promoTargetsAfterDeletion.size());

            targetManagersAfterDeletion = selectTargetManagersWhereOP(op.Id);
            System.assert(targetManagersInitial.size() > targetManagersAfterDeletion.size());

            targetRepsAfterDeletion = selectTargetRepsWhereOP(op.Id);
            System.assert(targetRepsInitial.size() > targetRepsAfterDeletion.size());

            resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.deletePromoTargets(productWrappers[2].promoTarget.Id, op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            opProductsAfterDeletion = selectProductsWhereOP(op.Id);
            System.assertEquals(0, opProductsAfterDeletion.size());

            promoTargetsAfterDeletion = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(0, promoTargetsAfterDeletion.size());

            targetManagersAfterDeletion = selectTargetManagersWhereOP(op.Id);
            System.assertEquals(0, targetManagersAfterDeletion.size());

            targetRepsAfterDeletion = selectTargetRepsWhereOP(op.Id);
            System.assertEquals(0, targetRepsAfterDeletion.size());
        }
    }

    @IsTest
    private static void deleteTargetManagersTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            EUR_CRM_Brand__c brand = makeBrand('Some brand');
            insert brand;
            EUR_CRM_Quality__c quality = makeBrandQuality('Some quality');
            insert quality;
            EUR_CRM_Size__c size = makeBrandQualitySize('Some size');
            insert size;

            List<EUR_CRM_OP_Product__c> opProducts = new List<EUR_CRM_OP_Product__c>();
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality__c', quality.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality_Size__c', size.Id));
            insert opProducts;

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()));
            insert promoTargets;
            List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()), new List<Id>(new Map<Id, EUR_CRM_OP_Promo_Target__c>(promoTargets).keySet()));
            insert targetManagers;
            List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, targetManagers);
            insert targetReps;

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            productWrappers = populateProductWrappers(productWrappers);

            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(productWrappers), op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsInitial = selectProductsWhereOP(op.Id);
            List<EUR_CRM_OP_Promo_Target__c> promoTargetsInitial = selectPromoTargetsWhereOP(op.Id);
            List<EUR_CRM_OP_Target_Manager__c> targetManagersInitial = selectTargetManagersWhereOP(op.Id);
            List<EUR_CRM_OP_Target_REP__c> targetRepsInitial = selectTargetRepsWhereOP(op.Id);

            System.assertEquals(3, opProductsInitial.size());

            resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.deleteTargetManagers(productWrappers[0].managers[0].targetManager.Id, op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsAfterDeletion = selectProductsWhereOP(op.Id);
            System.assertEquals(3, opProductsAfterDeletion.size());

            List<EUR_CRM_OP_Promo_Target__c> promoTargetsAfterDeletion = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(3, promoTargetsAfterDeletion.size());

            List<EUR_CRM_OP_Target_Manager__c> targetManagersAfterDeletion = selectTargetManagersWhereOP(op.Id);
            System.assertEquals(targetManagersInitial.size() - 1, targetManagersAfterDeletion.size());

            List<EUR_CRM_OP_Target_REP__c> targetRepsAfterDeletion = selectTargetRepsWhereOP(op.Id);
            System.assert(targetRepsInitial.size() > targetRepsAfterDeletion.size());
        }
    }

    @IsTest
    private static void deleteTargetRepsTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

            EUR_CRM_Brand__c brand = makeBrand('Some brand');
            insert brand;
            EUR_CRM_Quality__c quality = makeBrandQuality('Some quality');
            insert quality;
            EUR_CRM_Size__c size = makeBrandQualitySize('Some size');
            insert size;

            List<EUR_CRM_OP_Product__c> opProducts = new List<EUR_CRM_OP_Product__c>();
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality__c', quality.Id));
            opProducts.add(makeProduct(op.Id, 'EUR_CRM_Brand_Quality_Size__c', size.Id));
            insert opProducts;

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = makePromoTargets(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()));
            insert promoTargets;
            List<EUR_CRM_OP_Target_Manager__c> targetManagers = makeTargetManagers(op.Id, new List<Id>(new Map<Id, EUR_CRM_OP_Product__c>(opProducts).keySet()), new List<Id>(new Map<Id, EUR_CRM_OP_Promo_Target__c>(promoTargets).keySet()));
            insert targetManagers;
            List<EUR_CRM_OP_Target_REP__c> targetReps = makeTargetReps(op.Id, targetManagers);
            insert targetReps;

            List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers = EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(op.Id);
            productWrappers = populateProductWrappers(productWrappers);

            String resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(productWrappers), op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsInitial = selectProductsWhereOP(op.Id);
            List<EUR_CRM_OP_Promo_Target__c> promoTargetsInitial = selectPromoTargetsWhereOP(op.Id);
            List<EUR_CRM_OP_Target_Manager__c> targetManagersInitial = selectTargetManagersWhereOP(op.Id);
            List<EUR_CRM_OP_Target_REP__c> targetRepsInitial = selectTargetRepsWhereOP(op.Id);

            System.assertEquals(3, opProductsInitial.size());

            resultStatus = EUR_CRM_ObjPromoTargetMngmntCtrl.deleteTargetReps(productWrappers[0].managers[0].salesReps[0].targetSalesRep.Id, op.Id);
            System.assertEquals(EUR_CRM_ObjPromoTargetMngmntCtrl.SUCCESS_RESULT, resultStatus);

            List<EUR_CRM_OP_Product__c> opProductsAfterDeletion = selectProductsWhereOP(op.Id);
            System.assertEquals(3, opProductsAfterDeletion.size());

            List<EUR_CRM_OP_Promo_Target__c> promoTargetsAfterDeletion = selectPromoTargetsWhereOP(op.Id);
            System.assertEquals(3, promoTargetsAfterDeletion.size());

            List<EUR_CRM_OP_Target_Manager__c> targetManagersAfterDeletion = selectTargetManagersWhereOP(op.Id);
            System.assertEquals(targetManagersInitial.size(), targetManagersAfterDeletion.size());

            List<EUR_CRM_OP_Target_REP__c> targetRepsAfterDeletion = selectTargetRepsWhereOP(op.Id);
            System.assertEquals(targetRepsInitial.size() - 1, targetRepsAfterDeletion.size());
        }
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> populateProductWrappers(List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> productWrappers) {
        for (EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper pw : productWrappers) {
            for (Integer i = 0; i < 4; i++) {
                pw.columnWrappers[i].data = String.valueOf(i + 1);
            }

            for (EUR_CRM_ObjPromoTargetMngmntCtrl.ManagerWrapper mw : pw.managers) {
                for (Integer j = 0; j < 4; j++) {
                    mw.columnWrappers[j].data = String.valueOf(j + 1);
                }

                for (EUR_CRM_ObjPromoTargetMngmntCtrl.SalesRepWrapper sw : mw.salesReps) {
                    for (Integer k = 0; k < 4; k++) {
                        sw.columnWrappers[k].data = String.valueOf(k + 1);
                    }
                }
            }
        }
        return productWrappers;
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
            FROM EUR_CRM_Objectives_Promotions__c
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectProductsWhereOP(Id opId) {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
        ];
    }

    private static List<EUR_CRM_OP_Promo_Target__c> selectPromoTargetsWhereOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Product__c
            ,   EUR_CRM_Target_Quantity_Listing__c
            ,   EUR_CRM_Target_Quantity_People__c
            ,   EUR_CRM_Target_Quantity_Promo_Kits__c
            ,   EUR_CRM_Target_Quantity_Spyders__c
            FROM EUR_CRM_OP_Promo_Target__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
        ];
    }

    private static List<EUR_CRM_OP_Target_Manager__c> selectTargetManagersWhereOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Product__c
            ,   EUR_CRM_OP_Promo_Target__c
            ,   EUR_CRM_Target_Owner__c
            ,   EUR_CRM_Target_Quantity_Listing__c
            ,   EUR_CRM_Target_Quantity_People__c
            ,   EUR_CRM_Target_Quantity_Promo_Kits__c
            ,   EUR_CRM_Target_Quantity_Spyders__c
            FROM EUR_CRM_OP_Target_Manager__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
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

    private static List<User> getEMEAandEURsystemAdminUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'EUR System Admin'
                AND UserRole.Name = 'EMEA'
            LIMIT 1
        ];
    }

}