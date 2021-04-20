@isTest
private class LAT_MX_Edit_AccountMobileController_Test {
	
	private static Account init() {
		
		LAT_Mobile_Lookup_Filter__c mlf = new LAT_Mobile_Lookup_Filter__c();
  		mlf.LAT_Filter_Value__c = 'LAT_MX_FilterKey__c = \'DF-CRM-MX\'';
   		mlf.name='Business_Unit_AR__c';
   		mlf.LAT_Columns__c = 'Name,Descricao2__c,CodDefUsuario__c';
   		insert mlf;


		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
  		lgc.LAT_Value__c = UserInfo.getName();
   		lgc.name='MX_ON_TRADE_NO_KAM_USERS';
   		insert lgc;

		UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = '12 Dias MX - Test',
            Internal_Id__c = '12-123-CRM-PT',
            CodUs__c = 'PT',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc;
		UDC__c udc2 = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = 'MX - Test',
            Internal_Id__c = '12-123-CRM-DF',
            CodUs__c = 'DF',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc2;

		Account a = LAT_Account_TestFactory.getAccountBase('LAT_MX_ACC_OnTrade');
				
		a.CNPJ__c = 'LOZM701213E52'; 
		//a.Payment_Condition__c = udc.id;
		a.Business_Unit_AR__c = udc2.id; 
		a.LAT_MX_AvailableCreditLimit__c = 100.00;
		a.Client_country_AN8__c =  '12-1234';
		insert a;

		LAT_Product__c LAT_produto = new LAT_Product__c();
	    LAT_produto.Name = 'Test1';
	    LAT_produto.LAT_IsActive__c = true;
	    LAT_produto.LAT_CDUnit__c = 'UN';
	    LAT_produto.LAT_ExternalID__c = '444';
	    LAT_produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'LAT_MX_PRD_Standard' );
	    insert LAT_produto;

		LAT_Product__c LAT_produto2 = new LAT_Product__c();
	    LAT_produto2.Name = 'Test2';
	    LAT_produto2.LAT_IsActive__c = true;
	    LAT_produto2.LAT_CDUnit__c = 'UN';
	    LAT_produto2.LAT_ExternalID__c = '3333';
	    LAT_produto2.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'LAT_MX_PRD_Standard' );
	    insert LAT_produto2;

	    Lat_stock__c lStock = new Lat_stock__c();
	    lstock.LAT_Product__c = LAT_produto.id;
	    lStock.LAT_Branch__c = 'DHCJ';
	    lStock.LAT_Unit__c = 'C9';
	    lstock.LAT_Stock__c = 500;
	    lStock.LAT_ExternalId__c = '12-444';
	    insert lStock;

		LAT_Account__c latAcc = [SELECT Id FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: a.Id];
		latAcc.LAT_Cred_Debt__c = 100.00;
		latAcc.LAT_Cred_Limit__c = 1000.00;
		latAcc.LAT_Cred_OrderPending__c = 100.00;
		latAcc.LAT_Cred_UpdatedDate__c = Date.today().addDays(-2);
        latAcc.LAT_Cred_OrderAppr__c = 100.00; 
        latAcc.LAT_Cred_AboveLimit__c = 1.00;
        latAcc.LAT_Cred_RequestDate__c = Date.today();
		upsert latAcc;

	    return a;
	}

	@isTest static void test_method_one() {
		Account a = init();

		Test.startTest();

		ApexPages.StandardController stdCont = new ApexPages.StandardController(a);

    	ApexPages.currentPage().getParameters().put('id', a.Id);
    	//ApexPages.currentPage().getParameters().put('clone', 'a.Id');
    	//ApexPages.currentPage().getParameters().put('cred', 'edit');
		LAT_MX_Edit_AccountMobileController controller = new LAT_MX_Edit_AccountMobileController(stdCont);
		controller.selectRType();
		LAT_MX_Edit_AccountMobileController.SelectableRFC rfc = new LAT_MX_Edit_AccountMobileController.SelectableRFC('Test', 'rfcParam', false);
		controller.listaRFCActuales = new List<LAT_MX_Edit_AccountMobileController.SelectableRFC>();
		controller.listaRFCActuales.add(rfc);
		controller.doSave();
		
		Test.stopTest();

	}

	@isTest static void test_method_Edit() {
		Account a = init();

		Test.startTest();

		ApexPages.StandardController stdCont = new ApexPages.StandardController(a);

    	ApexPages.currentPage().getParameters().put('id', a.Id);
    	//ApexPages.currentPage().getParameters().put('clone', 'a.Id');
    	ApexPages.currentPage().getParameters().put('cred', 'edit');
		LAT_MX_Edit_AccountMobileController controller = new LAT_MX_Edit_AccountMobileController(stdCont);
		LAT_MX_Edit_AccountMobileController.getLookupFieldInformation('Business_Unit_AR__c','LAT_MX_UDC_Standard', a.Id);
		controller.doSave();
		Test.stopTest();

	}

	
}