/*
* A - EUR_CRM_Account__c (Account (EU))
* SO - EUR_CRM_Sales_Order__c (Sales Order (EU)) - lookup to A
* SOI - EUR_CRM_Sales_Order_Items__c (Sales Order Item (EU)) - lookup to SO, PCI, SI
*
* PC - EUR_CRM_Product_Catalog__c (Product Catalog (EU))
* PCI - EUR_CRM_ProductCatalogItem__c (Price Book Item (EU)) - lookup to PC
*
* S - EUR_CRM_Stock__c (Stock (EU))
* SI - EUR_CRM_Stock_Item__c (Stock Item (EU)) - lookup to S
* ST - EUR_CRM_Stock_Transaction__c (Stock Transaction (EU)) - lookup to SI and to SOI
*
* Main logic :
*
* After insert, update or delete SOI must insert, update or delete ST
* only if SO has valid RT : 'EUR_Free_Goods_to_Stock', 'EUR_Free_Goods_from_Stock'
* or
* valid status ('Instant validation').
*
* S must always exist. If not - nothing will happen during insert SOI.
*
* If SOI insert and if SOI hasn't SI lookup, then SOI must has at least PCI to create SI in before insert.
* Then will be created ST. If not - nothing will happen.
*
* If SOI insert and SOI has SI lookup then will be created ST.
* If SOI has not SI lookup, then if SOI has PCI lookup ->  SI will be created and related with SOI by PCI.
*
* If SOI update then will be updated related ST.
*
* If SOI delete then will be deleted related ST.
*
*                         |-----------------------------------------|
*                         |                                         |
*                         |           ===========                   |
*                         |           |    PC   |                   |
*     ===========         |           ===========                   |
*     | Account |         |                |                        |
*     ===========         |               |||                       |
*             |           |           ===========                   |
*             |     |------    |------|    PCI  |--------|          |
*            |||   |||         |      ===========        |         |||
*           ===========        |                         |     ===========
*           |   SO    |        |                         |     |    S    |
*           ===========        |                         |     ===========
*               |              |                         |              |
*               |      |--------                         --------|      |
*              |||    |||                                       |||    |||
*              ===========                                      ===========
*              |   SO    |                                      |   SI    |
*              ===========                                      ===========
*                |                                                     |
*                |                                                     |
*                |                                                     |
*                -----------------------------------------------|      |
*                                                              |||    |||
*                                                              ===========
*                                                              |   SI    |
*                                                              ===========
* */

@IsTest (IsParallel = true)
private class EUR_CRM_SalesOrderItemStockUpdateTest {

    private static final String ACCOUNT_RT = 'EUR_DK_On_Trade';
    private static final String STOCK_RT = 'EUR_DK_Stock';
    private static final String STOCK_ITEM_RT = 'EUR_DK_Stock_Item';

    private static final String SALES_ORDER_TO_STOCK_RT = 'EUR_Free_Goods_to_Stock';
    private static final String SALES_ORDER_FROM_STOCK_RT = 'EUR_Free_Goods_from_Stock';
    private static final String SALES_ORDER_INVALID_RT = 'EUR_Indirect';

    private static final String SALES_ORDER_VALID_STATUS = 'Instant validation';
    private static final String SALES_ORDER_INVALID_STATUS = 'On hold';

    private static final String CREDIT_STOCK_TRANSACTION_TYPE = 'Credit';
    private static final String DEBIT_STOCK_TRANSACTION_TYPE = 'Debit';

    @IsTest
    private static void EUR_CRM_SalesOrderItemTriggerHandler_Test() {
        EUR_CRM_SalesOrderItemStockUpdate.forTest();
        EUR_CRM_SalesOrderItemTriggerHandler.forTest();

    }


