public without sharing class EUR_CRM_FI_SubChainExt {

    private ApexPages.StandardController standardController {get;set;}

    public EUR_CRM_Contract__c contractObj{get; set;}

    public List<EUR_CRM_Account__c> chainAccounts {get;set;}

    public EUR_CRM_FI_SubChainExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        contractObj = (EUR_CRM_Contract__c )standardController.getRecord();

        retrieveChainAccounts();
    }

    public void retrieveChainAccounts(){
        chainAccounts = new List<EUR_CRM_Account__c>();

        chainAccounts = [SELECT Id, Name FROM EUR_CRM_Account__c WHERE EUR_CRM_Parent_Account__c = :contractObj.EUR_CRM_Account__c];
    }


}