public class ASI_MFM_CN_POSM_RequestItem_Trigger {
    Private Static Final String USER_ASSI_ID = Global_RecordTypeCache.getRtId('ASI_MFM_RequestItem_UserAssignment__cASI_MFM_CN_UA_POSM');
	public static void routineAfterInsert(list<ASI_FOC_Request_Item__c> trigger_new){
        //-------- Handle Clone item with User Assignment --------//
        List<ASI_FOC_Request_Item__c> cloneItemList = new List<ASI_FOC_Request_Item__c>();
        Set<Id> sourceReqItemIdSet = new Set<Id>();
        for(ASI_FOC_Request_Item__c item : trigger_new) {
            if(item.ASI_MFM_Clone_From__c != null){
                cloneItemList.add(item);
                sourceReqItemIdSet.add(item.ASI_MFM_Clone_From__c);
            }
        }
        if(sourceReqItemIdSet.size()>0) {
            Map<Id, List<ASI_MFM_RequestItem_UserAssignment__c>> reqItemToUaListMap = new Map<Id, List<ASI_MFM_RequestItem_UserAssignment__c>>();
            for(ASI_MFM_RequestItem_UserAssignment__c ua :[SELECT id, ASI_MFM_Qty__c, ASI_MFM_User__c, ASI_MFM_Request_Item__c
                                                           FROM ASI_MFM_RequestItem_UserAssignment__c 
                                                           WHERE ASI_MFM_Request_Item__c IN :sourceReqItemIdSet])
            {
                if(!reqItemToUaListMap.containsKey(ua.ASI_MFM_Request_Item__c)) reqItemToUaListMap.put(ua.ASI_MFM_Request_Item__c,new List<ASI_MFM_RequestItem_UserAssignment__c>());
                reqItemToUaListMap.get(ua.ASI_MFM_Request_Item__c).add(ua);
            }
            
            List<ASI_MFM_RequestItem_UserAssignment__c> insertUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
            for(ASI_FOC_Request_Item__c item :cloneItemList) {
                List<ASI_MFM_RequestItem_UserAssignment__c> sourceUaList = reqItemToUaListMap.get(item.ASI_MFM_Clone_From__c);
                if(sourceUaList == null || sourceUaList.size()==0) continue;
                for(ASI_MFM_RequestItem_UserAssignment__c sourceUa : sourceUaList) {
                    insertUaList.add(new ASI_MFM_RequestItem_UserAssignment__c(
                        ASI_MFM_User__c = sourceUa.ASI_MFM_User__c,
                        ASI_MFM_Qty__c  = sourceUa.ASI_MFM_Qty__c,
                        RecordTypeId = USER_ASSI_ID,
                        ASI_MFM_Request_Item__c = item.Id
                    ));
                }
            }
            
            if(insertUaList.size()>0) {
                insert insertUaList;
                system.debug(insertUaList);
                system.debug(cloneItemList);
            }
        }
        //-------- Handle Clone item with User Assignment --------//
    }

}