    /* =========================================================*/
    /*      Before insert tests
    /* =========================================================*/
//    @IsTest
//    private static void bi_SOitemWithoutStockItemAndWithProductCatalogItem_SOvalidStatusTest() {
//        EUR_CRM_ProductCatalog__c productCatalog = createProductCatalog();
//        EUR_CRM_ProductCatalogItem__c productCatalogItem = createProductCatalogItem(productCatalog.Id);
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Account__c acc = createAccount();
//
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, null);
//        soItem.EUR_CRM_PriceBookEntryID__c = productCatalogItem.Id;
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        List<EUR_CRM_Stock_Item__c> stockItems = selectStockItems();
//        System.assertEquals(stock.Id, stockItems[0].EUR_CRM_Stock__c);
//        System.assertEquals(STOCK_ITEM_RT, stockItems[0].RecordType.DeveloperName);
//
//        List<EUR_CRM_Sales_Order_Items__c> insertedSOitems = selectSOitems();
//        System.assertEquals(stockItems[0].Id, insertedSOitems[0].EUR_CRM_Stock_Item__c);
//        System.assertEquals(stockItems[0].EUR_Price_Book_Item__c, insertedSOitems[0].EUR_CRM_PriceBookEntryID__c);
//    }
//
//    @IsTest
//    private static void bi_SOitemWithoutStockItemAndWithProductCatalogItem_SOinvalidStatusTest() {
//        EUR_CRM_ProductCatalog__c productCatalog = createProductCatalog();
//        EUR_CRM_ProductCatalogItem__c productCatalogItem = createProductCatalogItem(productCatalog.Id);
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Account__c acc = createAccount();
//
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_INVALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, null);
//        soItem.EUR_CRM_PriceBookEntryID__c = productCatalogItem.Id;
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        List<EUR_CRM_Stock_Item__c> stockItems = selectStockItems();
//        System.assert(stockItems.isEmpty());
//
//        List<EUR_CRM_Sales_Order_Items__c> insertedSOitems = selectSOitems();
//        System.assertEquals(null, insertedSOitems[0].EUR_CRM_Stock_Item__c);
//    }
//
//    @IsTest
//    private static void bi_SOitemWithoutStockItemAndWithoutProductCatalogItem_SOvalidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Account__c acc = createAccount();
//
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, null);
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        List<EUR_CRM_Stock_Item__c> stockItems = selectStockItems();
//        System.assert(stockItems.isEmpty());
//
//        List<EUR_CRM_Sales_Order_Items__c> insertedSOitems = selectSOitems();
//        System.assertEquals(null, insertedSOitems[0].EUR_CRM_Stock_Item__c);
//    }
//
//    @IsTest
//    private static void bi_SOitemWithoutStockAndWithoutStockItemAndWithProductCatalogItem_SOvalidStatusTest() {
//        EUR_CRM_ProductCatalog__c productCatalog = createProductCatalog();
//        EUR_CRM_ProductCatalogItem__c productCatalogItem = createProductCatalogItem(productCatalog.Id);
//        EUR_CRM_Account__c acc = createAccount();
//
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, null);
//        soItem.EUR_CRM_PriceBookEntryID__c = productCatalogItem.Id;
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        List<EUR_CRM_Stock_Item__c> stockItems = selectStockItems();
//        System.assert(stockItems.isEmpty());
//
//        List<EUR_CRM_Sales_Order_Items__c> insertedSOitems = selectSOitems();
//        System.assertEquals(null, insertedSOitems[0].EUR_CRM_Stock_Item__c);
//    }


    /* =========================================================*/
    /*      After insert tests
    /* =========================================================*/
