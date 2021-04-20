/*********************************************************************************
 * Name: ASI_CRM_SG_ContractComparison_CtrlTest
 * Description: Test Class for ASI_CRM_SG_ContractComparison_Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/02/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_SG_ContractComparison_CtrlTest {

    @TestSetup
    public static void setupData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        
        ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        
        ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
        insert uploadLog;
        
        Attachment tempAttached = new Attachment();
        tempAttached.ParentId = uploadLog.Id;
        tempAttached.Name = 'Contract Comparison Result';
        tempAttached.Body = Blob.valueOf('Testing Content');
        insert tempAttached;
        
        for(integer i = 0 ; i < 2 ; i++) {
        	ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(false, customerData.customer);
        	contractData.contract.ASI_CRM_SG_PDF_Attachment__c = 'ContractComparsionPDF:' + tempAttached.Id + ';';
            contractList.add(contractData.contract);
        }
        insert contractList;
        
        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            for(ASI_MFM_SKU_Code__c sku : skuList) {
                ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contract, sku);
                contractTargetList.add(contractTargetData.contractTarget);
            }
        }
        insert contractTargetList;
    }
    
    public static testmethod void testController() {
        PageReference pageRef = Page.ASI_CRM_SG_ContractComparison_Page;
        Test.setCurrentPage(pageRef);
        
        ASI_CRM_SG_ContractComparison_Controller contractComparisonController = new ASI_CRM_SG_ContractComparison_Controller();
        List<Id> contractIdList = new List<Id>(); 
        for(ASI_TH_CRM_Contract__c contract : contractComparisonController.contractList) {
            contractIdList.add(contract.Id);
        }
        ApexPages.currentPage().getParameters().put('CONTRACT_ID_LIST_JSON', System.JSON.serialize(contractIdList));
        ApexPages.currentPage().getParameters().put('BASE_CONTRACT_ID', contractIdList.get(0));
        
        contractComparisonController.compareContractFromVFPage();
        
        
    }
    
    public static testmethod void testPDF() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        ASI_CRM_SG_ContractComparisonPDF_ComCtrl contractComparisonPDFCtrl = new ASI_CRM_SG_ContractComparisonPDF_ComCtrl();
        contractComparisonPDFCtrl.contractId = contract.Id;
        String body = contractComparisonPDFCtrl.getBody();
    }
}