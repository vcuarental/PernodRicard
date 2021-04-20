public with sharing class ASI_CRM_PH_TriggerCls {
	public static void routineBeforeDelete(list<ASI_HK_CRM_Visitation_Plan_Detail__c> trigger_old) {
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : trigger_old){
            if(vpd.ASI_CRM_Locked__c == True){
                vpd.addError('Visitation Plan Detail is Locked and CANNOT be deleted.');
            }
        }
    }
}