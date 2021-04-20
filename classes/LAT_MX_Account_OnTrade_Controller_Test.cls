@isTest
private class LAT_MX_Account_OnTrade_Controller_Test {

	@isTest static void testConstructor() {
		Account Acc = crearAccount();
    ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_MX_Account_OnTrade_Controller acOnTC = new LAT_MX_Account_OnTrade_Controller(controller);						  
	}

	@isTest static void createRFCTest() {
		   //reload user Name
		//pageuser = [SELECT NAME from user where id=:pageuser.Id];
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';

		insert lgc;
		system.debug(lgc);
		system.debug(LAT_GeneralConfig__c.getInstance('MX_ON_TRADE_NO_KAM_USERS'));

		
		Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert acc;
		Test.startTest();
		LAT_Account__c latAcc = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		Account accoHijo= new Account();
	   	accoHijo.Name = 'AccountTest2';
	    accoHijo.CNPJ__c = 'BRI800523HN1';
	    accoHijo.Client_code_AN8__c = '123451237';
	    accoHijo.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
	    accoHijo.parentID=acc.id;
	    insert accoHijo;


	 


		final ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_MX_Account_OnTrade_Controller acOnTC = new LAT_MX_Account_OnTrade_Controller(controller);	
		acOnTC.parentID = acc.id;
		acOnTC.rsSelec = 'asd';
		acOnTC.rfcSelec = 'OEP100421G75';
		acOnTC.insertRFCAccount(latAcc.id);

		Test.stopTest();
	}

	@isTest static void getUserTest(){
		
		Account acc = crearAccount();
		final ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_MX_Account_OnTrade_Controller acOnTC = new LAT_MX_Account_OnTrade_Controller(controller);	
		System.assertNotEquals(acOnTC.loggedInUser, null);
	}


	@isTest static void doSaveTest(){
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
		
		//reload user Name
		pageuser = [SELECT NAME from user where id=:pageuser.Id];
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = pageUser.Name; //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';

		insert lgc;
		system.debug(lgc);
		system.debug(LAT_GeneralConfig__c.getInstance('MX_ON_TRADE_NO_KAM_USERS'));


		Account parentacc = crearAccount();
		parentacc.OwnerId = pageUser.Id;
		insert parentacc;

		Account Acc = crearAccount();
		acc.OwnerId = pageUser.Id;
		acc.parentId = parentacc.Id;
		acc.CNPJ__c = 'PAC120605V43';
      	acc.Client_code_AN8__c = '123123';
		insert acc;

		//rfc parent
		LAT_Account__c latAccPar = [Select id from LAT_Account__c where LAT_Accountid__c =: parentacc.id];
		LAT_MX_RFC__c rfcPar = new LAT_MX_RFC__c();
		rfcPar.name ='abcd';
		rfcPar.LAT_RFC__c = 'PEP170404GTA';
		insert rfcPar;

		LAT_MX_RFC_Account__c rfcAccPar = new LAT_MX_RFC_Account__c();
		rfcAccPar.LAT_ACCOUNT__c = latAccPar.id;
		rfcAccPar.LAT_MX_RFC__c = rfcPar.id;
		insert rfcAccPar;


		//rfc child
		LAT_Account__c latAcc = [Select id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
		rfc.name ='abc';
		rfc.LAT_RFC__c = 'PEP170404GTE';
		insert rfc;

		LAT_MX_RFC_Account__c rfcAcc = new LAT_MX_RFC_Account__c();
		rfcAcc.LAT_ACCOUNT__c = latAcc.id;
		rfcAcc.LAT_MX_RFC__c = rfc.id;
		insert rfcAcc;


		
		Test.startTest();
		System.runAs(pageUser){
			final ApexPages.StandardController controller = new ApexPages.StandardController(acc);

			LAT_MX_Account_OnTrade_Controller acOnTC = new LAT_MX_Account_OnTrade_Controller(controller);	
			acOnTC.ParentId = parentacc.Id;
			
			acOnTC.Save();
			acOnTC.addRFCList();
			acOnTC.loadRFC();
		}
		
		Test.stopTest();
	}

	@isTest static void dodeletetest(){
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName();
		lgc.name='MX_ON_TRADE_NO_KAM_USERS';
		insert lgc;
		
		Account Acc = crearAccount();

		final ApexPages.StandardController controller = new ApexPages.StandardController(acc);
		LAT_MX_Account_OnTrade_Controller acOnTC = new LAT_MX_Account_OnTrade_Controller(controller);	
		acOnTC.Save();
		acOnTC.doDelete();


	}
	

  public static Account crearAccount(){
  		
  		Account acco = new Account();
   		acco.Name = 'AccountTest';
      acco.CNPJ__c = 'PAC120605V42';
      acco.Client_code_AN8__c = '123451236';
      acco.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
      return acco;
	}
}