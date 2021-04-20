@isTest
private class LAT_AR_SentReceiptEmail_Test {
	
	private static string initiateTest(){

        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        
        Account acc = new Account(
        RecordTypeId = recordOffTradeArg.Id,
        CNPJ__c = '20354266645',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Billing_Country__c ='test',
        Email_NFE__c = 'test@test2.com'
        );
        insert acc;

        Contact c = new Contact(LastName= 'Contact1', FirstName = 'Surname1', AccountId = acc.Id, Email= 'test@test.com');
   		insert c;

        Test.startTest();
        list<RCP_Receipt_ARG__c> receiptList = new list<RCP_Receipt_ARG__c>();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
        Account_AR__c = acc.id,
        Status_Ar__c = 'Receipt Issued Deposit done'

        //Name = 'TEST'
        );
        receiptList.add(receipt);        
        insert receiptList;

        receipt = [SELECT Id, Name FROM RCP_Receipt_ARG__c WHERE Id = :receipt.Id];  

        Attachment attach = new Attachment(
   		ParentId = receipt.Id,
   		Name = receipt.Name,
   		Body = Blob.valueof( 'asdasd' )
   		);
   		insert attach;

   		Test.stopTest();
		ApexPages.currentPage().getParameters().put('receiptId', receipt.Id);
		return receipt.Id;

	}

	@isTest static void test1() {
		initiateTest();
		LAT_AR_SentReceiptEmail c = new LAT_AR_SentReceiptEmail();
		c.sendMail();


	}
	@isTest static void test2() {
		String idRec = initiateTest();
		try {
			List<String> testStr = new List<String>();
			testStr.add('TEST');
			LAT_AR_SentReceiptEmailWS.sendEmail(testStr, 'Test', 'Test', idRec);
		} catch (Exception e) {}

	}
	
	
}