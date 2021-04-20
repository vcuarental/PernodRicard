@isTest
private class LAT_MX_Account_OnTrade_ProfTest {
	
	@isTest static void testConstructor() {
		//reload user Name
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';

		LAT_GeneralConfig__c lgc2 = new LAT_GeneralConfig__c();
		lgc2.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc2.SetupOwnerId = UserInfo.getOrganizationId();
		lgc2.name = 'MX_PROFILES_DELETE_ON_TRADE_ACCOUNTS';

		LAT_GeneralConfig__c lgc3 = new LAT_GeneralConfig__c();
		lgc3.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc3.SetupOwnerId = UserInfo.getOrganizationId();
		lgc3.name = 'MX_USERS_DELETE_ON_TRADE_ACCOUNTS';

		List<LAT_GeneralConfig__c> toInsert = new List<LAT_GeneralConfig__c>();
		toInsert.add(lgc);
		toInsert.add(lgc2);
		toInsert.add(lgc3);
		insert toInsert;
		Account acc = crearAccount();
		insert acc;

		ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		Test.setCurrentPageReference(new PageReference('Page.LAT_MX_Account_OnTrade_Prof_Control'));
       	System.currentPageReference().getParameters().put('id', acc.id);
		LAT_MX_Account_OnTrade_Prof_Control acOnTC = new LAT_MX_Account_OnTrade_Prof_Control(controller);
		System.assertNotEquals(acOnTC.accFields, null);	
	}

	@isTest static void doEditTest(){
		//reload user Name
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';
		LAT_GeneralConfig__c lgc2 = new LAT_GeneralConfig__c();
		lgc2.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc2.SetupOwnerId = UserInfo.getOrganizationId();
		lgc2.name = 'MX_PROFILES_DELETE_ON_TRADE_ACCOUNTS';

		LAT_GeneralConfig__c lgc3 = new LAT_GeneralConfig__c();
		lgc3.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc3.SetupOwnerId = UserInfo.getOrganizationId();
		lgc3.name = 'MX_USERS_DELETE_ON_TRADE_ACCOUNTS';

		List<LAT_GeneralConfig__c> toInsert = new List<LAT_GeneralConfig__c>();
		toInsert.add(lgc);
		toInsert.add(lgc2);
		toInsert.add(lgc3);
		insert toInsert;
		Account acc = crearAccount();
		insert acc;

		ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		Test.setCurrentPageReference(new PageReference('Page.LAT_MX_Account_OnTrade_Prof_Control'));
    	System.currentPageReference().getParameters().put('id', acc.id);
    	LAT_MX_Account_OnTrade_Prof_Control acOnTC = new LAT_MX_Account_OnTrade_Prof_Control(controller);
    	String a = ApexPages.currentPage().getURL();
    	acOnTC.doEdit();
		System.assertEquals(a, ApexPages.currentPage().getURL());	
	}	 

