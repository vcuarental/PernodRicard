/*********************************************************************************
 * Name:ASI_CRM_JP_SetContractDraftController
 * Description: Change the Staus of Contract to Draft
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 * 31/07/2015       Laputa: Hank            Created
*********************************************************************************/
public without sharing class ASI_CRM_JP_SetContractDraftController{
    private ASI_CRM_Purchase_Contract__c contract;
    public ASI_CRM_JP_SetContractDraftController(ApexPages.StandardController controller){
        contract = (ASI_CRM_Purchase_Contract__c)controller.getRecord();
        contract = [Select ASI_CRM_Status__c From ASI_CRM_Purchase_Contract__c Where Id = :contract.Id];
    }
    public PageReference save(){
        contract.ASI_CRM_Status__c = 'Draft';
        update contract;
        PageReference contractPage = new ApexPages.StandardController(contract).view();
        contractPage.setRedirect(true);
        return contractPage;
    }
}