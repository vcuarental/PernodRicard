@isTest
private class LAT_MX_MassiveUploadClientQuadrants_Test {
	
	@isTest static void test_method_one() {
		
		LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
		lgc.LAT_Value__c = UserInfo.getName(); //UserInfo.getName();
		lgc.SetupOwnerId = UserInfo.getOrganizationId();
		lgc.name = 'MX_ON_TRADE_NO_KAM_USERS';
		insert lgc;
		
		Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert acc;
		LAT_Account__c latAcc = [SELECT id from LAT_Account__c where LAT_Accountid__c =: acc.id];
		Account accoHijo= new Account();
	   	accoHijo.Name = 'AccountTest2';
	    accoHijo.CNPJ__c = 'BRI800523HN1';
	    accoHijo.Client_code_AN8__c = '123451237';
	    accoHijo.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
	    accoHijo.parentID=acc.id;
	    insert accoHijo;


		String toTest = 'Código Cliente JDE (AN8),Id. de la cuenta,Nombre de la cuenta,Segmentación\n';
		toTest	+= '11--11,' + accoHijo.Id + ',GRANERO BAR,Estrella\n';
		toTest	+= '1228-651,001D000001qvFOHIA2,BAREZZITO VERACRUZ,Lupa\n';
		toTest	+= '1198-643,001D000001qvFO5IAM,GUILT & ENVY,Contribuyente\n';
		toTest	+= '1198-642,001D000001qvFO4IAM,GUILT & ENVY,Volumen\n';
		toTest	+= 'abec,adssss,re\n';
		toTest	+= 'abec';

		LAT_MX_MassiveUploadClientQuadrants_Cont cont = new LAT_MX_MassiveUploadClientQuadrants_Cont();
		cont.toParse = Blob.valueOf(toTest);
		cont.upload();

		// Implement test code
	}
	
	
}