//    @IsTest
//    private static void ai_SOwithValidRecordTypeAndValidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = selectStockTransactions()[0];
//        System.assertEquals(stockItem.Id, stockTransaction.EUR_CRM_Stock_Item__c);
//        System.assertEquals(soItem.Id, stockTransaction.EUR_CRM_Sales_Order_Item__c);
//        System.assertEquals(10, stockTransaction.EUR_CRM_Quantity__c);
//        System.assertEquals(CREDIT_STOCK_TRANSACTION_TYPE, stockTransaction.EUR_CRM_Transaction_Type__c);
//        System.assertEquals('EUR_DK_Stock_Transaction', stockTransaction.RecordType.DeveloperName);
//    }
//
//    @IsTest
//    private static void ai_SOwithInvalidRecordTypeAndValidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_INVALID_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        System.assert(selectStockTransactions().isEmpty());
//    }
//
//    @IsTest
//    private static void ai_SOwithValidRecordTypeAndInvalidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_INVALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        System.assert(selectStockTransactions().isEmpty());
//    }
//
//    @IsTest
//    private static void ai_SOwithoutStockItemAndValidRacordTypeAndValidStatusTest() {
//        EUR_CRM_ProductCatalog__c productCatalog = createProductCatalog();
//        EUR_CRM_ProductCatalogItem__c productCatalogItem = createProductCatalogItem(productCatalog.Id);
//        EUR_CRM_Stock__c stock = createStock();
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, null);
//        soItem.EUR_CRM_PriceBookEntryID__c = productCatalogItem.Id;
//        soItem.EUR_CRM_Quantity__c = 10;
//
//        Test.startTest();
//        insert soItem;
//        Test.stopTest();
//
//        EUR_CRM_Stock_Item__c createdStockItem = selectStockItems()[0];
//        EUR_CRM_Sales_Order_Items__c updatedSOitem = selectSOitems()[0];
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = selectStockTransactions()[0];
//        System.assertEquals(createdStockItem.Id, stockTransaction.EUR_CRM_Stock_Item__c);
//        System.assertEquals(updatedSOitem.Id, stockTransaction.EUR_CRM_Sales_Order_Item__c);
//        System.assertEquals(10, stockTransaction.EUR_CRM_Quantity__c);
//        System.assertEquals(CREDIT_STOCK_TRANSACTION_TYPE, stockTransaction.EUR_CRM_Transaction_Type__c);
//        System.assertEquals('EUR_DK_Stock_Transaction', stockTransaction.RecordType.DeveloperName);
//    }


    /* =========================================================*/
    /*      After update tests
    /* =========================================================*/
