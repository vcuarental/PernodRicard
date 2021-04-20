/*********************************************************************************
 * Name: ASI_CRM_VN_RequestItemRollupAmount
 * Description: Roll up amount to gift box request header
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/08/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_RequestItemRollupAmount {
    
    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP   = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    
    public ASI_CRM_VN_RequestItemRollupAmount() {
    }
    
   	public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Item__c> requestItemList   = (List<ASI_GiftBox_Request_Item__c>) newList;
        Map<Id, ASI_GiftBox_Request_Item__c> requestItemMap = (Map<Id, ASI_GiftBox_Request_Item__c>) oldMap;
        
        List<ASI_GiftBox_Request_Item__c> filteredRequestItemList = filterRequest(requestItemList, requestItemMap);
        rollupToHeader(filteredRequestItemList);
    }
    
    private List<ASI_GiftBox_Request_Item__c> filterRequest(List<ASI_GiftBox_Request_Item__c> requestItemList, Map<Id, ASI_GiftBox_Request_Item__c> requestItemMap) {
        if(requestItemMap == null) {
        	return requestItemList;
        }
        
        List<ASI_GiftBox_Request_Item__c> filteredRequestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            if(requestItem.ASI_CRM_Amount__c != requestItemMap.get(requestItem.Id).ASI_CRM_Amount__c) {
                filteredRequestItemList.add(requestItem);
            }
        }
        
        return filteredRequestItemList;
    }
    
    private void rollupToHeader(List<ASI_GiftBox_Request_Item__c> requestItemList) {
        Set<Id> headerIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            headerIdSet.add(requestItem.ASI_GiftBox_Request_Id__c);
        }
        
        Map<Id, ASI_GiftBox_Request_Header__c> headerMap = new Map<Id, ASI_GiftBox_Request_Header__c>();
        for(ASI_GiftBox_Request_Item__c requestItem : retrieveRequestItemList(headerIdSet)) {
            Decimal itemAmount = requestItem.ASI_CRM_Amount__c == null ? 0 : requestItem.ASI_CRM_Amount__c;
            if(headerMap.containsKey(requestItem.ASI_GiftBox_Request_Id__c)) {
            	headerMap.get(requestItem.ASI_GiftBox_Request_Id__c).ASI_CRM_VN_Amount__c += itemAmount;
            } else {
            	ASI_GiftBox_Request_Header__c tempHeader = new ASI_GiftBox_Request_Header__c();
                tempHeader.Id = requestItem.ASI_GiftBox_Request_Id__c;
                tempHeader.ASI_CRM_VN_Amount__c = itemAmount;
                headerMap.put(tempHeader.Id, tempHeader);
            }
        }
        
        if(headerMap.size() > 0) {
            update headerMap.values();
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_GiftBox_Request_Item__c> retrieveRequestItemList(Set<Id> requestIdSet) {
    	String query = 'SELECT ' + genQueryField(REQUEST_ITEM_FIELD_MAP) +  
                       ', ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'WHERE ASI_GiftBox_Request_Id__c in :requestIdSet';
        
    	return (List<ASI_GiftBox_Request_Item__c>) Database.query(query);
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