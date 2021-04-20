/*********************************************************************************
 * Name: ASI_CRM_SG_AdjustOfftakesControllerTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-21       Billy Lo                Created
 */
@isTest
private class ASI_CRM_SG_AdjustOfftakesControllerTest {

	private static testMethod void testController() {
	    
	    Test.startTest();
	    
	    PageReference pageRef = Page.ASI_CRM_SG_AdjustOfftakes_Page;
        Test.setCurrentPage(pageRef);
	    
	    ASI_CRM_SG_AdjustOfftakesController controller = new ASI_CRM_SG_AdjustOfftakesController();
	    ASI_CRM_SG_AdjustOfftakesHelper helper = new ASI_CRM_SG_AdjustOfftakesHelper();
	    controller.init();
	    controller.runSearch();
	    controller.countSearch();
	    controller.refleshSearch();
	    
	    ASI_CRM_SG_TestClassHelper.createDataSettings();
	    ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
	    ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
		ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Yes');
	    List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
	    ASI_CRM_SG_TestClassHelper.offtakeData offtakeC = new ASI_CRM_SG_TestClassHelper.offtakeData(true, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, customerC.customer.Id, skuList.get(0).Id);
	    ASI_TH_CRM_Actual_Offtake__c offtake = offtakeC.offtake;
	    offtake.ASI_CRM_Temp_Checkbox__c = true;
	    offtake.ASI_TH_CRM_Quantity__c = 100;
	    offtake.ASI_CRM_Original_Quantity__c = 50;
	    List < ASI_TH_CRM_Actual_Offtake__c > offtakes = new List < ASI_TH_CRM_Actual_Offtake__c >();
	    offtakes.add(offtake);
	    controller.searchResult = offtakes;
	    controller.filterWrapper = offtake;
	    controller.filterDateFrom = date.newInstance(2000, 11, 1);
	    controller.filterDateTo = date.newInstance(2099, 11, 1);
	    controller.map_offtakeId_oldContractId.put(offtake.Id, offtake.ASI_CRM_Contract__c);
	    controller.saveOfftakes();
	    controller.deleteOfftakes();
	    controller.confirmOfftakes();
	    controller.Beginning();
	    controller.getDisablePrevious();
	    controller.getDisableNext();
	    controller.getPageNumber();
	    controller.getTotalPages();
	    controller.Next();
	    controller.Previous();
	    controller.End();
	    controller.getActualMonthString();
	    controller.getActualMonthConfirmed();
	    controller.runSearch();
	    
	    List<ASI_CRM_AccountsAdditionalField__c> wsList = new List<ASI_CRM_AccountsAdditionalField__c>();
	    wsList.add(customerC.customer);
	    helper.getConfirmOfftakesMessage(wsList, 2099, 1);
	    helper.getOutletMismatchMessage(contractC1.contract);
	    helper.sendOfftakeChangeEmail(offtakes);
	    helper.sendMail('a@a.com', 'subject', 'body');

	    Test.stopTest();

	}

}