/************************************************************************************************************************
*  Company:Zimmic     Developer:Nicolás Marán      Date:23/03/2016    Test Class: LAT_AR_ValuesBeforeInsertUpdateDelete *    
*************************************************************************************************************************/

@isTest
private class LAT_AR_ValuesTriggerTest {
	
	@isTest static void triggerTest() {
		Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
				insert acc;

				RCP_Receipt_ARG__c rec = new RCP_Receipt_ARG__c();
				rec.Account_AR__c = acc.id;
				rec.Status_AR__c = 'Receipt Issued Deposit pending';
				rec.name='abc'; 
				insert rec;

				VLS_Values_ARG__c val = new VLS_Values_ARG__c();
				val.ReceiptNo_AR__c = rec.id;
				val.AccType_AR__c = 'Bank Account';
				val.Bank_AR__c ='E';
				val.BranBranch_AR__c = 'ACL';
				val.name='123';
				insert val;



				update val;
				delete val;
	}
	
}