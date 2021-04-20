/*********************************************************************************
 * Name: ASI_CRM_TH_UpdateOutstandingPR_Batch 
 * Description: Retrieve current CDP and RSM names of outstanding (CRM PO - JDE PO != 0) PR
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/27/2016       Introv: Twinkle LI      Created
*********************************************************************************/

global with sharing class ASI_CRM_TH_UpdateOutstandingPR_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC){  
        Id PRrecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request');
        String soqlQuery = 'SELECT Id, Name, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.OwnerId, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.Owner.ManagerId FROM ASI_TH_CRM_PaymentRequest__c WHERE (ASI_CRM_CDP__c = NULL OR ASI_CRM_RSM__c = NULL OR ASI_CRM_CRMPO_JDEPO__c != 0) AND RecordTypeId ='+ '\'' +PRrecordTypeId+ '\'';
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){  
        if (scope == null) return;
        
        List<ASI_TH_CRM_PaymentRequest__c> listToUpdatePR = new List<ASI_TH_CRM_PaymentRequest__c>();
        for(sObject sObj : scope){
            ASI_TH_CRM_PaymentRequest__c pr = (ASI_TH_CRM_PaymentRequest__c) sObj;
            pr.ASI_CRM_CDP__c = pr.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.OwnerId;
            pr.ASI_CRM_RSM__c = pr.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.Owner.ManagerId;
            listToUpdatePR.add(pr);
            
            system.debug('CDP: '+pr.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.OwnerId);
            system.debug('RSM: '+pr.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.Owner.ManagerId);
        } 
        update listToUpdatePR;           
    }

    global void finish(Database.BatchableContext BC){
        system.debug('finish running!');
    } 
}