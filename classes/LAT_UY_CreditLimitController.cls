/********************************************************************************
*                         Copyright 2014 - Zimmic
********************************************************************************/

public without sharing class LAT_UY_CreditLimitController{

    public string caseId;
    public string latCaseId;

    public string userId{get;set;}

    public Case tCase{get;set;}
    public LAT_Case__c tLAT_Case{get;set;}
    public String approvePage{get;set;}

    public LAT_UY_CreditLimitController(){
        
    }
    
    public void setCaseId(String id){
        caseId = id;
        List<Case> tmpList = [Select id, Account.Reason_for_Inactivation__c, owner.Name,Account.Name,Account.Corporate_Name__c,Account.Credit_line__c,Credit_Analysis_AR__r.CreditLimitRequested_ARG__c, Account.CurrencyIsoCode,Description from Case where id =: caseId];
        if(!tmpList.isEmpty()){
            tCase = tmpList[0];
            List<ProcessInstanceWorkitem> lstPr = [SELECT ProcessInstanceId,Id FROM ProcessInstanceWorkitem where ActorId=:userId and ProcessInstance.TargetObjectId =: caseId and ProcessInstance.status = 'pending'];
            if(!lstPr.isEmpty()){
                   approvePage = URL.getSalesforceBaseUrl().toExternalForm() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + lstPr[0].id;
            }
        }
        
    }
    
    public String getCaseId(){
        return caseId;
    }

    public void setlatCaseId(String id){
        latCaseId = id;
        List<LAT_Case__c> tmpList = [Select id, LAT_Account__r.Reason_for_Inactivation__c, owner.Name,LAT_Account__r.Name,LAT_Account__r.Corporate_Name__c,LAT_Account__r.Credit_line__c,LAT_AR_CreditAnalysis__r.CreditLimitRequested_ARG__c, LAT_Account__r.CurrencyIsoCode,LAT_Description__c from LAT_Case__c where id =: latCaseId];
        if(!tmpList.isEmpty()){
            tLAT_Case = tmpList[0];
            List<ProcessInstanceWorkitem> lstPr = [SELECT ProcessInstanceId,Id FROM ProcessInstanceWorkitem where ActorId=:userId and ProcessInstance.TargetObjectId =: latCaseId and ProcessInstance.status = 'pending'];
            if(!lstPr.isEmpty()){
                   approvePage = URL.getSalesforceBaseUrl().toExternalForm() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + lstPr[0].id;
            }
        }
        
    }
    
    public String getLatCaseId(){
        return latCaseId;
    }
    
    
}