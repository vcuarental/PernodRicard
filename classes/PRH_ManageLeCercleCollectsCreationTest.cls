// Le Cercle application - evolution LCS-153 - July 2017
// Test class for scheduler that launch batch of creation of Le Cercle collects
@isTest(SeeAllData = false) 
private class PRH_ManageLeCercleCollectsCreationTest {
	
	@testSetup static void setUpData() {
        List<PRH_Luxury_Accounts__c> iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
		DateTime dt = DateTime.now(); 
		String dateTimeStr = dt.format('YYMMDD_hhmmss'); 
		List<PRH_Collect__c> listOfNewCollects = new List<PRH_Collect__c >();
		Profile adminp = [select id from profile where Name = 'System Administrator' limit 1];    
        System.debug('dateTimeStr : '+ dateTimeStr);
        
        // Creation of 5 users (iconic account's owners)
        Profile p = [SELECT Id FROM Profile WHERE Name='PRH_Iconic_Platform']; 
        User u1 = new User(Alias = 'user1', Email='PRH_testuser1'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser1'+dateTimeStr+'@prhtestorg.com');
        insert u1;
        User u2 = new User(Alias = 'user2', Email='PRH_testuser2'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser2'+dateTimeStr+'@prhtestorg.com');
        insert u2;
        User u3 = new User(Alias = 'user3', Email='PRH_testuser3'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser3', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = adminp.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser3'+dateTimeStr+'@prhtestorg.com');
        insert u3;

		User user1 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser1%') LIMIT 1];
		User user2 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser2%') LIMIT 1];
		User user3 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser3%') LIMIT 1];

		System.debug('==> user1.Id : '+ user1.Id);
		System.debug('==> user2.Id : '+ user2.Id);
		System.debug('==> user3.Id : '+ user3.Id);

		List<PermissionSet> listPs = [select id, name
                                      from PermissionSet
                                      where name = 'PRH_Iconic_Platform_Support_LeCercle'];
        if (listPS.size() > 0) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.assigneeId = user3.Id;
            psa.PermissionSetId = listPS[0].Id;
            Database.SaveResult resInsert = Database.insert(psa);
        }                              

		User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
        System.runAs(ic_myUser) {             
            // Creation of some Iconic Brands		
			PRH_Brand_Luxury_Brand__c ib1 = new PRH_Brand_Luxury_Brand__c();
            ib1.Name = 'Martell XO';
			ib1.PRH_Competitor_Brand__c = false;
			ib1.PRH_Sequence__c = 'LCEB0001';
			ib1.PRH_Active__c = True;
            ib1.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert ib1;
			
			PRH_Brand_Luxury_Brand__c ib2 = new PRH_Brand_Luxury_Brand__c();
            ib2.Name = 'PJ Belle Epoque and above';
			ib2.PRH_Competitor_Brand__c = false;
			ib2.PRH_Sequence__c = 'LCEB0002';
			ib2.PRH_Active__c = True;
            ib2.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert ib2;
			
			PRH_Brand_Luxury_Brand__c ib3 = new PRH_Brand_Luxury_Brand__c();
            ib3.Name = 'Dom Perignon';
			ib3.PRH_Competitor_Brand__c = true;
			ib3.PRH_Sequence__c = 'COMP0001';
			ib3.PRH_Active__c = True;
            ib3.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
            insert ib3;
            
			// Creation of the Iconic Account
			for (Integer i = 0; i < 2; i++) { 
				acc = new PRH_Luxury_Accounts__c(
					Name = 'Iconic-'+i,
                    PRH_High_Networth_Individuals__c = false,
					PRH_Suppress_and_archive__c = false,
					PRH_Account_Region__c = 'PR LATAM'
				);
				iconicAccounts.add(acc); 
			}	
			insert iconicAccounts;
		}
    }
    

	@isTest static void Test_PRH_BatchManageLeCercleCollectsCreation1() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation() ic_myUser : '+ ic_myUser);
		
        System.runAs(ic_myUser) {         	
			System.Test.startTest(); 

        	List<PRH_Collect__c> listOfCollectsToUpdate = new List<PRH_Collect__c >();
			Date PRH_PeriodStartDatePreviousCollect = date.newInstance(2016, 11, 01);
			Date PRH_PeriodEndDatePreviousCollect = date.newInstance(2017, 28, 02);

			List<PRH_Collect__c> listActiveColl = [Select id, PRH_Period_End__c, PRH_Period_Start__c From PRH_Collect__c Where PRH_Active__c=true ];
			System.assertEquals(2,listActiveColl.size());
			System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, there are ' + listActiveColl.size() + ' active collects');
			
			for (PRH_Collect__c c:listActiveColl) {
				c.PRH_Period_Start__c = PRH_PeriodStartDatePreviousCollect;
				c.PRH_Period_End__c = PRH_PeriodEndDatePreviousCollect;
				listOfCollectsToUpdate.add(c);
			}

			if (listOfCollectsToUpdate.size() > 0) {
				update listOfCollectsToUpdate; 
				System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, ' + listOfCollectsToUpdate.size() + ' collects have been updated with PRH_Period_Start__c = ' + PRH_PeriodStartDatePreviousCollect);
			}		
			
            List<PRH_Competitor_Brands__c> newCompetitorBrandsListbefore = [SELECT Id, Name FROM PRH_Competitor_Brands__c];
            System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation : '+ newCompetitorBrandsListbefore);
			System.assertEquals(2,newCompetitorBrandsListbefore.size());
            

			PRH_ManageLeCercleCollectsCreation obj = new PRH_ManageLeCercleCollectsCreation(); 
            DataBase.executeBatch(obj,200);  

            System.Test.stopTest(); 
			List<PRH_Competitor_Brands__c> newCompetitorBrandsList = [SELECT Id, Name FROM PRH_Competitor_Brands__c where PRH_Collect__c In :listActiveColl ];
            System.debug('==> newCompetitorBrandsList : '+ newCompetitorBrandsList);
			System.assertEquals(2,newCompetitorBrandsList.size());
		} 	
    }

