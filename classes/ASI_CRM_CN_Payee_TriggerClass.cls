public without sharing class ASI_CRM_CN_Payee_TriggerClass {
	public ASI_CRM_CN_Payee_TriggerClass (){}
    
    public static void routineBeforeUpsert(list<ASI_CRM_CN_PH_Payee_Line_Item__c> trigger_new, map<id, ASI_CRM_CN_PH_Payee_Line_Item__c> trigger_oldMap) {
		Set<ID> AccountID = new Set<ID>();
		for(ASI_CRM_CN_PH_Payee_Line_Item__c p: trigger_new) {
            if(p.ASI_CRM_CN_Payee_T2__c != null) AccountID.add(p.ASI_CRM_CN_Payee_T2__c);
			if(p.ASI_CRM_CN_Payee_T1__c != null) AccountID.add(p.ASI_CRM_CN_Payee_T1__c);
        }

        Map<id, id> AccountMap = new Map<id, id>();
        for(ASI_CRM_AccountsAdditionalField__c c : [SELECT id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c in: AccountID]) {
            if(!AccountMap.containsKey(c.ASI_CRM_Account__c)) AccountMap.put(c.ASI_CRM_Account__c, c.id);
        }
    
		for(ASI_CRM_CN_PH_Payee_Line_Item__c p: trigger_new) {
            if(p.ASI_CRM_CN_Payee_T2__c != null && AccountMap.containsKey(p.ASI_CRM_CN_Payee_T2__c)) p.ASI_CRM_CN_Payee_Name_T2_lookup__c = AccountMap.get(p.ASI_CRM_CN_Payee_T2__c);
			if(p.ASI_CRM_CN_Payee_T1__c != null && AccountMap.containsKey(p.ASI_CRM_CN_Payee_T1__c)) p.ASI_CRM_CN_Payee_Name_T1__c = AccountMap.get(p.ASI_CRM_CN_Payee_T1__c);
        }
        
        //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
		setFinanceLastUpdated(trigger_new, trigger_oldMap);

    }    
    
    //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
    private static void setFinanceLastUpdated(list<ASI_CRM_CN_PH_Payee_Line_Item__c> trigger_new, map<id, ASI_CRM_CN_PH_Payee_Line_Item__c> trigger_oldMap) {
        for (ASI_CRM_CN_PH_Payee_Line_Item__c p : trigger_new) {
            if (trigger_oldMap == NULL) {
                if (p.ASI_CRM_CN_Invoice_Number__c != NULL) p.ASI_CRM_Finance_Last_Updated_By__c = UserInfo.getUserId();
            } else {
                if (p.ASI_CRM_CN_Invoice_Number__c != trigger_oldMap.get(p.Id).ASI_CRM_CN_Invoice_Number__c) p.ASI_CRM_Finance_Last_Updated_By__c = UserInfo.getUserId();
            }
        }
    }
    
}