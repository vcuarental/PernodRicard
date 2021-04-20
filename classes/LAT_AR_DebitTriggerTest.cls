/*************************************************************************************************************************
*  Company:Zimmic     Developer:Nicolás Marán      Date:23/03/2016    Test Class: LAT_AR_DebitBeforeInsertUpdateDelete   *    
**************************************************************************************************************************/
@isTest
private class LAT_AR_DebitTriggerTest {
	
	@isTest static void triggerTest() {
		Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
		insert acc;

		RCP_Receipt_ARG__c rec = new RCP_Receipt_ARG__c();
		rec.Account_AR__c = acc.id;
		rec.name='abc';
		rec.Status_AR__c = 'Receipt Issued Deposit pending';
		insert rec;

		DBT_Debit_ARG__c debi = new DBT_Debit_ARG__c();
		debi.ReceiptNo_AR__c = rec.id;
		debi.name='abc';
		insert debi;
		update debi;
		delete debi;
	}
	
	
	
}