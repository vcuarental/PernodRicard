public without sharing class ASI_NPL_CN_Channel_Strategy_TriggerClass {
	public static void routineBeforeInsert(list<ASI_CRM_CN_Channel_Strategy__c> trigger_new, map<id, ASI_CRM_CN_Channel_Strategy__c> trigger_oldMap) {
        assignTeam(trigger_new);
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_CN_Channel_Strategy__c> trigger_new, map<id, ASI_CRM_CN_Channel_Strategy__c> trigger_oldMap) {
        assignTeam(trigger_new);
    }
    
    private static void assignTeam(list<ASI_CRM_CN_Channel_Strategy__c> trigger_new) {

        Set<Id> setApprover = new Set<Id>();
        for(ASI_CRM_CN_Channel_Strategy__c oRecord : trigger_new) {
            if (oRecord.ASI_CRM_CN_Sys_Approver_1__c != NULL) setApprover.add(oRecord.ASI_CRM_CN_Sys_Approver_1__c);
        }
        
        if (setApprover.size() > 0) {
            string sTeamRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Team__cASI_MFM_CN_Brand_Team');
            
            List<ASI_MFM_Team_Member__c> ltMember = 
                [SELECT ID, ASI_MFM_Team_Member__c, ASI_MFM_Team__r.Name
                 FROM ASI_MFM_Team_Member__c
                 WHERE ASI_MFM_Team__r.recordtypeid = :sTeamRTID AND ASI_MFM_Team_Member__c = :setApprover];

            if (ltMember.size() > 0) {
                Map<Id, string> mapApproverTeam = new Map<Id, string>();
                for(ASI_MFM_Team_Member__c oMember : ltMember) {
                    mapApproverTeam.put(oMember.ASI_MFM_Team_Member__c, oMember.ASI_MFM_Team__r.Name);
                }

                for(ASI_CRM_CN_Channel_Strategy__c oRecord : trigger_new) {
                    if ((oRecord.ASI_CRM_CN_Sys_Approver_1__c != NULL) && mapApproverTeam.containsKey(oRecord.ASI_CRM_CN_Sys_Approver_1__c)) {
                        oRecord.ASI_CRM_Team__c = mapApproverTeam.get(oRecord.ASI_CRM_CN_Sys_Approver_1__c);
                    }
                }
            }
        }

    }
    
}