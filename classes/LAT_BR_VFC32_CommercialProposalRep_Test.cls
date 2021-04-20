@isTest
private class LAT_BR_VFC32_CommercialProposalRep_Test {
	
	@isTest static void test_method_one() {
		

		Account a = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
		a.Client_country_An8__c = '1-8899';
		insert a;
	    Attachment lAtt = new Attachment();
	    lAtt.ParentId = a.id; 
	    lAtt.name = 'propostacomercialTest';
	    lAtt.Body = Blob.valueof( 'asdasd' );
	    insert lAtt;
	    new LAT_BR_VFC32_CommercialProposalRepCont();

	}
	

	
}