	@isTest static void Test_PRH_BatchManageLeCercleCollectsCreation2() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation() ic_myUser : '+ ic_myUser);
		
        System.runAs(ic_myUser) {         	
			System.Test.startTest(); 

        	List<PRH_Collect__c> listOfCollectsToUpdate = new List<PRH_Collect__c >();
			Date PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 01, 03);
			Date PRH_PeriodEndDatePreviousCollect = date.newInstance(2017, 30, 06);

			List<PRH_Collect__c> listActiveColl = [Select id, PRH_Period_End__c, PRH_Period_Start__c From PRH_Collect__c Where PRH_Active__c=true ];
			System.assertEquals(2,listActiveColl.size());
			System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, there are ' + listActiveColl.size() + ' active collects');
			
			for (PRH_Collect__c c:listActiveColl) {
				c.PRH_Period_Start__c = PRH_PeriodStartDatePreviousCollect;
				c.PRH_Period_End__c = PRH_PeriodEndDatePreviousCollect;
				listOfCollectsToUpdate.add(c);
			}

			if (listOfCollectsToUpdate.size() > 0) {
				update listOfCollectsToUpdate; 
				System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, ' + listOfCollectsToUpdate.size() + ' collects have been updated with PRH_Period_Start__c = ' + PRH_PeriodStartDatePreviousCollect);
			}		
			
            List<PRH_Competitor_Brands__c> newCompetitorBrandsListbefore = [SELECT Id, Name FROM PRH_Competitor_Brands__c];
            System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation : '+ newCompetitorBrandsListbefore);
			System.assertEquals(2,newCompetitorBrandsListbefore.size());
            

			PRH_ManageLeCercleCollectsCreation obj = new PRH_ManageLeCercleCollectsCreation(); 
			obj.setNextStep(1);
            DataBase.executeBatch(obj,200);    

