@isTest
private class LAT_VFC09_MasiveOwnerUpdateDynamic_Test {
	
	@isTest static void test_method_one() {
		Test.startTest();
	    insert new LAT_GeneralConfig__c (Name = 'ACCOUNT_OWNER_UPDATE', LAT_Value__c = 'ARS:');
    	Test.stopTest();

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
        //User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        //System.runAs(usuario) {
	        
			Account a = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
			a.Client_code_An8__c = '8899';
			a.OwnerId = u.Id;
			insert a;

			LAT_VFC09_MasiveOwnerUpdateDynamic cont = new LAT_VFC09_MasiveOwnerUpdateDynamic();
			cont.accOldLookup = a;
			cont.accNewLookup = a;
			cont.getAccountsPerUser();
			cont.listInnerAccount[0].isSelected = true;
			cont.transferAccounts();
		    
			
		//}
		// Implement test code
	}
	
}