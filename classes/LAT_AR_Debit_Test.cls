/***************************************************************************************************
*  Company:Zimmic     Developer:Nicolás Marán      Date:23/03/2016    Test Class: LAT_AR_Debit     *
****************************************************************************************************/

@isTest
private class LAT_AR_Debit_Test {
	
	@isTest static void DebitCheckPrintStatusTest() {
		Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
		insert acc;

		RCP_Receipt_ARG__c rec = new RCP_Receipt_ARG__c();
		rec.Account_AR__c = acc.id;
		rec.Status_AR__c = 'Receipt printed Deposit done';
		insert rec;
		Test.startTest();

		DBT_Debit_ARG__c debi = new DBT_Debit_ARG__c();
		debi.ReceiptNo_AR__c = rec.id;
		insert debi;

		Map<id,DBT_Debit_ARG__c> testMapeo = new Map<id,DBT_Debit_ARG__c>();
		testMapeo.put(debi.id,debi);
		LAT_AR_Debit.DebitCheckPrintStatus(testMapeo);
		LAT_AR_Debit.replicateJDE_ID(testMapeo);
		Test.stopTest();
	}
	@isTest static void DebitCheckPrintStatusTest2() {
		Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
		insert acc;

		RCP_Receipt_ARG__c rec = new RCP_Receipt_ARG__c();
		rec.Account_AR__c = acc.id;
		rec.Status_AR__c = 'Receipt Issued Deposit pending';
		insert rec;
		Test.startTest();

		DBT_Debit_ARG__c debi = new DBT_Debit_ARG__c();
		debi.ReceiptNo_AR__c = rec.id;
		insert debi;
		try{update debi;}catch(Exception e){}

		Map<id,DBT_Debit_ARG__c> testMapeo = new Map<id,DBT_Debit_ARG__c>();
		testMapeo.put(debi.id,debi);
		LAT_AR_Debit.DebitCheckPrintStatus(testMapeo);
		LAT_AR_Debit.replicateJDE_ID(testMapeo);
		try{delete debi;}catch(Exception e){}
		Test.stopTest();
	}
	
}