	@isTest static void doDeleteTest() {
		//reload user Name
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';
		LAT_GeneralConfig__c lgc2 = new LAT_GeneralConfig__c();
		lgc2.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc2.SetupOwnerId = UserInfo.getOrganizationId();
		lgc2.name = 'MX_PROFILES_DELETE_ON_TRADE_ACCOUNTS';

		LAT_GeneralConfig__c lgc3 = new LAT_GeneralConfig__c();
		lgc3.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc3.SetupOwnerId = UserInfo.getOrganizationId();
		lgc3.name = 'MX_USERS_DELETE_ON_TRADE_ACCOUNTS';

		List<LAT_GeneralConfig__c> toInsert = new List<LAT_GeneralConfig__c>();
		toInsert.add(lgc);
		toInsert.add(lgc2);
		toInsert.add(lgc3);
		insert toInsert;
		Account acc = crearAccount();
		insert acc;
		LAT_Account__c latAcc = [Select id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
		rfc.name ='abc';
		rfc.LAT_RFC__c = 'PEP170404GTE';
		insert rfc;

		LAT_MX_RFC_Account__c rfcAcc = new LAT_MX_RFC_Account__c();
		rfcAcc.LAT_ACCOUNT__c = latAcc.id;
		rfcAcc.LAT_MX_RFC__c = rfc.id;
		insert rfcAcc;
		Test.setCurrentPageReference(new PageReference('Page.LAT_MX_Account_OnTrade_Prof_Control'));
		System.currentPageReference().getParameters().put('id', acc.id);
		System.currentPageReference().getParameters().put('toDelete', rfcAcc.id);

		ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_MX_Account_OnTrade_Prof_Control acOnTC = new LAT_MX_Account_OnTrade_Prof_Control(controller);
		acOnTC.doDelete();
		List<String> lista = new List<String>{acc.id};
		LAT_MX_OnTrade_Account.callOnTradeChangeWS(lista);

		new LAT_WS_MX_AccountOnTrade.NewOperationResponse_element();
		new LAT_WS_MX_AccountOnTrade.NewOperation_element();
		List<LAT_MX_RFC_Account__c> rfcDel = [Select id from LAT_MX_RFC_Account__c where id =: rfcAcc.id];
		System.assertEquals(0, rfcDel.size());
	}

	@isTest static void deleteAccountTest() {
		//reload user Name
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';
		LAT_GeneralConfig__c lgc2 = new LAT_GeneralConfig__c();
		lgc2.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc2.SetupOwnerId = UserInfo.getOrganizationId();
		lgc2.name = 'MX_PROFILES_DELETE_ON_TRADE_ACCOUNTS';

		LAT_GeneralConfig__c lgc3 = new LAT_GeneralConfig__c();
		lgc3.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc3.SetupOwnerId = UserInfo.getOrganizationId();
		lgc3.name = 'MX_USERS_DELETE_ON_TRADE_ACCOUNTS';

		List<LAT_GeneralConfig__c> toInsert = new List<LAT_GeneralConfig__c>();
		toInsert.add(lgc);
		toInsert.add(lgc2);
		toInsert.add(lgc3);
		insert toInsert;
		Account acc = crearAccount();
		insert acc;
		LAT_Account__c latAcc = [Select id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
		rfc.name ='abc';
		rfc.LAT_RFC__c = 'PEP170404GTE';
		insert rfc;

		LAT_MX_RFC_Account__c rfcAcc = new LAT_MX_RFC_Account__c();
		rfcAcc.LAT_ACCOUNT__c = latAcc.id;
		rfcAcc.LAT_MX_RFC__c = rfc.id;
		insert rfcAcc;
        
		Test.setCurrentPageReference(new PageReference('Page.LAT_MX_Account_OnTrade_Profile?id=' + acc.id));
		
		ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_MX_Account_OnTrade_Prof_Control acOnTC = new LAT_MX_Account_OnTrade_Prof_Control(controller);
		acOnTC.deleteAccount();
	}
    
	@isTest static void doInactivateTest() {
		//reload user Name
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); 
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';
		LAT_GeneralConfig__c lgc2 = new LAT_GeneralConfig__c();
		lgc2.LAT_Value__c = UserInfo.getProfileId(); 
		lgc2.SetupOwnerId = UserInfo.getOrganizationId();
		lgc2.name = 'MX_PROFILES_DELETE_ON_TRADE_ACCOUNTS';
		LAT_GeneralConfig__c lgc3 = new LAT_GeneralConfig__c();
		lgc3.LAT_Value__c = UserInfo.getProfileId(); 
		lgc3.SetupOwnerId = UserInfo.getOrganizationId();
		lgc3.name = 'MX_USERS_DELETE_ON_TRADE_ACCOUNTS';

		List<LAT_GeneralConfig__c> toInsert = new List<LAT_GeneralConfig__c>();
		toInsert.add(lgc);
		toInsert.add(lgc2);
		toInsert.add(lgc3);
		insert toInsert;

		Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0); 
		User manager = SObjectInstance.createUser();
		manager.profileId = p.Id;
		manager.Username = 'test@manager.com.manager';
		manager.email = 'test@manager.com.manager';
		manager.CommunityNickname = 'testCCoommUsssrMa123';
		insert manager;
		User pageUser = SObjectInstance.createUser();
		pageUser.ManagerId = manager.Id;
		pageUser.profileId = p.Id;
		pageUser.Username = 'testuser@usertesttttt.com.testt';
		pageUser.email = 'testuser@usertesttttt.com.testt';
		manager.CommunityNickname = 'testCCoommUsssr';
		insert pageUser;
      
        Account acc = crearAccountOffTrade();
        insert acc;
        LAT_Account__c latAcc = [Select id from LAT_Account__c where LAT_Accountid__c =: acc.id];
        LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
        rfc.name ='abc';
        rfc.LAT_RFC__c = 'PEP170404GTE';
        insert rfc;
        LAT_MX_RFC_Account__c rfcAcc = new LAT_MX_RFC_Account__c();
        rfcAcc.LAT_ACCOUNT__c = latAcc.id;
        rfcAcc.LAT_MX_RFC__c = rfc.id;
        insert rfcAcc;
        
		Test.setCurrentPageReference(new PageReference('Page.LAT_MX_Account_OnTrade_Prof_Control'));
		System.currentPageReference().getParameters().put('id', acc.id);
		System.currentPageReference().getParameters().put('toDelete', rfcAcc.id);
        
		Test.startTest();		
        System.runAs(pageUser){
			acc.Reason_for_Inactivation__c = 'Término de Contrato';
            acc.status__c = 'Inactive Account';
            update acc;
			ApexPages.StandardController controller = new ApexPages.StandardController(acc);
			LAT_MX_Account_OnTrade_Prof_Control acOnTC = new LAT_MX_Account_OnTrade_Prof_Control(controller);
			acOnTC.doInactivar();
		}
		Test.stopTest();
	}

