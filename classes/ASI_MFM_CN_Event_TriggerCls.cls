/* History                          Desc                          Log #                Status        Deployment State
 * -------------------------------------------------------------------------------------------------------------------
 * 2015-05-20 Alan Wong (Elufa)     Running Number Assignment     cn-sfdc-event-002    Developed
*/
public with sharing class ASI_MFM_CN_Event_TriggerCls{
    
    public static void routineBeforeUpdate(list<ASI_MFM_Event__c> trigger_new, map<id, ASI_MFM_Event__c> trigger_oldMap){
        Set<Id> setEvent = new Set<Id>();
        List<ASI_MFM_Event_PP__c> lstEventPP = new List<ASI_MFM_Event_PP__c>();
        
        for(ASI_MFM_Event__c i : trigger_new){
            if(Global_RecordTypeCache.getRt(i.recordTypeId).developerName.contains('ASI_MFM_CN')){
                if(i.Name != trigger_oldMap.get(i.id).Name){
                    setEvent.add(i.id);
                }
            }
        }
        
        if(setEvent.size() > 0){
            for(ASI_MFM_Event_PP__c i : [SELECT id, ASI_MFM_Event__r.Name FROM ASI_MFM_Event_PP__c WHERE ASI_MFM_Event__c IN :setEvent]){
                lstEventPP.add(i); //i.Name = i.ASI_MFM_Event__r.Name;
            }
        }
        
        for(ASI_MFM_Event_PP__c i : lstEventPP){
            i.Name = i.ASI_MFM_Event__r.Name;
        }
        
        update lstEventPP;
    }
    
    public static void routineBeforeInsert(list<ASI_MFM_Event__c> trigger_new){
        // Start cn-sfdc-event-002
       	ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_MFM_CN_Event');
        for (ASI_MFM_Event__c Event : trigger_new) {
            Event.ASI_MFM_Event_ID__c = autoNumAssign.nextAutoNumStr();
        }
        autoNumAssign.writeToDB();
        // End cn-sfdc-event-002
    }
}