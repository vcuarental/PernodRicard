public with sharing class EUR_CRM_SalesOrderToStockItemHandler {

    // SO, soSomething - Sales Order, Sales Order Something
    // PC, pcSomething - Product Catalog, Product Catalog Something

    private static final String SO_STATUS_TO_UPDATE_STOCK = 'Finished';
    private final Map<String, String> STOCK_TRANSACTION_TYPE_BY_SO_RT = new Map<String, String> {
        'EUR_Free_Goods_to_Stock' => 'Credit'
    ,   'EUR_Free_Goods_from_Stock' => 'Debit'
    };
    private static List<EUR_CRM_Stock_Transaction__c> stockTransactionsToInsert = new List<EUR_CRM_Stock_Transaction__c>();


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void onAfterUpdate(List<EUR_CRM_Sales_Order__c> sos, Map<Id, EUR_CRM_Sales_Order__c> oldSOsById) {
        System.debug('\n sos => ' + JSON.serializePretty(sos) + '\n');
        List<EUR_CRM_Sales_Order__c> sosWithChangedStatus = this.getSOsWithChangedStatus(sos,oldSOsById);
        System.debug('\n sosWithChangedStatus.size() => ' + sosWithChangedStatus.size() + '\n');
        System.debug('\n sosWithChangedStatus => ' + JSON.serializePretty(sosWithChangedStatus) + '\n');

        if (sosWithChangedStatus.isEmpty()) { return; }

        Map<Id, EUR_CRM_Sales_Order_Items__c> soItemById = this.selectSOitemsWhereSOids(sosWithChangedStatus);
        System.debug('\n soItemsToCreateTransactions.size() => ' + soItemById.size() + '\n');

        if (soItemById.isEmpty()) { return; }

        Map<Id,EUR_CRM_Sales_Order_Items__c> soItemToCreateTransactionById = new Map<Id,EUR_CRM_Sales_Order_Items__c>();
        Map<Id,EUR_CRM_Sales_Order_Items__c> soItemToUpdateTransactionById = new Map<Id,EUR_CRM_Sales_Order_Items__c>();
        for (EUR_CRM_Sales_Order_Items__c soItem : soItemById.values()) {
            if (soItem.Stock_Transactions_EU__r.isEmpty()) {
                soItemToCreateTransactionById.put(soItem.Id, soItem);
            } else {
                soItemToUpdateTransactionById.put(soItem.Id, soItem);
            }

        }
        System.debug('\n soItemToCreateTransactionById.size() => ' + soItemToCreateTransactionById.size() + '\n');

        this.updateStock(soItemToCreateTransactionById);
        System.debug('\n stockTransactionsToInsert.size() => ' + stockTransactionsToInsert.size() + '\n');
        insert stockTransactionsToInsert;

        System.debug('\n soItemToUpdateTransactionById.size() => ' + soItemToUpdateTransactionById.size() + '\n');
        if (soItemToUpdateTransactionById.isEmpty()) { return; }
        List<EUR_CRM_Stock_Transaction__c> stockTransactionsToUpdate = this.updateStockTransaction(soItemToUpdateTransactionById);
        System.debug('\n stockTransactionsToUpdate.size() => ' + stockTransactionsToUpdate.size() + '\n');
        update stockTransactionsToUpdate;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void updateStock(Map<Id, EUR_CRM_Sales_Order_Items__c> soItemToCreateTransactionById) {
        List<EUR_CRM_ProductCatalogItem__c> pcItems = this.selectPCItemWhereSOitems(soItemToCreateTransactionById.values());
        System.debug('\n pcItems.size() => ' + pcItems.size() + '\n');
        Map<Id, EUR_CRM_Stock_Item__c> stockItemByPCitemId = this.extractStockItemFromPCitem(pcItems, soItemToCreateTransactionById);
        System.debug('\n stockItemByPCitemId.size() => ' + stockItemByPCitemId.size() + '\n');

        List<SOitemWrapper> soItemWrappers = new List<SOitemWrapper>();
        for (EUR_CRM_ProductCatalogItem__c pcItem : pcItems) {
            if (!pcItem.Sales_Order_Item_EU__r.isEmpty()) {
                for (EUR_CRM_Sales_Order_Items__c soItem : pcItem.Sales_Order_Item_EU__r) {
                    if ( ! soItemToCreateTransactionById.containsKey(soItem.Id)) { continue; }
                    if (stockItemByPCitemId.containsKey(pcItem.Id)) {
                        stockTransactionsToInsert.add(this.makeTransaction(soItem, stockItemByPCitemId.get(pcItem.Id).Id));
                    } else {
                        soItemWrappers.add(new SOitemWrapper(soItem));
                    }
                }
            }
        }
        System.debug('\n soItemWrappers.size() => ' + soItemWrappers.size() + '\n');
        if (soItemWrappers.isEmpty()) { return; }

        Map<Id, EUR_CRM_Stock_Item__c> stockItemByPCitemIdToInsert = this.makeStockItemByPCitemToInsert(soItemWrappers);
        System.debug('\n stockItemByPCitemIdToInsert.size() => ' + stockItemByPCitemIdToInsert.size() + '\n');
        if (stockItemByPCitemIdToInsert.isEmpty()) { return; }

        insert stockItemByPCitemIdToInsert.values();

        stockTransactionsToInsert.addAll(this.makeTransactionsToInsert(soItemWrappers, stockItemByPCitemIdToInsert));
    }

    private List<EUR_CRM_Stock_Transaction__c> updateStockTransaction(Map<Id,EUR_CRM_Sales_Order_Items__c> soItemToUpdateTransactionById) {
        List<EUR_CRM_Stock_Transaction__c> stockTransactionsToUpdate = new List<EUR_CRM_Stock_Transaction__c>();
        for (EUR_CRM_Sales_Order_Items__c soItem : soItemToUpdateTransactionById.values()) {
            String stockTransType = this.getStockTransactionType(soItem);
            Decimal stockTransQuantity = this.getStockTransactionQuantity(soItem, stockTransType);
            EUR_CRM_Stock_Transaction__c stockTransactionToUpdate = soItem.Stock_Transactions_EU__r[0];
            stockTransactionToUpdate.EUR_CRM_Transaction_Type__c = stockTransType;
            stockTransactionToUpdate.EUR_CRM_Quantity__c = stockTransQuantity;
            stockTransactionsToUpdate.add(stockTransactionToUpdate);
        }
        return stockTransactionsToUpdate;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, EUR_CRM_Stock_Item__c> makeStockItemByPCitemToInsert(List<SOitemWrapper> soItemWrappers) {
        Set<Id> stockOwnerIds = this.extractSOcreatorIds(soItemWrappers);
        System.debug('\n stockOwnerIds.size() => ' + stockOwnerIds.size() + '\n');
        List<EUR_CRM_Stock__c> stocksToInsertStockItems = this.selectStockWhereOwnerId(stockOwnerIds);
        System.debug('\n stocksToInsertStockItems.size() => ' + stocksToInsertStockItems.size() + '\n');

        if (stocksToInsertStockItems.isEmpty()) { return new Map<Id, EUR_CRM_Stock_Item__c>(); }

        return this.makeStockItemByPCItemToInsert(stocksToInsertStockItems, soItemWrappers);
    }

    private Map<Id, EUR_CRM_Stock_Item__c> makeStockItemByPCItemToInsert(List<EUR_CRM_Stock__c> stocksToInsertStockItems, List<SOitemWrapper> soItemWrappers) {
        Map<Id, EUR_CRM_Stock_Item__c> stockItemByPCitemIdToInsert = new Map<Id, EUR_CRM_Stock_Item__c>();
        for (EUR_CRM_Stock__c stock : stocksToInsertStockItems) {
            for (SOitemWrapper soiWrap : soItemWrappers) {
                if (stock.OwnerId == soiWrap.soCreatorId) {
                    if (!stockItemByPCitemIdToInsert.containsKey(soiWrap.pcItemId)) {
                        stockItemByPCitemIdToInsert.put(soiWrap.pcItemId, this.makeStockItem(stock, soiWrap.pcItemId));
                    }
                }
            }
        }
        return stockItemByPCitemIdToInsert;
    }

    private List<EUR_CRM_Stock_Transaction__c> makeTransactionsToInsert(List<SOitemWrapper> soItemWrappers, Map<Id, EUR_CRM_Stock_Item__c> stockItemByPCitemIdToInsert) {
        List<EUR_CRM_Stock_Transaction__c> stockTransactionsToInsertAfterStockItemsInsert = new List<EUR_CRM_Stock_Transaction__c>();
        for (SOitemWrapper soiWrap : soItemWrappers) {
            if (stockItemByPCitemIdToInsert.containsKey(soiWrap.pcItemId)) {
                stockTransactionsToInsertAfterStockItemsInsert.add(
                    this.makeTransaction(soiWrap.soItem, stockItemByPCitemIdToInsert.get(soiWrap.pcItemId).Id)
                );
            }
        }
        return stockTransactionsToInsertAfterStockItemsInsert;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Sales_Order__c> getSOsWithChangedStatus(List<EUR_CRM_Sales_Order__c> sos, Map<Id, EUR_CRM_Sales_Order__c> oldSOsById) {
        List<EUR_CRM_Sales_Order__c> sosForStockUpdate = new List<EUR_CRM_Sales_Order__c>();
        for (EUR_CRM_Sales_Order__c so : sos) {
            if (this.isStatusChanged(so, oldSOsById) && this.isStatusFinished(so)) {
                sosForStockUpdate.add(so);
            }
        }
        return sosForStockUpdate;
    }

     private Map<Id, EUR_CRM_Stock_Item__c> extractStockItemFromPCitem(List<EUR_CRM_ProductCatalogItem__c> pcItems, Map<Id, EUR_CRM_Sales_Order_Items__c> soItemToCreateTransactionById) {
        Map<Id, EUR_CRM_Stock_Item__c> stockItemByPCitemId = new Map<Id, EUR_CRM_Stock_Item__c>();
        for (EUR_CRM_ProductCatalogItem__c pcItem : pcItems) {
            for (EUR_CRM_Stock_Item__c stockItem : pcItem.Stock_Items_EU__r) {
                for (EUR_CRM_Sales_Order_Items__c soItem : soItemToCreateTransactionById.values()) {
                    if (stockItem.EUR_CRM_Stock__r.OwnerId != soItem.EUR_CRM_Sales_Order__r.CreatedById) { continue; }
                    stockItemByPCitemId.put(pcItem.Id, stockItem);
                }
            }
        }
        return stockItemByPCitemId;
    }

    private Set<Id> extractSOcreatorIds(List<SOitemWrapper> soItemWrappers) {
        Set<Id> stockOwnerIds = new Set<Id>();
        for (SOitemWrapper soiWrap : soItemWrappers) {
            stockOwnerIds.add(soiWrap.soCreatorId);
        }
        return stockOwnerIds;
    }

    private String getStockTransactionType(EUR_CRM_Sales_Order_Items__c soItem) {
        if ( ! STOCK_TRANSACTION_TYPE_BY_SO_RT.containsKey(soItem.EUR_CRM_Sales_Order__r.RecordType.DeveloperName)) {
            return '';
        }
        return STOCK_TRANSACTION_TYPE_BY_SO_RT.get(soItem.EUR_CRM_Sales_Order__r.RecordType.DeveloperName);

    }

    private Decimal getStockTransactionQuantity(EUR_CRM_Sales_Order_Items__c soItem, String type) {
        Decimal soItemQuantity = soItem.EUR_CRM_Quantity__c == null ? 0 : soItem.EUR_CRM_Quantity__c;
        Decimal stockTransQuantity = 0;
        if (type.equalsIgnoreCase('Credit')) { stockTransQuantity = soItemQuantity; }
        if (type.equalsIgnoreCase('Debit')) { stockTransQuantity = -soItemQuantity; }
        return stockTransQuantity;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isStatusChanged(EUR_CRM_Sales_Order__c so, Map<Id, EUR_CRM_Sales_Order__c> oldSOsById) {
        return so.EUR_CRM_Status__c != oldSOsById.get(so.Id).EUR_CRM_Status__c;
    }

    private Boolean isStatusFinished(EUR_CRM_Sales_Order__c so) {
        return so.EUR_CRM_Status__c == SO_STATUS_TO_UPDATE_STOCK;
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private EUR_CRM_Stock_Transaction__c makeTransaction(EUR_CRM_Sales_Order_Items__c soItem, Id stockItemId) {
        String stockTransType = this.getStockTransactionType(soItem);
        Decimal stockTransQuantity = this.getStockTransactionQuantity(soItem, stockTransType);
//        String type = STOCK_TRANSACTION_TYPE_BY_SO_RT.get(soItem.EUR_CRM_Sales_Order__r.RecordType.DeveloperName);
//        soItem.EUR_CRM_Quantity__c = soItem.EUR_CRM_Quantity__c == null? 0 : soItem.EUR_CRM_Quantity__c;
//        Decimal quantity = type == 'Credit' ? soItem.EUR_CRM_Quantity__c : (-soItem.EUR_CRM_Quantity__c);

        return new EUR_CRM_Stock_Transaction__c(
            EUR_CRM_Stock_Item__c = stockItemId
        ,   EUR_CRM_Sales_Order_Item__c = soItem.Id
        ,   EUR_CRM_Quantity__c = stockTransQuantity
        ,   EUR_CRM_Transaction_Type__c = stockTransType
        );
    }

    private EUR_CRM_Stock_Item__c makeStockItem(EUR_CRM_Stock__c stock, Id pcId) {
        Id rtId = null;
        String rtdevName = 'EUR_' + stock.EUR_CRM_Country_Code__c + '_Stock_Item';
        if(Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().containsKey(rtdevName)) {
            rtId = Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().get(rtdevName).getRecordTypeId();
        }
        return new EUR_CRM_Stock_Item__c(
            EUR_CRM_Stock__c = stock.Id
        ,   EUR_Price_Book_Item__c = pcId
        ,   RecordTypeId = rtId
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private Map<Id, EUR_CRM_Sales_Order_Items__c> selectSOitemsWhereSOids(List<EUR_CRM_Sales_Order__c> sos) {
        return new Map<Id, EUR_CRM_Sales_Order_Items__c>([
            SELECT Id
                , EUR_CRM_Sales_Order__c
                , EUR_CRM_Sales_Order__r.CreatedById
                , EUR_CRM_Sales_Order__r.RecordType.DeveloperName
                , EUR_CRM_PriceBookEntryID__c
                , EUR_CRM_Stock_Item__c
                , EUR_CRM_Quantity__c
                , RecordType.DeveloperName
                , (
                    SELECT
                        Id
                        , EUR_CRM_Sales_Order_Item__c
                        , EUR_CRM_Quantity__c
                        , EUR_CRM_Transaction_Type__c
                    FROM Stock_Transactions_EU__r
                )
            FROM EUR_CRM_Sales_Order_Items__c
            WHERE EUR_CRM_Sales_Order__c IN :sos
                AND EUR_CRM_Sales_Order__r.RecordType.DeveloperName IN :STOCK_TRANSACTION_TYPE_BY_SO_RT.keySet()
                AND EUR_CRM_PriceBookEntryID__c != null
        ]);
    }

    private List<EUR_CRM_Stock__c> selectStockWhereOwnerId(Set<Id> ownerIds) {
        return [
            SELECT Id
                , OwnerId
                , EUR_CRM_Country_Code__c
            FROM EUR_CRM_Stock__c
            WHERE OwnerId IN:ownerIds
        ];
    }

    private List<EUR_CRM_ProductCatalogItem__c> selectPCItemWhereSOitems(List<EUR_CRM_Sales_Order_Items__c> soItems) {
        return [
            SELECT Id, (
                SELECT
                    Id
                    , EUR_CRM_Sales_Order__r.CreatedById
                    , EUR_CRM_Sales_Order__r.RecordType.DeveloperName
                    , EUR_CRM_PriceBookEntryID__c
                    , EUR_CRM_Quantity__c
                    , EUR_CRM_Sales_Order__c
                FROM Sales_Order_Item_EU__r
            ), (
                SELECT
                    Id
                    , EUR_CRM_Stock__c
                    , EUR_CRM_Stock__r.OwnerId
                    , EUR_Price_Book_Item__c
                FROM Stock_Items_EU__r
            )
            FROM EUR_CRM_ProductCatalogItem__c
            WHERE Id IN (
                SELECT EUR_CRM_PriceBookEntryID__c
                FROM EUR_CRM_Sales_Order_Items__c
                WHERE Id IN :soItems
            )
        ];
    }

    /* ========================================================= */
    /*     Wrappers
    /* ========================================================= */
    private class SOitemWrapper {
        private Id soCreatorId;
        private Id pcItemId;
        private EUR_CRM_Sales_Order_Items__c soItem;
        private Decimal quantity;

        private SOitemWrapper(EUR_CRM_Sales_Order_Items__c soItem) {
            this.soCreatorId = soItem.EUR_CRM_Sales_Order__r.CreatedById;
            this.pcItemId = soItem.EUR_CRM_PriceBookEntryID__c;
            this.soItem = soItem;
            this.quantity = soItem.EUR_CRM_Quantity__c;
        }

    }

}