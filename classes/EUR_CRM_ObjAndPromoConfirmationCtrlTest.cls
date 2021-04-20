@IsTest (IsParallel = true)
private class EUR_CRM_ObjAndPromoConfirmationCtrlTest {
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


    @IsTest
    private static void getOPTemplateWithOPActionsTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        Test.startTest();
        EUR_CRM_OP_Template__c template = EUR_CRM_ObjAndPromoConfirmationCtrl.getOPTemplateWithOPActions(op.Id);
        Test.stopTest();

        List<EUR_CRM_OP_Template__c> opTemplates = selectOPTemplates();
        System.assertEquals(opTemplates[0].Id, template.Id);
    }

    @IsTest
    private static void getAccountTargetGroupWithRelatedAccountsTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        Test.startTest();
        EUR_CRM_ObjPromoToAccAssignAuraCtrl.AccountTargetGroupWrapper accountTargetGroupWrapper = EUR_CRM_ObjAndPromoConfirmationCtrl.getAccountTargetGroupWithRelatedAccounts(op.Id);
        Test.stopTest();

        List<EUR_CRM_Account_Target_Group__c> accountTargetGroups = selectAccountTargetGroups();
        System.assertEquals(accountTargetGroups[0].Id, accountTargetGroupWrapper.accountGroup.Id);
    }

    @IsTest static void deleteProductWithBrandTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Brand__c brand = makeBrand('test');
        insert brand;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c target = makePromoTarget(op.Id, product.Id, 0, 0);
        insert target;
        System.assertEquals(1, selectProducts().size());

        Test.startTest();
        EUR_CRM_ObjAndPromoConfirmationCtrl.deleteProductWithRelated(brand.Id, op.id);
        Test.stopTest();

        System.assertEquals(0, selectProducts().size());
    }

    @IsTest static void deleteProductWithBrandQualityTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Quality__c bq = makeBrandQuality('test');
        insert bq;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand_Quality__c', bq.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c target = makePromoTarget(op.Id, product.Id, 0, 0);
        insert target;
        System.assertEquals(1, selectProducts().size());

        Test.startTest();
        EUR_CRM_ObjAndPromoConfirmationCtrl.deleteProductWithRelated(bq.Id, op.id);
        Test.stopTest();

        System.assertEquals(0, selectProducts().size());
    }

    @IsTest static void deleteProductWithBrandQualitySizeTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Size__c bqs = makeBrandQualitySize('test');
        insert bqs;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand_Quality_Size__c', bqs.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c target = makePromoTarget(op.Id, product.Id, 0, 0);
        insert target;
        System.assertEquals(1, selectProducts().size());

        Test.startTest();
        EUR_CRM_ObjAndPromoConfirmationCtrl.deleteProductWithRelated(bqs.Id, op.id);
        Test.stopTest();

        System.assertEquals(0, selectProducts().size());
    }

    @IsTest static void deleteProductWithSKUTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_SKU__c sku = makeSKU('test');
        insert sku;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_SKU_EU__c', sku.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c target = makePromoTarget(op.Id, product.Id, 0, 0);
        insert target;
        System.assertEquals(1, selectProducts().size());

        Test.startTest();
        EUR_CRM_ObjAndPromoConfirmationCtrl.deleteProductWithRelated(sku.Id, op.id);
        Test.stopTest();

        System.assertEquals(0, selectProducts().size());
    }

    @IsTest static void deleteProductWithPOSMaterialTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_POS_Material__c posm = makePOSMaterial('test');
        insert posm;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_POS_Material__c', posm.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c target = makePromoTarget(op.Id, product.Id, 0, 0);
        insert target;
        System.assertEquals(1, selectProducts().size());

        Test.startTest();
        EUR_CRM_ObjAndPromoConfirmationCtrl.deleteProductWithRelated(posm.Id, op.id);
        Test.stopTest();

        System.assertEquals(0, selectProducts().size());
    }

    @IsTest static void deleteProductWithProductToolkitTest() {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotions()[0];

        EUR_CRM_Product_Toolkit__c pt = makeProductToolkit('test');
        insert pt;
        EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Product_Toolkit__c', pt.Id);
        insert product;
        EUR_CRM_OP_Promo_Target__c target = makePromoTarget(op.Id, product.Id, 0, 0);
        insert target;
        System.assertEquals(1, selectProducts().size());

        Test.startTest();
        EUR_CRM_ObjAndPromoConfirmationCtrl.deleteProductWithRelated(pt.Id, op.id);
        Test.stopTest();

        System.assertEquals(0, selectProducts().size());
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
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

    private static EUR_CRM_OP_Promo_Target__c makePromoTarget(Id opId, Id productId, Integer targetBottles, Integer targetDisplays) {
        return new EUR_CRM_OP_Promo_Target__c(
            EUR_CRM_Objectives_Promotions__c = opId
            ,   EUR_CRM_OP_Product__c = productId
            ,   EUR_CRM_Target_Sell_in_Amount_Bottle__c = targetBottles
            ,   EUR_CRM_Target_Sell_in_Amount_Display__c = targetDisplays
        );
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
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

    private static List<EUR_CRM_Account_Target_Group__c> selectAccountTargetGroups() {
        return [
            SELECT Id
            FROM EUR_CRM_Account_Target_Group__c
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectProducts() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Product__c
        ];
    }

}