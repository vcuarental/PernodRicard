/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCS_updateHeaderAmount
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    ----------------------------------------
 * 23/11/2017       Kevin Choi             Created          
***********************************************************************************/
public class ASI_CRM_VN_CapsuleCS_updateHeaderAmount{
    public ASI_CRM_VN_CapsuleCS_updateHeaderAmount() {

    }

    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP   = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> REQUEST_HEADER_FIELD_MAP   = Schema.SObjectType.ASI_GiftBox_Request_Header__c.fields.getMap();
	
    // For After Delete Trigger
    public void executeTrigger(List<sObject> oldList) {
        system.debug('Trigger ASI_CRM_VN_CapsuleCS_updateHeaderAmount function');
        List<ASI_GiftBox_Request_Item__c> requestItemList   = (List<ASI_GiftBox_Request_Item__c>) oldList;
        rollupToHeader(requestItemList);
    }
	// For After Update Trigger
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
        system.debug('headerIdSet: '+headerIdSet);
        Map<Id, ASI_GiftBox_Request_Header__c> headerMap = new Map<Id, ASI_GiftBox_Request_Header__c>();
        List<ASI_GiftBox_Request_Item__c>retrievedRequestItemList = retrieveRequestItemList(headerIdSet);

        if (retrievedRequestItemList.size() == 0){
            system.debug(' No Request Line ');
            List<ASI_GiftBox_Request_Header__c>  requestHeaderList = retrieveRequestHeaderList(headerIdSet);
            for (ASI_GiftBox_Request_Header__c header : requestHeaderList){
                system.debug(' Set total Amount to 0 ');
                header.ASI_CRM_VN_Amount__c = 0;
            }
            update requestHeaderList;
            return;
        }

        for(ASI_GiftBox_Request_Item__c requestItem : retrievedRequestItemList) {
            system.debug(' current requestItem: '+requestItem);
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
		
        
        // Round Down Function
        if(headerMap.size() > 0) {
            for (ASI_GiftBox_Request_Header__c header : headerMap.values()){
                system.debug('Previous:'+header.ASI_CRM_VN_Amount__c);
                
                Decimal totalAmt = header.ASI_CRM_VN_Amount__c/10000;
                header.ASI_CRM_VN_Amount__c = (totalAmt.round(System.RoundingMode.DOWN))*10000;
                
                system.debug('After:'+header.ASI_CRM_VN_Amount__c);
            }
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

    private List<ASI_GiftBox_Request_Header__c> retrieveRequestHeaderList(Set<Id> requestIdSet) {
        String query = 'SELECT ' + genQueryField(REQUEST_HEADER_FIELD_MAP) +  
            ' FROM ASI_GiftBox_Request_Header__c ' + 
            'WHERE Id in :requestIdSet';

        return (List<ASI_GiftBox_Request_Header__c>) Database.query(query);
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