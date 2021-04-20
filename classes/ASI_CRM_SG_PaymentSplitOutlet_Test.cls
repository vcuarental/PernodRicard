/***************************************************************************************************************************
 * Name:        ASI_CRM_SG_PaymentSplitOutlet_Test
 * Description: Test class for ASI_CRM_SG_PaymentSplitOutlet_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-05-31       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_SG_PaymentSplitOutlet_Test {
    @IsTest static void testBehavior() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Yes');
        ASI_CRM_SG_TestClassHelper.paymentData paymentData = new ASI_CRM_SG_TestClassHelper.paymentData(true, contractC1);
        ASI_CRM_SG_TestClassHelper.paymentItemData paymentItemData = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentData.payment);
        ASI_CRM_SG_TestClassHelper.creditDebitNoteData creditDebitNoteData = new ASI_CRM_SG_TestClassHelper.creditDebitNoteData(true, contractC1.contract,customerC.customer,customerC.customer);
        ASI_CRM_SG_TestClassHelper.creditDebitNoteLineItemData creditDebitNoteLineItemData = new ASI_CRM_SG_TestClassHelper.creditDebitNoteLineItemData(true, creditDebitNoteData.creditDebitNote, [SELECT Id FROM ASI_MFM_Sub_brand__c LIMIT 1]);

        ApexPages.currentPage().getParameters().put('id', paymentData.payment.Id);
        ApexPages.currentPage().getParameters().put('type', 'Payment');
        ApexPages.currentPage().getParameters().put('OUTLET_ID_LIST_JSON', JSON.serialize(new List<String>{customerC.customer.Id}));


        ApexPages.StandardController sc = new ApexPages.StandardController(paymentData.payment);
        ASI_CRM_SG_PaymentSplitOutlet_Ctrl controller = new ASI_CRM_SG_PaymentSplitOutlet_Ctrl();

        controller.splitPaymentFromVFPage();

        ApexPages.currentPage().getParameters().put('id', creditDebitNoteData.creditDebitNote.Id);
        ApexPages.currentPage().getParameters().put('type', 'Credit');
        ASI_CRM_SG_PaymentSplitOutlet_Ctrl controller2 = new ASI_CRM_SG_PaymentSplitOutlet_Ctrl();
        controller2.splitPaymentFromVFPage();

    }
}