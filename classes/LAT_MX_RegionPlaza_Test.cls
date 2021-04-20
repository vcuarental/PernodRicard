@isTest
private class LAT_MX_RegionPlaza_Test {

	public static LAT_Account__c retAccount () {
		Test.startTest();
        User u2 = new User();
   		u2 = LAT_TestUserAdmin.userWithAdminPorf ('Nome','Sobrenome','NSobre','nome@sobrenome.com','PriceCalculationInterfac@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u2.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		insert u2;

   		LAT_MX_Region__c reg = new LAT_MX_Region__c(Name = 'REG', LAT_MX_KAM__c = u2.Id );
   		insert reg;

        User u = new User();
   		u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		u.ManagerId = u2.Id;
   		insert u;

   		LAT_MX_Plaza__c plaza = new LAT_MX_Plaza__c(Name= 'PLA', LAT_MX_Ejecutivo__c = u.Id);
   		insert plaza;

		createCSMxOnTradeNoKam();
		Account accoHijo= new Account();
	   	accoHijo.Name = 'AccountTest2';
	    accoHijo.CNPJ__c = 'BRI800523HN1';
	    accoHijo.Client_code_AN8__c = '123451237';
	    accoHijo.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
	    accoHijo.OwnerId = u.Id;
	    insert accoHijo;

		LAT_Account__c latAcc = [Select id, LAT_Accountid__c, LAT_MX_Region__c FROM LAT_Account__c WHERE LAT_Accountid__c = :accoHijo.Id];
		latAcc.LAT_MX_Region__c = reg.Id;
		update latAcc;

	    Test.stopTest();
	    return latAcc;
 	}

	private static void createCSMxOnTradeNoKam() {
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
                  Name = 'MX_ON_TRADE_NO_KAM_USERS',
                LAT_Value__c = 'MIGUEL BAQUEDANO,');
        insert cfg;
	}

	@isTest static void test1() {
		LAT_Account__c latAcc = retAccount(); 
		Set<Id> regsNew = new Set<Id>();
		regsNew.add(latAcc.LAT_MX_Region__c);
		try {
			LAT_MX_Region.getAssociatedAccountsAndNotify(regsNew);
		} catch (Exception e) {} 
		Map<Id, LAT_MX_Region__c> mapa = new Map<Id, LAT_MX_Region__c>();
		LAT_MX_Region__c region = [SELECT id, Name, LAT_MX_KAM__c FROM LAT_MX_Region__c WHERE Id = :latAcc.LAT_MX_Region__c];
		mapa.put(latAcc.LAT_MX_Region__c, region);

		LAT_MX_Region.getOwnerAccountsAndSetNewRegion(mapa);
	}
	
	@isTest static void validateUniquePlazaTest() {

		createCSMxOnTradeNoKam();

		User u = new User();
   		u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		insert u;

   		LAT_MX_Plaza__c plaza = new LAT_MX_Plaza__c(Name= 'PLA', LAT_MX_Ejecutivo__c = u.Id);
   		insert plaza;

   		try{

   			LAT_MX_Plaza__c plaza2 = new LAT_MX_Plaza__c(Name= 'PLA2', LAT_MX_Ejecutivo__c = u.Id);
   			insert plaza2;

   			}catch(Exception e){

   			}
   		
		// Implement test code
	}

	@isTest static void updatePlazaNotifyTest() {

		createCSMxOnTradeNoKam();

		LAT_Account__c latAcc = retAccount();
		//LAT_Account__c latAcc = [Select id, LAT_Accountid__c, LAT_MX_Region__c FROM LAT_Account__c WHERE LAT_Accountid__c = :accoHijo.Id];
		LAT_MX_Plaza__c plaza = [select id, name from LAT_MX_Plaza__c where Name = 'PLA'];

		latAcc.LAT_MX_Plaza__c = plaza.Id;
		
		update latAcc;
   		
   		plaza.Name = 'PLAZAU';

   		update plaza;
   		
	}

	@isTest static void updateExecutiveNotifyTest() {

		createCSMxOnTradeNoKam();

		LAT_Account__c latAcc = retAccount();
		//LAT_Account__c latAcc = [Select id, LAT_Accountid__c, LAT_MX_Region__c FROM LAT_Account__c WHERE LAT_Accountid__c = :accoHijo.Id];
		LAT_MX_Plaza__c plaza = [select id, name from LAT_MX_Plaza__c where Name = 'PLA'];

		latAcc.LAT_MX_Plaza__c = plaza.Id;
		
		update latAcc;
   		
		User u = new User();
   		u = LAT_TestUserAdmin.userWithAdminPorf ('Nome4','Sobrenome4','NSobre4','nome4@sobrenome.com','PriceCalculationInterface4@mail.com','123jjjuuu4','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
   		u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
   		insert u;

   		plaza.LAT_MX_Ejecutivo__c = u.id;

   		update plaza;
   		
	}

	@isTest static void updateKAMNotifyTest() {

		createCSMxOnTradeNoKam();

		LAT_Account__c latAcc = retAccount();
		//LAT_Account__c latAcc = [Select id, LAT_Accountid__c, LAT_MX_Region__c FROM LAT_Account__c WHERE LAT_Accountid__c = :accoHijo.Id];
		latAcc = [Select id, LAT_Accountid__r.ownerid, LAT_Accountid__c FROM LAT_Account__c WHERE id = :latAcc.Id];

		LAT_MX_Region__c region = new LAT_MX_Region__c(Name = 'REG2', LAT_MX_KAM__c = latAcc.LAT_Accountid__r.ownerid);
		insert region;

		latAcc.LAT_MX_Region__c = region.Id;

		update latAcc;

		update region;
   		
   		
	}

	@isTest static void updateRegionNameTest() {

		createCSMxOnTradeNoKam();

		LAT_Account__c latAcc = retAccount();
		
		LAT_MX_Region__c region = [select id, name from LAT_MX_Region__c where name = 'REG'];
		region.name = 'REG2';

		update region;
   		
   		
	}
	
}