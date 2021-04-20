/*
 *********************************************************************************
 * Name: ASI_CRM_SG_ContractManageAll_Test
 * Description: Test class for ASI_CRM_SG_ContractManageAll_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/11/2017       Jeffrey Cheung          Created, only calculateBackRebatesAmountTest has assertions
 */
@isTest
private class ASI_CRM_SG_OfftakeChangeEmailPage_Test {

	private static testMethod void testController() {
	    
	    Test.startTest();

	    ASI_CRM_SG_TestClassHelper.createDataSettings();
	    ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
	    ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
		ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Yes');
	    ASI_TH_CRM_Contract__c c = contractC1.contract;
	    c.ASI_CRM_Sales_Revenue__c  = 100;
	    c.ASI_CRM_Sales_Revenue_Target__c  = 100;
	    List<ASI_TH_CRM_PaymentRequest__c> list_p = new List<ASI_TH_CRM_PaymentRequest__c>();
	    List<ASI_CRM_ContractSalesStaffIncentive__c> list_s = new List<ASI_CRM_ContractSalesStaffIncentive__c>();
	    List<String> list_contractId = new List<String>();
        list_contractId.add(c.Id);
	    PageReference pageRef = Page.ASI_CRM_SG_OfftakeChangeEmailPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', c.id);
	    
	    ASI_CRM_SG_OfftakeChangeEmailPage_Ctrl controller = new ASI_CRM_SG_OfftakeChangeEmailPage_Ctrl();
        controller.list_contractId = list_contractId;
	    controller.init();
	    
	    ASI_CRM_SG_OfftakeChangeEmailPage_Ctrl.Wrapper_Contract w = controller.list_wrapper.get(0);
	    w.c = c;
	    w.getSalesRevenueTarget();
	    w.getPaymentSize();
	    w.getYear_this();
	    w.getMonth_this();
	    w.getSalesRevenue_this();
	    w.getYear_previous();
	    w.getMonth_previous();
	    w.getSalesRevenue_previous();
	    w.getSalesRevenue_var();
	    

	    Test.stopTest();

	}

}