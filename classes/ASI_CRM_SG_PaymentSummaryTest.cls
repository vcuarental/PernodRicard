/***************************************************************************************************************************
 * Name:        ASI_CRM_SG_PaymentSummaryTest
 * Description: Test class for ASI_CRM_SG_PaymentSummaryCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-05-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_SG_PaymentSummaryTest {
    @IsTest static void testBehavior() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Yes');
        ASI_CRM_SG_TestClassHelper.paymentData paymentData = new ASI_CRM_SG_TestClassHelper.paymentData(true, contractC1);
        ASI_CRM_SG_TestClassHelper.paymentItemData paymentItemData = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentData.payment);


        ApexPages.StandardController sc = new ApexPages.StandardController(paymentData.payment);
        ASI_CRM_SG_PaymentSummaryCtrl controller = new ASI_CRM_SG_PaymentSummaryCtrl(sc);

    }
}