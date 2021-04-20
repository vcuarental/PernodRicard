/*********************************************************************************
 * Name: ASI_CRM_VN_FOCRequestItem_CalAmount
 * Description: Calculate the amount of FOC request item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/08/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_FOCRequestItem_CalAmount {
    
    private final static Map<String, Schema.SObjectField> INVENTORY_MASTER_FIELD_MAP     = Schema.SObjectType.ASI_GiftBox_Inventory_Master__c.fields.getMap();
    
    public ASI_CRM_VN_FOCRequestItem_CalAmount() {
    }

    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Item__c> requestItemList   = (List<ASI_GiftBox_Request_Item__c>) newList;
        Map<Id, ASI_GiftBox_Request_Item__c> requestItemMap = (Map<Id, ASI_GiftBox_Request_Item__c>) oldMap;
        
        List<ASI_GiftBox_Request_Item__c> filteredRequestItemList = filterRequestItem(requestItemList, requestItemMap);
		calculateAmount(filteredRequestItemList);
    }
    
    private List<ASI_GiftBox_Request_Item__c> filterRequestItem(List<ASI_GiftBox_Request_Item__c> requestItemList, Map<Id, ASI_GiftBox_Request_Item__c> requestItemMap) {
    	if(requestItemMap == null) {
        	return requestItemList;
        }
        
        List<ASI_GiftBox_Request_Item__c> filteredRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            if(requestItem.ASI_GiftBox_Request_Item__c != requestItemMap.get(requestItem.Id).ASI_GiftBox_Request_Item__c || 
               requestItem.ASI_GiftBox_Request_Quantity__c != requestItemMap.get(requestItem.Id).ASI_GiftBox_Request_Quantity__c) {
                filteredRequestItemList.add(requestItem);
            }
        }
        
        return filteredRequestItemList;
    }

    private void calculateAmount(List<ASI_GiftBox_Request_Item__c> requestItemList) {
    	Set<Id> itemIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            itemIdSet.add(requestItem.ASI_GiftBox_Request_Item__c);
        }
        
        Map<Id, ASI_GiftBox_Inventory_Master__c> itemMap = new Map<Id, ASI_GiftBox_Inventory_Master__c>(retrieveInventoryMasterList(itemIdSet));
        
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            ASI_GiftBox_Inventory_Master__c tempItem = itemMap.get(requestItem.ASI_GiftBox_Request_Item__c);
            if(tempItem.ASI_GiftBox_Unit_Price__c == null || tempItem.ASI_GiftBox_Unit_Price__c == 0) {
                showError(requestItem, String.format(Label.ASI_CRM_VN_Request_Item_No_Price, new String[]{tempItem.Name}));
                continue;
            //Vincent@2017-11-07 Disable FOC Item Checking Start
            //} else if(tempItem.ASI_GiftBox_Item_Available_Quantity__c == null || tempItem.ASI_GiftBox_Item_Available_Quantity__c == 0) {
            //    showError(requestItem, String.format(Label.ASI_CRM_VN_Request_Item_No_Qty, new String[]{tempItem.Name}));
            //	continue;
            //Vincent@2017-11-07 Disable FOC Item Checking End
            }
            
            requestItem.ASI_CRM_Amount__c = (tempItem.ASI_GiftBox_Unit_Price__c == null ? 0 : tempItem.ASI_GiftBox_Unit_Price__c)
                                             * (requestItem.ASI_GiftBox_Request_Quantity__c == null ? 0 : requestItem.ASI_GiftBox_Request_Quantity__c);
        }
    }
    
    private void showError(ASI_GiftBox_Request_Item__c requestItem, String errorMsg) {
        requestItem.addError(errorMsg);
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_GiftBox_Inventory_Master__c> retrieveInventoryMasterList(Set<Id> itemIdSet) {
    	String query = 'SELECT ' + genQueryField(INVENTORY_MASTER_FIELD_MAP) +  
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Inventory_Master__c ' + 
                       'Where Id in :itemIdSet';
        
    	return (List<ASI_GiftBox_Inventory_Master__c>) Database.query(query);
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