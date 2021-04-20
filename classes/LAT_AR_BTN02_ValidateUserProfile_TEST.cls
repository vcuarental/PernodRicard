/********************************************************************************
*   Company:Valuenet       Developer:Denis Aranda       Date:24/06/2013         *
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
@isTest
public with sharing class LAT_AR_BTN02_ValidateUserProfile_TEST {
	
	static testmethod void unitTest(){
		
   User usuario = new User();
   usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','AR'); 
   insert usuario;
			
		System.runAs(usuario){ 
			LAT_AR_BTN02_ValidateUserProfile.ValidateUserProfile();
		}
	}
	
	static testmethod void unitTest2(){
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'AR_Vendedor' OR Name = 'LAT_AR2_Vendedor' LIMIT 1]; 
		
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
			
		System.runAs(u){ 
			LAT_AR_BTN02_ValidateUserProfile.ValidateUserProfile();
		}
	}
}