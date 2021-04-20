@isTest

private class LAT_AR_VFC_13_TransferAccsOppsConts_Test{

	public static Account retAccount (User u) {
		Test.startTest();

   		Account accoHijo= new Account();
		
	   	accoHijo.Name = 'AccountTest2';
	    accoHijo.CNPJ__c = '30713131500';
	    accoHijo.Client_code_AN8__c = '123451237';
	    accoHijo.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_3_OnTrade_ARG');
	    accoHijo.OwnerId = u.Id;
	    accoHijo.Status__c = 'Cliente cadastrado no JDE';
	    accoHijo.Rating = 'Cliente';

	    insert accoHijo;

	    /*Account accoHijo1 = new Account();
		
	   	accoHijo1.Name = 'AccountTest';
	    accoHijo1.CNPJ__c = '30709619450';
	    accoHijo1.Client_code_AN8__c = '123451239';
	    accoHijo1.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_3_OnTrade_ARG');
	    accoHijo1.OwnerId = u.Id;
	    accoHijo1.Status__c = 'Cliente cadastrado no JDE';
	    accoHijo1.Rating = 'Cliente';

	    insert accoHijo1;*/

	    LAT_Account__c latAcc = [SELECT id, LAT_ID_Status__c FROM LAT_Account__c WHERE LAT_Accountid__c = :accoHijo.Id];
	    latAcc.LAT_ID_Status__c = 'Activo';
	    update latAcc;
		
		LAT_GeneralConfig__c mailSetting = new LAT_GeneralConfig__c(name = 'ACCOUNT_NOTIFY_ERROR_MAIL', LAT_Value__c = 'test@gmail.com;');
	    
	    insert mailSetting;

	    Test.stopTest();
	    return accoHijo;
	    
 	}
	
	@isTest static void  test1() {
		LAT_Utils_test.createUDC('PY','00','Blanco','6-00-00-PY', 'Standard_AR');
		try {
			User u = new User();
	   		u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
	   		u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_AR2_Vendedor');
	   		
	   		insert u;
			Account acc = retAccount(u);
			LAT_AR_TransferAccounts_Batch.CustomerInterfaceJDESync(acc);

		} catch (Exception e) {

		}
	}

	@isTest static void  test2() {
        LAT_Utils_test.createUDC('PY','00','Blanco','6-00-00-PY', 'Standard_AR');
		
        List<User> us =[SELECT Id, C_digo_JDE__c FROM User Where Profile.Name = 'LAT_AR2_Vendedor' AND IsActive = true AND Manager.Manager.ManagerId <> null LIMIT 2];
		
   		
   		
		User u3 = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true AND Manager.Manager.ManagerId <> null LIMIT 1];
   		
   		System.runAs(u3) {
			UDC__c udc = LAT_Utils_test.createUDC('02','01','Blanco','6-00-01-02', 'Standard_AR');
			UDC__c clon = udc.clone();
			clon.CodDefUsuario__c = us[1].C_digo_JDE__c;
			clon.Internal_Id__c = '6-'+ us[1].C_digo_JDE__c +'-01-02';
			UDC__c clon3 = udc.clone();
			clon3.CodDefUsuario__c = 'NOT_FOUND';
			clon3.Internal_Id__c = '6-NOT_FOUND-01-02';
			UDC__c clon2 = udc.clone();
			clon2.CodDefUsuario__c = us[0].C_digo_JDE__c;
			clon2.Internal_Id__c = '6-'+ us[0].C_digo_JDE__c +'-01-02';
			insert new List<UDC__c> {clon, clon2, clon3};
			System.debug('%%%% UDCS: '+ [select Recordtype.Developername, CodProd__c, CodUs__c,CodDefUsuario__c, id FROM UDC__c ]);
   			Account acc = retAccount(us[0]);
			LAT_AR_VFC_13_TransferAccsOppsConts cont = new LAT_AR_VFC_13_TransferAccsOppsConts();
			cont.accOldLookup.OwnerId = acc.OwnerId;

			cont.getAccountsPerUser();
			LAT_AR_VFC_13_TransferAccsOppsConts.AccountInner acInn = new LAT_AR_VFC_13_TransferAccsOppsConts.AccountInner();
			acInn.isSelected = true;
			acInn.accId = acc.Id;
			acInn.ownerId = acc.OwnerId;
			cont.listInnerAccount.add(acInn);
			cont.accNewLookup.OwnerId = us[1].Id;

			Lat_opportunity__c opp = new Lat_opportunity__c(name='Test Opp', lat_account__c=acc.Id, LAT_CloseDate__c =Date.today(), LAT_StageName__c='Novo pedido');
			insert opp;

			Contact con = new Contact(lastname='test', accountid=acc.id);
			insert con;

			cont.udcNewLookup.LAT_JDEZoneUDC__c = udc.Id;
			cont.transferContacts = true;
	    	cont.transferOpps = true;
	    	cont.shareOption = 'Read';
			
			cont.transferAccounts();
			cont.assignUDCs();
			cont.getSortDirection();
			cont.setSortDirection('ASC');
			LAT_AR_TransferAccounts_Batch batch = new LAT_AR_TransferAccounts_Batch(new Set<Id>{acc.Id}, us[1].Id);
			LAT_AR_TransferAccounts_Batch.getAccount(new Set<Id>{acc.Id});

			List<SelectOption> shareOptions = cont.getShareOptions();

			cont.shareAccounts();
   		}
		
	}
		
}