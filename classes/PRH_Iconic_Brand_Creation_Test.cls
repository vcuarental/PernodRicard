/*
  January 2017 - evolution application Le Cercle LCS-11
  July 2017 - evolution LCS-159
  PRH_Iconic_Brand_Creation test class
*/

@isTest(SeeAllData = false) 
private class PRH_Iconic_Brand_Creation_Test {
	@testSetup static void setUpData() {
        List<PRH_Luxury_Accounts__c> iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
		PRH_Collect__c newCollect1;
		PRH_Collect__c newCollect2;
		DateTime dt = DateTime.now(); 
		String dateTimeStr = dt.format('YYMMDD_hhmmss'); 
		Profile adminp = [select id from profile where Name = 'System Administrator' limit 1];    
        System.debug('dateTimeStr : '+ dateTimeStr);
		
        // Creation of 1 user (iconic account's owners)
        Profile p = [SELECT Id FROM Profile WHERE Name='PRH_Iconic_Platform']; 
        User u1 = new User(Alias = 'user1', Email='PRH_testuser1'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser1'+dateTimeStr+'@prhtestorg.com');
        insert u1;

		User user1 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser1%') LIMIT 1];
		System.debug('==> user1.Id : '+ user1.Id);
		        
		User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
        System.runAs(ic_myUser) { 
			PRH_Competitor_Brands__c compBrand1;	
			PRH_Brand_Criteria__c leCercleBrand1;	
			PRH_Brand_Criteria__c leCercleBrand2;	
			List<PRH_Collect__c> listOfNewCollects = new List<PRH_Collect__c>();
			List<PRH_Brand_Criteria__c> newLeCercleBRsList = new List<PRH_Brand_Criteria__c>();
			List<PRH_Competitor_Brands__c> newCompetitorBRsList = new List<PRH_Competitor_Brands__c >();		
			
			// Creation of the Iconic Accounts
			for (Integer i=0; i < 2; i++) { 
				if (i < 1) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'IconicAcc-'+i,
                        PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = false,
						PRH_Account_Region__c = 'PR LATAM'
					);
					iconicAccounts.add(acc); 
				} else {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'IconicAcc-'+i,
						PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = false,
						PRH_Account_Region__c = 'France'
					);
					iconicAccounts.add(acc); 
				}
			}	
			insert iconicAccounts;
		}
    }
    
	@isTest static void PRH_Test_BrandsCreation_Trigger() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
		System.debug('==> PRH_Test_BrandsCreation_Trigger() ic_myUser : '+ ic_myUser);
		
        System.runAs(ic_myUser) {         	
			System.Test.startTest(); 

			// Verify the trigger has run 
			List<PRH_Competitor_Brands__c> compBRbeforeTrigger = [SELECT Id FROM PRH_Competitor_Brands__c]; 
			System.assertEquals(0, compBRbeforeTrigger.size()); 

			PRH_Brand_Luxury_Brand__c br1 = new PRH_Brand_Luxury_Brand__c();
            br1.Name = 'Cidre doux';
			br1.PRH_Competitor_Brand__c = true;
			br1.PRH_Sequence__c = 'COMP0001';
			br1.PRH_PIM_ID__c = 'PIMC001';
            br1.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
            insert br1;
			
			List<PRH_Competitor_Brands__c> compBRafterTrigger = [SELECT Id, Name FROM PRH_Competitor_Brands__c]; 
			System.assertEquals(0, compBRafterTrigger.size()); 
			
			List<PRH_Brand_Criteria__c> lecercleBRbeforeTrigger = [SELECT Id, Name FROM PRH_Brand_Criteria__c]; 
			System.assertEquals(0, lecercleBRbeforeTrigger.size()); 

			PRH_Brand_Luxury_Brand__c br2 = new PRH_Brand_Luxury_Brand__c();
            br2.Name = 'Malibu Coco';
			br2.PRH_Competitor_Brand__c = false;
			br2.PRH_Sequence__c = 'LCEB0001';
			br2.PRH_PIM_ID__c = 'PIM001';
            br2.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert br2;
			
			PRH_Brand_Luxury_Brand__c br3 = new PRH_Brand_Luxury_Brand__c();
            br3.Name = 'Dom Perignon';
			br3.PRH_Competitor_Brand__c = false;
			br3.PRH_Sequence__c = 'LCEB0002';
			br3.PRH_PIM_ID__c = 'PIM002';
            br3.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert br3;
			
			List<PRH_Brand_Criteria__c> lecercleBRafterTrigger = [SELECT Id, Name FROM PRH_Brand_Criteria__c]; 
			System.assertEquals(0, lecercleBRafterTrigger.size()); 
			
			System.Test.stopTest(); 
		}   	
    }
}