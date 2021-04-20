/**
 * Created by V. Kamenskyi on 23.07.2018.
 */

@IsTest
private class EUR_CRM_Test_DealDetailsService {

    private static final String DEAL_NAME = 'TEST DEAL';
    private static final Integer PROD_IN_DEAL_NUMBER = 3;
    private static final Integer FREE_PROD_IN_DEAL_NUMBER = 2;
    private static final Integer POSM_IN_DEAL_NUMBER = 4;
    private static final Id DEAL_DISCOUNT_RT_ID;
    private static final Id DEAL_FREE_RT_ID;

    private static final EUR_CRM_RecordTypeHelper_v2 rtHelper;

    static {
        rtHelper = new EUR_CRM_RecordTypeHelper_v2();
        DEAL_DISCOUNT_RT_ID = rtHelper.getRTByDevName(EUR_CRM_Deal__c.SObjectType, 'EUR_Discount');
        DEAL_FREE_RT_ID = rtHelper.getRTByDevName(EUR_CRM_Deal__c.SObjectType, 'EUR_Free');
    }

    /*
    * TEST MODEL CONSTRUCTION
    */

    @IsTest
    private static void constructModelForNewDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        EUR_CRM_DealDetailsService.Data dataService = new EUR_CRM_DealDetailsService.Data();
        System.assertNotEquals(null, EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue());
        System.assertNotEquals(null, testUser.Country);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model model = dataService.constructModel(null);
            // TODO: check user country code population
            testUser = [SELECT Id,EUR_CRM_Country_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            System.assertEquals(null, model.deal.Id);
            System.assertEquals(testUser.EUR_CRM_Country_Code__c, model.deal.EUR_CRM_Country__c);
        }
    }

    @IsTest
    private static void constructModelForExistDiscountDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.assertNotEquals(null, testUser.Country);
        System.runAs(testUser) {
            EUR_CRM_Deal__c deal = createDiscountDeal(testUser, EUR_CRM_DealDetailsService.DIRECT_ORDER);
            System.assertNotEquals(null, deal.Id);
            System.assertNotEquals(null, deal.EUR_CRM_Country__c);
            EUR_CRM_DealDetailsService.Data dataService = new EUR_CRM_DealDetailsService.Data();
            EUR_CRM_DealDetailsController.Model model = dataService.constructModel(deal.Id);
            System.assertEquals(testUser.Country, model.deal.EUR_CRM_Country__c);
            System.assertEquals(deal.Id, model.deal.Id);
            System.assertEquals(deal.EUR_CRM_Objectives_Promotions__c, model.deal.EUR_CRM_Objectives_Promotions__c);
            System.assertEquals(deal.EUR_CRM_Deal_logic__c, model.deal.EUR_CRM_Deal_logic__c);
            System.assertEquals(deal.EUR_CRM_OrderType__c, model.deal.EUR_CRM_OrderType__c);
            System.assertEquals(PROD_IN_DEAL_NUMBER, model.productsInDeal.size());
        }
    }

    @IsTest
    private static void constructModelForExistFreeDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.assertNotEquals(null, testUser.Country);
        System.runAs(testUser) {
            EUR_CRM_Deal__c deal = createFreeDeal(testUser, EUR_CRM_DealDetailsService.DIRECT_ORDER);
            System.assertNotEquals(null, deal.Id);
            System.assertNotEquals(null, deal.EUR_CRM_Country__c);
            EUR_CRM_DealDetailsService.Data dataService = new EUR_CRM_DealDetailsService.Data();
            EUR_CRM_DealDetailsController.Model model = dataService.constructModel(deal.Id);
            System.assertEquals(testUser.Country, model.deal.EUR_CRM_Country__c);
            System.assertEquals(deal.Id, model.deal.Id);
            System.assertEquals(deal.EUR_CRM_Objectives_Promotions__c, model.deal.EUR_CRM_Objectives_Promotions__c);
            System.assertEquals(deal.EUR_CRM_Deal_logic__c, model.deal.EUR_CRM_Deal_logic__c);
            System.assertEquals(deal.EUR_CRM_OrderType__c, model.deal.EUR_CRM_OrderType__c);
            System.assertEquals(PROD_IN_DEAL_NUMBER, model.productsInDeal.size());
            System.assertEquals(FREE_PROD_IN_DEAL_NUMBER, model.freeProductGroupings.size());
            System.assertEquals(POSM_IN_DEAL_NUMBER, model.posmGroupings.size());
        }
    }

    /*
    * TEST DEAL INSERT
    */

    @IsTest
    public static void insertDirectOrderDiscountDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_DISCOUNT_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.DIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            view.productsInDeal = getProductsInDeal(null, true, true);
            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_SKU__c != NULL
            ]);
        }
    }

    @IsTest
    public static void insertIndirectOrderDiscountDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_DISCOUNT_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.INDIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            view.productsInDeal = getProductsInDeal(null, false, true);
            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_BQS__c != NULL
            ]);
        }
    }

    @IsTest
    public static void insertDirectOrderFreeDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_FREE_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.DIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            view.productsInDeal = getProductsInDeal(null, true, false);
            view.freeProductGroupings = getFreeGroupings(null, true);
            view.posmGroupings = getPosmGroupings(null);
            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_SKU__c != NULL
            ]);
            System.assertEquals(view.freeProductGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c = NULL
                    AND EUR_CRM_SKU__c != NULL
            ]);
            System.assertEquals(view.posmGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c != NULL
            ]);
        }
    }

    @IsTest
    public static void insertIndirectOrderFreeDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_FREE_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.INDIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            view.productsInDeal = getProductsInDeal(null, false, false);
            view.freeProductGroupings = getFreeGroupings(null, false);
            view.posmGroupings = getPosmGroupings(null);
            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_BQS__c != NULL
            ]);
            System.assertEquals(view.freeProductGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c = NULL
                    AND EUR_CRM_BQS__c != NULL
            ]);
            System.assertEquals(view.posmGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c != NULL
            ]);
        }
    }

    /*
    * TEST DEAL UPDATE
    */

    @IsTest
    public static void updateDirectOrderDiscountDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_DISCOUNT_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.DIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            insert view.deal;
            insert getProductsInDeal(view.deal.Id, true, true);
            view.productsInDeal = new EUR_CRM_DealDetailsService.Selector().selectProductsInDeal(view.deal.Id);
            view.productsInDeal.addAll(getProductsInDeal(view.deal.Id, true, true));

            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_SKU__c != NULL
            ]);
        }
    }

    @IsTest
    public static void updateIndirectOrderDiscountDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_DISCOUNT_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.INDIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            insert view.deal;
            insert getProductsInDeal(view.deal.Id, false, true);
            view.productsInDeal = new EUR_CRM_DealDetailsService.Selector().selectProductsInDeal(view.deal.Id);
            view.productsInDeal.addAll(getProductsInDeal(view.deal.Id, false, true));

            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_BQS__c != NULL
            ]);
        }
    }

    @IsTest
    public static void updateDirectOrderFreeDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_FREE_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.DIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            insert view.deal;
            insert getProductsInDeal(view.deal.Id, true, false);
            insert getFreeGroupings(view.deal.Id, true);
            insert getPosmGroupings(view.deal.Id);
            EUR_CRM_DealDetailsService.Selector selector = new EUR_CRM_DealDetailsService.Selector();
            view.productsInDeal = selector.selectProductsInDeal(view.deal.Id);
            view.productsInDeal.addAll(getProductsInDeal(view.deal.Id, true, false));
            view.freeProductGroupings = selector.selectFreeProductGroupings(view.deal.Id);
            view.freeProductGroupings.addAll(getFreeGroupings(view.deal.Id, true));
            view.posmGroupings = selector.selectPOSMGroupings(view.deal.Id);
            view.posmGroupings.addAll(getPosmGroupings(view.deal.Id));

            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_SKU__c != NULL
            ]);
            System.assertEquals(view.freeProductGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c = NULL
                    AND EUR_CRM_SKU__c != NULL
            ]);
            System.assertEquals(view.posmGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c != NULL
            ]);
        }
    }

    @IsTest
    public static void updateIndirectOrderFreeDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            view.deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_FREE_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.INDIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            insert view.deal;
            insert getProductsInDeal(view.deal.Id, false, false);
            insert getFreeGroupings(view.deal.Id, false);
            insert getPosmGroupings(view.deal.Id);
            EUR_CRM_DealDetailsService.Selector selector = new EUR_CRM_DealDetailsService.Selector();
            view.productsInDeal = selector.selectProductsInDeal(view.deal.Id);
            view.productsInDeal.addAll(getProductsInDeal(view.deal.Id, false, true));
            view.freeProductGroupings = selector.selectFreeProductGroupings(view.deal.Id);
            view.freeProductGroupings.addAll(getFreeGroupings(view.deal.Id, false));
            view.posmGroupings = selector.selectPOSMGroupings(view.deal.Id);
            view.posmGroupings.addAll(getPosmGroupings(view.deal.Id));

            String res = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
            System.assertEquals(view.productsInDeal.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_BQS__c != NULL
            ]);
            System.assertEquals(view.freeProductGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c = NULL
                    AND EUR_CRM_BQS__c != NULL
            ]);
            System.assertEquals(view.posmGroupings.size(), [
                    SELECT COUNT()
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :result.getId()
                    AND EUR_CRM_POS_Material__c != NULL
            ]);
        }
    }

    /*
    * TEST DEAL DELETE
    */

    @IsTest
    private static void deleteIndirectOrderFreeDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            EUR_CRM_Deal__c deal = new EUR_CRM_Deal__c(
                    Name = DEAL_NAME,
                    RecordTypeId = DEAL_FREE_RT_ID,
                    EUR_CRM_OrderType__c = EUR_CRM_DealDetailsService.INDIRECT_ORDER,
                    EUR_CRM_Objectives_Promotions__c = op.Id,
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Multiply__c = true
            );
            insert deal;
            insert getProductsInDeal(deal.Id, false, false);
            insert getFreeGroupings(deal.Id, false);
            insert getPosmGroupings(deal.Id);
            Database.DeleteResult result = new EUR_CRM_DealDetailsService.Data().doDelete(deal.Id);
            System.assert(result.isSuccess());
            System.assertEquals(0, [SELECT COUNT() FROM EUR_CRM_Product_in_Deal__c]);
            System.assertEquals(0, [SELECT COUNT() FROM EUR_CRM_ProductCatalogItemGrouping__c]);
        }
    }

    /*
    * TEST EXCEPTIONS
    */

    @IsTest
    private static void exceptionOnUpsert() {
        EUR_CRM_DealDetailsController.Model view = new EUR_CRM_DealDetailsController.Model();
        view.deal = new EUR_CRM_Deal__c(Id = EUR_CRM_TestDataFactory.getGeneratedId(EUR_CRM_Deal__c.SObjectType));
        String result;
        try {
            result = new EUR_CRM_DealDetailsService.Data().doUpsert(view);
        } catch (AuraHandledException ex) {}
        System.assertEquals(null, result);
    }

    @IsTest
    private static void exceptionOnDelete() {
        Database.DeleteResult result;
        try {
            result = new EUR_CRM_DealDetailsService.Data()
                    .doDelete(EUR_CRM_TestDataFactory.getGeneratedId(EUR_CRM_Deal__c.SObjectType));
        } catch (AuraHandledException ex) {}
        System.assertEquals(null, result);
    }

    /*
    * UTILITY METHODS
    */

    private static EUR_CRM_Deal__c createDiscountDeal(User testUser, String orderType) {
        EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
        EUR_CRM_Deal__c deal = (EUR_CRM_Deal__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Deal__c(
                Name = DEAL_NAME,
                EUR_CRM_Country__c = testUser.Country,
                EUR_CRM_Deal_logic__c = 'OR',
                EUR_CRM_Objectives_Promotions__c = op.Id,
                RecordTypeId = DEAL_DISCOUNT_RT_ID
        ), true);
        System.assertNotEquals(null, deal.EUR_CRM_Country__c);
        insert getProductsInDeal(deal.Id, true, true);
        return deal;
    }

    private static EUR_CRM_Deal__c createFreeDeal(User testUser, String orderType) {
        EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
        EUR_CRM_Deal__c deal = (EUR_CRM_Deal__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Deal__c(
                Name = DEAL_NAME,
                EUR_CRM_Country__c = testUser.Country,
                EUR_CRM_Deal_logic__c = 'OR',
                EUR_CRM_Objectives_Promotions__c = op.Id,
                RecordTypeId = DEAL_FREE_RT_ID,
                EUR_CRM_OrderType__c = 'EUR_Direct'
        ), true);
        System.assertNotEquals(null, deal.EUR_CRM_Country__c);
        insert getProductsInDeal(deal.Id, true, false);
        insert getFreeGroupings(deal.Id, true);
        insert getPosmGroupings(deal.Id);

        return deal;
    }

    private static List<EUR_CRM_Product_in_Deal__c> getProductsInDeal(Id dealId, Boolean isDirectOrder, Boolean isDiscountDeal) {
        List<EUR_CRM_Product_in_Deal__c> result = (List<EUR_CRM_Product_in_Deal__c>) EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_Product_in_Deal__c(), PROD_IN_DEAL_NUMBER, false);
        List<SObject> products = isDirectOrder
                ? EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_SKU__c(), PROD_IN_DEAL_NUMBER, true)
                : EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_Size__c(), PROD_IN_DEAL_NUMBER, true);
        Integer index = 0;
        for (EUR_CRM_Product_in_Deal__c pid : result) {
            pid.EUR_CRM_AnimationID__c = dealId;
            if (isDirectOrder) {
                pid.EUR_CRM_SKU__c = products[index++].Id;
            } else {
                pid.EUR_CRM_BQS__c = products[index++].Id;
            }
            if (isDiscountDeal) {
                pid.EUR_CRM_Discount__c = index/10;
            }
            pid.EUR_CRM_Quantity__c = index;
        }
        return result;
    }

    private static List<EUR_CRM_ProductCatalogItemGrouping__c> getFreeGroupings(Id dealId, Boolean isDirectOrder) {
        List<EUR_CRM_ProductCatalogItemGrouping__c> result = (List<EUR_CRM_ProductCatalogItemGrouping__c>) EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_ProductCatalogItemGrouping__c(), FREE_PROD_IN_DEAL_NUMBER, false);
        List<SObject> products = isDirectOrder
                ? EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_SKU__c(), FREE_PROD_IN_DEAL_NUMBER, true)
                : EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_Size__c(), FREE_PROD_IN_DEAL_NUMBER, true);
        Integer index = 0;
        for (EUR_CRM_ProductCatalogItemGrouping__c free : result) {
            free.EUR_CRM_AnimationID__c = dealId;
            if (isDirectOrder) {
                free.EUR_CRM_SKU__c = products[index++].Id;
            } else {
                free.EUR_CRM_BQS__c = products[index++].Id;
            }
            free.EUR_CRM_Quantity__c = index;
        }
        return result;
    }

    private static List<EUR_CRM_ProductCatalogItemGrouping__c> getPosmGroupings(Id dealId) {
        List<EUR_CRM_ProductCatalogItemGrouping__c> result = (List<EUR_CRM_ProductCatalogItemGrouping__c>) EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_ProductCatalogItemGrouping__c(), POSM_IN_DEAL_NUMBER, false);
        List<SObject> skuList = EUR_CRM_TestDataFactory.createSObjectList(new EUR_CRM_POS_Material__c(), POSM_IN_DEAL_NUMBER, true);
        Integer index = 0;
        for (EUR_CRM_ProductCatalogItemGrouping__c posm : result) {
            posm.EUR_CRM_AnimationID__c = dealId;
            posm.EUR_CRM_POS_Material__c = skuList[index++].Id;
            posm.EUR_CRM_Quantity__c = index;
        }
        return result;
    }


}