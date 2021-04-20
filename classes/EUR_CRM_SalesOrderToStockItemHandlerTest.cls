// Finished status is not available for EUR_Free_Goods_from_Stock

@IsTest(IsParallel = true)
private class EUR_CRM_SalesOrderToStockItemHandlerTest {

    private static final String ACCOUNT_RT = 'EUR_DK_On_Trade';
    private static final String STOCK_RT = 'EUR_DK_Stock';
    private static final String STOCK_ITEM_RT = 'EUR_DK_Stock_Item';


    /* =========================================================*/
    /*      After update tests
    /* =========================================================*/
    @IsTest
    private static void au_StockWithStockItemWithoutStockTransaction_SOValid_PositiveTest() {
        EUR_CRM_ProductCatalog__c pc = makeProductCatalog();
        insert pc;

        EUR_CRM_ProductCatalogItem__c pcItem = makeProductCatalogItem(pc.Id);
        insert pcItem;

        EUR_CRM_Stock__c stock = makeStock();
        insert stock;

        EUR_CRM_Stock_Item__c stockItem = makeStockItem(stock.Id);
        stockItem.EUR_Price_Book_Item__c = pcItem.Id;
        insert stockItem;

        EUR_CRM_Account__c acc = makeAccount();
        insert acc;

        EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_Free_Goods_to_Stock', 'Instant validation');
        insert so;

        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
        soItem.EUR_CRM_PriceBookEntryID__c = pcItem.Id;
        soItem.EUR_CRM_Quantity__c = 10;
        insert soItem;


        Test.startTest();
        so.EUR_CRM_Status__c = 'Finished';
        update so;
        Test.stopTest();

        List<EUR_CRM_Stock_Transaction__c> insertedStockTransactions = selectStockTransactions();
        System.assertEquals(10, insertedStockTransactions[0].EUR_CRM_Quantity__c);
        System.assertEquals('Credit', insertedStockTransactions[0].EUR_CRM_Transaction_Type__c);
    }

    @IsTest
    private static void au_StockWithStockItemWithStockTransaction_SOValid_PositiveTest() {
        EUR_CRM_ProductCatalog__c pc = makeProductCatalog();
        insert pc;

        EUR_CRM_ProductCatalogItem__c pcItem = makeProductCatalogItem(pc.Id);
        insert pcItem;

        EUR_CRM_Stock__c stock = makeStock();
        insert stock;

        EUR_CRM_Stock_Item__c stockItem = makeStockItem(stock.Id);
        stockItem.EUR_Price_Book_Item__c = pcItem.Id;
        insert stockItem;

        EUR_CRM_Account__c acc = makeAccount();
        insert acc;

        EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_Free_Goods_to_Stock', 'Instant validation');
        insert so;

        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
        soItem.EUR_CRM_PriceBookEntryID__c = pcItem.Id;
        soItem.EUR_CRM_Quantity__c = 10;
        insert soItem;

        EUR_CRM_Stock_Transaction__c stockTransaction = makeStockTransaction(stockItem.Id);
        stockTransaction.EUR_CRM_Sales_Order_Item__c = soItem.Id;
        stockTransaction.EUR_CRM_Quantity__c = 20;
        insert stockTransaction;


        Test.startTest();
        so.EUR_CRM_Status__c = 'Finished';
        update so;
        Test.stopTest();

        List<EUR_CRM_Stock_Transaction__c> updatedSTockTransactions = selectStockTransactions();
        System.assertEquals(10, updatedSTockTransactions[0].EUR_CRM_Quantity__c);
        System.assertEquals('Credit', updatedSTockTransactions[0].EUR_CRM_Transaction_Type__c);
    }

    @IsTest
    private static void au_StockWithoutStockItem_SOValid_PositiveTest() {
        EUR_CRM_ProductCatalog__c pc = makeProductCatalog();
        insert pc;

        EUR_CRM_ProductCatalogItem__c pcItem = makeProductCatalogItem(pc.Id);
        insert pcItem;

        EUR_CRM_Stock__c stock = makeStock();
        insert stock;

        EUR_CRM_Account__c acc = makeAccount();
        insert acc;

        EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_Free_Goods_to_Stock', 'Instant validation');
        insert so;

        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, null);
        soItem.EUR_CRM_PriceBookEntryID__c = pcItem.Id;
        soItem.EUR_CRM_Quantity__c = 10;
        insert soItem;


        Test.startTest();
        so.EUR_CRM_Status__c = 'Finished';
        update so;
        Test.stopTest();

        List<EUR_CRM_Stock_Item__c> stockItems = selectStockItems();
        System.assertEquals(1, stockItems.size());
        System.assertEquals(stock.Id, stockItems[0].EUR_CRM_Stock__c);
        System.assertEquals(pcItem.Id, stockItems[0].EUR_Price_Book_Item__c);

