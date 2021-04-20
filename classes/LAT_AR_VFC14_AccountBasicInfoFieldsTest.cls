@isTest
private class LAT_AR_VFC14_AccountBasicInfoFieldsTest {
	
	@isTest static void test_method_one() {
        
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
     		Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF',
   			LAT_Value__c = 'LAT_AR2_Vendedor');
        insert cfg;

        Account acc;
        
        acc = new Account(
        	Name = 'TEST',
        	AccountNumber = '1000', 
        	Status__c = 'Novo cadastro', 
        	Type = 'Payer', 
        	Phone = '11 1111-1111', 
        	Notes__c = 'TEST', 
        	AddressLine1_AR__c = 'TEST', 
        	CNPJ__c = '30641670223', 
        	Corporate_Name__c = 'TEST', 
        	Channel__c = 'WS', 
        	RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG')
        	);
        insert acc;
		
		ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_AR_VFC14_AccountBasicInfoFieldsCont testPage = new LAT_AR_VFC14_AccountBasicInfoFieldsCont(controller);
		testPage.doEdit();
		testPage.doSave();
		testPage.doCancel();


	}

}