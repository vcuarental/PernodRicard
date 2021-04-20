@isTest
private class LAT_WS_GetAvailableCredit_Test {
	
	
	private static void Init(String recordTypeAccount, String country) {
        
		LAT_GeneralConfig__c cs = new LAT_GeneralConfig__c(
			Name = 'UPDATE_CREDIT_AVAILABLE',
			LAT_Value__c = '10'
		);
		insert cs;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = '12 Dias MX - Test',
            Internal_Id__c = '12-123-CRM-PT',
            CodUs__c = 'PT',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc;

		Account a = LAT_Account_TestFactory.getAccountBase(recordTypeAccount);
		
		if ( country == '12' ) {
			a.CNPJ__c = 'LOZM701213E52'; 
			a.Payment_Condition__c = udc.id; 
			a.LAT_MX_AvailableCreditLimit__c = 100.00;
		} else { 
			if ( country == '1') {
				a = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
			} else {
				if ( country == '5') {
					a = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
				}
			}
		}
		a.Client_country_AN8__c = country + '-1234';
		insert a;

		LAT_Account__c latAcc = [SELECT Id FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: a.Id];
		latAcc.LAT_Cred_Debt__c = 100.00;
		latAcc.LAT_Cred_Limit__c = 1000.00;
		latAcc.LAT_Cred_OrderPending__c = 100.00;
		latAcc.LAT_Cred_UpdatedDate__c = Date.today().addDays(-2);
        latAcc.LAT_Cred_OrderAppr__c = 100.00; 
        latAcc.LAT_Cred_AboveLimit__c = 1.00;
        latAcc.LAT_Cred_RequestDate__c = Date.today();
		upsert latAcc;
	}
	
	@isTest static void test_method_MX() {
		Init('LAT_MX_ACC_OffTrade', '12');
		Test.startTest();
        LAT_WS_GetAvailableCredit.getAvailableCredit('12-1234');
		Test.stopTest();	
	}

	@isTest static void test_method_BR() {
		Init('Off_Trade', '1');
		Test.startTest();
        LAT_WS_GetAvailableCredit.getAvailableCredit('1-123451236');
		Test.stopTest();	
	}
	
	@isTest static void test_method_AR() {
		Init('ACC_1_OffTrade_ARG', '6'); 
		Test.startTest();
        LAT_WS_GetAvailableCredit.getAvailableCredit('6-1234');
		LAT_Account__c lat_Acc = [SELECT Id, LAT_Cred_UpdatedDate__c, NAme FROM LAT_ACCOUNT__c LIMIT 1];
		LAT_GetAvailableCreditHelper.getAvailableCreditListAR(lat_Acc);
		Test.stopTest();	
	}
}