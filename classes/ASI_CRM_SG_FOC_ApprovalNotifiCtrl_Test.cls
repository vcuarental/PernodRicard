/*********************************************************************************
 * Name:ASI_CRM_SG_FOC_ApprovalNotifiCtrl_Test
 * Description: Test all related code to the FOC approval email controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-06       Laputa: Vincent Lam     Created
*********************************************************************************/
@isTest
public class ASI_CRM_SG_FOC_ApprovalNotifiCtrl_Test {
    
    public static testmethod void testEmail () {
    
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(true);
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractData.contract, skuList[0]);
        ASI_CRM_SG_TestClassHelper.freeGoodsData focData = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true,'ASI_CRM_SG_FOC');
        ASI_FOC_Free_Goods_Request__c foc = focData.freeGoods;
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData  focItemData = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData (true,foc);
        ASI_CRM_SG_TestClassHelper.offtakeData offtakeData = new ASI_CRM_SG_TestClassHelper.offtakeData(true, 'ASI_CRM_SG_Actual_offtake', contractData.contract.Id, customerData.customer.Id, skuList[0].Id);
        
        ASI_CRM_FOC_Linkage__c focLinkage = new ASI_CRM_FOC_Linkage__c();
        focLinkage.ASI_CRM_FOC_Request_Item__c = focItemData.freeGoodsItem.Id;
        focLinkage.ASI_CRM_Actual_Offtake__c   = offtakeData.offtake.Id;
        focLinkage.ASI_CRM_Contract_Target__c  = contractTargetData.contractTarget.Id;
        focLinkage.ASI_CRM_Match_By__c         = 'SKU';
        insert focLinkage;
        
        test.starttest();
        
        ASI_CRM_SG_FOC_ApprovalNotifiController controller = new ASI_CRM_SG_FOC_ApprovalNotifiController();
        controller.focID = foc.id;
        controller.getApproverName();
        controller.getChilds();
        controller.getHeader();
        controller.getChildLinkages();
        
        test.stoptest();
        
        
    }
    
    
    
}