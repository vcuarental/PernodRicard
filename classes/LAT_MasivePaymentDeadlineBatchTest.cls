@isTest
private class LAT_MasivePaymentDeadlineBatchTest {
	
	static testmethod void test_masivePaymentDeadLineBatchTest() {

		Account acc = LAT_VFC07_MasivePaymentDeadlineTest.CreateMXOfftradeAccount();
		LAT_MasivePaymentDeadlineHeader__c header = new LAT_MasivePaymentDeadlineHeader__c(LAT_Status__c = 'New',LAT_Approver__c = UserInfo.getUserId());
		insert header;
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
              Name = 'EMAIL_TARGET_ADDRESSES',
              LAT_Value__c = 'test@example.com'
        );
        insert cfg;

		UDC__c pd = new UDC__c(
			CodDefUsuario__c = 'D02',
			CodProd__c = 'CRM',
			CodUs__c = 'PT',
			Internal_Id__c = '12-D02-CRM-PT',
			RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'LAT_MX_UDC_Standard')
		);
      	insert pd;

		LAT_MasivePaymentDeadlineLine__c deadLineHeader = new LAT_MasivePaymentDeadlineLine__c();
		deadLineHeader.LAT_Account__c = acc.Id;
		deadLineHeader.LAT_Header__c = header.Id;
		deadLineHeader.LAT_NewValue__c = pd.Id;
		insert deadLineHeader;
       Test.startTest();
       LAT_MasivePaymentDeadlineBatch latMasiveBatch = new LAT_MasivePaymentDeadlineBatch(header.Id);
       Database.executeBatch(latMasiveBatch);
       Test.stopTest();
       Integer i = [SELECT COUNT() FROM LAT_MasivePaymentDeadlineLine__c];
       System.assertEquals(true,i!= 0);
    }
	
}