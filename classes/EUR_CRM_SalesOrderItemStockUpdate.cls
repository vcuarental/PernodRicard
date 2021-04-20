public with sharing class EUR_CRM_SalesOrderItemStockUpdate {

    // SO, soSomething - Sales Order, Sales Order Something
//    private final Map<String, String> STOCK_TRANSACTION_TYPE_BY_SO_RT = new Map<String, String> {
//        'EUR_Free_Goods_from_Stock' => 'Debit',
//        'EUR_Free_Goods_to_Stock' => 'Credit'
//    };
//
//    private final String SO_STATUS_TO_UPDATE_STOCK = 'Instant validation';
//
//    private final String STOCK_ITEM_RECORD_TYPE_TEMPLATE = 'EUR_{0}_Stock_Item';
//    private final String STOCK_TRANSACTION_RECORD_TYPE_TEMPLATE = 'EUR_{0}_Stock_Transaction';
//
//    private Map<String, RecordTypeInfo> stockItemRecordTypeInfoByDevName;
//    private Map<String, RecordTypeInfo> stockTransactionRecordTypeInfoByDevName;

    @TestVisible
    private static String forTest() {
        return '';
    }

    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
//    public void onBeforeInsert(List<EUR_CRM_Sales_Order_Items__c> soItems) {
//        Map<Id, List<EUR_CRM_Sales_Order_Items__c>> soItemsWithoutStockItemBySOid = this.getSOItemsWithoutStockItemBySOid(soItems);
//        System.debug('\n\n soItemsWithoutStockItemBySOid.size() => ' + JSON.serializePretty(soItemsWithoutStockItemBySOid.size()) + '\n');
//        System.debug('\n\n soItemsWithoutStockItemBySOid => ' + JSON.serializePretty(soItemsWithoutStockItemBySOid) + '\n');
//        if (soItemsWithoutStockItemBySOid.isEmpty()) { return; }
//
//        List<EUR_CRM_Sales_Order__c> sos = this.selectSOsWhereIds(soItemsWithoutStockItemBySOid.keySet());
//        System.debug('\n\n sos.size() => ' + JSON.serializePretty(sos.size()) + '\n');
//        System.debug('\n\n sos => ' + JSON.serializePretty(sos) + '\n');
//        if (sos.isEmpty()) { return; }
//
//        Map<Id, List<EUR_CRM_Sales_Order_Items__c>> soItemsWithoutStockItemBySOcreatorId = this.getSOItemsWithoutStockItemBySOcreatorId(sos, soItemsWithoutStockItemBySOid);
//        System.debug('\n\n soItemsWithoutStockItemBySOcreatorId.size() => ' + JSON.serializePretty(soItemsWithoutStockItemBySOcreatorId.size()) + '\n');
//        System.debug('\n\n soItemsWithoutStockItemBySOcreatorId => ' + JSON.serializePretty(soItemsWithoutStockItemBySOcreatorId) + '\n');
//        List<EUR_CRM_Stock__c> stocks = this.selectStocksWhereOwnerIds(soItemsWithoutStockItemBySOcreatorId.keySet());
//        if (stocks.isEmpty()) { return; }
//
//        List<EUR_CRM_Stock_Item__c> stockItemsToInsert = this.makeStockItems(stocks, soItemsWithoutStockItemBySOcreatorId);
//        System.debug('\n\n stockItemsToInsert.size() => ' + JSON.serializePretty(stockItemsToInsert.size()) + '\n');
//        System.debug('\n\n stockItemsToInsert => ' + JSON.serializePretty(stockItemsToInsert) + '\n');
//        insert stockItemsToInsert;
//
//        this.assignPriceBookAndStockItemToSOItemForUpdate(soItemsWithoutStockItemBySOcreatorId, stockItemsToInsert);
//    }
//
//    public void onAfterInsert(List<EUR_CRM_Sales_Order_Items__c> soItems) {
//        List<EUR_CRM_Sales_Order_Items__c> soItemsWithRelatives = this.selectSOitemsWhereIds(soItems);
//        System.debug('\n\n soItemsWithRelatives.size() => ' + JSON.serializePretty(soItemsWithRelatives.size()) + '\n');
//        System.debug('\n\n soItemsWithRelatives => ' + JSON.serializePretty(soItemsWithRelatives) + '\n');
//        if (soItemsWithRelatives.isEmpty()) { return; }
//
//        List<EUR_CRM_Stock_Transaction__c> stockTransactionsToInsert = this.makeStockTransactions(soItemsWithRelatives);
//        System.debug('\n\n stockTransactionsToInsert.size() => ' + JSON.serializePretty(stockTransactionsToInsert.size()) + '\n');
//        System.debug('\n\n stockTransactionsToInsert => ' + JSON.serializePretty(stockTransactionsToInsert) + '\n');
//        if ( ! stockTransactionsToInsert.isEmpty()) {
//            insert stockTransactionsToInsert;
//        }
//    }
//
//    public void onAfterUpdate(List<EUR_CRM_Sales_Order_Items__c> soItems, Map<Id, EUR_CRM_Sales_Order_Items__c> oldSOItemById) {
//        List<EUR_CRM_Sales_Order_Items__c> soItemsWithChangedQuantity = this.getSOitemsWithQuantityChanged(soItems, oldSOItemById);
//        System.debug('\n\n soItemsWithChangedQuantity.size() => ' + JSON.serializePretty(soItemsWithChangedQuantity.size()) + '\n');
//        System.debug('\n\n soItemsWithChangedQuantity => ' + JSON.serializePretty(soItemsWithChangedQuantity) + '\n');
//        if (soItemsWithChangedQuantity.isEmpty()) { return; }
//
//        List<EUR_CRM_Sales_Order_Items__c> soItemsWithRelatives = this.selectSOitemsWhereIds(soItems);
//        System.debug('\n\n soItemsWithRelatives.size() => ' + JSON.serializePretty(soItemsWithRelatives.size()) + '\n');
//        System.debug('\n\n soItemsWithRelatives => ' + JSON.serializePretty(soItemsWithRelatives) + '\n');
//        if (soItemsWithRelatives.isEmpty()) { return; }
//
//        Map<EUR_CRM_Sales_Order_Items__c, EUR_CRM_Stock_Transaction__c> stockTransactionBySOitem = this.getSOitemByStockTransaction(soItemsWithRelatives);
//        System.debug('\n\n stockTransactionBySOitem.size() => ' + JSON.serializePretty(stockTransactionBySOitem.size()) + '\n');
//        System.debug('\n\n stockTransactionBySOitem => ' + JSON.serializePretty(stockTransactionBySOitem) + '\n');
//        if (stockTransactionBySOitem.isEmpty()) { return ; }
//
//        List<EUR_CRM_Stock_Transaction__c> stockTransactionsToUpdate = this.assignQuantityToStockTransaction(stockTransactionBySOitem);
//        System.debug('\n\n stockTransactionsToUpdate.size() => ' + JSON.serializePretty(stockTransactionsToUpdate.size()) + '\n');
//        System.debug('\n\n stockTransactionsToUpdate => ' + JSON.serializePretty(stockTransactionsToUpdate) + '\n');
//        update stockTransactionsToUpdate;
//    }
//
//    public void onBeforeDelete(List<EUR_CRM_Sales_Order_Items__c> oldSOItems) {
//        List<EUR_CRM_Sales_Order_Items__c> soItemsWithRelatives = this.selectSOitemsWhereIds(oldSOItems);
//        System.debug('\n\n soItemsWithRelatives.size() => ' + JSON.serializePretty(soItemsWithRelatives.size()) + '\n');
//        System.debug('\n\n soItemsWithRelatives => ' + JSON.serializePretty(soItemsWithRelatives) + '\n');
//        if (soItemsWithRelatives.isEmpty()) { return; }
//
//        Map<EUR_CRM_Sales_Order_Items__c, EUR_CRM_Stock_Transaction__c> stockTransactionBySOitem = this.getSOitemByStockTransaction(soItemsWithRelatives);
//        System.debug('\n stockTransactionBySOitem => ' + JSON.serializePretty(stockTransactionBySOitem) + '\n');
//        if (stockTransactionBySOitem.isEmpty()) { return ; }
//
//        delete stockTransactionBySOitem.values();
//    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
//    private Map<Id, List<EUR_CRM_Sales_Order_Items__c>> getSOItemsWithoutStockItemBySOid(List<EUR_CRM_Sales_Order_Items__c> soItems) {
//        Map<Id, List<EUR_CRM_Sales_Order_Items__c>> soItemsWithoutStockItemBySOid = new Map<Id, List<EUR_CRM_Sales_Order_Items__c>>();
//        for (EUR_CRM_Sales_Order_Items__c soItem : soItems) {
//            if ( ! this.hasStockItem(soItem) && this.hasPriceBookItem(soItem)) {
//                if (soItemsWithoutStockItemBySOid.containsKey(soItem.EUR_CRM_Sales_Order__c)) {
//                    soItemsWithoutStockItemBySOid.get(soItem.EUR_CRM_Sales_Order__c).add(soItem);
//                } else {
//                    soItemsWithoutStockItemBySOid.put(soItem.EUR_CRM_Sales_Order__c, new List<EUR_CRM_Sales_Order_Items__c> { soItem });
//                }
//            }
//        }
//        return soItemsWithoutStockItemBySOid;
//    }
//
//    private Map<Id, List<EUR_CRM_Sales_Order_Items__c>> getSOItemsWithoutStockItemBySOcreatorId(List<EUR_CRM_Sales_Order__c> sos, Map<Id, List<EUR_CRM_Sales_Order_Items__c>> soItemsWithoutStockItemBySOid) {
//        Map<Id, List<EUR_CRM_Sales_Order_Items__c>> soItemsWithoutStockItemBySOcreatorId = new Map<Id, List<EUR_CRM_Sales_Order_Items__c>>();
//        for (EUR_CRM_Sales_Order__c so : sos) {
//            if (soItemsWithoutStockItemBySOcreatorId.containsKey(so.CreatedById)) {
//                soItemsWithoutStockItemBySOcreatorId.get(so.CreatedById).addAll(soItemsWithoutStockItemBySOid.get(so.Id));
//            } else {
//                soItemsWithoutStockItemBySOcreatorId.put(so.CreatedById, soItemsWithoutStockItemBySOid.get(so.Id));
//            }
//        }
//        return soItemsWithoutStockItemBySOcreatorId;
//    }
//
//    private List<EUR_CRM_Sales_Order_Items__c> getSOitemsWithQuantityChanged(List<EUR_CRM_Sales_Order_Items__c> soItems, Map<Id,EUR_CRM_Sales_Order_Items__c> oldSOItemById) {
//        List<EUR_CRM_Sales_Order_Items__c> soItemsWithChangedQuantity = new List<EUR_CRM_Sales_Order_Items__c>();
//        for (EUR_CRM_Sales_Order_Items__c soItem : soItems) {
//            if (this.isQuantityChanged(soItem, oldSOItemById.get(soItem.Id))) {
//                soItemsWithChangedQuantity.add(soItem);
//            }
//        }
//        return soItemsWithChangedQuantity;
//    }
//
//    @TestVisible
//    private Map<EUR_CRM_Sales_Order_Items__c, EUR_CRM_Stock_Transaction__c> getSOitemByStockTransaction(List<EUR_CRM_Sales_Order_Items__c> soItems) {
//        Map<EUR_CRM_Sales_Order_Items__c, EUR_CRM_Stock_Transaction__c> stockTransactionBySOitem = new Map<EUR_CRM_Sales_Order_Items__c, EUR_CRM_Stock_Transaction__c>();
//        for (EUR_CRM_Sales_Order_Items__c soItem : soItems) {
//            if (this.hasStockTransactions(soItem)) {
//                stockTransactionBySOitem.put(soItem, soItem.Stock_Transactions_EU__r[0]);
//            }
//        }
//        return stockTransactionBySOitem;
//    }
//
//    private List<EUR_CRM_Stock_Transaction__c> assignQuantityToStockTransaction(Map<EUR_CRM_Sales_Order_Items__c, EUR_CRM_Stock_Transaction__c> stockTransactionBySOitem) {
//        for (EUR_CRM_Sales_Order_Items__c soItem : stockTransactionBySOitem.keySet()) {
//            String transactionType = STOCK_TRANSACTION_TYPE_BY_SO_RT.get(soItem.EUR_CRM_Sales_Order__r.RecordType.DeveloperName);
//            stockTransactionBySOitem.get(soItem).EUR_CRM_Quantity__c = transactionType == 'Credit' ?
//                soItem.EUR_CRM_Quantity__c : (-soItem.EUR_CRM_Quantity__c);
//            stockTransactionBySOitem.get(soItem).EUR_CRM_Transaction_Type__c = transactionType;
//        }
//        return stockTransactionBySOitem.values();
//    }
//
//    private void assignPriceBookAndStockItemToSOItemForUpdate(Map<Id, List<EUR_CRM_Sales_Order_Items__c>> soItemsWithoutStockItemBySOcreatorId, List<EUR_CRM_Stock_Item__c> insertedStockItems) {
//        for (Id soCreatorId : soItemsWithoutStockItemBySOcreatorId.keySet()) {
//            for (EUR_CRM_Sales_Order_Items__c soItem : soItemsWithoutStockItemBySOcreatorId.get(soCreatorId)) {
//                for (EUR_CRM_Stock_Item__c stockItem : insertedStockItems) {
//                    if (soItem.EUR_CRM_PriceBookEntryID__c == stockItem.EUR_Price_Book_Item__c) {
//                        soItem.EUR_CRM_Stock_Item__c = stockItem.Id;
//                    }
//                }
//            }
//        }
//    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
//    private Id getStockItemRecordTypeId(String stockRecTypeDevName) {
//        String stockItemRecTypeDevName = this.buildRecordTypeDevName(STOCK_ITEM_RECORD_TYPE_TEMPLATE, stockRecTypeDevName);
//        RecordTypeInfo stockItemRecTypeInfo = stockItemRecordTypeInfoByDevName.get(stockItemRecTypeDevName);
//        System.debug('\n stockItemRecTypeInfo => ' + stockItemRecTypeInfo + '\n');
//
//        return stockItemRecTypeInfo == null ? null : stockItemRecTypeInfo.getRecordTypeId();
//    }
//
//    private Id getStockTransactionRecordTypeId(String stockItemRecTypeDevName) {
//        String stockTransactionRecTypeDevName = this.buildRecordTypeDevName(STOCK_TRANSACTION_RECORD_TYPE_TEMPLATE, stockItemRecTypeDevName);
//        RecordTypeInfo stockTransactionRecTypeInfo = stockTransactionRecordTypeInfoByDevName.get(stockTransactionRecTypeDevName);
//        System.debug('\n stockTransactionRecTypeInfo => ' + stockTransactionRecTypeInfo + '\n');
//        return stockTransactionRecTypeInfo == null ? null : stockTransactionRecTypeInfo.getRecordTypeId();
//    }
//
//    private String buildRecordTypeDevName(String stringTemplate, String stockRecTypeDevName) {
//        return String.format(stringTemplate, new List<String>{
//            stockRecTypeDevName.substringBetween('EUR_', '_Stock')
//        });
//    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
//    private Boolean hasStockItem(EUR_CRM_Sales_Order_Items__c soItem) {
//        return soItem.EUR_CRM_Stock_Item__c != null;
//    }
//
//    private Boolean hasPriceBookItem(EUR_CRM_Sales_Order_Items__c soItem) {
//        return soItem.EUR_CRM_PriceBookEntryID__c != null;
//    }
//
//    private Boolean isQuantityChanged(EUR_CRM_Sales_Order_Items__c soItem, EUR_CRM_Sales_Order_Items__c oldSOItem) {
//        return soItem.EUR_CRM_Quantity__c != oldSOItem.EUR_CRM_Quantity__c;
//    }
//
//    private Boolean hasStockTransactions(EUR_CRM_Sales_Order_Items__c soItem) {
//        return  ! soItem.Stock_Transactions_EU__r.isEmpty();
//    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
//    private List<EUR_CRM_Stock_Item__c> makeStockItems(List<EUR_CRM_Stock__c> stocks, Map<Id, List<EUR_CRM_Sales_Order_Items__c>> soItemsWithoutStockItemBySOcreatorId) {
//        this.stockItemRecordTypeInfoByDevName = Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName();
//
//        List<EUR_CRM_Stock_Item__c> stockItemsToInsert = new List<EUR_CRM_Stock_Item__c>();
//        for (EUR_CRM_Stock__c stock : stocks) {
//            Id stockItemRecTypeId = this.getStockItemRecordTypeId(stock.RecordType.DeveloperName);
//
//            for (EUR_CRM_Sales_Order_Items__c soItemWithoutStockItem : soItemsWithoutStockItemBySOcreatorId.get(stock.OwnerId)) {
//                stockItemsToInsert.add(this.makeStockItem(stock.Id, stockItemRecTypeId, soItemWithoutStockItem.EUR_CRM_PriceBookEntryID__c));
//            }
//        }
//        return stockItemsToInsert;
//    }
//
//    private List<EUR_CRM_Stock_Transaction__c> makeStockTransactions(List<EUR_CRM_Sales_Order_Items__c> soItems) {
//        this.stockTransactionRecordTypeInfoByDevName = Schema.SObjectType.EUR_CRM_Stock_Transaction__c.getRecordTypeInfosByDeveloperName();
//
//        List<EUR_CRM_Stock_Transaction__c> stockTransactionsToInsert = new List<EUR_CRM_Stock_Transaction__c>();
//        for (EUR_CRM_Sales_Order_Items__c soItem : soItems) {
//            if (soItem.EUR_CRM_Stock_Item__c != null) {
//                Id stockTransactionRecTypeId = this.getStockTransactionRecordTypeId(soItem.EUR_CRM_Stock_Item__r.RecordType.DeveloperName);
//                stockTransactionsToInsert.add(this.makeStockTransaction(stockTransactionRecTypeId, soItem));
//            }
//        }
//        return stockTransactionsToInsert;
//    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
//    private EUR_CRM_Stock_Item__c makeStockItem(Id stockId, Id recordTypeId, Id priceBookItemId) {
//        EUR_CRM_Stock_Item__c newStockItem = new EUR_CRM_Stock_Item__c();
//        if (recordTypeId != null) { newStockItem.RecordTypeId = recordTypeId; }
//        newStockItem.EUR_CRM_Stock__c = stockId;
//        newStockItem.EUR_Price_Book_Item__c = priceBookItemId;
//        return newStockItem;
//    }
//
//    private EUR_CRM_Stock_Transaction__c makeStockTransaction(Id recordTypeId, EUR_CRM_Sales_Order_Items__c soItem) {
//        EUR_CRM_Stock_Transaction__c newStockTransaction = new EUR_CRM_Stock_Transaction__c();
//        String transactionType = STOCK_TRANSACTION_TYPE_BY_SO_RT.get(soItem.EUR_CRM_Sales_Order__r.RecordType.DeveloperName);
//        if (recordTypeId != null) { newStockTransaction.RecordTypeId = recordTypeId; }
//        newStockTransaction.EUR_CRM_Stock_Item__c = soItem.EUR_CRM_Stock_Item__c;
//        newStockTransaction.EUR_CRM_Sales_Order_Item__c = soItem.Id;
//        newStockTransaction.EUR_CRM_Transaction_Type__c = transactionType;
//        newStockTransaction.EUR_CRM_Quantity__c = transactionType == 'Credit'? soItem.EUR_CRM_Quantity__c : (-soItem.EUR_CRM_Quantity__c);
//
//        return newStockTransaction;
//    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
//    @TestVisible
//    private List<EUR_CRM_Sales_Order_Items__c> selectSOitemsWhereIds(List<EUR_CRM_Sales_Order_Items__c> soItems) {
//        return [
//            SELECT Id
//                , RecordTypeId
//                , RecordType.DeveloperName
//                , EUR_CRM_Quantity__c
//                , EUR_CRM_Sales_Order__r.RecordType.DeveloperName
//                , EUR_CRM_Sales_Order__r.CreatedById
//                , EUR_CRM_Sales_Order__r.EUR_CRM_Status__c
//                , EUR_CRM_Stock_Item__c
//                , EUR_CRM_Stock_Item__r.RecordType.DeveloperName
//                , EUR_CRM_PriceBookEntryID__c
//                , (
//                    SELECT Id
//                        , EUR_CRM_Stock_Item__c
//                        , EUR_CRM_Transaction_Type__c
//                        , EUR_CRM_Quantity__c
//                    FROM Stock_Transactions_EU__r
//                    LIMIT 1
//            )
//            FROM EUR_CRM_Sales_Order_Items__c
//            WHERE Id IN :soItems
//                AND EUR_CRM_Sales_Order__r.RecordType.DeveloperName IN :STOCK_TRANSACTION_TYPE_BY_SO_RT.keySet()
//                AND EUR_CRM_Sales_Order__r.EUR_CRM_Status__c = :SO_STATUS_TO_UPDATE_STOCK
//        ];
//    }
//
//    private List<EUR_CRM_Stock__c> selectStocksWhereOwnerIds(Set<Id> ownerIds) {
//        return [
//            SELECT Id
//                , OwnerId
//                , RecordType.DeveloperName
//            FROM EUR_CRM_Stock__c
//            WHERE OwnerId IN :ownerIds
//        ];
//    }
//
//    private List<EUR_CRM_Sales_Order__c> selectSOsWhereIds(Set<Id> soIds) {
//        return [
//            SELECT Id
//                , CreatedById
//                , RecordType.DeveloperName
//                , EUR_CRM_Status__c
//            FROM EUR_CRM_Sales_Order__c
//            WHERE Id IN :soIds
//                AND RecordType.DeveloperName IN :STOCK_TRANSACTION_TYPE_BY_SO_RT.keySet()
//                AND EUR_CRM_Status__c = :SO_STATUS_TO_UPDATE_STOCK
//        ];
//    }

}