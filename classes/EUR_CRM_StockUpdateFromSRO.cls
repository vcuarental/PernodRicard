/*************************************************
* Creates Stock line items and corrosponding Transactions from the SalesRep Order Line Item
* Called Before Update
************************************************/

public with sharing class EUR_CRM_StockUpdateFromSRO extends EUR_CRM_TriggerAbstract{

    Set<String> validRTSet = EUR_CRM_RecordTypeHelper.StockUpdate_validRecordTypes;
    Map<Id, Recordtype> salesRepOrderRTMap = new Map<Id, Recordtype>();
    Map<Id, EUR_CRM_SalesRep_Order__c> salesRepOrdersMap = new Map<Id, EUR_CRM_SalesRep_Order__c>();

    List<EUR_CRM_SalesRep_Order__c> salesRepOrdersList = new List<EUR_CRM_SalesRep_Order__c>();

    List<EUR_CRM_SalesRep_Order_Items__c> sroItemsToUpdate = new List<EUR_CRM_SalesRep_Order_Items__c>();
    List<EUR_CRM_Stock_Item__c> stockItemsToUpdate = new List<EUR_CRM_Stock_Item__c>();
    List<EUR_CRM_Stock_Transaction__c> transactionsToUpdate = new List<EUR_CRM_Stock_Transaction__c>();

    public EUR_CRM_StockUpdateFromSRO(){
        super('EUR_CRM_StockUpdateFromSRO');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){

        // Cast the list to SrO type
        List<EUR_CRM_SalesRep_Order__c> salesRepOrdersListFromTrigger = (List<EUR_CRM_SalesRep_Order__c>) sObjList;
        List<Recordtype> salesRepOrderRT = Global_RecordTypeCache.getRtList('EUR_CRM_SalesRep_Order__c');

        for(Recordtype rt : salesRepOrderRT){
            salesRepOrderRTMap.put(rt.Id, rt);
        }

        for(EUR_CRM_SalesRep_Order__c sro : salesRepOrdersListFromTrigger) {
            String currentRecordType = salesRepOrderRTMap.get(sro.recordtypeId).developerName;
            if(validRTSet.contains(currentRecordType)){
                salesRepOrdersMap.put(sro.Id, sro);
            }
        }

        if(salesRepOrdersMap.size() > 0){
            salesRepOrdersList = [SELECT Id, Recordtype.developerName, EUR_CRM_Order_Status__c, OwnerId, 
                                (SELECT Id, EUR_CRM_SKU__c, EUR_CRM_Quantity__c, EUR_CRM_Stock_Item__c FROM SalesRep_Order_Items__r)
                                FROM EUR_CRM_SalesRep_Order__c 
                                WHERE Id 
                                IN : salesRepOrdersMap.KeySet()];
            List<Id> sroOwners = new List<Id>();
            for(EUR_CRM_SalesRep_Order__c sro : salesRepOrdersList){
                sroOwners.add(sro.OwnerId);
            }

            Map<Id, List<EUR_CRM_Stock_Item__c>> ownerStockItemListMap = new Map<Id, List<EUR_CRM_Stock_Item__c>>();
            Map<Id, EUR_CRM_Stock__c> ownerStockMap = new Map<Id, EUR_CRM_Stock__c>();
            for(EUR_CRM_Stock__c stock : [SELECT Id, OwnerId, EUR_CRM_Country_Code__c, (SELECT Id, EUR_CRM_SKU__c FROM Stock_Items__r) FROM EUR_CRM_Stock__c WHERE OwnerId IN :sroOwners]){
                ownerStockItemListMap.put(stock.ownerId, stock.Stock_Items__r);
                ownerStockMap.put(stock.ownerId, stock);
            }
            System.debug(ownerStockItemListMap);
            System.debug(salesRepOrdersList);
            Map<Id, EUR_CRM_Stock_Item__c> newSIMap = new Map<Id, EUR_CRM_Stock_Item__c>();
            for(EUR_CRM_SalesRep_Order__c sro : salesRepOrdersList){
                if(sro.Recordtype.developerName.contains('_to_SR_Stock') && (sro.EUR_CRM_Order_Status__c == 'Finished' 
                                                                                            || (salesRepOrdersMap.get(sro.Id).EUR_CRM_Order_Status__c=='Finished')
                                                                                            )){
                    Set<Id> stockLISKUSet = new Set<Id>();
                    Map<Id, EUR_CRM_Stock_Item__c> stockLISKUMap = new Map<Id, EUR_CRM_Stock_Item__c>(); // Key is SKU Id
                    for(EUR_CRM_Stock_Item__c si : ownerStockItemListMap.get(sro.OwnerId)){
                        stockLISKUSet.add(si.EUR_CRM_SKU__c);
                        stockLISKUMap.put(si.EUR_CRM_SKU__c, si);
                    }
                    for(EUR_CRM_SalesRep_Order_Items__c li : sro.SalesRep_Order_Items__r){
                        if(!stockLISKUSet.contains(li.EUR_CRM_SKU__c)){
                            System.debug('doesnt exist');
                            System.debug(li.EUR_CRM_SKU__c);
                            Id rtId = null;
                            String rtdevName = 'EUR_' + ownerStockMap.get(sro.OwnerId).EUR_CRM_Country_Code__c + '_Stock_Item';
                            if(Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().containsKey(rtdevName)) {
                                rtId = Schema.SObjectType.EUR_CRM_Stock_Item__c.getRecordTypeInfosByDeveloperName().get(rtdevName).getRecordTypeId();
                            }
                            EUR_CRM_Stock_Item__c newSI = new EUR_CRM_Stock_Item__c(EUR_CRM_Stock__c = ownerStockMap.get(sro.OwnerId).Id,
                                                                                    EUR_CRM_SKU__c = li.EUR_CRM_SKU__c, RecordTypeId = rtId);
                            newSIMap.put(li.Id, newSI);
                            stockItemsToUpdate.add(newSI);
                            sroItemsToUpdate.add(li);
                        }
                        else {
                            if(!(li.EUR_CRM_Stock_Item__c != null)){
                                li.EUR_CRM_Stock_Item__c = stockLISKUMap.get(li.EUR_CRM_SKU__c).Id;
                                sroItemsToUpdate.add(li);
                            }
                            else {
                                System.debug('Already exists - do nothing');
                                continue;
                            }
                        }
                    }
                }
            }
            if(stockItemsToUpdate.size() > 0){
                EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert',stockItemsToUpdate);
            }
            for(EUR_CRM_SalesRep_Order_Items__c li : sroItemsToUpdate){
                if(newSIMap.size() > 0 && newSIMap.get(li.Id) != null){
                    li.EUR_CRM_Stock_Item__c = newSIMap.get(li.Id).Id;
                }
                EUR_CRM_Stock_Transaction__c newTransaction = new EUR_CRM_Stock_Transaction__c(EUR_CRM_Stock_Item__c = li.EUR_CRM_Stock_Item__c,
                                                                                                EUR_CRM_Quantity__c = li.EUR_CRM_Quantity__c,
                                                                                                EUR_CRM_Transaction_Type__c = 'Credit',
                                                                                                EUR_CRM_Sales_Rep_Order_Item__c = li.Id);
                transactionsToUpdate.add(newTransaction);               
            }
            if(sroItemsToUpdate.size() > 0){
                EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', sroItemsToUpdate);
            }
            if(transactionsToUpdate.size() > 0){
                EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', transactionsToUpdate);
            }
        }
    }
}