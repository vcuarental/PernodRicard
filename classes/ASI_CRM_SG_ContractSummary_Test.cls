/*********************************************************************************
 * Name:ASI_CRM_SG_ContractSummary_Test
 * Description: Test all related code to the ASI_CRM_SG_ContractSummary
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-11       Laputa: Vincent Lam     Created
*********************************************************************************/
@isTest
public class ASI_CRM_SG_ContractSummary_Test {
    
    public static testmethod void testController () {
    
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList);
        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(true, 'Contract Approved');
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractC.contract, skuList.get(0));
        
        test.starttest();
        
        PageReference pageRef = Page.ASI_CRM_SG_ContractSummary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', contractC.contract.id);
        ApexPages.currentPage().getParameters().put('external', '0');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contractC.contract);
        ASI_CRM_SG_ContractSummary controller = new ASI_CRM_SG_ContractSummary(sc);
        controller.init();
        controller.getContract();
        controller.getContractTarget();
        controller.getContractOutlet();
        
        test.stoptest();
        
        
    }
    
    
    
}