/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCS_createCSRequestLine
 * Description: 

 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    ----------------------------------------
 * 23/11/2017       Kevin Choi             Created          
***********************************************************************************/
public class ASI_CRM_VN_CapsuleCS_ChangeLineRT {
    
    private final static String RECORD_APPROVED = 'Approved';
    private final static String RECORD_OPEN     = 'Open';
    
    private final static String OPEN_RECORD_TYPE      = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__c' + 'ASI_CRM_VN_Capsule_CS_Request_Item');
    private final static String READ_ONLY_RECORD_TYPE = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__c' + 'ASI_CRM_VN_Capsule_CS_Request_Item_Read_Only');
    
    public ASI_CRM_VN_CapsuleCS_ChangeLineRT() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> requestList = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> requestOldMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        
        Map<Id, ASI_GiftBox_Request_Header__c> requestApprovedMap = new Map<Id, ASI_GiftBox_Request_Header__c>();
        Map<Id, ASI_GiftBox_Request_Header__c> requestRejectedMap = new Map<Id, ASI_GiftBox_Request_Header__c>();
        
        for (ASI_GiftBox_Request_Header__c request : requestList){
            if (request.ASI_GiftBox_Status__c == RECORD_APPROVED && 
                requestOldMap.get(request.Id).ASI_GiftBox_Status__c != RECORD_APPROVED)
                requestApprovedMap.put(request.Id, request);
			else if(request.ASI_GiftBox_Status__c == RECORD_OPEN && 
                    requestOldMap.get(request.Id).ASI_GiftBox_Status__c != RECORD_OPEN)
                requestRejectedMap.put(request.Id, request);
        }
        
        if(requestApprovedMap.size() > 0 || 
           requestRejectedMap.size() > 0)
        	updateRequestLineItemRecordType(requestApprovedMap, requestRejectedMap);
    }
    
    private void updateRequestLineItemRecordType(Map<Id, ASI_GiftBox_Request_Header__c> requestApprovedMap, Map<Id, ASI_GiftBox_Request_Header__c> requestRejectedMap) {
        Set<Id> requestIdSet = new Set<Id>();
        requestIdSet.addAll(requestApprovedMap.keySet());
        requestIdSet.addAll(requestRejectedMap.keySet());
        
        List<ASI_GiftBox_Request_Item__c> requestItemList = [SELECT Id, ASI_GiftBox_Request_Id__c, RecordTypeId 
                                                             FROM ASI_GiftBox_Request_Item__c WHERE ASI_GiftBox_Request_Id__c IN: requestIdSet];
        
        for(ASI_GiftBox_Request_Item__c requestItem : requestItemList) {
            if(requestApprovedMap.containsKey(requestItem.ASI_GiftBox_Request_Id__c))
                requestItem.RecordTypeId = READ_ONLY_RECORD_TYPE;
            else if(requestRejectedMap.containsKey(requestItem.ASI_GiftBox_Request_Id__c))
                requestItem.RecordTypeId = OPEN_RECORD_TYPE;
        }
        
        update requestItemList;
    }
}