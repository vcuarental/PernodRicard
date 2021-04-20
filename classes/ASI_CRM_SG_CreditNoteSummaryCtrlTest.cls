/*********************************************************************************
 * Name: ASI_CRM_SG_CreditNoteSummaryCtrlTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-22       Billy Lo                Created
 */
@isTest
private class ASI_CRM_SG_CreditNoteSummaryCtrlTest {

	private static testMethod void testController() {
	    
	    Test.startTest();
	    ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true);
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        ASI_CRM_SG_TestClassHelper.creditDebitNoteData creditDebitNoteC = new ASI_CRM_SG_TestClassHelper.creditDebitNoteData(true, contractC1.contract, customerC.customer, customerC.customer);
        ASI_CRM_SG_TestClassHelper.creditDebitNoteLineItemData creditDebitNoteLineItemC = new ASI_CRM_SG_TestClassHelper.creditDebitNoteLineItemData(true, creditDebitNoteC.creditDebitNote, subBrandList.get(0));
	    ApexPages.StandardController sc = new ApexPages.StandardController(creditDebitNoteC.creditDebitNote);
		ApexPages.currentPage().getParameters().put('Id', creditDebitNoteC.creditDebitNote.id);
	    ASI_CRM_SG_CreditNoteSummaryCtrl controller = new ASI_CRM_SG_CreditNoteSummaryCtrl(sc);
	    Test.stopTest();

	}

}