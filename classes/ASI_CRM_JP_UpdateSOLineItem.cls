/*********************************************************************************
 * Name: ASI_CRM_JP_UpdateSOLineItem
 * Description: Update SO Line Item After SO Header updated
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/05/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_UpdateSOLineItem extends ASI_CRM_JP_TriggerAbstract {
    
    private final static Map<String, Schema.SObjectField> SALES_ORDER_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ITEM_AVAILABILITY_FIELD_MAP  = Schema.SObjectType.ASI_CRM_JP_Item_Availability__c.fields.getMap();
    
    private final static String INACTIVE_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Inactive_Sales_Order';
    
    public ASI_CRM_JP_UpdateSOLineItem() {
        super('ASI_CRM_JP_UpdateSOLineItem');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_CRM_JP_Sales_Order__c> salesOrderList   = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
		Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap;
        
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = filterSalesOrderList(salesOrderList, salesOrderMap);
        
        if(filteredSalesOrderList.size() > 0) {
            Set<Id> salesOrderIdSet = new Set<Id>();
            for(ASI_CRM_JP_Sales_Order__c filteredSalesOrder : filteredSalesOrderList) {
                salesOrderIdSet.add(filteredSalesOrder.Id);
            }

            Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> salesOrderDetailMap = retrieveSalesOrderDetailMap(salesOrderIdSet);
            List<ASI_CRM_JP_Sales_Order_Item__c> updatedSalesOrderDetailList = assignItemAvailabilityToSODetail(filteredSalesOrderList, salesOrderDetailMap);

            if(updatedSalesOrderDetailList.size() > 0) {
            	update updatedSalesOrderDetailList;
            }
        }
    }
    
    private List<ASI_CRM_JP_Sales_Order__c> filterSalesOrderList(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
    	if(salesOrderMap == null || salesOrderMap.size() == 0) {
            return salesOrderList;
        }
        
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order__c>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(salesOrder.ASI_CRM_Branch_Plant__c != salesOrderMap.get(salesOrder.Id).ASI_CRM_Branch_Plant__c &&
               salesOrderMap.get(salesOrder.Id).RecordTypeId != Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + INACTIVE_SALES_ORDER_RECORD_TYPE)) {
                filteredSalesOrderList.add(salesOrder);
            }
        }
        
        return filteredSalesOrderList;
    }
    
    private Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> retrieveSalesOrderDetailMap(Set<Id> salesOrderIdSet) {
        List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderDetailList = retrieveSalesOrderDetailList(salesOrderIdSet);
        Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> salesOrderDetailMap = new Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>>();
        
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderDetail : salesOrderDetailList) {
            List<ASI_CRM_JP_Sales_Order_Item__c> tempSalesOrderDetailList;
            
            if(salesOrderDetailMap.containsKey(salesOrderDetail.ASI_CRM_Sales_Order__c)) {
                tempSalesOrderDetailList = salesOrderDetailMap.get(salesOrderDetail.ASI_CRM_Sales_Order__c);
            } else {
                tempSalesOrderDetailList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
            }
            
            tempSalesOrderDetailList.add(salesOrderDetail);
            salesOrderDetailMap.put(salesOrderDetail.ASI_CRM_Sales_Order__c, tempSalesOrderDetailList);
        }
        
        return salesOrderDetailMap;
    }
    
    private List<ASI_CRM_JP_Sales_Order_Item__c> assignItemAvailabilityToSODetail(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> salesOrderDetailMap) {
        Set<String> branchPlantSet = new Set<String>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            branchPlantSet.add(salesOrder.ASI_CRM_Branch_Plant__c);
        }
        
        Set<Id> skuIdSet = new Set<Id>();
        for(List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderDetailList : salesOrderDetailMap.values()) {
            for(ASI_CRM_JP_Sales_Order_Item__c soDetail : salesOrderDetailList) {
            	skuIdSet.add(soDetail.ASI_CRM_SKU__c);
            }
        }
        
        Map<String, ASI_CRM_JP_Item_Availability__c> itemAvailabilityMap = retrieveItemAvailabilityMap(skuIdSet, branchPlantSet);
        List<ASI_CRM_JP_Sales_Order_Item__c> updatedSalesOrderDetailList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
        
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderDetailList;
            if(salesOrderDetailMap.containsKey(salesOrder.Id)) {
                salesOrderDetailList = salesOrderDetailMap.get(salesOrder.Id);
                
                Boolean isItemAvailabilityNotExist = false;
                for(ASI_CRM_JP_Sales_Order_Item__c soDetail : salesOrderDetailList) {
                    String key = salesOrder.ASI_CRM_Branch_Plant__c + '_' + soDetail.ASI_CRM_SKU__c;
                    if(itemAvailabilityMap.containsKey(key)) {
                        soDetail.ASI_CRM_Sys_Item_Availability_Filter__c = salesOrder.ASI_CRM_Branch_Plant__c;
                        soDetail.ASI_CRM_SKU_Item__c = itemAvailabilityMap.get(key).Id;
                        updatedSalesOrderDetailList.add(soDetail);
                    } else {
                    	isItemAvailabilityNotExist = true;
                    }
                }
                
                if(isItemAvailabilityNotExist) {
            		showError(salesOrder);
                }
            } 
        }
        
        return updatedSalesOrderDetailList;
    }
    
    private void showError(ASI_CRM_JP_Sales_Order__c salesOrder) {
        salesOrder.addError(String.format(Label.ASI_CRM_JP_SO_No_Item_Available_Found, new String[]{salesOrder.ASI_CRM_Branch_Plant__c}));
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_CRM_JP_Sales_Order_Item__c> retrieveSalesOrderDetailList(Set<Id> salesOrderIdSet) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_DETAIL_FIELD_MAP) + 
                       ', ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_MFM_Item_Group__c, ASI_CRM_SKU_Item__r.Name ' + 
                       'FROM ASI_CRM_JP_Sales_Order_Item__c ' + 
                       'Where ASI_CRM_Sales_Order__c in :salesOrderIdSet ' + 
                       'AND ASI_CRM_Status__c != \'980-Cancelled\'';

        return (List<ASI_CRM_JP_Sales_Order_Item__c>) Database.query(query);
    }
    
    private Map<String, ASI_CRM_JP_Item_Availability__c> retrieveItemAvailabilityMap(Set<Id> skuIdSet, Set<String> branchPlantSet) {
        String query = 'SELECT ' + genQueryField(ITEM_AVAILABILITY_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_JP_Item_Availability__c ' + 
                       'Where ASI_SKU__c in :skuIdSet ' + 
                       'AND ASI_Warehouse_Location__c in :branchPlantSet';

        List<ASI_CRM_JP_Item_Availability__c> itemAvailabilityList = (List<ASI_CRM_JP_Item_Availability__c>) Database.query(query);
        
        //Map the item availability by sku id and warehouse location
        Map<String, ASI_CRM_JP_Item_Availability__c> itemAvailabilityMap = new Map<String, ASI_CRM_JP_Item_Availability__c>();
        for(ASI_CRM_JP_Item_Availability__c itemAvailability : itemAvailabilityList) {
            String key = itemAvailability.ASI_Warehouse_Location__c + '_' + itemAvailability.ASI_SKU__c;
            itemAvailabilityMap.put(key, itemAvailability);
        }

        return itemAvailabilityMap;
    }
    
    /***************
    Tools Function
    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}