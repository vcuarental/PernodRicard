@IsTest(IsParallel = true)
private class EUR_CRM_SE_ObjPromoManageControllerTest {

    @IsTest
    static void test() {
        EUR_CRM_Account__c acc = makeAccount();
        insert acc;
        EUR_CRM_OP_Action_List_Template__c actionListTemp = makeTemplate();
        insert actionListTemp;
        EUR_CRM_ObjPromo__c objAndProm = makeObjPromo('EUR_SE_Events');
        insert objAndProm;
        EUR_CRM_ObjPromo_Target__c testTarget = makeObjPromoTarget(objAndProm);
        insert testTarget;

        PageReference publishObjectivePage = Page.EUR_CRM_SE_ObjPromoManagePage;
        publishObjectivePage.getParameters().put('ObjPromoId', objAndProm.Id);
        Test.setCurrentPage(publishObjectivePage);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objAndProm);
        EUR_CRM_SE_ObjPromoManageController controller = new EUR_CRM_SE_ObjPromoManageController(stdCtrl);

        Object testObj = controller.getIsEditable();
        testObj = controller.getIsListViewOptionRendered();
        testObj = controller.getIsCTaxOptionRendered();
        testObj = controller.getIsPRSOptionRendered();
        testObj = controller.getIsAccountListView();
        testObj = controller.getIsCustomerTaxonomy();
        testObj = controller.getIsPRS();
        testObj = controller.getIsBrandRendered();
        testObj = controller.getIsBrandSizeRendered();
        testObj = controller.getIsBrandQualityRendered();
        testObj = controller.getIsSKURendered();
        testObj = controller.getPromoKitUnits();
        testObj = controller.getTargetQtyField();
        testObj = controller.getTargetProductField();
        testObj = controller.getRegionalAndSalesAgencyTargetWraps();
        testObj = controller.getIsProductionSelectionRendered();
        testObj = controller.getIsMGTargetManagementRendered();
        testObj = controller.getIsSRTargetManagementRendered();
        testObj = controller.getIsOPTargetManagementRendered();
        testObj = controller.getIsTargetManagementRendered();
        testObj = controller.getProductSelectionTabVisibility();
        testObj = controller.getTargetManagementTabVisibility();
        testObj = controller.getTargetMGTabVisibility();
        testObj = controller.getTargetOPTabVisibility();
        testObj = controller.getIsProductSelectionSelected();
        testObj = controller.getTargetsInSelectedProductLevel();
        testObj = controller.getTargetSRTabVisibility();
        testObj = controller.getRegionalManagerOptions();
//        testObj = controller.createAccOP();


        List<EUR_CRM_OPTargetHelperClass.TargetWrap> salesRepTargetWrap = controller.salesRepTargetWrap;
        controller.resetSalesRepTargetWrap();

        controller.isAccountSelectionDone = true;
        controller.isDraft = true;

        controller.setPublishStatus();


        controller.firstPage();
        controller.saveProducts();
        controller.quickSaveObjectiveTargets();
        controller.saveObjectiveTargets();
        controller.saveRegionalTargets();
        controller.quickSaveSRTargets();
        controller.saveSRTargets();
        System.assertEquals(true, controller.isAccountSelectionDone);
    }

    @IsTest
    static void testAddMethod() {
        EUR_CRM_Account__c acc = makeAccount();
        insert acc;
        EUR_CRM_OP_Action_List_Template__c actionListTemp = makeTemplate();
        insert actionListTemp;
        EUR_CRM_ObjPromo__c objAndProm = makeObjPromo('EUR_SE_Volume_Campaign');
        insert objAndProm;
        EUR_CRM_ObjPromo_Target__c testTarget = makeObjPromoTarget(objAndProm);
        insert testTarget;

        PageReference publishObjectivePage = Page.EUR_CRM_SE_ObjPromoManagePage;
        publishObjectivePage.getParameters().put('ObjPromoId', objAndProm.Id);
        Test.setCurrentPage(publishObjectivePage);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objAndProm);
        EUR_CRM_SE_ObjPromoManageController controller = new EUR_CRM_SE_ObjPromoManageController(stdCtrl);

        EUR_CRM_Size__c bqs = new EUR_CRM_Size__c();
        insert bqs;
        publishObjectivePage.getParameters().put('p1', bqs.Id);
        controller.selectedProductSelection = 'size';
        controller.add();
        publishObjectivePage.getParameters().put('rowIndex', '1');
        controller.removeProduct();

        EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c();
        insert sku;
        publishObjectivePage.getParameters().put('p1', sku.Id);
        controller.selectedProductSelection = 'sku';
        controller.add();
        controller.removeProduct();

        EUR_CRM_Quality__c quality = new EUR_CRM_Quality__c();
        insert quality;
        publishObjectivePage.getParameters().put('p1', quality.Id);
        controller.selectedProductSelection = 'quality';
        controller.add();
        controller.removeProduct();

        EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c();
        insert brand;
        publishObjectivePage.getParameters().put('p1', brand.Id);
        controller.selectedProductSelection = 'brand';
        controller.add();
        controller.removeProduct();
        System.assertNotEquals(null, controller.selectedProductSelection);
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_OP_Action_List_Template__c makeTemplate() {
        return new EUR_CRM_OP_Action_List_Template__c(
            name = 'Promo Action List Template 1'
        ,   EUR_CRM_External_ID__c = 'BE_On_Trade_Promo_Kit_Activation'
        );
    }

    private static EUR_CRM_ObjPromo__c makeObjPromo(String recTypeDevName){
        RecordType rt = [SELECT Id From RecordType WHERE DeveloperName = :recTypeDevName];
        return new EUR_CRM_ObjPromo__c(
            Name = 'test ObjPromo'
        ,   RecordTypeId = rt.Id
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addDays(-1)
        ,   EUR_CRM_Active_End_Date__c = Date.Today().addDays(360)
        ,   EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(20)
        ,   EUR_CRM_Status__c = 'Active'
        );
    }

    private static EUR_CRM_ObjPromo_Target__c makeObjPromoTarget(EUR_CRM_ObjPromo__c objPromo) {
        RecordType rt = [SELECT Id From RecordType WHERE DeveloperName = 'EUR_SE_Objective_People_Target'];
        return new EUR_CRM_ObjPromo_Target__c(
            RecordTypeId = rt.Id
        ,   EUR_CRM_ObjPromo__c = objPromo.Id
        ,   EUR_CRM_Target_Owner__c = UserInfo.getUserId()
        ,   EUR_CRM_Product_Level__c = 'EUR_CRM_SKU__c'
        );
    }

    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'test'
        ,   EUR_CRM_Status__c = 'Active'
        ,   EUR_CRM_Postal_Code__c = '00000'
        );
    }
}