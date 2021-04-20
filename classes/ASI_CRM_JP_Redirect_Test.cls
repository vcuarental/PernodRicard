/*********************************************************************************
 * Name:ASI_CRM_JP_Redirect_Test
 * Description: Test Class for ASI_CRM_JP_CallPlanRedirectController
 *                             ASI_CRM_JP_ContractRedirectController
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 20/06/2016       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_Redirect_Test{
    static testMethod void ASI_CRM_JP_CallPlanRedirect_Test(){
        ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'));
        ASI_CRM_Call_Plan__c plan2 = new ASI_CRM_Call_Plan__c();
        PageReference pageRef = Page.ASI_CRM_JP_CallPlanRedirectPage;
        pageRef.getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'));  
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(plan); 
        ASI_CRM_JP_CallPlanRedirectController controller = new ASI_CRM_JP_CallPlanRedirectController(sc);
        controller.redirect(); 
        sc = new ApexPages.StandardController(plan2);   
        try{  
            controller = new ASI_CRM_JP_CallPlanRedirectController(sc);
            controller.redirect(); 
        }catch(Exception e){
        
        }
    }
    
    static testMethod void ASI_CRM_JP_ContractRedirectController_Test(){
        ASI_CRM_Purchase_Contract__c contract = new ASI_CRM_Purchase_Contract__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'));
        ASI_CRM_Purchase_Contract__c contract2 = new ASI_CRM_Purchase_Contract__c();
        PageReference pageRef = Page.ASI_CRM_JP_ContractRedirectPage;
        pageRef.getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'));  
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(contract); 
        ASI_CRM_JP_ContractRedirectController controller = new ASI_CRM_JP_ContractRedirectController(sc);
        controller.redirect(); 
        sc = new ApexPages.StandardController(contract2);     
        controller = new ASI_CRM_JP_ContractRedirectController(sc);
        controller.redirect(); 
    }
    
    static testMethod void ASI_CRM_JP_InvoiceRedirectController_Test(){
        ASI_CRM_Payment_Invoice__c invoice = new ASI_CRM_Payment_Invoice__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice'));
        ASI_CRM_Payment_Invoice__c invoice2 = new ASI_CRM_Payment_Invoice__c();
        PageReference pageRef = Page.ASI_CRM_JP_InvoiceRedirectPage;
        pageRef.getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice'));  
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice); 
        ASI_CRM_JP_InvoiceRedirectController controller = new ASI_CRM_JP_InvoiceRedirectController(sc);
        controller.redirect(); 
        sc = new ApexPages.StandardController(invoice2);     
        controller = new ASI_CRM_JP_InvoiceRedirectController(sc);
        controller.redirect(); 
    }
}