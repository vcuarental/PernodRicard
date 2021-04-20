/*********************************************************************************************************************************
*  Company:Zimmic     Developer:Nicolás Marán      Date:23/03/2016    Test Class: LAT_AR_TaxCertificatesBeforeInsertUpdateDelete *    
**********************************************************************************************************************************/
@isTest
private class LAT_AR_TaxCertificatesTriggerTest {
	
	@isTest static void triggerTest() {
		Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
		insert acc;

		RCP_Receipt_ARG__c rec = new RCP_Receipt_ARG__c();
		rec.Account_AR__c = acc.id;
		rec.Status_AR__c = 'Receipt Issued Deposit pending';
		insert rec;

		TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c();
		tax.ReceiptNo_AR__c = rec.id;
		tax.name='abc';
		insert tax;
		update tax;
		delete tax;
	}
	
	
	
}