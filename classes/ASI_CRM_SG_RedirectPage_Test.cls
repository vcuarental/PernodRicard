/*********************************************************************************
 * Name: ASI_CRM_SG_RedirectPage_Test
 * Description: Test ASI_CRM_RedirectContractNew_Ctr and ASI_CRM_RedirectContractEdit_Ctr 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-15       Laputa: Hugo Cheung     Created (Clone From ASI_CRM_RedirectPage_Test)
 * 2016-08-04       Laputa: Hugo Cheung     Updated. Add test setup function  
 */

@isTest
private class ASI_CRM_SG_RedirectPage_Test {
    
    @TestSetup
    public static void setupTestData() {

    }

    static testMethod void ASI_CRM_RedirectContract_Test() {
        //---- covered classes: ----
        //---- 1. ASI_CRM_RedirectContractEdit_Ctr ----
        //---- 2. ASI_CRM_RedirectContractNew_Ctr ----
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.contractData contractD1 = new ASI_CRM_SG_TestClassHelper.contractData(false);
        ASI_CRM_SG_TestClassHelper.contractData contractD2 = new ASI_CRM_SG_TestClassHelper.contractData(false);
        ASI_CRM_SG_TestClassHelper.contractData contractD3 = new ASI_CRM_SG_TestClassHelper.contractData(false);
        ASI_CRM_SG_TestClassHelper.contractData contractD4 = new ASI_CRM_SG_TestClassHelper.contractData(false);

        contractD1.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract');
        contractD2.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only');
        contractD3.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        contractD4.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');

        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        contractList.add(contractD1.contract);
        contractList.add(contractD2.contract);
        contractList.add(contractD3.contract);
        contractList.add(contractD4.contract);
        insert contractList;

        test.startTest();
        
        ApexPages.StandardController stdController4 = new ApexPages.StandardController(contractD1.contract);
        ApexPages.StandardController stdController5 = new ApexPages.StandardController(contractD2.contract);
        ApexPages.StandardController stdController6 = new ApexPages.StandardController(contractD3.contract); 
        ApexPages.StandardController stdController7 = new ApexPages.StandardController(contractD4.contract); 

        ASI_CRM_RedirectContractNew_Ctr controllerNew4 = new ASI_CRM_RedirectContractNew_Ctr(stdController4);
        ASI_CRM_RedirectContractNew_Ctr controllerNew5 = new ASI_CRM_RedirectContractNew_Ctr(stdController6);
        controllerNew4.redirect();
        controllerNew5.redirect();

        ASI_CRM_RedirectContractEdit_Ctr controllerEdit3 = new ASI_CRM_RedirectContractEdit_Ctr(stdController4);        
        ASI_CRM_RedirectContractEdit_Ctr controllerEdit4 = new ASI_CRM_RedirectContractEdit_Ctr(stdController5);
        ASI_CRM_RedirectContractEdit_Ctr controllerEdit5 = new ASI_CRM_RedirectContractEdit_Ctr(stdController6);        
        ASI_CRM_RedirectContractEdit_Ctr controllerEdit6 = new ASI_CRM_RedirectContractEdit_Ctr(stdController7);
        controllerEdit3.redirect();
        controllerEdit4.redirect();
        controllerEdit5.redirect();
        controllerEdit6.redirect();

        test.stopTest();       
    }
    
}