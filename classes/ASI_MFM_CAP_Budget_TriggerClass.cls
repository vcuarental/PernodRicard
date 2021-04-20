/*
*    Budget Trigger class tailored for Capex and Opex.
*/
public without sharing class ASI_MFM_CAP_Budget_TriggerClass {

    public static void routineBeforeInsert(list<ASI_MFM_Budget__c> trigger_new) {
        //Logic to update AC Code based on the inserted AP Code.
        Set<ID> apCodeIDSet = new Set<ID>();
        for(ASI_MFM_Budget__c budget : trigger_new)
        {
            if(budget.ASI_MFM_AP_Code__c != null)
                apCodeIDSet.add(budget.ASI_MFM_AP_Code__c);
        }
        
        Map<ID, ASI_MFM_AP_Code__c> apCodeMap = new Map<ID, ASI_MFM_AP_Code__c>([SELECT ID, Name, ASI_MFM_A_C_Code__c FROM ASI_MFM_AP_Code__c WHERE ID IN : apCodeIDSet]);
        
        for(ASI_MFM_Budget__c budget : trigger_new)
        {
            ASI_MFM_AP_Code__c apCode = apCodeMap.get(budget.ASI_MFM_AP_Code__c);
            if (apCode != null)
            {
                budget.ASI_MFM_A_C_Code__c = apCode.ASI_MFM_A_C_Code__c;
            }
        }
        
    }

}