//    @IsTest
//    private static void au_SOwithValidRecordTypeAndValidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//        insert soItem;
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = makeStockTransaction(stockItem.Id);
//        stockTransaction.EUR_CRM_Sales_Order_Item__c = soItem.Id;
//        stockTransaction.EUR_CRM_Quantity__c = 10;
//        stockTransaction.EUR_CRM_Transaction_Type__c = CREDIT_STOCK_TRANSACTION_TYPE;
//        insert stockTransaction;
//
//        System.assertEquals(stockTransaction.EUR_CRM_Quantity__c, soItem.EUR_CRM_Quantity__c);
//
//        Test.startTest();
//        soItem.EUR_CRM_Quantity__c = 20;
//        update soItem;
//        Test.stopTest();
//
//        List<EUR_CRM_Stock_Transaction__c> updatedStockTransactions = selectStockTransactions();
//        System.assertEquals(20, updatedStockTransactions[0].EUR_CRM_Quantity__c);
//        System.assertEquals(CREDIT_STOCK_TRANSACTION_TYPE, updatedStockTransactions[0].EUR_CRM_Transaction_Type__c);
//
//        List<EUR_CRM_Sales_Order_Items__c> updatedSOitems =
//            new EUR_CRM_SalesOrderItemStockUpdate().selectSOitemsWhereIds(new List<EUR_CRM_Sales_Order_Items__c>{soItem});
//        System.assertEquals(1, updatedSOitems.size());
//        System.assertEquals(1, new EUR_CRM_SalesOrderItemStockUpdate().getSOitemByStockTransaction(new List<EUR_CRM_Sales_Order_Items__c>{updatedSOitems[0]}).size());
//    }
//
//    @IsTest
//    private static void au_SOwithInvalidRecordTypeTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_INVALID_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//        insert soItem;
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = makeStockTransaction(stockItem.Id);
//        stockTransaction.EUR_CRM_Sales_Order_Item__c = soItem.Id;
//        stockTransaction.EUR_CRM_Quantity__c = 10;
//        stockTransaction.EUR_CRM_Transaction_Type__c = CREDIT_STOCK_TRANSACTION_TYPE;
//        insert stockTransaction;
//
//        System.assertEquals(soItem.EUR_CRM_Quantity__c, stockTransaction.EUR_CRM_Quantity__c);
//
//        Test.startTest();
//        soItem.EUR_CRM_Quantity__c = 20;
//        update soItem;
//        Test.stopTest();
//
//        EUR_CRM_Stock_Transaction__c updatedStockTransaction = selectStockTransactions()[0];
//        System.assertEquals(10, updatedStockTransaction.EUR_CRM_Quantity__c);
//        System.assertEquals(CREDIT_STOCK_TRANSACTION_TYPE, updatedStockTransaction.EUR_CRM_Transaction_Type__c);
//
//        List<EUR_CRM_Sales_Order_Items__c> updatedSOitems =
//            new EUR_CRM_SalesOrderItemStockUpdate().selectSOitemsWhereIds(new List<EUR_CRM_Sales_Order_Items__c>{soItem});
//        System.assert(updatedSOitems.isEmpty());
//    }
//
//    @IsTest
//    private static void au_SOwithValidRecordTypeAndInvalidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_INVALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//        insert soItem;
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = makeStockTransaction(stockItem.Id);
//        stockTransaction.EUR_CRM_Sales_Order_Item__c = soItem.Id;
//        stockTransaction.EUR_CRM_Quantity__c = 10;
//        stockTransaction.EUR_CRM_Transaction_Type__c = CREDIT_STOCK_TRANSACTION_TYPE;
//        insert stockTransaction;
//
//        System.assertEquals(soItem.EUR_CRM_Quantity__c, stockTransaction.EUR_CRM_Quantity__c);
//
//        Test.startTest();
//        soItem.EUR_CRM_Quantity__c = 20;
//        update soItem;
//        Test.stopTest();
//
//        EUR_CRM_Stock_Transaction__c updatedStockTransaction = selectStockTransactions()[0];
//        System.assertEquals(10, updatedStockTransaction.EUR_CRM_Quantity__c);
//        System.assertEquals(CREDIT_STOCK_TRANSACTION_TYPE, updatedStockTransaction.EUR_CRM_Transaction_Type__c);
//
//        List<EUR_CRM_Sales_Order_Items__c> updatedSOitems =
//            new EUR_CRM_SalesOrderItemStockUpdate().selectSOitemsWhereIds(new List<EUR_CRM_Sales_Order_Items__c>{soItem});
//        System.assert(updatedSOitems.isEmpty());
//
//    }
//
//    @IsTest
//    private static void au_SalesOrderChangeRecordTypeToAnotherValidRecordTypeAndValidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//        insert soItem;
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = makeStockTransaction(stockItem.Id);
//        stockTransaction.EUR_CRM_Sales_Order_Item__c = soItem.Id;
//        stockTransaction.EUR_CRM_Quantity__c = 10;
//        stockTransaction.EUR_CRM_Transaction_Type__c = CREDIT_STOCK_TRANSACTION_TYPE;
//        insert stockTransaction;
//
//        System.assertEquals(soItem.EUR_CRM_Quantity__c, stockTransaction.EUR_CRM_Quantity__c);
//
//        EUR_CRM_Sales_Order__c soToUpdateRecordType = selectSalesOrders()[0];
//        Id soRecTypeId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(SALES_ORDER_FROM_STOCK_RT).getRecordTypeId();
//        soToUpdateRecordType.RecordTypeId = soRecTypeId;
//        update soToUpdateRecordType;
//
//        Test.startTest();
//        soItem.EUR_CRM_Quantity__c = 20;
//        update soItem;
//        Test.stopTest();
//
//        EUR_CRM_Stock_Transaction__c updatedStockTransaction = selectStockTransactions()[0];
//        System.assertEquals(-20, updatedStockTransaction.EUR_CRM_Quantity__c);
//        System.assertEquals(DEBIT_STOCK_TRANSACTION_TYPE, updatedStockTransaction.EUR_CRM_Transaction_Type__c);
//
//        List<EUR_CRM_Sales_Order_Items__c> updatedSOitems =
//            new EUR_CRM_SalesOrderItemStockUpdate().selectSOitemsWhereIds(new List<EUR_CRM_Sales_Order_Items__c>{soItem});
//        System.assertEquals(1, updatedSOitems.size());
//        System.assertEquals(1, new EUR_CRM_SalesOrderItemStockUpdate().getSOitemByStockTransaction(new List<EUR_CRM_Sales_Order_Items__c>{updatedSOitems[0]}).size());
//    }


    /* =========================================================*/
    /*      After delete tests
    /* =========================================================*/
