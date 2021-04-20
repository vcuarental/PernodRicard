/*********************************************************************************
 * Name: ASI_CRM_JP_SOLineItemSetAvailability
 * Description: Retrieve the item availability by header branch/plant and sku (Also update sys packaging size)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 12/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOLineItemSetAvailability extends ASI_CRM_JP_TriggerAbstract {
       
   	//Field Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP        = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SKU_FIELD_MAP                = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ITEM_AVAILABILITY_FIELD_MAP  = Schema.SObjectType.ASI_CRM_JP_Item_Availability__c.fields.getMap();
    
    //Filter Record Type
    private final static Set<String> RECORD_TYPE_FILTER = new Set<String> {
    	'ASI_CRM_JP_Duty_Free_SO',
        'ASI_CRM_JP_Duty_Free_SO_Locked'
    };
    
    public ASI_CRM_JP_SOLineItemSetAvailability() {
        super('ASI_CRM_JP_SOLineItemSetAvailability');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        //String sUserId = UserInfo.getUserId();
        //List <User> list_user = [SELECT id, name, BypassTriggers__c FROM user WHERE id = :sUserId];
        //for (User idx_user : list_user) {
		//	String CurrentClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        //    if (idx_user.BypassTriggers__c.contains(CurrentClassName)) {
        //        return;
        //    }
        //} 	
        
        List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList = (List<ASI_CRM_JP_Sales_Order_Item__c>) sObjList;
        Map<Id, ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemMap = (Map<Id, ASI_CRM_JP_Sales_Order_Item__c>) oldMap;
            
        Set<Id> salesOrderIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            salesOrderIdSet.add(salesOrderItem.ASI_CRM_Sales_Order__c);
        }
        
        Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = new Map<Id, ASI_CRM_JP_Sales_Order__c>(retrieveSalesOrderList(salesOrderIdSet));
        
        List<ASI_CRM_JP_Sales_Order_Item__c> filteredSalesOrderItemList = filterSalesOrderItem(salesOrderItemList, salesOrderItemMap, salesOrderMap);
        
        assignItemAvailability(filteredSalesOrderItemList, salesOrderMap);
    }
    
    private List<ASI_CRM_JP_Sales_Order_Item__c> filterSalesOrderItem(List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList, Map<Id, ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemMap, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
    	
        List<ASI_CRM_JP_Sales_Order_Item__c> filteredSalesOrderItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
        
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            ASI_CRM_JP_Sales_Order__c salesOrder = salesOrderMap.get(salesOrderItem.ASI_CRM_Sales_Order__c);
            
            if(RECORD_TYPE_FILTER.contains(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).DeveloperName)) {
            	continue;
            }
            
            if(salesOrderItemMap == null) {
                filteredSalesOrderItemList.add(salesOrderItem);
            } else if(salesOrderItem.ASI_CRM_SKU__c != salesOrderItemMap.get(salesOrderItem.Id).ASI_CRM_SKU__c && 
                      salesOrderItem.ASI_CRM_Status__c != '980-Cancelled') {
                filteredSalesOrderItemList.add(salesOrderItem);
            }
        }
        
        return filteredSalesOrderItemList;
    }
    
    private void assignItemAvailability(List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
    	Set<String> branchPlantSet = new Set<String>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderMap.values()) {
            branchPlantSet.add(salesOrder.ASI_CRM_Branch_Plant__c);
        }
        
        Set<Id> skuIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            skuIdSet.add(salesOrderItem.ASI_CRM_SKU__c);
        }
        
        Map<String, ASI_CRM_JP_Item_Availability__c> itemAvailabilityMap = retrieveItemAvailabilityMap(skuIdSet, branchPlantSet);
        Map<Id, ASI_MFM_SKU_Code__c> skuMap = new Map<Id, ASI_MFM_SKU_Code__c>(retrieveSKUList(skuIdSet));
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            ASI_CRM_JP_Sales_Order__c salesOrder = salesOrderMap.get(salesOrderItem.ASI_CRM_Sales_Order__c);
            String key = salesOrder.ASI_CRM_Branch_Plant__c + '_' + salesOrderItem.ASI_CRM_SKU__c;
            if(itemAvailabilityMap.containsKey(key)) {
                salesOrderItem.ASI_CRM_SKU_Item__c = itemAvailabilityMap.get(key).Id;
            } else { 
                showError(salesOrderItem, skuMap.get(salesOrderItem.ASI_CRM_SKU__c), salesOrder);
            }
            
            salesOrderItem.ASI_CRM_JP_Sys_Packaging_Size__c = skuMap.get(salesOrderItem.ASI_CRM_SKU__c).ASI_HK_CRM_Packaging_Size__c;
        }
    }
    
    private void showError(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem, ASI_MFM_SKU_Code__c skuCode, ASI_CRM_JP_Sales_Order__c salesOrder) {
        String skuName     = skuCode == null ? '' : skuCode.Name;
        String branchPlant = salesOrder.ASI_CRM_Branch_Plant__c;
                
        String errorMsg = String.format(Label.ASI_CRM_JP_SO_No_Item_Available_Found_With_SKU, 
                                        new String[] {branchPlant, skuName});
        salesOrderItem.addError(errorMsg);
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
    
    private List<ASI_MFM_SKU_Code__c> retrieveSKUList(Set<Id> skuIdSet) {
        String query = 'SELECT ' + genQueryField(SKU_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_MFM_SKU_Code__c ' + 
                       'Where Id in :skuIdSet';
        return (List<ASI_MFM_SKU_Code__c>) Database.query(query);
    }
    
    private Map<String, ASI_CRM_JP_Item_Availability__c> retrieveItemAvailabilityMap(Set<Id> skuIdSet, Set<String> branchPlantSet) {
        String query = 'SELECT ' + genQueryField(ITEM_AVAILABILITY_FIELD_MAP) + 
                       ', ASI_SKU__r.ASI_HK_CRM_Packaging_Size__c ' + 
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