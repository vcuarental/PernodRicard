/*********************************************************************************
 * Name:ASI_CRM_SG_Payment_AppNotifiCtrl_Test
 * Description: Test all related code to the Payment approval email controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-06       Laputa: Vincent Lam     Created
*********************************************************************************/
@isTest
public class ASI_CRM_SG_Payment_AppNotifiCtrl_Test {
    
    public static testmethod void testEmail () {
    
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData outletData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.customerData vendorData = new ASI_CRM_SG_TestClassHelper.customerData(true, Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Supplier'));
        ASI_CRM_SG_TestClassHelper.paymentData paymentP = new ASI_CRM_SG_TestClassHelper.paymentData(true);
        ASI_CRM_SG_TestClassHelper.paymentItemData  paymentItemP = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentP.payment );
        ASI_CRM_SG_TestClassHelper.paymentData paymentPWOutlet = new ASI_CRM_SG_TestClassHelper.paymentData(true, outletData.customer, vendorData.customer);
        ASI_CRM_SG_TestClassHelper.paymentItemData  paymentItemPWOutlet = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentPWOutlet.payment );
        ASI_TH_CRM_PaymentRequest__c paymentTemp = paymentP.payment;
        
        test.starttest();
        
        ASI_CRM_SG_Payment_ApprovalNotifiCtrl controller = new ASI_CRM_SG_Payment_ApprovalNotifiCtrl();
        controller.paymentID = paymentTemp.id;
        controller.isGenerated = false;
        controller.getApproverName();
        controller.getChilds();
        controller.getHeader();
        controller.getSummary();
        
        test.stoptest();
        
        
    }
    
    
    
}