        List<EUR_CRM_Stock_Transaction__c> insertedStockTransactions = selectStockTransactions();
        System.assertEquals(10, insertedStockTransactions[0].EUR_CRM_Quantity__c);
        System.assertEquals('Credit', insertedStockTransactions[0].EUR_CRM_Transaction_Type__c);
    }

    @IsTest
    private static void au_StockWithStockItem_SOInvalidStatus_NegativeTest() {
        EUR_CRM_ProductCatalog__c pc = makeProductCatalog();
        insert pc;

        EUR_CRM_ProductCatalogItem__c pcItem = makeProductCatalogItem(pc.Id);
        insert pcItem;

        EUR_CRM_Stock__c stock = makeStock();
        insert stock;

        EUR_CRM_Stock_Item__c stockItem = makeStockItem(stock.Id);
        stockItem.EUR_Price_Book_Item__c = pcItem.Id;
        insert stockItem;

        EUR_CRM_Account__c acc = makeAccount();
        insert acc;

        EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_Free_Goods_to_Stock', 'Instant validation');
        insert so;

        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
        soItem.EUR_CRM_PriceBookEntryID__c = pcItem.Id;
        soItem.EUR_CRM_Quantity__c = 10;
        insert soItem;


        Test.startTest();
        so.EUR_CRM_Status__c = 'On hold';
        update so;
        Test.stopTest();

        System.assert(selectStockTransactions().isEmpty());
    }

    @IsTest
    private static void au_StockWithStockItem_SOInvalidRecordType_NegativeTest() {
        EUR_CRM_ProductCatalog__c pc = makeProductCatalog();
        insert pc;

        EUR_CRM_ProductCatalogItem__c pcItem = makeProductCatalogItem(pc.Id);
        insert pcItem;

        EUR_CRM_Stock__c stock = makeStock();
        insert stock;

        EUR_CRM_Stock_Item__c stockItem = makeStockItem(stock.Id);
        stockItem.EUR_Price_Book_Item__c = pcItem.Id;
        insert stockItem;

        EUR_CRM_Account__c acc = makeAccount();
        insert acc;

        EUR_CRM_Sales_Order__c so = makeSalesOrder(acc.Id, 'EUR_Free_Goods_from_Stock', 'Instant validation');
        insert so;

        EUR_CRM_Sales_Order_Items__c soItem = makeSOitem(so.Id, stockItem.Id);
        soItem.EUR_CRM_PriceBookEntryID__c = pcItem.Id;
        soItem.EUR_CRM_Quantity__c = 10;
        insert soItem;


        Test.startTest();
        so.EUR_CRM_Status__c = 'On hold'; // Finished status is not available for EUR_Free_Goods_from_Stock
        update so;
        Test.stopTest();

        System.assert(selectStockTransactions().isEmpty());
    }


    /* =========================================================*/
    /*      Makers
    /* =========================================================*/
    private static EUR_CRM_ProductCatalog__c makeProductCatalog() {
        EUR_CRM_ProductCatalog__c productCatalog = new EUR_CRM_ProductCatalog__c();
        return productCatalog;
    }

    private static EUR_CRM_ProductCatalogItem__c makeProductCatalogItem(Id productCatalogId) {
        EUR_CRM_ProductCatalogItem__c productCatalogItem = new EUR_CRM_ProductCatalogItem__c();
        productCatalogItem.EUR_CRM_PriceBookID__c = productCatalogId;
        return productCatalogItem;
    }

    private static EUR_CRM_Account__c makeAccount() {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RT).getRecordTypeId();

        EUR_CRM_Account__c account = new EUR_CRM_Account__c();
        account.RecordTypeId = recordTypeId;
        account.EUR_CRM_Postal_Code__c = '112233';
        return account;
    }

    private static EUR_CRM_Stock__c makeStock() {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Stock__c.getRecordTypeInfosByDeveloperName().get(STOCK_RT).getRecordTypeId();

        EUR_CRM_Stock__c stock = new EUR_CRM_Stock__c();
        stock.RecordTypeId = recordTypeId;
        return stock;
    }

    private static EUR_CRM_Stock_Item__c makeStockItem(Id stockId) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().get(STOCK_ITEM_RT).getRecordTypeId();

        EUR_CRM_Stock_Item__c stockItem = new EUR_CRM_Stock_Item__c();
        stockItem.EUR_CRM_Stock__c = stockId;
        stockItem.RecordTypeId = recordTypeId;
        return stockItem;
    }

    private static EUR_CRM_Sales_Order__c makeSalesOrder(Id accountId, String recTypeDevName, String status) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();

        EUR_CRM_Sales_Order__c so = new EUR_CRM_Sales_Order__c();
        so.EUR_CRM_Account__c = accountId;
        so.RecordTypeId = recordTypeId;
        so.EUR_CRM_Status__c = status;
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

    private static List<EUR_CRM_Stock_Item__c> selectStockItems() {
        return [
            SELECT Id
                , EUR_CRM_Stock__c
                , EUR_Price_Book_Item__c
                , RecordType.DeveloperName
            FROM EUR_CRM_Stock_Item__c
        ];
    }

}