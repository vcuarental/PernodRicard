public without sharing class ASI_MFM_CN_VAT_Invoice_TriggerCls {
    
    public static void routineBeforeInsert(list<ASI_MFM_VAT_Invoice__c> trigger_new){
		getPOOwner(trigger_new);
    }
    
    private static void getPOOwner(list<ASI_MFM_VAT_Invoice__c> trigger_new){
        Map<Id, ASI_MFM_PO__c> poMap = new Map<Id, ASI_MFM_PO__c>();
        Set<Id> poSet = new Set<Id>();
        
        for(ASI_MFM_VAT_Invoice__c obj : trigger_new){
            if(obj.ASI_MFM_PO_No__c != null)
	            poSet.add(obj.ASI_MFM_PO_No__c);
        }
        
        if(!poSet.isEmpty()){
            poMap = new Map<Id, ASI_MFM_PO__c>([
                SELECT Id
                , OwnerId
                FROM ASI_MFM_PO__c
                WHERE Id IN :poSet
            ]);
            
            for(ASI_MFM_VAT_Invoice__c obj : trigger_new){
                if(obj.ASI_MFM_PO_No__c != null && poMap.containsKey(obj.ASI_MFM_PO_No__c)){
                    obj.ASI_MFM_PO_Owner__c = poMap.get(obj.ASI_MFM_PO_No__c).OwnerId;
                }
            }
        }
        
    }
}