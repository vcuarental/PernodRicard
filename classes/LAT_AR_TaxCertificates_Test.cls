/*************************************************************************************************************
*  Company:Zimmic     Developer:Nicolás Marán      Date:23/03/2016    Test Class: LAT_AR_TaxCertificates     *
**************************************************************************************************************/
@isTest
private class LAT_AR_TaxCertificates_Test {
	
	@isTest static void TaxCertificatesCheckPrintStatusTest() {
			Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
		insert acc;

		RCP_Receipt_ARG__c rec = new RCP_Receipt_ARG__c();
		rec.Account_AR__c = acc.id;
		rec.Status_AR__c = 'Receipt printed Deposit done';
		insert rec;

		TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c();
		tax.ReceiptNo_AR__c = rec.id;
		insert tax;

		Map<id,TXC_TaxCertificates_ARG__c> testMapeo = new Map<id,TXC_TaxCertificates_ARG__c>();
		testMapeo.put(tax.id,tax);
		LAT_AR_TaxCertificates.TaxCertificatesCheckPrintStatus(testMapeo);
	}
}