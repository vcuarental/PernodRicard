public class ASI_KOR_POSM_Details_TriggerClass {
    
    public static void routineBeforeUpsert(list<ASI_KOR_POSM_Order_Detail__c> trigger_new, map<id, ASI_KOR_POSM_Order_Detail__c> trigger_oldMap) {
     
    }
   
    public static void routineBeforeInsert(list<ASI_KOR_POSM_Order_Detail__c> trigger_new) {
        
        
        // Copy ASI_KOR_POSM_Order_Request__c Name to POSM_Order_Request_Name__c
        set<id> posm_set = new set<id>();                
        for (ASI_KOR_POSM_Order_Detail__c p:trigger_new) {
            posm_set.add(p.ASI_KOR_POSM_Order_Request__c);  
        }
        
        if (posm_set.size() > 0) {
            list<ASI_KOR_POSM_Order_Request__c> POSM_list = [select name,ASI_MFM_KR_POSM_Order_Request_Name__c   from ASI_KOR_POSM_Order_Request__c where id in :posm_set for update];
            
            for (ASI_KOR_POSM_Order_Request__c posm:POSM_list) {
                if (posm.Name!= null) {  
                    posm.ASI_MFM_KR_POSM_Order_Request_Name__c = posm.Name;
                    
                }               
            }  
            update POSM_list;
        } 
        
    }
    
}