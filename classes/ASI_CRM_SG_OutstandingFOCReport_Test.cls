/*********************************************************************************
 * Name:ASI_CRM_SG_OutstandingFOCReport_Test
 * Description: Test all related code to the ASI_CRM_SG_OutstandingFOCReport
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-09       Laputa: Vincent Lam     Created
 * 2019-05-22       Wilken Lee	     		[WL 1.0] Add coverage for RTM scenario
*********************************************************************************/
@isTest
public class ASI_CRM_SG_OutstandingFOCReport_Test {
    
    public static testmethod void testController_RTM() {    
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList);
        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(false, 'Contract Approved');
        contractC.contract.ASI_TH_CRM_Start_Date__c = Date.today();
        contractC.contract.ASI_TH_CRM_End_Date__c = Date.today().addMonths(12);
        insert contractC.contract;
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(0));
        contractTargetC1.contractTarget.ASI_CRM_SG_Management_Incentives__c = 100;
        insert contractTargetC1.contractTarget;
        ASI_CRM_SG_TestClassHelper.freeGoodsData focData = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false,'ASI_CRM_SG_FOC','Approved');
        ASI_FOC_Free_Goods_Request__c foc = focData.freeGoods;
        foc.ASI_CRM_Contract__c = contractC.contract.id;
        insert foc;
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData  focItemData = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData (true,foc,skuList.get(0),'A&P Fund');
        
        test.starttest();
        
        PageReference pageRef = Page.ASI_CRM_SG_OutstandingFOCReport;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', contractC.contract.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contractC.contract);
        ASI_CRM_SG_OutstandingFOCReport controller = new ASI_CRM_SG_OutstandingFOCReport(sc);
        controller.init();
        
        test.stoptest();
    }
    
	/*[WL 1.0] BEGIN*/
	public static testmethod void testController_nonRTM() {    
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList);
        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(false, 'Contract Approved');
		
        contractC.contract.ASI_TH_CRM_Start_Date__c = Date.today();
        contractC.contract.ASI_TH_CRM_End_Date__c = Date.today().addMonths(12);
		contractC.contract.ASI_CRM_Contract_Exist_Before_RTM__c = true;	//WL 1.0
        insert contractC.contract;
		
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(0));
        contractTargetC1.contractTarget.ASI_CRM_SG_Management_Incentives__c = 100;
        insert contractTargetC1.contractTarget;
        ASI_CRM_SG_TestClassHelper.freeGoodsData focData = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false,'ASI_CRM_SG_FOC','Approved');
        ASI_FOC_Free_Goods_Request__c foc = focData.freeGoods;
        foc.ASI_CRM_Contract__c = contractC.contract.id;
        insert foc;
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData  focItemData = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData (true,foc,skuList.get(0),'Management Incentive');
        
        test.starttest();
        
        PageReference pageRef = Page.ASI_CRM_SG_OutstandingFOCReport;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', contractC.contract.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contractC.contract);
        ASI_CRM_SG_OutstandingFOCReport controller = new ASI_CRM_SG_OutstandingFOCReport(sc);
        controller.init();
        
        test.stoptest();
    }
    /*[WL 1.0] END*/
}