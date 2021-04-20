/*************************************************
* Creates Stock line items and corrosponding Transactions from the Sales Order Line Item
* Called Before Update
************************************************/

public with sharing class EUR_CRM_StockUpdateFromSO extends EUR_CRM_TriggerAbstract {

    Set<String> validRTSet = EUR_CRM_RecordTypeHelper.StockUpdate_validRecordTypes;
    Map<Id, Recordtype> salesOrderRTMap = new Map<Id, Recordtype>();
    Map<Id, EUR_CRM_Sales_Order__c> salesOrdersMap = new Map<Id, EUR_CRM_Sales_Order__c>();


    List<EUR_CRM_Sales_Order__c> salesOrdersList = new List<EUR_CRM_Sales_Order__c>();

    List<EUR_CRM_Sales_Order_Items__c> soItemsToUpdate = new List<EUR_CRM_Sales_Order_Items__c>();
    List<EUR_CRM_Stock_Item__c> stockItemsToUpdate = new List<EUR_CRM_Stock_Item__c>();
    List<EUR_CRM_Stock_Transaction__c> transactionsToUpdate = new List<EUR_CRM_Stock_Transaction__c>();

    public EUR_CRM_StockUpdateFromSO() {
        super('EUR_CRM_StockUpdateFromSO');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {

        // Cast the list to SO type
        List<EUR_CRM_Sales_Order__c> salesOrdersListFromTrigger = (List<EUR_CRM_Sales_Order__c>) sObjList;
        List<Recordtype> salesOrderRT = Global_RecordTypeCache.getRtList('EUR_CRM_Sales_Order__c');

        for (Recordtype rt : salesOrderRT) {
            salesOrderRTMap.put(rt.Id, rt);
        }

        for (EUR_CRM_Sales_Order__c so : salesOrdersListFromTrigger) {
            String currentRecordType = salesOrderRTMap.get(so.recordtypeId).developerName;
            if (validRTSet.contains(currentRecordType)) {
                salesOrdersMap.put(so.Id, so);
            }
        }

        if (salesOrdersMap.size() > 0) {
            salesOrdersList = [
                    SELECT Id, Recordtype.developerName, EUR_CRM_Order_Status__c, EUR_CRM_Account__r.OwnerId, EUR_CRM_Account__c,
                            (SELECT Id, EUR_CRM_SKU__c, EUR_CRM_Quantity__c, EUR_CRM_Stock_Item__c FROM Sales_Order_Items__r)
                    FROM EUR_CRM_Sales_Order__c
                    WHERE Id
                            IN :salesOrdersMap.KeySet()
            ];
            List<Id> soOwners = new List<Id>();
            for (EUR_CRM_Sales_Order__c so : salesOrdersList) {
                soOwners.add(so.EUR_CRM_Account__r.OwnerId);
            }

            Map<Id, List<EUR_CRM_Stock_Item__c>> ownerStockItemListMap = new Map<Id, List<EUR_CRM_Stock_Item__c>>();
            Map<Id, EUR_CRM_Stock__c> ownerStockMap = new Map<Id, EUR_CRM_Stock__c>();
            for (EUR_CRM_Stock__c stock : [SELECT Id, OwnerId, EUR_CRM_Country_Code__c, (SELECT Id, EUR_CRM_SKU__c FROM Stock_Items__r) FROM EUR_CRM_Stock__c WHERE OwnerId IN :soOwners]) {
                ownerStockItemListMap.put(stock.ownerId, stock.Stock_Items__r);
                ownerStockMap.put(stock.ownerId, stock);
            }
//            System.debug('### ownerStockItemListMap:'+ownerStockItemListMap);
            //System.debug(salesOrdersList);
            Map<Id, EUR_CRM_Stock_Item__c> newSIMap = new Map<Id, EUR_CRM_Stock_Item__c>();
            for (EUR_CRM_Sales_Order__c so : salesOrdersList) {
                if (so.Recordtype.developerName.contains('_from_SR_Stock') && (so.EUR_CRM_Order_Status__c == 'Finished'
                        || (salesOrdersMap.get(so.Id).EUR_CRM_Order_Status__c == 'Finished')
                )) {
                    Set<Id> stockLISKUSet = new Set<Id>();
                    Map<Id, EUR_CRM_Stock_Item__c> stockLISKUMap = new Map<Id, EUR_CRM_Stock_Item__c>(); // Key is SKU Id
                    if (so.EUR_CRM_Account__c != null && so.EUR_CRM_Account__r.OwnerId != null && !ownerStockItemListMap.isEmpty()) {
                        for (EUR_CRM_Stock_Item__c si : ownerStockItemListMap.get(so.EUR_CRM_Account__r.OwnerId)) {
                            stockLISKUSet.add(si.EUR_CRM_SKU__c);
                            stockLISKUMap.put(si.EUR_CRM_SKU__c, si);
                        }
                    }
                    for (EUR_CRM_Sales_Order_Items__c li : so.Sales_Order_Items__r) {
                        if (!stockLISKUSet.contains(li.EUR_CRM_SKU__c) && ownerStockMap.containsKey(so.EUR_CRM_Account__r.OwnerId)) {
                            //System.debug('doesnt exist');
                            //System.debug(li.EUR_CRM_SKU__c);
                            Id rtId = null;
                            String rtdevName = 'EUR_' + ownerStockMap.get(so.EUR_CRM_Account__r.OwnerId).EUR_CRM_Country_Code__c + '_Stock_Item';
                            if(Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().containsKey(rtdevName)) {
                                rtId = Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().get(rtdevName).getRecordTypeId();
                            }
                            EUR_CRM_Stock_Item__c newSI = new EUR_CRM_Stock_Item__c(EUR_CRM_Stock__c = ownerStockMap.get(so.EUR_CRM_Account__r.OwnerId).Id,
                                    EUR_CRM_SKU__c = li.EUR_CRM_SKU__c, RecordTypeId = rtId);
                            newSIMap.put(li.Id, newSI);
                            stockItemsToUpdate.add(newSI);
                            soItemsToUpdate.add(li);
                        } else {
                            if (!(li.EUR_CRM_Stock_Item__c != null) && stockLISKUMap.containsKey(li.EUR_CRM_SKU__c)) {
                                li.EUR_CRM_Stock_Item__c = stockLISKUMap.get(li.EUR_CRM_SKU__c).Id;
                                soItemsToUpdate.add(li);
                            } else {
                                //System.debug('Already exists - do nothing');
                                continue;
                            }
                        }
                    }
                }
            }
            if (stockItemsToUpdate.size() > 0) {
                EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', stockItemsToUpdate);
            }
            for (EUR_CRM_Sales_Order_Items__c li : soItemsToUpdate) {
                if (newSIMap.size() > 0 && newSIMap.get(li.Id) != null) {
                    li.EUR_CRM_Stock_Item__c = newSIMap.get(li.Id).Id;
                }
                EUR_CRM_Stock_Transaction__c newTransaction = new EUR_CRM_Stock_Transaction__c(EUR_CRM_Stock_Item__c = li.EUR_CRM_Stock_Item__c,
                        EUR_CRM_Quantity__c = (0 - li.EUR_CRM_Quantity__c),
                        EUR_CRM_Transaction_Type__c = 'Debit',
                        EUR_CRM_Sales_Order_Item__c = li.Id);
                transactionsToUpdate.add(newTransaction);
            }
            if (soItemsToUpdate.size() > 0) {
                EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', soItemsToUpdate);
            }
            if (transactionsToUpdate.size() > 0) {
                EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', transactionsToUpdate);
            }
        }
    }
}