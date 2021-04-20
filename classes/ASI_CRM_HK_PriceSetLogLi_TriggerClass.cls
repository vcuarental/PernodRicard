public class ASI_CRM_HK_PriceSetLogLi_TriggerClass {

    public static void routineBeforeUpSert(list<ASI_CRM_Price_Set_Generation_Log_Detail__c> trigger_new) {
        
        Set<Id> headerIdSet = new Set<Id>();
        
        for(ASI_CRM_Price_Set_Generation_Log_Detail__c obj : trigger_new){
            
            headerIdSet.add(obj.ASI_CRM_Price_Set_Generation_Log__c);
        }
        
        List<ASI_CRM_Price_Set_Generation_Log_Detail__c> lineItemList = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>([SELECT id
                                                                                                                              , ASI_CRM_Pre_Approval_Form__c
                                                                                                                              , ASI_CRM_Price_Set_Generation_Log__c
                                                                                                                              FROM ASI_CRM_Price_Set_Generation_Log_Detail__c
                                                                                                                              WHERE ASI_CRM_Price_Set_Generation_Log__c IN : headerIdSet
                                                                                                                              AND id NOT IN : trigger_new
                                                                                                                             ]);
        
        Set<String> validationSet = new Set<String>();
        
        for(ASI_CRM_Price_Set_Generation_Log_Detail__c obj : lineItemList){
            
            validationSet.add(obj.ASI_CRM_Price_Set_Generation_Log__c + '' + obj.ASI_CRM_Pre_Approval_Form__c);
        }
        
        for(ASI_CRM_Price_Set_Generation_Log_Detail__c obj : trigger_new){
            
            if(validationSet.contains(obj.ASI_CRM_Price_Set_Generation_Log__c + '' + obj.ASI_CRM_Pre_Approval_Form__c))
                obj.addError('Duplicated Pre-Approval Form found');
            if(!validationSet.contains(obj.ASI_CRM_Price_Set_Generation_Log__c + '' + obj.ASI_CRM_Pre_Approval_Form__c))
                validationSet.add(obj.ASI_CRM_Price_Set_Generation_Log__c + '' + obj.ASI_CRM_Pre_Approval_Form__c);
        }
    }
    
    public static void routineAfterInsert(list<ASI_CRM_Price_Set_Generation_Log_Detail__c> trigger_new) {
        Set<id> PSDraftGenSet = new Set<id>();
        Set<Id> headerIdSet = new Set<Id>();
        for(ASI_CRM_Price_Set_Generation_Log_Detail__c obj : trigger_new){
            headerIdSet.add(obj.ASI_CRM_Price_Set_Generation_Log__c);
        }
        List<ASI_CRM_Price_Set_Generation_Log_Detail__c> lineItemList 
            = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>([SELECT id
                                                                    , ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Status__c
                                                                    FROM ASI_CRM_Price_Set_Generation_Log_Detail__c
                                                                    WHERE ASI_CRM_Price_Set_Generation_Log__c IN : headerIdSet]);
        System.debug('LCheck:-'+lineItemList);
        for (ASI_CRM_Price_Set_Generation_Log_Detail__c line: lineItemList) {
            //Status: Draft
            if(line.ASI_CRM_Price_Set_Generation_Log__r.ASI_CRM_Status__c == 'Draft') {
                    System.debug('LCheck:-'+line.id);
                    PSDraftGenSet.add(line.id);
            }
        }
        if (PSDraftGenSet.size() > 0){
            List<ASI_HK_CRM_Pre_Approval_Form__c> updatePAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            List<ASI_CRM_Price_Set_Generation_Log_Detail__c> PSLogItems = [SELECT id, ASI_CRM_Pre_Approval_Form__c FROM ASI_CRM_Price_Set_Generation_Log_Detail__c WHERE Id IN: PSDraftGenSet];
            for (ASI_CRM_Price_Set_Generation_Log_Detail__c PSLItem: PSLogItems) {
                ASI_HK_CRM_Pre_Approval_Form__c PAF = new ASI_HK_CRM_Pre_Approval_Form__c(id = PSLItem.ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Price_Set_Generation_Status__c = 'Draft'); 
                updatePAF.add(PAF);
            }
            update updatePAF;
        }
    }
}