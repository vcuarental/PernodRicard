/* Filename:  ASI_MFM_CN_PaymentLineItem_TriggerClass.cls
 * Author:    Michael Yip (Introv Limited)
 * Purpose:    Handle CN Payment Line Item Trigger Logic
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2012-06-04  michael.yip@introv.com    Create
 * 
 */
public with sharing class ASI_MFM_AP_Code_TriggerClass {
   

    public static void routineBeforeInsert(list<ASI_MFM_AP_Code__c> trigger_new) {
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_AP_Code__c')){
            MRecType.put(rec.developername,rec.id);
        }

        String TRRecTypeID = MRecType.get('ASI_MFM_TR_AP_Code');
        
        list<ASI_MFM_AP_Code__c> px_map = new list<ASI_MFM_AP_Code__c>([select id, ASI_MFM_AP_Code__c, ASI_MFM_TR_Rec_Type__c from ASI_MFM_AP_Code__c where RecordTypeid = :TRRecTypeID and ASI_MFM_Inactive__c = false ]);
        boolean checkDuplicate = false;
        for (ASI_MFM_AP_Code__c newAP:trigger_new) { 
             for (ASI_MFM_AP_Code__c allAP:px_map) { 
                if (allAP.ASI_MFM_AP_Code__c == newAP.ASI_MFM_AP_Code__c && allAP.ASI_MFM_TR_Rec_Type__c == newAP.ASI_MFM_TR_Rec_Type__c){
                    newAP.addError('The AP Code must be unique.');
                }               
             }
            
        }
             
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_AP_Code__c> trigger_new, map<id, ASI_MFM_AP_Code__c> trigger_oldMap) {
        // Changed: Edited by Steve Wan (Introv) 09Jun2014
        Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
        boolean isuserAdmin = prof.name.contains('System Administrator');
       for (ASI_MFM_AP_Code__c pi:trigger_new) {
           if (pi.ASI_MFM_AP_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_AP_Code__c && !isuserAdmin)
            {
                pi.addError('Cannot change AP Code after creation');
            }
        }
       
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_AP_Code__c')){
            MRecType.put(rec.developername,rec.id);
        }

        String TRRecTypeID = MRecType.get('ASI_MFM_TR_AP_Code');
        
        list<ASI_MFM_AP_Code__c> px_map = new list<ASI_MFM_AP_Code__c>([select id, ASI_MFM_AP_Code__c, ASI_MFM_TR_Rec_Type__c from ASI_MFM_AP_Code__c where RecordTypeid = :TRRecTypeID and ASI_MFM_Inactive__c = false AND id NOT IN:trigger_new ]);
        boolean checkDuplicate = false;
        for (ASI_MFM_AP_Code__c newAP:trigger_new) { 
             for (ASI_MFM_AP_Code__c allAP:px_map) { 
                if (allAP.ASI_MFM_AP_Code__c == newAP.ASI_MFM_AP_Code__c && allAP.ASI_MFM_TR_Rec_Type__c == newAP.ASI_MFM_TR_Rec_Type__c){
                    newAP.addError('The AP Code must be unique.');
                }               
             }
            
        }
        
        
    }
    
}