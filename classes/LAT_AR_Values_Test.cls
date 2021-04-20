/************************************************************************************************
*  Company:Zimmic     Developer:Nicolás Marán      Date:23/03/2016     Test Class: LAT_AR_Values*
*************************************************************************************************/

@isTest
private class LAT_AR_Values_Test {
	
	@isTest static void ValuesCheckPrintStatusTest() {
			Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
				insert acc;

				RCP_Receipt_ARG__c rec = new RCP_Receipt_ARG__c();
				rec.Account_AR__c = acc.id;
				rec.Status_AR__c = 'Receipt printed Deposit done';
				insert rec;

				VLS_Values_ARG__c val = new VLS_Values_ARG__c();
				val.ReceiptNo_AR__c = rec.id;
				val.AccType_AR__c = 'Bank Account';
				val.Bank_AR__c ='E';
				val.BranBranch_AR__c = 'ACL';
				insert val;
				
				Map<id,VLS_Values_ARG__c> testMapeo = new Map<id,VLS_Values_ARG__c>();
				testMapeo.put(val.id,val);
				LAT_AR_Values.ValuesCheckPrintStatus(testMapeo);
	}
}