//    @IsTest
//    private static void ad_SOwithValidRecordTypeAndValidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_TO_STOCK_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//        insert soItem;
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = selectStockTransactions()[0];
//        System.assertEquals(stockTransaction.EUR_CRM_Stock_Item__c, stockItem.Id);
//        System.assertEquals(stockTransaction.EUR_CRM_Sales_Order_Item__c, soItem.Id);
//        System.assertEquals(stockTransaction.EUR_CRM_Quantity__c, 10);
//        System.assertEquals(stockTransaction.EUR_CRM_Transaction_Type__c, CREDIT_STOCK_TRANSACTION_TYPE);
//
//        Test.startTest();
//        List<EUR_CRM_Sales_Order_Items__c> soItemsToDelete = selectSOitems();
//        delete soItemsToDelete;
//        Test.stopTest();
//
//        List<EUR_CRM_Stock_Transaction__c> stockTransactions = selectStockTransactions();
//        System.assert(stockTransactions.isEmpty());
//    }
//
//    @IsTest
//    private static void ad_SOwithInvalidRecordTypeAndValidStatusTest() {
//        EUR_CRM_Stock__c stock = createStock();
//        EUR_CRM_Stock_Item__c stockItem = createStockItem(stock.Id);
//
//        EUR_CRM_Account__c acc = createAccount();
//        EUR_CRM_Sales_Order__c so = createSalesOrder(acc.Id, SALES_ORDER_INVALID_RT, SALES_ORDER_VALID_STATUS);
//
//        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
//        soItem.EUR_CRM_Quantity__c = 10;
//        insert soItem;
//
//        EUR_CRM_Stock_Transaction__c stockTransaction = makeStockTransaction(stockItem.Id);
//        stockTransaction.EUR_CRM_Sales_Order_Item__c = soItem.Id;
//        stockTransaction.EUR_CRM_Quantity__c = 10;
//        stockTransaction.EUR_CRM_Transaction_Type__c = CREDIT_STOCK_TRANSACTION_TYPE;
//        insert stockTransaction;
//
//        Test.startTest();
//        List<EUR_CRM_Sales_Order_Items__c> soItemsToDelete = selectSOitems();
//        delete soItemsToDelete;
//        Test.stopTest();
//
//        List<EUR_CRM_Stock_Transaction__c> stockTransactions = selectStockTransactions();
//        System.assertEquals(1, stockTransactions.size());
//    }


    /* =========================================================*/
    /*      Makers
    /* =========================================================*/
    private static EUR_CRM_ProductCatalog__c createProductCatalog() {
        EUR_CRM_ProductCatalog__c productCatalog = new EUR_CRM_ProductCatalog__c();
        insert productCatalog;
        return productCatalog;
    }

    private static EUR_CRM_ProductCatalogItem__c createProductCatalogItem(Id productCatalogId) {
        EUR_CRM_ProductCatalogItem__c productCatalogItem = new EUR_CRM_ProductCatalogItem__c();
        productCatalogItem.EUR_CRM_PriceBookID__c = productCatalogId;
        insert productCatalogItem;
        return productCatalogItem;
    }

    private static EUR_CRM_Account__c createAccount() {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RT).getRecordTypeId();

        EUR_CRM_Account__c account = new EUR_CRM_Account__c();
        account.RecordTypeId = recordTypeId;
        account.EUR_CRM_Postal_Code__c = '112233';
        insert account;
        
        return account;
    }

    private static EUR_CRM_Stock__c createStock() {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Stock__c.getRecordTypeInfosByDeveloperName().get(STOCK_RT).getRecordTypeId();

        EUR_CRM_Stock__c stock = new EUR_CRM_Stock__c();
        stock.RecordTypeId = recordTypeId;
        insert stock;
        
        return stock;
    }

    private static EUR_CRM_Stock_Item__c createStockItem(Id stockId) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().get(STOCK_ITEM_RT).getRecordTypeId();

        EUR_CRM_Stock_Item__c stockItem = new EUR_CRM_Stock_Item__c();
        stockItem.EUR_CRM_Stock__c = stockId;
        stockItem.RecordTypeId = recordTypeId;
        insert stockItem;
        
        return stockItem;
    }

    private static EUR_CRM_Sales_Order__c createSalesOrder(Id accountId, String recTypeDevName, String status) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();

        EUR_CRM_Sales_Order__c so = new EUR_CRM_Sales_Order__c();
        so.EUR_CRM_Account__c = accountId;
        so.RecordTypeId = recordTypeId;
        so.EUR_CRM_Status__c = status;
        insert so;
        
        return so;
    }

    private static EUR_CRM_Sales_Order_Items__c makeSOitem(Id orderId, Id stockItemId) {
        EUR_CRM_Sales_Order_Items__c soItem = new EUR_CRM_Sales_Order_Items__c();
        soItem.EUR_CRM_Sales_Order__c = orderId;
        soItem.EUR_CRM_Stock_Item__c = stockItemId;
        return soItem;
    }

    private static EUR_CRM_Stock_Transaction__c makeStockTransaction(Id stockItemId) {
        EUR_CRM_Stock_Transaction__c stockTransaction = new EUR_CRM_Stock_Transaction__c();
        stockTransaction.EUR_CRM_Stock_Item__c = stockItemId;
        return stockTransaction;
    }


    /* =========================================================*/
    /*    SOQL Selectors
    /* =========================================================*/
    private static List<EUR_CRM_Stock_Transaction__c> selectStockTransactions() {
        return [
            SELECT Id
                , EUR_CRM_Stock_Item__c
                , EUR_CRM_Sales_Order_Item__c
                , EUR_CRM_Transaction_Type__c
                , EUR_CRM_Quantity__c
                , RecordType.DeveloperName
            FROM EUR_CRM_Stock_Transaction__c
        ];
    }

    private static List<EUR_CRM_Sales_Order__c> selectSalesOrders() {
        return [
            SELECT Id
                , RecordTypeId
            FROM EUR_CRM_Sales_Order__c
        ];
    }

    private static List<EUR_CRM_Stock_Item__c> selectStockItems() {
        return [
            SELECT Id
                , EUR_CRM_Stock__c
                , EUR_Price_Book_Item__c
                , RecordType.DeveloperName
                , (
                    SELECT Id
                    FROM Sales_Order_Item_EU__r
                )
            FROM EUR_CRM_Stock_Item__c
        ];
    }

    private static List<EUR_CRM_Sales_Order_Items__c> selectSOitems() {
        return [
            SELECT Id
                , RecordTypeId
                , RecordType.DeveloperName
                , EUR_CRM_Quantity__c
                , EUR_CRM_Sales_Order__r.RecordType.DeveloperName
                , EUR_CRM_Sales_Order__r.CreatedById
                , EUR_CRM_Sales_Order__r.EUR_CRM_Status__c
                , EUR_CRM_Stock_Item__c
                , EUR_CRM_PriceBookEntryID__c
                , (
                    SELECT Id
                        , EUR_CRM_Stock_Item__c
                        , EUR_CRM_Transaction_Type__c
                        , EUR_CRM_Quantity__c
                    FROM Stock_Transactions_EU__r
                )
            FROM EUR_CRM_Sales_Order_Items__c
        ];
    }

}