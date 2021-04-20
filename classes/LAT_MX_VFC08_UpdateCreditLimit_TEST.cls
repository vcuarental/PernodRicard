@isTest
private class LAT_MX_VFC08_UpdateCreditLimit_TEST {
	
	@isTest static void testUploadFile() {

		String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX,
            client_country_an8__c = '12-1234'
        );
		insert acc;


		LAT_MX_VFC08_UpdateCreditLimit controller = new LAT_MX_VFC08_UpdateCreditLimit();
		controller.toParse = blob.valueOf('AN8,creditLimit\r\n1234,1000\r\n');
		controller.upload();
	}
	
	@isTest static void test_HeaderCreditLine() {
		String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX,
            client_country_an8__c = '12-1234'
        );
		insert acc;

		LAT_MasiveCreditLineHeader__c header = new LAT_MasiveCreditLineHeader__c();
    	header.lat_status__c = 'Nuevo';
    	header.LAT_Approver__c = UserInfo.getUserId();
    	insert header;

    	header.lat_status__c = 'En ejecucion';
    	update header;



	}

	@isTest static void test_LineCreditLine() {
		String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX,
            client_country_an8__c = '12-1234',
            Credit_line__c = 10
        );
		insert acc;

		LAT_MasiveCreditLineHeader__c header = new LAT_MasiveCreditLineHeader__c();
    	header.lat_status__c = 'Nuevo';
    	header.LAT_Approver__c = UserInfo.getUserId();
    	insert header;

		LAT_MasiveCreditLineLine__c line = new LAT_MasiveCreditLineLine__c();
		line.LAT_Account__c = acc.id;
		line.LAT_AccountAN8__c = acc.client_country_an8__c;
		line.LAT_OldValue__c = acc.Credit_line__c;
		line.LAT_Header__c = header.id;
		line.LAT_New_Value__c = 20;

		insert line;

		header.lat_status__c = 'En ejecucion';
    	update header;

    	line.LAT_New_Value__c = 20;
    	update line;



	}
	
}