            System.Test.stopTest(); 
			List<PRH_Competitor_Brands__c> newCompetitorBrandsList = [SELECT Id, Name FROM PRH_Competitor_Brands__c where PRH_Collect__c In :listActiveColl ];
            System.debug('==> newCompetitorBrandsList : '+ newCompetitorBrandsList);
			System.assertEquals(2,newCompetitorBrandsList.size());
		} 	
    }
    
    @isTest static void Test_PRH_BatchManageLeCercleCollectsCreation3() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation() ic_myUser : '+ ic_myUser);
		
        System.runAs(ic_myUser) {         	
			System.Test.startTest(); 

        	List<PRH_Collect__c> listOfCollectsToUpdate = new List<PRH_Collect__c >();
			Date PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 01, 07);
			Date PRH_PeriodEndDatePreviousCollect = date.newInstance(2017, 30, 10);

			List<PRH_Collect__c> listActiveColl = [Select id, PRH_Period_End__c, PRH_Period_Start__c From PRH_Collect__c Where PRH_Active__c=true ];
			System.assertEquals(2,listActiveColl.size());
			System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, there are ' + listActiveColl.size() + ' active collects');
			
			for (PRH_Collect__c c:listActiveColl) {
				c.PRH_Period_Start__c = PRH_PeriodStartDatePreviousCollect;
				c.PRH_Period_End__c = PRH_PeriodEndDatePreviousCollect;
				listOfCollectsToUpdate.add(c);
			}

			if (listOfCollectsToUpdate.size() > 0) {
				update listOfCollectsToUpdate; 
				System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, ' + listOfCollectsToUpdate.size() + ' collects have been updated with PRH_Period_Start__c = ' + PRH_PeriodStartDatePreviousCollect);
			}		
			
            List<PRH_Competitor_Brands__c> newCompetitorBrandsListbefore = [SELECT Id, Name FROM PRH_Competitor_Brands__c];
            System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation : '+ newCompetitorBrandsListbefore);
			System.assertEquals(2,newCompetitorBrandsListbefore.size());
            

			PRH_ManageLeCercleCollectsCreation obj = new PRH_ManageLeCercleCollectsCreation(); 
			obj.setNextStep(2);
            DataBase.executeBatch(obj,200);   

            System.Test.stopTest(); 
			List<PRH_Competitor_Brands__c> newCompetitorBrandsList = [SELECT Id, Name FROM PRH_Competitor_Brands__c where PRH_Collect__c In :listActiveColl ];
            System.debug('==> newCompetitorBrandsList : '+ newCompetitorBrandsList);
			System.assertEquals(2,newCompetitorBrandsList.size());
		} 	
    }

    @isTest static void Test_PRH_BatchManageLeCercleCollectsCreation4() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation() ic_myUser : '+ ic_myUser);
		
        System.runAs(ic_myUser) {         	
			System.Test.startTest(); 

        	List<PRH_Collect__c> listOfCollectsToUpdate = new List<PRH_Collect__c >();
			Date PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 01, 07);
			Date PRH_PeriodEndDatePreviousCollect = date.newInstance(2017, 30, 10);

			List<PRH_Collect__c> listActiveColl = [Select id, PRH_Period_End__c, PRH_Period_Start__c From PRH_Collect__c Where PRH_Active__c=true ];
			System.assertEquals(2,listActiveColl.size());
			System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, there are ' + listActiveColl.size() + ' active collects');
			
			for (PRH_Collect__c c:listActiveColl) {
				c.PRH_Period_Start__c = PRH_PeriodStartDatePreviousCollect;
				c.PRH_Period_End__c = PRH_PeriodEndDatePreviousCollect;
				listOfCollectsToUpdate.add(c);
			}

			if (listOfCollectsToUpdate.size() > 0) {
				update listOfCollectsToUpdate; 
				System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation, ' + listOfCollectsToUpdate.size() + ' collects have been updated with PRH_Period_Start__c = ' + PRH_PeriodStartDatePreviousCollect);
			}		
			
            List<PRH_Competitor_Brands__c> newCompetitorBrandsListbefore = [SELECT Id, Name FROM PRH_Competitor_Brands__c];
            System.debug('==> Test_PRH_BatchManageLeCercleCollectsCreation : '+ newCompetitorBrandsListbefore);
			System.assertEquals(2,newCompetitorBrandsListbefore.size());
            

			PRH_ManageLeCercleCollectsCreation obj = new PRH_ManageLeCercleCollectsCreation(); 
			obj.setNextStep(3);
            DataBase.executeBatch(obj,200);     

            System.Test.stopTest(); 
			List<PRH_Competitor_Brands__c> newCompetitorBrandsList = [SELECT Id, Name FROM PRH_Competitor_Brands__c where PRH_Collect__c In :listActiveColl ];
            System.debug('==> newCompetitorBrandsList : '+ newCompetitorBrandsList);
			System.assertEquals(2,newCompetitorBrandsList.size());
		} 	
    }

    @isTest static void Test_PRH_ScheduleBatchBrandsCreationForCollects() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
		System.debug('==> Test_PRH_ScheduleBatchBrandsCreationForCollects() ic_myUser : '+ ic_myUser);
		
        System.runAs(ic_myUser) {         	
			System.Test.startTest(); 
			
			String CRON_EXP = '0 0 0 2 3 ? 2098';
			String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new PRH_BatchLeCercleCollectsCreation()); 
			
			CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

			System.assertEquals(CRON_EXP, ct.CronExpression); 
			System.assertEquals(0, ct.TimesTriggered);
			
			System.Test.stopTest(); 
		}   	
    }
}