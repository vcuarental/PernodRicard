/*********************************************************************************
 * Name:EUR_CRM_NG_TerritoryUpdate_Test 
 * Description: Test Class for Territory related functions
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/30/2015        Laputa: Conrad          Created
**********************************************************************************/
@isTest
public class EUR_CRM_NG_TerritoryUpdate_Test {
	
	public class setUser {
		User u;
		public setUser(String uName) {
		    Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
		    UserRole r = [select id from UserRole where Developername ='EMEA'];
		    u = new User(Alias = 'standt', Email=uName+'@test.com', userroleid=r.id,
		    EmailEncodingKey='UTF-8', LastName=uName+'lastName', LanguageLocaleKey='en_US', 
		    LocaleSidKey='en_US', ProfileId = p.Id, 
		    TimeZoneSidKey='America/Los_Angeles', UserName=uName+'@test.com');
		    insert u;
		}
	}

	static testMethod  void testTerritoryHandler(){
        User eurSysUser = new setUser('userEmail1234ng').u;
        User eurSysUserKD = new setUser('userEmail1234ngKD').u;
        User eurSysUserOff = new setUser('userEmail1234ngOFF').u;
        User eurSysUserON = new setUser('userEmail1234ngON').u;
        
        System.runAs(eurSysUser){
		    Id ngAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_NG_On_Trade');
		    Id ngTerritoryRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Territory__c', 'EUR_CRM_NG_Territory');
		    Id ngRegionRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Region__c', 'EUR_NG_Region');
		    
        	EUR_CRM_Region__c region = EUR_CRM_TestClassUtilityHelper.createRegion('testregion', eurSysUser.id, 'EUR_NG_Region');
        	insert region;

        	EUR_CRM_Territory__c territory = EUR_CRM_TestClassUtilityHelper.createTerritory('testterritory', eurSysUser.id, region.id, 'EUR_CRM_NG_Territory');
		    territory.EUR_CRM_Default__c = true;
		    territory.EUR_CRM_KD_Owner__c = eurSysUserKD.id;
		    territory.EUR_CRM_Off_Trade_Owner__c = eurSysUserOff.id;
		    territory.EUR_CRM_On_Trade_Owner__c = eurSysUserON.id;
		    insert territory; 
		   	Test.startTest();
		    EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountEU('test account', 'TEST CODE', 'EUR_NG_On_Trade');
		    account.EUR_CRM_Territory__c = territory.Id;
		    insert account;
		    
		    ApexPages.StandardController sc = new ApexPages.StandardController(territory);
		    User eurSysUserON2 = new setUser('userEmail1234ngON2').u;
		    territory.EUR_CRM_On_Trade_Owner__c = eurSysUserON2.id;
		    update territory;
		    EUR_CRM_NG_TerritoryUpdateController tc = new EUR_CRM_NG_TerritoryUpdateController(sc);
		    tc.massUpdateNigeriaAccounts();
            EUR_CRM_MassUpdateNGAccountOwner massUpdateAccOwn = new EUR_CRM_MassUpdateNGAccountOwner('SELECT Id, RecordTypeId, OwnerId, EUR_CRM_Territory__c, EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Off_Trade_Owner__c, EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c, EUR_CRM_Image_Level__c, EUR_CRM_RTDevName__c, EUR_CRM_Image_Level_Name__c, EUR_CRM_Territory_KD_Owner__c FROM EUR_CRM_Account__c LIMIT 10');
            EUR_CRM_MassUpdateNGAccountOwner test2 = new EUR_CRM_MassUpdateNGAccountOwner(New Set<Id>());
            test2.deleteSharingRules(New List<AccountShare>(),New List<EUR_CRM_Account__Share>(), New Map<Id,Id>(),New Map<ID, ID>());
            database.executeBatch(massUpdateAccOwn, 100);
		    Test.stopTest();

    	}
	}

}