public class ASI_TnE_ClaimHeaderTriggerClass {
        public static void routineBeforeUpsert(list<ASI_TnE_ClaimHeader__c> trigger_new, map<id, ASI_TnE_ClaimHeader__c> trigger_oldMap) {

//Set Approver        
        set<id> rq_set = new set<id>();
        if (trigger_new != null) {
            for (ASI_TnE_ClaimHeader__c rq:trigger_new) {
                if (rq.ASI_TnE_Status__c == 'Open'){
                    rq.ASI_TnE_Approver1__c = null;
                    rq.ASI_TnE_Approver2__c = null;
                    rq.ASI_TnE_Approver3__c = null;
                    rq.ASI_TnE_Approver4__c = null;
                    
                    User u = [select userRole.developerName from user where id = :rq.ownerID];
                    
                    List<ASI_TnE_Route_Criteria__c> routeCriteriaList = [select ASI_TnE_Route_Type__r.ASI_TnE_Approver1__c, ASI_TnE_Route_Type__r.ASI_TnE_Approver2__c, ASI_TnE_Route_Type__r.ASI_TnE_Approver3__c, ASI_TnE_Route_Type__r.ASI_TnE_Approver4__c 
                        from ASI_TnE_Route_Criteria__c where Name = :u.userRole.developerName];
                    
                    if (routeCriteriaList.size() >= 1){
                        rq.ASI_TnE_Approver1__c = routeCriteriaList.get(0).ASI_TnE_Route_Type__r.ASI_TnE_Approver1__c;
                        rq.ASI_TnE_Approver2__c = routeCriteriaList.get(0).ASI_TnE_Route_Type__r.ASI_TnE_Approver2__c;
                        rq.ASI_TnE_Approver3__c = routeCriteriaList.get(0).ASI_TnE_Route_Type__r.ASI_TnE_Approver3__c;
                        rq.ASI_TnE_Approver4__c = routeCriteriaList.get(0).ASI_TnE_Route_Type__r.ASI_TnE_Approver4__c;
                    }
                }
            }
        }
    }
}