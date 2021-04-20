public with sharing class ASI_CRM_MY_CalculatedPayment_TriggerCls {
	
    // Declaration
    public static String className = 'ASI_CRM_MY_CalculatedPayment_TriggerCls';
    
    
    
	public static void routineBeforeUpdate(list<ASI_CRM_Calculated_Payment__c > trigger_new, map<id, ASI_CRM_Calculated_Payment__c> trigger_oldMap) {

    }

    public static void routineBeforeUpsert(list<ASI_CRM_Calculated_Payment__c > trigger_new){

    }
    
    public static void routineAfterUpdate(list<ASI_CRM_Calculated_Payment__c> trigger_new, Map<Id, ASI_CRM_Calculated_Payment__c> trigger_oldMap) {
       
    }
    
    public static void routineAfterUpsert(list<ASI_CRM_Calculated_Payment__c> trigger_new) {
    	
		Set<Id> setContract = new Set<Id>();        
        for(ASI_CRM_Calculated_Payment__c i : trigger_new){
            if(i.ASI_CRM_Contract__c  != NULL){
                setContract.add(i.ASI_CRM_Contract__c);
            }
            
        }
        updateSummary(setContract);
        
    }
    
    public static void routineBeforeDelete(map<id, ASI_CRM_Calculated_Payment__c> trigger_oldMap) {
        Set<Id> setContract = new Set<Id>();       
        for (ASI_CRM_Calculated_Payment__c calcPayment : trigger_oldMap.values()){
            if(calcPayment.ASI_CRM_Contract__c != null){
                setContract.add(calcPayment.ASI_CRM_Contract__c);  
                
            }
        }
        system.debug('**setContract='+setContract);
        
        updateSummary(setContract);
    }
    
    public static void updateSummary(Set<Id> setContract){
        
        if(setContract.size() > 0){
            Map<Id, Decimal> mapContractPayment = new Map<Id, Decimal>();
            List<ASI_TH_CRM_Contract__c> lstContract = [SELECT id, ASI_CRM_MY_Accumulated_AP_Cash_ToDate__c FROM ASI_TH_CRM_Contract__c WHERE Id IN :setContract];
            
            for(AggregateResult i : [
                SELECT SUM(ASI_CRM_Total_Payment__c) totalPayment, ASI_CRM_Contract__c 
                FROM ASI_CRM_Calculated_Payment__c  
                WHERE ASI_CRM_Contract__c IN :setContract 
                AND ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c  = 'Final'
                AND ASI_CRM_Contract__r.ASI_CRM_Terminate__c = FALSE
                AND ASI_CRM_Incentive_Type__c = 'Other Incentive'
                AND ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = FALSE
                GROUP BY ASI_CRM_Contract__c 
            ]){
                Id idtemp = (Id) i.get('ASI_CRM_Contract__c');
                Decimal dectemp = (Decimal) i.get('totalPayment');
                mapContractPayment.put(idtemp, dectemp);
            }
        
            for(ASI_TH_CRM_Contract__c i : lstContract){
               i.ASI_CRM_MY_Accumulated_AP_Cash_ToDate__c = mapContractPayment.get(i.id) == null ? 0 : mapContractPayment.get(i.id);
            }
            
            try {
                update lstContract; // Temporary prevent to update the non edtiable contract because of the owner problem //TODO
            } catch (Exception e) {
                system.debug('ASI_CRM_MY_PaymentRequest_TriggerCls AfterTrigger  Update Contract Error:'+e);
            }
        
        }
    }

    
    
}