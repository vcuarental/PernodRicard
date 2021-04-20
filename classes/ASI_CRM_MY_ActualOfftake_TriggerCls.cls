/*********************************************************************************
 * Name:        ASI_CRM_MY_ActualOfftake_TriggerClass--> ASI_CRM_MY_ActualOfftake_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-16       Introv: Daniel WONG     Created
*********************************************************************************/

public without sharing class ASI_CRM_MY_ActualOfftake_TriggerCls{
    public static String className = 'ASI_CRM_MY_ActualOfftake_TriggerCls';
    //public static Map<String, Set<id>> mapMYGroup_user = ASI_CRM_MY_Function.getMYGroup();
    
    public static void routineBeforeUpsert(list<ASI_TH_CRM_Actual_Offtake__c> trigger_new){ 
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {      
            for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){
                // Only to generate customer number for potential outlet
                if(i.recordTypeId ==  Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake')){
                    if(i.ASI_CRM_Adjustment__c == FALSE){
                        string tempID = '';
                        tempID = string.valueof(i.ASI_CRM_InvoiceNumber__c) + '_' +
                                 string.valueof(i.ASI_CRM_FromWS__c) + '_' +
                                 string.valueof(i.ASI_CRM_SKU__c);
                        i.ASI_TH_CRM_Actual_Offtake_External_ID__c = tempID;
                    }else{
                        //if(mapMYGroup_user.get('ASI_CRM_MY_Offtake_Adjustment') != NULL){
                            //if(mapMYGroup_user.get('ASI_CRM_MY_Offtake_Adjustment').CONTAINS(UserInfo.getUserId()))
                            if(ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_Offtake_Adjustment'))
                                i.ASI_TH_CRM_Actual_Offtake_External_ID__c = '';
                            else
                                i.addError('No permission allowed to adjust the record.');
                        //}else{
                        //    i.addError('No user allowed to adjust the record.');
                        //}                    
                    }
                }
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_TH_CRM_Actual_Offtake__c> trigger_old) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            Set<Id> setActualOffTakeHeaderId = new Set<Id>();
            List<ASI_CRM_ActualOfftakeHeader__c> listActualOffTakeHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
            Map<id, ASI_CRM_ActualOfftakeHeader__c> mapActualOffTakeHeader = new Map<id, ASI_CRM_ActualOfftakeHeader__c>();
            
            for(ASI_TH_CRM_Actual_Offtake__c aoff : trigger_old){
                setActualOffTakeHeaderId.add(aoff.ASI_CRM_ActualOfftakeHeader__c);
            }
            listActualOffTakeHeader = [SELECT id, ASI_CRM_Status__c FROM ASI_CRM_ActualOfftakeHeader__c WHERE id IN: setActualOffTakeHeaderId];
            
            for(ASI_CRM_ActualOfftakeHeader__c a : listActualOffTakeHeader){
                mapActualOffTakeHeader.put(a.id, a);
            }
            
            for(ASI_TH_CRM_Actual_Offtake__c aoff : trigger_old){
                if(mapActualOffTakeHeader.get(aoff.ASI_CRM_ActualOfftakeHeader__c) != null && mapActualOffTakeHeader.get(aoff.ASI_CRM_ActualOfftakeHeader__c).ASI_CRM_Status__c == 'Final'){
                    aoff.addError('Record(s) cannot be deleted.');
                }
            }
        }
    }
}