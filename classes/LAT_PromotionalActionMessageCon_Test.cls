@isTest
private class LAT_PromotionalActionMessageCon_Test {

	@isTest static void LAT_PromotionalActionMessageController() {

		LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
		Account acc = getAccount();
		Test.startTest();
		LAT_AccountInAction__c aiac = createAccountInAction(ap.id, acc.Id);
		aiac.ClientNotAdhering__c = true;
		update aiac;
			ApexPages.CurrentPage().getparameters().put('id', ap.id);
			ApexPages.StandardController apStandard = new ApexPages.StandardController(ap);

        	LAT_PromotionalActionMessageController cl = new LAT_PromotionalActionMessageController(apStandard);
		Test.stopTest();
	}

  	public static LAT_AccountInAction__c createAccountInAction(String apId, String accId) {


	    LAT_AccountInAction__c aia = new LAT_AccountInAction__c();
	    aia.LAT_Account__c = accId;
	    aia.LAT_PromotionalAction__c = apId;
		aia.LAT_Status__c = 'Cliente Validado';
		aia.LAT_Execute__c = true;
	    insert aia;

	    return aia;
  	}

  	public static Account getAccount(){
	    Account acc = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
	    acc.LAT_BR_RegionalClientOnPremise__c = 'REG NE';
	    insert acc;
	    return acc;
  	}

}