/*********************************************************************************
 * Name: ASI_CRM_JP_SOLineItemSetSKU
 * Description: Retrieve the sku when header record type is Duty Free
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 12/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOLineItemSetSKU extends ASI_CRM_JP_TriggerAbstract {
    
    //Field Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP        = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SKU_FIELD_MAP                = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ITEM_AVAILABILITY_FIELD_MAP  = Schema.SObjectType.ASI_CRM_JP_Item_Availability__c.fields.getMap();
    
    //Filter Record Type
    private final static Set<String> RECORD_TYPE_FILTER = new Set<String> {
    	'ASI_CRM_JP_Duty_Free_SO',
        'ASI_CRM_JP_Duty_Free_SO_Locked'
    };
    
    public ASI_CRM_JP_SOLineItemSetSKU() {
        super('ASI_CRM_JP_SOLineItemSetSKU');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList = (List<ASI_CRM_JP_Sales_Order_Item__c>) sObjList;
        Map<Id, ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemMap = (Map<Id, ASI_CRM_JP_Sales_Order_Item__c>) oldMap;
            
        Set<Id> salesOrderIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            salesOrderIdSet.add(salesOrderItem.ASI_CRM_Sales_Order__c);
        }
        
        Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = new Map<Id, ASI_CRM_JP_Sales_Order__c>(retrieveSalesOrderList(salesOrderIdSet));
        
        List<ASI_CRM_JP_Sales_Order_Item__c> filteredSalesOrderItemList = filterSalesOrderItem(salesOrderItemList, salesOrderItemMap, salesOrderMap);
    	
        assignSKU(filteredSalesOrderItemList);
    }
    
    private List<ASI_CRM_JP_Sales_Order_Item__c> filterSalesOrderItem(List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList, Map<Id, ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemMap, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
    	List<ASI_CRM_JP_Sales_Order_Item__c> filteredSalesOrderItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
        
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            ASI_CRM_JP_Sales_Order__c salesOrder = salesOrderMap.get(salesOrderItem.ASI_CRM_Sales_Order__c);
            
            if(RECORD_TYPE_FILTER.contains(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).DeveloperName) == false) {
            	continue;
            }
            
            if(salesOrderItemMap == null) {
                filteredSalesOrderItemList.add(salesOrderItem);
            } else if(salesOrderItem.ASI_CRM_SKU_Item__c == salesOrderItemMap.get(salesOrderItem.Id).ASI_CRM_SKU_Item__c && 
                      salesOrderItem.ASI_CRM_Status__c != '980-Cancelled') {
                filteredSalesOrderItemList.add(salesOrderItem);
            }
        }
        
        return filteredSalesOrderItemList;
    }
    
    private void assignSKU(List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList) {
        Set<Id> itemAvailabilityIdSet = new Set<Id>();
    	for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            itemAvailabilityIdSet.add(salesOrderItem.ASI_CRM_SKU_Item__c);
        }
        
        Map<Id, ASI_CRM_JP_Item_Availability__c> itemAvailabilityMap = new Map<Id, ASI_CRM_JP_Item_Availability__c>(retrieveItemAvailabilityMap(itemAvailabilityIdSet));
        
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            ASI_CRM_JP_Item_Availability__c itemAvailability = itemAvailabilityMap.get(salesOrderItem.ASI_CRM_SKU_Item__c);
            
            salesOrderItem.ASI_CRM_SKU__c = itemAvailability.ASI_SKU__c;
            salesOrderItem.ASI_CRM_JP_Sys_Packaging_Size__c = itemAvailability.ASI_SKU__r.ASI_HK_CRM_Packaging_Size__c;
        }
    }
    
    /***************
	Data Retrievement Function
	***************/
    private List<ASI_CRM_JP_Sales_Order__c> retrieveSalesOrderList(Set<Id> salesOrderIdSet) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_JP_Sales_Order__c ' +
                       'WHERE Id in :salesOrderIdSet ';
        return (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
    }
    
    private List<ASI_CRM_JP_Item_Availability__c> retrieveItemAvailabilityMap(Set<Id> itemAvailabilityIdSet) {
        String query = 'SELECT ' + genQueryField(ITEM_AVAILABILITY_FIELD_MAP) + 
                       ', ASI_SKU__r.ASI_HK_CRM_Packaging_Size__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_JP_Item_Availability__c ' + 
                       'Where Id in :itemAvailabilityIdSet ';

        return (List<ASI_CRM_JP_Item_Availability__c>) Database.query(query);
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