@IsTest (isParallel = true)
private class EUR_CRM_ObjPromoToProdAssignAuraCtrlTest {


    @IsTest
    private static void getSelectedProductTypeTest() {
        EUR_CRM_OP_Template__c opTemplate = makeOPTemplate('Brand');
        insert opTemplate;
        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(opTemplate.Id);
        insert op;

        Test.startTest();
        String productType = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getSelectedProductType(op.Id);
        Test.stopTest();

        System.assertEquals('Brand', productType);
    }

    @IsTest
    private static void getProductsOfBrandTest() {
        EUR_CRM_Brand__c brand = makeBrand('Brand Test');
        insert brand;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfBrand(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(brand.Name, products[0].label);
        System.assertEquals(brand.Id, products[0].value);
        System.assertEquals(false, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfBrandSelectedTest() {
        EUR_CRM_Brand__c brand = makeBrand('Brand Test');
        insert brand;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        EUR_CRM_OP_Product__c opProduct = makeOPProduct(op.Id);
        opProduct.EUR_CRM_Brand__c = brand.Id;
        insert opProduct;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfBrand(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(brand.Name, products[0].label);
        System.assertEquals(brand.Id, products[0].value);
        System.assertEquals(true, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfBrandQualityTest() {
        EUR_CRM_Quality__c quality = makeBrandQuality('Brand Quality Test');
        insert quality;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfBrandQuality(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(quality.Name, products[0].label);
        System.assertEquals(quality.Id, products[0].value);
        System.assertEquals(false, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfBrandQualitySelectedTest() {
        EUR_CRM_Quality__c quality = makeBrandQuality('Brand Quality Test');
        insert quality;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        EUR_CRM_OP_Product__c opProduct = makeOPProduct(op.Id);
        opProduct.EUR_CRM_Brand_Quality__c = quality.Id;
        insert opProduct;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfBrandQuality(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(quality.Name, products[0].label);
        System.assertEquals(quality.Id, products[0].value);
        System.assertEquals(true, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfBrandQualitySizeTest() {
        EUR_CRM_Size__c size = makeBrandQualitySize('Brand Quality Size Test');
        insert size;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfBrandQualitySize(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(size.Name, products[0].label);
        System.assertEquals(size.Id, products[0].value);
        System.assertEquals(false, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfBrandQualitySizeSelectedTest() {
        EUR_CRM_Size__c size = makeBrandQualitySize('Brand Quality Size Test');
        insert size;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        EUR_CRM_OP_Product__c opProduct = makeOPProduct(op.Id);
        opProduct.EUR_CRM_Brand_Quality_Size__c = size.Id;
        insert opProduct;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfBrandQualitySize(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(size.Name, products[0].label);
        System.assertEquals(size.Id, products[0].value);
        System.assertEquals(true, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfSKUTest() {
        EUR_CRM_SKU__c sku = makeSKU('Brand Test');
        insert sku;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfSKU(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(sku.Id, products[0].value);
        System.assertEquals(false, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfSKUSelectedTest() {
        EUR_CRM_SKU__c sku = makeSKU('Brand Test');
        insert sku;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        EUR_CRM_OP_Product__c opProduct = makeOPProduct(op.Id);
        opProduct.EUR_CRM_SKU_EU__c = sku.Id;
        insert opProduct;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfSKU(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(sku.Id, products[0].value);
        System.assertEquals(true, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfPOSMaterialsTest() {
        EUR_CRM_POS_Material__c posMaterial = makePOSMaterial('POS Material Test');
        insert posMaterial;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfPOSMaterials(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(posMaterial.Name, products[0].label);
        System.assertEquals(posMaterial.Id, products[0].value);
        System.assertEquals(false, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfPOSMaterialsSelectedTest() {
        EUR_CRM_POS_Material__c posMaterial = makePOSMaterial('POS Material Test');
        insert posMaterial;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        EUR_CRM_OP_Product__c opProduct = makeOPProduct(op.Id);
        opProduct.EUR_CRM_POS_Material__c = posMaterial.Id;
        insert opProduct;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfPOSMaterials(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(posMaterial.Name, products[0].label);
        System.assertEquals(posMaterial.Id, products[0].value);
        System.assertEquals(true, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfProductToolkitTest() {
        EUR_CRM_Product_Toolkit__c productToolkit = makeProductToolkit('Product Toolkit Test');
        insert productToolkit;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfProductToolkit(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(productToolkit.Name, products[0].label);
        System.assertEquals(productToolkit.Id, products[0].value);
        System.assertEquals(false, products[0].isSelected);
    }

    @IsTest
    private static void getProductsOfProductToolkitSelectedTest() {
        EUR_CRM_Product_Toolkit__c productToolkit = makeProductToolkit('Product Toolkit Test');
        insert productToolkit;

        EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(null);
        insert op;

        EUR_CRM_OP_Product__c opProduct = makeOPProduct(op.Id);
        opProduct.EUR_CRM_Product_Toolkit__c = productToolkit.Id;
        insert opProduct;

        Test.startTest();
        List<EUR_CRM_ObjPromoToProdAssignAuraCtrl.SelectOptionWrapper> products = EUR_CRM_ObjPromoToProdAssignAuraCtrl.getProductsOfProductToolkit(op.Id);
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals(productToolkit.Name, products[0].label);
        System.assertEquals(productToolkit.Id, products[0].value);
        System.assertEquals(true, products[0].isSelected);
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Brand__c makeBrand(String name) {
        return new EUR_CRM_Brand__c(
            Name = name,
            EUR_CRM_Active__c = true
        );
    }

    private static EUR_CRM_Quality__c makeBrandQuality(String name) {
        return new EUR_CRM_Quality__c(
            Name = name,
            EUR_CRM_Active__c = true
        );
    }

    private static EUR_CRM_Size__c makeBrandQualitySize(String name) {
        return new EUR_CRM_Size__c(
            Name = name,
            EUR_CRM_Active__c = true
        );
    }

    private static EUR_CRM_SKU__c makeSKU(String name) {
        return new EUR_CRM_SKU__c(
                Name = name,
                EUR_CRM_Active__c = true,
                EUR_CRM_Article_no__c = '10006054'
        );
    }

    private static EUR_CRM_POS_Material__c makePOSMaterial(String name) {
        return new EUR_CRM_POS_Material__c(
            Name = name,
            EUR_CRM_Active__c = true
        );
    }

    private static EUR_CRM_Product_Toolkit__c makeProductToolkit(String name) {
        return new EUR_CRM_Product_Toolkit__c(
            Name = name,
            EUR_CRM_Is_Active__c = true
        );
    }

    private static EUR_CRM_OP_Template__c makeOPTemplate(String productLevel) {
        return new EUR_CRM_OP_Template__c(
            Name = 'OP Template Test'
        ,   EUR_CRM_Product_Level__c = productLevel
        );
    }

    private static EUR_CRM_Objectives_Promotions__c makeObjectivesPromotions(Id opTemplateId) {
        return new EUR_CRM_Objectives_Promotions__c(
            EUR_CRM_OP_Template__c = opTemplateId
        ,   Name = 'OP Test'
        );
    }

    private static EUR_CRM_OP_Product__c makeOPProduct(Id opId) {
        return new EUR_CRM_OP_Product__c(
            EUR_CRM_Objectives_Promotions__c = opId
        );
    }

}