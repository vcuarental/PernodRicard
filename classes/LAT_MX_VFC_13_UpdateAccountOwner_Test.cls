@isTest
private class LAT_MX_VFC_13_UpdateAccountOwner_Test {
	


	public static Account retAccount (User u, User u2) {
		Test.startTest();


   		LAT_MX_Region__c reg = new LAT_MX_Region__c(Name = 'REG', LAT_MX_KAM__c = u2.Id);
   		insert reg;



       

   		LAT_MX_Plaza__c plaza = new LAT_MX_Plaza__c(Name= 'PLA', LAT_MX_Ejecutivo__c = u.Id);
   		insert plaza;
   		Account accoHijo= new Account();

   		
		createCSMxOnTradeNoKam();
		
	   	accoHijo.Name = 'AccountTest2';
	    accoHijo.CNPJ__c = 'BRI800523HN1';
	    accoHijo.Client_code_AN8__c = '123451237';
	    accoHijo.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
	    accoHijo.OwnerId = u.Id;
	    accoHijo.Status__c = 'Cliente cadastrado no JDE';
	    insert accoHijo;

	    LAT_Account__c latAcc = [SELECT id, LAT_ID_Status__c FROM LAT_Account__c WHERE LAT_Accountid__c = :accoHijo.Id];
	    latAcc.LAT_ID_Status__c = 'Activo';
	    update latAcc;
		
	    Test.stopTest();
	    return accoHijo;
 	}

	private static void createCSMxOnTradeNoKam() {
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
                  Name = 'MX_ON_TRADE_NO_KAM_USERS',
                LAT_Value__c = 'MIGUEL BAQUEDANO,');
        insert cfg;
	}

	@isTest static void  test1() {
        User u2 = new User();
   		u2 = LAT_TestUserAdmin.userWithAdminPorf ('Nome','Sobrenome','NSobre','nome@sobrenome.com','PriceCalculationInterfac@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u2.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		insert u2;

        User u = new User();
   		u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		u.ManagerId = u2.Id;
   		insert u;



	 	User u3 = new User();
   		u3 = LAT_TestUserAdmin.userWithAdminPorf ('Nome3','Sobrenome3','NSobre3','nome3@sobrenome.com','PriceCalculationInterface3@mail.com','123jjjuuu3','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u3.profileId = LAT_GlobalProfileCache.getProfileIdByName('System Administrator');
  

   		System.runAs(u3) {
			Account acc = retAccount(u, u2);
			LAT_MX_VFC_13_UpdateAccountOwner cont = new LAT_MX_VFC_13_UpdateAccountOwner();
			cont.accOldLookup.OwnerId = acc.OwnerId;
			cont.getAccountsPerUser();
			LAT_MX_VFC_13_UpdateAccountOwner.AccountInner acInn = new LAT_MX_VFC_13_UpdateAccountOwner.AccountInner();
			acInn.isSelected = true;
			acInn.accId = acc.Id;
			acInn.razSocial = 'Test';
			acInn.nameFantasia = 'Test';
			acInn.an8 = 'Test';
			acInn.description = 'Test';
			acInn.phone = 'Test';
			acInn.address = 'Test';
			cont.listInnerAccount.add(acInn);
			cont.accNewLookup.OwnerId = acc.Owner.ManagerId;
			cont.transferAccounts();
		}

	}
	@isTest static void  test2() {
        User u2 = new User();
   		u2 = LAT_TestUserAdmin.userWithAdminPorf ('Nome','Sobrenome','NSobre','nome@sobrenome.com','PriceCalculationInterfac@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u2.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		insert u2;		

        User u = new User();
   		u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		u.ManagerId = u2.Id;
   		insert u;

	 	User u3 = new User();
   		u3 = LAT_TestUserAdmin.userWithAdminPorf ('Nome3','Sobrenome3','NSobre3','nome3@sobrenome.com','PriceCalculationInterface3@mail.com','123jjjuuu3','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u3.profileId = LAT_GlobalProfileCache.getProfileIdByName('System Administrator');
   		

   		System.runAs(u3) {
			Account acc = retAccount(u, u2);
			LAT_MX_VFC_13_UpdateAccountOwner cont = new LAT_MX_VFC_13_UpdateAccountOwner();
			cont.accOldLookup.OwnerId = acc.OwnerId;
			cont.getAccountsPerUser();
			LAT_MX_VFC_13_UpdateAccountOwner.AccountInner acInn = new LAT_MX_VFC_13_UpdateAccountOwner.AccountInner();
			acInn.isSelected = true;
			acInn.accId = acc.Id;
			acInn.ownerId = acc.OwnerId;
			cont.listInnerAccount.add(acInn);
			cont.accNewLookup.OwnerId = acc.OwnerId;
			cont.transferAccounts();
		}
	}


	@isTest
	static void saveManager(){
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_BR2_Vendas' LIMIT 1]; 
            
        User u = new User(
            Alias = 'testB', 
            Email='testAlias@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='TestUser1', 
            FirstName = 'TestUser1',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAlias@testorg.com'
        );      
        insert u;

        User u2 = new User(
            Alias = 'testA', 
            Email='testAliasa@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='TestUser2', 
            FirstName = 'TestUser2',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAliasa@testorg.com'
        );      
        insert u2;

		Account testAccount = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		testAccount.OwnerId = u.Id;
		testAccount.Area_Manager__c = u2.Id;

		LAT_BR_VFC19_UpdateManager cont = new LAT_BR_VFC19_UpdateManager();
		cont.accLookup = testAccount;
		
		cont.saveManager();

	}
}