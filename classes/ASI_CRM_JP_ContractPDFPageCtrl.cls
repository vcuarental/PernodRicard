/**********************************************************************************
 * Name : ASI_CRM_JP_ContractPDFPageCtrl
 * Created : DC @04/26/2016 12:56 PM
 * Revision History:
 * 1. 04/26/2016 - [DC 1.0] Created
 **********************************************************************************/

public with sharing class ASI_CRM_JP_ContractPDFPageCtrl {
    
    public String action {get;set;}
    public String pageMargin {get;set;}
    public String firstMargin {get;set;}
    private ASI_CRM_Purchase_Contract__c contract; 
    private Id paymentId;

    public ASI_CRM_JP_ContractPDFPageCtrl(ApexPages.StandardController controller) {
        contract = (ASI_CRM_Purchase_Contract__c )controller.getRecord();
        contract = [Select Id,RecordType.DeveloperName From ASI_CRM_Purchase_Contract__c Where Id = :contract.Id];
        setMargin();
    }

    public void setMargin(){

        if(contract.RecordType.DeveloperName.contains('ASI_CRM_JP_SPTD_Contract'))   {
                pageMargin = '200px';
                firstMargin = '180px';
        } else 
        if(contract.RecordType.DeveloperName.contains('ASI_CRM_JP_Direct_Rebate_Contract'))   {
                pageMargin = '165px';
                firstMargin = '145px';
        } else 
        if(contract.RecordType.DeveloperName.contains('ASI_CRM_JP_Indirect_Rebate_Contract'))   {
                pageMargin = '175px';
                firstMargin = '145px';
        } 

    }    
    
}