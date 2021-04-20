@isTest
private class LAT_BR_VFP_31_NovoCadastroOverride_Test {
	
	static testMethod void UnitTest(){ 
		     
	    Test.startTest();
		ApexPages.currentPage().getParameters().put('save_new', 'testtest');
		ApexPages.currentPage().getParameters().put('null', null);
		LAT_BR_VFP_31_NovoCadastroOverride cont = new LAT_BR_VFP_31_NovoCadastroOverride();
		cont.authorized();
		Test.stopTest();

	}

	static testMethod void UnitTest2(){ 
		     
	    Test.startTest();
	    new LAT_CreditStatusHandler_1.ClientInfoType();
	    new LAT_CreditStatusHandler_1.result_element();
	    new LAT_CreditStatusHandler_1.getCreditStatus_element();
	    new LAT_CreditStatusHandler_1.getCreditStatusResponse_element();
	    new LAT_CreditStatusHandler_1.GetCustomerCreditStatusSFDCReqSOAP();






		Test.stopTest();

	}
	


}