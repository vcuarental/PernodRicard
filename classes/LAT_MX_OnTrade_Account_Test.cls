@isTest
private class LAT_MX_OnTrade_Account_Test {
	
	private static void createCSMxOnTradeNoKam() {
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
                  Name = 'MX_ON_TRADE_NO_KAM_USERS',
                LAT_Value__c = 'MIGUEL BAQUEDANO,');
        insert cfg;
	}

	@isTest static void updateCountryCodeAn8Test() {
		Test.startTest();
		createCSMxOnTradeNoKam();
		List<Account> accNew = new List<Account>(); 
		Map<id,Account> mapAcc = new Map<id,Account>();
		Account acc = retAccount();
		accNew.add(acc);
		acc.Client_code_AN8__c = '1233';
		mapAcc.put(acc.id,acc);
		LAT_MX_OnTrade_Account.updateCountryCodeAn8(accNew,mapAcc,true);
		Test.stopTest();
		System.assertEquals(acc.Client_country_AN8__c, '12-On-'+acc.Client_code_AN8__c);
	}
	
	@isTest static void notifyOnTradeChangeTest() {
			Test.startTest();
			createCSMxOnTradeNoKam();
			Account acc = retAccount();
			List<Account> accNew = new List<Account>();
			acc.Status__c = 'Directed to be registered In JDE';
			accNew.add(acc);
			LAT_MX_OnTrade_Account.notifyOnTradeChange(accNew);
			Test.stopTest();
	}

	@isTest static void updateStatusTest() {
		Test.startTest();
		createCSMxOnTradeNoKam();
		List<Account> accNew = new List<Account>(); 
		Map<id,Account> mapAcc = new Map<id,Account>();
		Account acc = retAccount();
		acc.status__c = 'Integrado Compuarte';
		accNew.add(acc);
		mapAcc.put(acc.id,acc);
		LAT_MX_OnTrade_Account.updateStatus(accNew,mapAcc);
		Test.stopTest();
	}
	
	@isTest static void validateFieldMissing() {
		Account acc = retAccount();
		Test.startTest();
		LAT_Account__c lat = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		lat.LAT_TipoCentro__c = 'Hotel Convenio';
		update lat;
		Test.stopTest();		
	}

	@isTest static void validarZipCodeTest() {
			Test.startTest();
			createCSMxOnTradeNoKam();

			Account acc = retAccount(); 
			LAT_Account__c lat = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
			lat.LAT_MX_PostalCode__c = '1060';
			
			List<LAT_Account__c> latlist = new List<LAT_Account__c>();
			MAP<id,LAT_Account__c> latMap = new MAP<id,LAT_Account__c>();
			
			latlist.add(lat);
			latMap.put(lat.id,lat);

			LAT_MX_OnTradE_Account.validarZipCode(latlist,latMap,true);

			Test.stopTest();

	}

	@isTest static void sendForApprovalTest() {
			Test.startTest();
			createCSMxOnTradeNoKam();
			List<Account> accNew = new List<Account>(); 
			Map<id,Account> mapAcc = new Map<id,Account>();
			Account acc = retAccount();
			acc.status__c = 'Modification requested in CRM';			

			accNew.add(acc);
			mapAcc.put(acc.id,acc);
			LAT_MX_OnTrade_Account.sendForApproval(accNew,mapAcc);
			Test.stopTest();
	}
    
	@isTest static void inactiveAccountsApprovedTest() {
			Test.startTest();
			createCSMxOnTradeNoKam();
			List<Account> accNew = new List<Account>(); 
			Account acc = retAccount();
			acc.status__c = 'Inactive Approved';			
			accNew.add(acc);
			LAT_MX_OnTrade_Account.inactiveAccounts(accNew);
			Test.stopTest();
	}
    
	@isTest static void inactiveAccountsRejectedTest() {
			Test.startTest();
			createCSMxOnTradeNoKam();
			List<Account> accNew = new List<Account>(); 
			Account acc = retAccount();
        	acc.status__c = 'Inactive Rejected';			
			accNew.add(acc);
			LAT_MX_OnTrade_Account.inactiveAccounts(accNew);
			Test.stopTest();
	}
    
    @isTest static void calcularValorCalificacionNC() {
		Test.startTest();
		createCSMxOnTradeNoKam();
		LAT_MX_SegmentacionRatios__c regSeg = new LAT_MX_SegmentacionRatios__c();
		regSeg.BacardiTo__c = 50;
		regSeg.BacardiFrom__c = 20;
		regSeg.BacardiValue__c = 0.5;
		regSeg.Values__c = 'NIGHT CLUB';
		regSeg.DjInter__c = 0.1;
		regSeg.ResAcceso__c = 0.1;
		regSeg.Visibilidad__c = 0.1;
		insert regSeg;
		Account acc = retAccount(); 
		LAT_Account__c lat = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		lat.LAT_PrecioBacardi__c = '30';
		lat.LAT_DJInternacional__c = true;
		lat.LAT_VisibilidadTailorMade__c = true;
		lat.LAT_RestriccionesAcceso__c = true;
		List<LAT_Account__c> latList = new List<LAT_Account__c>();
		latList.add(lat);	
		LAT_MX_OnTrade_Account.calcularValorCalificacion(latList);
		Test.stopTest();
	}

	@isTest static void calcularValorCalificacionHEB() {
		Test.startTest();
		createCSMxOnTradeNoKam();
		LAT_MX_SegmentacionRatios__c regSeg = new LAT_MX_SegmentacionRatios__c();
		regSeg.Values__c = 'HEB';
		regSeg.ChampFrom__c =1;
		regSeg.ChampTo__c = 10;
		regSeg.Champ_Value__c = 0.5;
		regSeg.promo__c = 0.1;
		regSeg.BrandSelec__c = 0.1;
		regSeg.CubaTo__c = 80;
		regSeg.CubaFrom__c = 30;
		regSeg.CubaValue__c = 0.1;
		regSeg.ChampFrom__c = 30;
		regSeg.ChampTo__c = 70;
		regSeg.Champ_Value__c = 0.2;
		insert regSeg;
		Account acc = retAccount(); 
		LAT_Account__c lat = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		lat.LAT_SKUChampagne__c = '40';
		lat.LAT_Branding__c = true;
		lat.LAT_CubaLibre__c = '50';
		lat.LAT_PromocionesPrecioPaquete__c = true;
		List<LAT_Account__c> latList = new List<LAT_Account__c>();
		latList.add(lat);	
		LAT_MX_OnTrade_Account.calcularValorCalificacion(latList);
		Test.stopTest();
	}

	@isTest static void calcularValorCalificacionLEB() {
		Test.startTest();
		createCSMxOnTradeNoKam();
		LAT_MX_SegmentacionRatios__c regSeg = new LAT_MX_SegmentacionRatios__c();
		regSeg.CalidadBateo__c = 'Premium';
		regSeg.CalidadBateoValue__c = 0.5;
		regSeg.Promo__c = 0.1;
		regSeg.CubaFrom__c = 20;
		regSeg.CubaTo__c = 50;
		regSeg.CubaValue__c = 0.1;
		regSeg.BrandSelec__c = 0.1;
		regSeg.Values__c = 'LEB';
		insert regSeg;
		Account acc = retAccount(); 
		LAT_Account__c lat = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		lat.LAT_CalidadBateo__c = 'Premium';
		lat.LAT_CubaLibre__c = '30';
		lat.LAT_Branding__c = true;
		lat.LAT_PromocionesPrecioPaquete__c = true;	
        lat.LAT_MX_AttendingKAM__c = UserInfo.getUserId();
		List<LAT_Account__c> latList = new List<LAT_Account__c>();
		latList.add(lat);
		LAT_MX_OnTrade_Account.calcularValorCalificacion(latList);
		List<Account> accList = new List<Account>();
		accList.add(acc);
		try {LAT_MX_OnTrade_Account.notifyOnTradeChangeSync(accList);} catch (Exception e) {}
		Test.stopTest();
	}
	@isTest static void calcularValorCalificacionRes() {
		Test.startTest();
		createCSMxOnTradeNoKam();
		LAT_MX_SegmentacionRatios__c regSeg = new LAT_MX_SegmentacionRatios__c();
		regSeg.minPlatoTo__c = 50;
		regSeg.minPlatoFrom__c = 20;
		regSeg.minPlatoValue__c = 0.5;
		regSeg.Somelier__c = 0.1;
		regSeg.Promo__c = 0.1;
		regSeg.WhiskFrom__c = 20;
		regSeg.WhiskTo__c = 50;
		regSeg.WhiskValue__c = 0.1;
		regSeg.Values__c = 'RESTAURANTE';

		insert regSeg;
		Account acc = retAccount(); 
		LAT_Account__c lat = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		lat.LAT_PrecioMinPlatoFuerte__c = '30';
		lat.LAT_SKUWhiskies__c = '30';
		lat.LAT_Somelier__c = true;
		lat.LAT_PromocionesPrecioPaquete__c = true;
		List<LAT_Account__c> latList = new List<LAT_Account__c>();
		latList.add(lat);
		LAT_MX_OnTrade_Account.calcularValorCalificacion(latList);
		Test.stopTest();
	}

	public static Account retAccount () {
		createCSMxOnTradeNoKam();
		Account accoHijo= new Account();
	   	accoHijo.Name = 'AccountTest2';
	    accoHijo.CNPJ__c = 'BRI800523HN1';
	    accoHijo.Client_code_AN8__c = '123451237';
	    accoHijo.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
	    insert accoHijo;
	    return accoHijo;
  }
}