global with sharing class ASI_CRM_CN_AccountGradeGeneration_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String soqlQuery = 'SELECT Id,ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c,ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c, ASI_CRM_CN_CR12_Btl_per_month__c, ASI_CRM_CN_Grade__c FROM ASI_CRM_AccountsAdditionalField__c WHERE RecordType.DeveloperName = \'ASI_CRM_CN_WS\' OR RecordType.DeveloperName = \'ASI_CRM_Outlet_CN\'';
        
        System.debug('soqlQuery:' + soqlQuery);
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        List<ASI_CRM_CN_AccountGradingSetting__c> accountGradeSettings = [SELECT ASI_CRM_CN_Grade__c,ASI_CRM_CN_OnOff__c,ASI_CRM_CN_QtyFrom__c, ASI_CRM_CN_QtyTo__c, RecordTypeId FROM ASI_CRM_CN_AccountGradingSetting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_AccountGradingSetting_RcrdTyp'];
        
        if (accountGradeSettings  != null && accountGradeSettings.size() > 0){
            for(sObject sObj : scope){
                ASI_CRM_AccountsAdditionalField__c accountAdditional = (ASI_CRM_AccountsAdditionalField__c) sObj;
                
                if(accountAdditional.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c != null && accountAdditional.ASI_CRM_CN_CR12_Btl_per_month__c != null)
                {
                    for(ASI_CRM_CN_AccountGradingSetting__c accountGradeSetting : accountGradeSettings){
                        if(accountGradeSetting.ASI_CRM_CN_OnOff__c != null && accountGradeSetting.ASI_CRM_CN_OnOff__c == accountAdditional.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c){
                            if ((accountGradeSetting.ASI_CRM_CN_QtyFrom__c != null && accountAdditional.ASI_CRM_CN_CR12_Btl_per_month__c >= accountGradeSetting.ASI_CRM_CN_QtyFrom__c) && (accountGradeSetting.ASI_CRM_CN_QtyTo__c == null || (accountGradeSetting.ASI_CRM_CN_QtyTo__c != null && accountAdditional.ASI_CRM_CN_CR12_Btl_per_month__c <= accountGradeSetting.ASI_CRM_CN_QtyTo__c))){
                                accountAdditional.ASI_CRM_CN_Grade__c = accountGradeSetting.ASI_CRM_CN_Grade__c;
                                break;
                            }
                        }
                    }  
                }
                
                else if (accountAdditional.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c != null && accountAdditional.ASI_CRM_CN_CR12_Btl_per_month__c != null){
                    for(ASI_CRM_CN_AccountGradingSetting__c accountGradeSetting : accountGradeSettings){
                        if(accountGradeSetting.ASI_CRM_CN_OnOff__c != null && accountGradeSetting.ASI_CRM_CN_OnOff__c == accountAdditional.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c){
                            if ((accountGradeSetting.ASI_CRM_CN_QtyFrom__c != null && accountAdditional.ASI_CRM_CN_CR12_Btl_per_month__c >= accountGradeSetting.ASI_CRM_CN_QtyFrom__c) && (accountGradeSetting.ASI_CRM_CN_QtyTo__c == null || (accountGradeSetting.ASI_CRM_CN_QtyTo__c != null && accountAdditional.ASI_CRM_CN_CR12_Btl_per_month__c <= accountGradeSetting.ASI_CRM_CN_QtyTo__c))){
                                accountAdditional.ASI_CRM_CN_Grade__c = accountGradeSetting.ASI_CRM_CN_Grade__c;
                                break;
                            }
                        }
                    }        
                }
            }
            
            update scope;
        } 
    }
    
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest())
           database.executebatch(new ASI_CRM_CN_updateContractChannel_Batch());
    } 
}