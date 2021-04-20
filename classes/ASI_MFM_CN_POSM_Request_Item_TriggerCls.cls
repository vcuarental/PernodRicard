public with sharing class ASI_MFM_CN_POSM_Request_Item_TriggerCls {

    public static void routineBeforeUpsert(list<ASI_MFM_POSM_Return_Request_Item__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request_Item__c> trigger_oldMap) {
        assignItemOwner(trigger_new);
    }

    Public Static void routineBeforeDelete(List<ASI_MFM_POSM_Return_Request_Item__c> trigger_old) {
        Set<ID> setHeaderID = new Set<ID>();
        
        for(ASI_MFM_POSM_Return_Request_Item__c obj : trigger_old){
            setHeaderID.add(obj.ASI_MFM_Request_Order__c);
        }
        
        Map<ID, ASI_MFM_POSM_Return_Request__c> mapHeader = new Map<ID, ASI_MFM_POSM_Return_Request__c>([SELECT Id, ASI_MFM_Request_Status__c FROM ASI_MFM_POSM_Return_Request__c WHERE id IN : setHeaderID]);
        
        for(ASI_MFM_POSM_Return_Request_Item__c obj : trigger_old){
            if(mapHeader.containsKey(obj.ASI_MFM_Request_Order__c)){
                if(mapHeader.get(obj.ASI_MFM_Request_Order__c).ASI_MFM_Request_Status__c != 'Open'){
                    obj.addError('Not allowed to delete record in current status');
                }
            }
        }
    }
    
    //20191021 - allow user to decide item owner
    private static void assignItemOwner(list<ASI_MFM_POSM_Return_Request_Item__c> trigger_new) {
        Set<Id> setHeader = new Set<Id>();
        for(ASI_MFM_POSM_Return_Request_Item__c oItem : trigger_new) {
            setHeader.add(oItem.ASI_MFM_Request_Order__c);
        }
        
        Map<Id, ASI_MFM_POSM_Return_Request__c> mapHeader = new Map<Id, ASI_MFM_POSM_Return_Request__c>([
            SELECT Id, OwnerId
            FROM ASI_MFM_POSM_Return_Request__c
            WHERE Id IN :setHeader
        ]);
        
        for(ASI_MFM_POSM_Return_Request_Item__c oItem : trigger_new) {
            if ((oItem.ASI_MFM_Owner__c != NULL) && (oItem.ASI_MFM_Owner__c != mapHeader.get(oItem.ASI_MFM_Request_Order__c).OwnerId)) {
                oItem.ASI_MFM_Item_Owner__c = oItem.ASI_MFM_Owner__c;
            } else {
                oItem.ASI_MFM_Item_Owner__c = NULL;
            }
        }
    }

    //202009 added by LEO Jing BSL
    public static void autoSubmitOrderApproval(list<ASI_MFM_POSM_Return_Request_Item__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request_Item__c> trigger_oldMap){
        System.debug(LoggingLevel.INFO, '*** YES: ');
        Set<Id> yes_itemIds = new Set<Id>();
        Set<Id> no_itemIds = new Set<Id>();
        Set<Id> prrIds = new Set<Id>();
        for (ASI_MFM_POSM_Return_Request_Item__c item : trigger_new) {
            ASI_MFM_POSM_Return_Request_Item__c old_item = trigger_oldMap.get(item.Id);            
            if (item.ASI_POSM_Return_Request_Approval_Header__c != null && item.ASI_MFM_Approval_Status__c == 'Approved' && item.ASI_MFM_Approval_Status__c != old_item.ASI_MFM_Approval_Status__c) {
                yes_itemIds.add(item.Id);
                prrIds.add(item.ASI_POSM_Return_Request_Approval_Header__c);
            }
            if (item.ASI_POSM_Return_Request_Approval_Header__c != null && item.ASI_MFM_Approval_Status__c == 'Rejected' && item.ASI_MFM_Approval_Status__c != old_item.ASI_MFM_Approval_Status__c) {
                no_itemIds.add(item.Id);
                
            }
        }

        List<ASI_MFM_POSM_Return_Request_Item__c> yes_itemList = [SELECT Id FROM ASI_MFM_POSM_Return_Request_Item__c WHERE ASI_MFM_POSM_Return_Reques_Approval_Item__c IN: yes_itemIds];
        List<ASI_MFM_POSM_Return_Request_Item__c> no_itemList = [SELECT Id FROM ASI_MFM_POSM_Return_Request_Item__c WHERE ASI_MFM_POSM_Return_Reques_Approval_Item__c IN: no_itemIds];
        if (yes_itemList.size() > 0) {
            for (ASI_MFM_POSM_Return_Request_Item__c item : yes_itemList) {
                item.ASI_MFM_Approval_Status__c = 'Approved';

            }
            update yes_itemList;
        }
        if (no_itemList.size() > 0) {
            for (ASI_MFM_POSM_Return_Request_Item__c item : no_itemList) {
                item.ASI_MFM_Approval_Status__c = 'Rejected';

            }
            update no_itemList;
        }

        List<ASI_MFM_POSM_Return_Request__c> prrList =  [SELECT Id,ASI_MFM_Request_Status__c,(SELECT Id,ASI_MFM_Approval_Status__c FROM ASI_POSM_Return_Request_Approval_Header__r) FROM ASI_MFM_POSM_Return_Request__c WHERE Id IN: prrIds];
        for (ASI_MFM_POSM_Return_Request__c prr : prrList){
            if (prr.ASI_MFM_Request_Status__c != 'Approved') {
                Boolean pass = true;
                for (ASI_MFM_POSM_Return_Request_Item__c item : prr.ASI_POSM_Return_Request_Approval_Header__r) {  
                    if (item.ASI_MFM_Approval_Status__c != 'Approved') {
                        pass = false;
                        continue; 
                    }
                }
                System.debug(LoggingLevel.INFO, '*** pass: ' + pass);
                if (pass) {
                    List<Approval.ProcessSubmitRequest> header_req = new List<Approval.ProcessSubmitRequest>();                    
                    Approval.ProcessSubmitRequest tmp_header_req = new Approval.ProcessSubmitRequest();
                    tmp_header_req.setObjectId(prr.id);
                    header_req.add(tmp_header_req);                    
                    List<Approval.ProcessResult> header_result = Approval.process(header_req);  
                    
                }
            }
            
        }
    }
    
    //20191021 - to be disabled
    /*
    private static void assignItemOwner(list<ASI_MFM_POSM_Return_Request_Item__c> trigger_new) {
        Set<Id> setSKU = new Set<Id>();
        Set<Id> setHeader = new Set<Id>();
        for(ASI_MFM_POSM_Return_Request_Item__c oItem : trigger_new) {
            if (oItem.ASI_MFM_SKU__c != NULL) setSKU.add(oItem.ASI_MFM_SKU__c);
            setHeader.add(oItem.ASI_MFM_Request_Order__c);
        }
        
        Map<Id, ASI_MFM_POSM_Return_Request__c> mapHeader = new Map<Id, ASI_MFM_POSM_Return_Request__c>([
            SELECT Id, OwnerId
            FROM ASI_MFM_POSM_Return_Request__c
            WHERE Id IN :setHeader
        ]);
        
        Map<Id, ASI_MFM_SKU_Code__c> mapSKU = new Map<Id, ASI_MFM_SKU_Code__c>([
            SELECT Id, Name, ASI_FOC_Location_Item_Owner__c
            FROM ASI_MFM_SKU_Code__c
            WHERE Id IN :setSKU
            	AND ASI_FOC_Location_Item_Owner__c != NULL
        ]);
        
        for(ASI_MFM_POSM_Return_Request_Item__c oItem : trigger_new) {
            if (oItem.ASI_MFM_Approval_Status__c == NULL) {
                if ((oItem.ASI_MFM_SKU__c != NULL) && (mapSKU.containsKey(oItem.ASI_MFM_SKU__c))) {
                    oItem.ASI_MFM_Owner__c = mapSKU.get(oItem.ASI_MFM_SKU__c).ASI_FOC_Location_Item_Owner__c;
                    if (mapSKU.get(oItem.ASI_MFM_SKU__c).ASI_FOC_Location_Item_Owner__c != mapHeader.get(oItem.ASI_MFM_Request_Order__c).OwnerId) oItem.ASI_MFM_Item_Owner__c = mapSKU.get(oItem.ASI_MFM_SKU__c).ASI_FOC_Location_Item_Owner__c;
                }
            }
        }
    }
	*/
    
}