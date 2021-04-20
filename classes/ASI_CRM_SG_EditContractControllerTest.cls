/**********************************************************************************
 * Name : ASI_CRM_SG_EditContractControllerTest
 * Created : DC @04/19/2016 12:43 PM
 * Revision History:
 * 1. 04/19/2016 - [DC 1.0] Created
 * 1. 04/21/2016 - [DC 1.1] Added revision history
 **********************************************************************************/

@isTest
private class ASI_CRM_SG_EditContractControllerTest {
    
    private static ASI_TH_CRM_Contract__c contractInstance = new ASI_TH_CRM_Contract__c();

    @TestSetup
    private static void setupData() {

   /*     ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Contract_No',
            ASI_HK_CRM_Running_Number__c = 1,
            ASI_HK_CRM_Format__c = 'PRS-{YY}-{0000}',
            ASI_HK_CRM_Fiscal_Year__c = 2016,
            ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7
        );
        insert runningNumber;*/
        
        ASI_CRM_SG_TestClassHelper.customerData customerD = new ASI_CRM_SG_TestClassHelper.customerData(true);
        
        Id contractRecTypeId = Schema.SObjectType.ASI_TH_CRM_Contract__c
                                                 .getRecordTypeInfosByName()
                                                 .get('ASI CRM SG 1. Proposal').getRecordTypeId();

        contractInstance = new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Start_Date__c = Date.today(),
            ASI_CRM_CN_Outlet_WS__c = customerD.customer.Id,
            RecordTypeId = contractRecTypeId
        );

        insert contractInstance;
    }

    static testMethod void testEditExisting() {
        contractInstance = [SELECT Id, RecordTypeId FROM ASI_TH_CRM_Contract__c LIMIT 1];

        System.Test.setCurrentPage(Page.ASI_CRM_SG_EditContractPage);
        ApexPages.currentPage().getParameters().put('RecordType', contractInstance.RecordTypeId);

        ASI_CRM_SG_EditContractController controllerInstance =
            new ASI_CRM_SG_EditContractController(
                new ApexPages.StandardController(contractInstance)
            );

        controllerInstance.pageBlockTitle = '';
        controllerInstance.titleInformation = '';
        controllerInstance.titleMarketing = '';
        controllerInstance.titleIndicator = '';
        controllerInstance.titleSummary = '';
        controllerInstance.titleSysInformation = '';

        controllerInstance.save();
    }

    static testMethod void testCreateNew() {

        Id contractRecTypeId = Schema.SObjectType.ASI_TH_CRM_Contract__c
                                                 .getRecordTypeInfosByName()
                                                 .get('ASI CRM SG Proposal (Read-Only)').getRecordTypeId();
        
        System.Test.setCurrentPage(Page.ASI_CRM_SG_EditContractPage);
        ApexPages.currentPage().getParameters().put('RecordType', contractRecTypeId);

        ASI_CRM_SG_EditContractController controllerInstance =
            new ASI_CRM_SG_EditContractController(
                new ApexPages.StandardController(contractInstance)
            );

        controllerInstance.pageBlockTitle = '';
        controllerInstance.titleInformation = '';
        controllerInstance.titleMarketing = '';
        controllerInstance.titleIndicator = '';
        controllerInstance.titleSummary = '';
        controllerInstance.titleSysInformation = '';

        controllerInstance.save();
    }
}