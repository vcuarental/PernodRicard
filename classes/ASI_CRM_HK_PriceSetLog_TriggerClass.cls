public class ASI_CRM_HK_PriceSetLog_TriggerClass {
	 public static void routineAfterUpdate(list<ASI_CRM_Price_Set_Generation_Log__c> trigger_new, map<id, ASI_CRM_Price_Set_Generation_Log__c> trigger_oldMap) {
         Set<id> PSGenSet = new Set<id>();
         Set<id> PSCompleteSet = new Set<id>();
         Set<id> PSSARejectedSet = new Set<id>(); //20160414, edited by Leo
         Set<id> PSHubRejectedSet = new Set<id>(); //20160414, added by Leo
         Set<id> PSApprovedSet = new Set<id>();
         //system.debug('Checkpoint 1');
         for (ASI_CRM_Price_Set_Generation_Log__c PSLog: trigger_new) {
             //Status: Draft->Submitted
             if (Global_RecordTypeCache.getRt(PSLog.recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')) {
                 if(PSLog.ASI_CRM_Status__c == 'Submitted' && trigger_oldMap.get(PSLog.id).ASI_CRM_Status__c == 'Draft') {
                     PSGenSet.add(PSLog.id);
                 }
             }
             //Status: Submitted->Approved
             if (Global_RecordTypeCache.getRt(PSLog.recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')) {
                 if(PSLog.ASI_CRM_Status__c == 'Approved' && trigger_oldMap.get(PSLog.id).ASI_CRM_Status__c == 'Submitted') {
                     PSApprovedSet.add(PSLog.id);
                 }
             }
             //Status: Approved->Completed
             if (Global_RecordTypeCache.getRt(PSLog.recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')) {
                 if(PSLog.ASI_CRM_Status__c == 'Completed' && trigger_oldMap.get(PSLog.id).ASI_CRM_Status__c == 'Approved') {
                     PSCompleteSet.add(PSLog.id);
                 }
             }
             //Status: Submitted->SA Rejected
             if (Global_RecordTypeCache.getRt(PSLog.recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')) {
                 if(PSLog.ASI_CRM_Status__c == 'SA Rejected' && trigger_oldMap.get(PSLog.id).ASI_CRM_Status__c == 'Submitted') { //20160414, edited by Leo, change rejected->SA reject
                     PSSARejectedSet.add(PSLog.id);
                 }
             }
             //Status: Approved->Hub Rejected //20160414, added by Leo
             if (Global_RecordTypeCache.getRt(PSLog.recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')) {
                 if(PSLog.ASI_CRM_Status__c == 'Hub Rejected' && trigger_oldMap.get(PSLog.id).ASI_CRM_Status__c == 'Approved') {
                     PSHubRejectedSet.add(PSLog.id);
                 }
             }//20160414, added by Leo
         }   
         if (PSGenSet.size() > 0){
             List<ASI_HK_CRM_Pre_Approval_Form__c> updatePAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
             List<ASI_CRM_Price_Set_Generation_Log_Detail__c> PSLogItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c IN: PSGenSet];
             System.debug('PSLogItems' + PSLogItems.size());
             for (ASI_CRM_Price_Set_Generation_Log_Detail__c PSLItem: PSLogItems) {
                 ASI_HK_CRM_Pre_Approval_Form__c PAF = new ASI_HK_CRM_Pre_Approval_Form__c(id = PSLItem.ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Status__c = 'Submitted', ASI_CRM_Price_Set_Submission_Date__c = PSLItem.ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Submission_Date__c); 
                 updatePAF.add(PAF);//20160414, edited by Leo
             }
             update updatePAF;
         }
         if (PSApprovedSet.size() > 0){
             List<ASI_HK_CRM_Pre_Approval_Form__c> updatePAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
             List<ASI_CRM_Price_Set_Generation_Log_Detail__c> PSLogItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Approved_Date__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c IN: PSApprovedSet];
             for (ASI_CRM_Price_Set_Generation_Log_Detail__c PSLItem: PSLogItems) {
                 ASI_HK_CRM_Pre_Approval_Form__c PAF = new ASI_HK_CRM_Pre_Approval_Form__c(id = PSLItem.ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Status__c = 'Approved', ASI_CRM_Price_Set_Approved_Date__c = PSLItem.ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Approved_Date__c); 
                 updatePAF.add(PAF);
             }
             update updatePAF;
         }
         if (PSCompleteSet.size() > 0){
             List<ASI_HK_CRM_Pre_Approval_Form__c> updatePAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
             List<ASI_CRM_Price_Set_Generation_Log_Detail__c> PSLogItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Completed_Date__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c IN: PSCompleteSet];
             for (ASI_CRM_Price_Set_Generation_Log_Detail__c PSLItem: PSLogItems) {
                 ASI_HK_CRM_Pre_Approval_Form__c PAF = new ASI_HK_CRM_Pre_Approval_Form__c(id = PSLItem.ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Status__c = 'Completed', ASI_CRM_Price_Set_Completed_Date__c = PSLItem.ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Completed_Date__c); 
                 updatePAF.add(PAF);
             }
             update updatePAF;
         }
         if (PSHubRejectedSet.size() > 0){
             List<ASI_HK_CRM_Pre_Approval_Form__c> updatePAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
             List<ASI_CRM_Price_Set_Generation_Log_Detail__c> PSLogItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c IN: PSHubRejectedSet];
             for (ASI_CRM_Price_Set_Generation_Log_Detail__c PSLItem: PSLogItems) {
                 ASI_HK_CRM_Pre_Approval_Form__c PAF = new ASI_HK_CRM_Pre_Approval_Form__c(id = PSLItem.ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Status__c = 'Hub Rejected'); 
                 updatePAF.add(PAF);
             }
             update updatePAF;
         }
         //20160414, added by Leo
         if (PSSARejectedSet.size() > 0){
             List<ASI_HK_CRM_Pre_Approval_Form__c> updatePAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
             List<ASI_CRM_Price_Set_Generation_Log_Detail__c> PSLogItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE ASI_CRM_Price_Set_Generation_Log__c IN: PSSARejectedSet];
             for (ASI_CRM_Price_Set_Generation_Log_Detail__c PSLItem: PSLogItems) {
                 ASI_HK_CRM_Pre_Approval_Form__c PAF = new ASI_HK_CRM_Pre_Approval_Form__c(id = PSLItem.ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Status__c = 'SA Rejected'); 
                 updatePAF.add(PAF);
             }
             update updatePAF;
         }
         //20160414, added by Leo
     }
    public static void routineBeforeUpdate(list<ASI_CRM_Price_Set_Generation_Log__c> trigger_new, map<id, ASI_CRM_Price_Set_Generation_Log__c> trigger_oldMap) {
        
        Map<id, Set<Id>> mapPafApprover = new Map<id, Set<Id>>();
        Map<String, Set<Id>> mapChannelAdmin = new Map<String, Set<Id>>();
        List<ASI_CRM_Price_Set_Generation_Log_Detail__c> lineItemList = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>([SELECT id
                                                                                                                              , ASI_CRM_Price_Set_Generation_Log__c
                                                                                                                              ,	ASI_CRM_Pre_Approval_Form__c
                                                                                                                              , ASI_CRM_Pre_Approval_Form__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c
                                                                                                                              FROM ASI_CRM_Price_Set_Generation_Log_Detail__c
                                                                                                                              WHERE ASI_CRM_Price_Set_Generation_Log__c IN : trigger_new
                                                                                                                             ]);
        
        for(ASI_HK_CRM_Channel_Local_Channel_Map__c obj : [SELECT id
                                                           , ASI_HK_CRM_Channel_Map_Unique_ID__c
                                                           , ASI_CRM_Channel_Admin1__c
                                                           , ASI_CRM_Channel_Admin2__c
                                                           , ASI_CRM_Channel_Admin3__c
                                                           , ASI_CRM_Channel_Admin4__c
                                                           FROM ASI_HK_CRM_Channel_Local_Channel_Map__c 
                                                           WHERE recordType.DeveloperName Like 'ASI_HK_CRM_Channel_to_Local_Channel_Map'
                                                          ]){
                                                              Set<Id> channelAdminSet = new Set<Id>();
                                                              if(obj.ASI_CRM_Channel_Admin1__c != NULL)
                                                                  channelAdminSet.add(obj.ASI_CRM_Channel_Admin1__c);
                                                              if(obj.ASI_CRM_Channel_Admin2__c != NULL)
                                                                  channelAdminSet.add(obj.ASI_CRM_Channel_Admin2__c);
                                                              if(obj.ASI_CRM_Channel_Admin3__c != NULL)
                                                                  channelAdminSet.add(obj.ASI_CRM_Channel_Admin3__c);
                                                              if(obj.ASI_CRM_Channel_Admin4__c != NULL)
                                                                  channelAdminSet.add(obj.ASI_CRM_Channel_Admin4__c);
                                                              
                                                              system.debug('Check111 ' + channelAdminSet);
                                                              mapChannelAdmin.put(obj.ASI_HK_CRM_Channel_Map_Unique_ID__c, channelAdminSet);
                                                          }
        
        if(lineItemList.size() > 0){
            for(ASI_CRM_Price_Set_Generation_Log_Detail__c obj : lineItemList){
                
                if(mapChannelAdmin.containsKey(obj.ASI_CRM_Pre_Approval_Form__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c)){
                    
                    Set<Id> adminIdSet = new Set<Id>();
                    
                    if(mapPafApprover.containsKey(obj.ASI_CRM_Price_Set_Generation_Log__c))
                        adminIdSet = mapPafApprover.get(obj.ASI_CRM_Price_Set_Generation_Log__c);
                    
                    adminIdSet.addAll(mapChannelAdmin.get(obj.ASI_CRM_Pre_Approval_Form__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c));
                    mapPafApprover.put(obj.ASI_CRM_Price_Set_Generation_Log__c, adminIdSet);
                }
            }
        }
        
        for(ASI_CRM_Price_Set_Generation_Log__c obj : trigger_new){
            
            if(mapPafApprover.containsKey(obj.id)){
                Integer i = 1;
                String sysApprover;
                for(Id adminId : mapPafApprover.get(obj.id)){
                    
                    sysApprover = 'ASI_CRM_Sys_Approver_' + i +'__c';
                    
                    obj.put(sysApprover, adminId);
                    i++;
                    
                    if(i > 5)
                        break;
                }
            }
        }
    }
}