	@isTest static void doEdit2TEst() {

		//reload user Name
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';
		LAT_GeneralConfig__c lgc2 = new LAT_GeneralConfig__c();
		lgc2.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc2.SetupOwnerId = UserInfo.getOrganizationId();
		lgc2.name = 'MX_PROFILES_DELETE_ON_TRADE_ACCOUNTS';

		LAT_GeneralConfig__c lgc3 = new LAT_GeneralConfig__c();
		lgc3.LAT_Value__c = UserInfo.getProfileId(); //UserInfo.getName();
		lgc3.SetupOwnerId = UserInfo.getOrganizationId();
		lgc3.name = 'MX_USERS_DELETE_ON_TRADE_ACCOUNTS';

		List<LAT_GeneralConfig__c> toInsert = new List<LAT_GeneralConfig__c>();
		toInsert.add(lgc);
		toInsert.add(lgc2);
		toInsert.add(lgc3);
		insert toInsert;
		Account acc = crearAccount();
		insert acc;
		LAT_Account__c latAcc = [Select id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
		rfc.name ='abc';
		rfc.LAT_RFC__c = 'PEP170404GTE';
		insert rfc;

		LAT_MX_RFC_Account__c rfcAcc = new LAT_MX_RFC_Account__c();
		rfcAcc.LAT_ACCOUNT__c = latAcc.id;
		rfcAcc.LAT_MX_RFC__c = rfc.id;
		insert rfcAcc;
		Test.setCurrentPageReference(new PageReference('Page.LAT_MX_Account_OnTrade_Prof_Control'));
		System.currentPageReference().getParameters().put('id', acc.id);
		System.currentPageReference().getParameters().put('toDelete', rfcAcc.id);

		ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_MX_Account_OnTrade_Prof_Control acOnTC = new LAT_MX_Account_OnTrade_Prof_Control(controller);
		acOnTC.doEdit();
		List<String> lista = new List<String>{acc.id};
		LAT_MX_OnTrade_Account.callOnTradeChangeWS(lista);

		new LAT_WS_MX_AccountOnTrade.NewOperationResponse_element();
		new LAT_WS_MX_AccountOnTrade.NewOperation_element();
		List<LAT_MX_RFC_Account__c> rfcDel = [Select id from LAT_MX_RFC_Account__c where id =: rfcAcc.id];
	}
	 
    public static Account crearAccount(){
		Account acco = new Account();
   		acco.Name = 'AccountTest';
      	acco.CNPJ__c = 'PAC120605V42';
      	acco.Client_code_AN8__c = '123451236';
      	acco.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
      	return acco;
	}
    
    public static Account crearAccountOffTrade() {
		Account acco = new Account();
   		acco.Name = 'AccountTestOffTrade';
      	acco.CNPJ__c = 'PAC120605V42';
      	acco.Client_code_AN8__c = '123481236';
      	acco.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
      	return acco;
    }
}