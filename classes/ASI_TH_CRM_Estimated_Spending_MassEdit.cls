public with sharing class ASI_TH_CRM_Estimated_Spending_MassEdit {
    //public Opportunity opportunity {get;set;}
    public List<ASI_TH_CRM_Estimated_Spending__c> estimatedSpendingList {set;get;}          
    public ApexPages.StandardController standardController;
    
    //Modified by William Yang (Introv) to avoid the exception when Estimated Spending is already locked (ASI_TH_CRM_Locked__c = true)
    public List<ASI_TH_CRM_Estimated_Spending__c> updateEstimatedSpendingList = new List<ASI_TH_CRM_Estimated_Spending__c>();
    public Boolean commercialAnalyst {get;set;}
    public Boolean salesCo {get;set;}
    public Boolean CDP {get;set;}
    public Boolean systemAdmin {get;set;}
    public UserRole role {get;set;}
    public String profile {get;set;}
    public Boolean allowEdit {get;set;}
    public String contractStatus{get;set;}
    
    public ASI_TH_CRM_Estimated_Spending_MassEdit(ApexPages.StandardController controller) {
        //this.acct = (Account)stdController.getRecord();               
        standardController = controller;
        commercialAnalyst = false;
        salesCo = false;
        CDP = false;
        allowEdit = true;
        systemAdmin = false;
        
        estimatedSpendingList = [SELECT id, Name, ASI_TH_CRM_Fund_Advance__c, ASI_TH_CRM_Fund_Cash__c, ASI_TH_CRM_Fund_FOC__c, ASI_TH_CRM_Activity_Cash__c, 
        ASI_TH_CRM_Activity_FOC__c, ASI_TH_CRM_Locked__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Estimated_Spending__c where ASI_TH_CRM_Contract__c = :controller.getRecord().id
        ORDER BY ASI_TH_CRM_Date__c];
        
        
        //Modified by William Yang (Introv) 20140411
        if(estimatedSpendingList != null && estimatedSpendingList.size()>0)
            contractStatus = estimatedSpendingList[0].ASI_TH_CRM_Contract_Status__c;
        
        role = [SELECT Id, Name, DeveloperName FROM UserRole where id = :UserInfo.getUserRoleId() limit 1];
        profile = [SELECT Name FROM Profile where id = :UserInfo.getProfileId() limit 1].Name;
        
        if(role != null)
        {
            if(role.DeveloperName.contains('Commercial_Analyst'))
                commercialAnalyst = true;
            if(role.DeveloperName.contains('Sales_Co'))
                salesCo = true;
            if(role.DeveloperName.contains('On-Premise'))
                CDP = true;
            if(profile.contains('System Admin'))
                systemAdmin = true;
        }
        
        if(contractStatus != 'Freeze' && contractStatus != 'Editing')
            allowEdit = false;
        else if(contractStatus == 'Editing' && !commercialAnalyst && !salesCo && !systemAdmin)
            allowEdit = false;
    }
    
    public List<ASI_TH_CRM_Estimated_Spending__c> getEstimatedSpendingList(){
        return estimatedSpendingList;
    }
    
    public PageReference save() {
        
        //Modified by William Yang (Introv) to avoid the exception when Estimated Spending is already locked (ASI_TH_CRM_Locked__c = true)
        for(ASI_TH_CRM_Estimated_Spending__c es:estimatedSpendingList)
            if(es.ASI_TH_CRM_Locked__c == false || (es.ASI_TH_CRM_Locked__c && commercialAnalyst))
                updateEstimatedSpendingList.add(es);
        if(updateEstimatedSpendingList != null && updateEstimatedSpendingList.size()>0)
            update updateEstimatedSpendingList;
        PageReference cancel = standardController.cancel();
        
        return cancel;        
    }
}