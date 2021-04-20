/*
* Created Date: September 15,2016
*
* Description: Test class for PRH_Iconic_Accounts_Controller controller
*
*/
@isTest(SeeAllData = false) 

private class PRH_Iconic_Accounts_ControllerTest {
    
    @testSetup static void setUpUsers() {
        List<PRH_Luxury_Accounts__c> iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
		DateTime dt = DateTime.now(); 
		String dateTimeStr = dt.format('YYMMDD_hhmmss'); 
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
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser3'+dateTimeStr+'@prhtestorg.com');
        insert u3;
        User u4 = new User(Alias = 'user4', Email='PRH_testuser4'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser4', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser4'+dateTimeStr+'@prhtestorg.com');
        insert u4;
        User u5 = new User(Alias = 'user5', Email='PRH_testuser5'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser5', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser5'+dateTimeStr+'@prhtestorg.com');
        insert u5;
		
        User u6 = new User(Alias = 'user6', Email='PRH_testuser6'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser6', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = adminp.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser6'+dateTimeStr+'@prhtestorg.com');
        insert u6;
        
		User user1 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser1%') LIMIT 1];
		User user2 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser2%') LIMIT 1];
		User user3 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser3%') LIMIT 1];
		User user4 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser4%') LIMIT 1];
		User user5 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser5%') LIMIT 1];
		System.debug('==> user1.Id : '+ user1.Id);
		System.debug('==> user2.Id : '+ user2.Id);
		System.debug('==> user3.Id : '+ user3.Id);
		System.debug('==> user4.Id : '+ user4.Id);
		System.debug('==> user5.Id : '+ user5.Id);
		        
		User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        System.runAs(ic_myUser) {         
			// Creation of the Iconic Accounts
			for (Integer i=0; i < 70; i++) { 
				if (i < 10) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Fraccount-'+i,
                        PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = false,
						PRH_Located_in_a_hotel__c = false,
                        PRH_ICT_Account__c = false,
						PRH_Account_Region__c = 'PR LATAM'
					);
					iconicAccounts.add(acc); 
				} else if (i >= 10 && i < 20) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Fraccount-'+i,
                        PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = false,
						PRH_Located_in_a_hotel__c = false,
                        PRH_ICT_Account__c = true
					);
					iconicAccounts.add(acc); 
                } else if (i >= 20 && i < 30) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Account-'+i,
						PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = false,
                        PRH_ICT_Account__c = false,
						PRH_Located_in_a_hotel__c = false
					);
					iconicAccounts.add(acc); 
				} else if (i >= 30 && i < 40) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Pernod-'+i,
						PRH_High_Networth_Individuals__c = true,
						PRH_Suppress_and_archive__c = true,
                        PRH_ICT_Account__c = false,
						PRH_Located_in_a_hotel__c = true
					);
					iconicAccounts.add(acc); 
				} else if (i >= 40 && i < 45) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Dudule-'+i,
						PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = false,
                        PRH_ICT_Account__c = false,
						PRH_Located_in_a_hotel__c = false
					);
					iconicAccounts.add(acc); 
				} else if (i >= 45 && i < 55) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Cccoo-'+i,
						PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = true,
                        PRH_ICT_Account__c = false,
						PRH_Located_in_a_hotel__c = true
					);
					iconicAccounts.add(acc); 
				} else if (i >= 55 && i < 60) {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Nnn-'+i,
						PRH_High_Networth_Individuals__c = true,
						PRH_Suppress_and_archive__c = false,
						PRH_Located_in_a_hotel__c = true,
                        PRH_ICT_Account__c = false,
						PRH_Account_Country__c = 'USA',
						PRH_City__c = 'Boston'
					);
					iconicAccounts.add(acc); 
				} else {
					acc = new PRH_Luxury_Accounts__c(
						Name = 'Zoo-'+i,
						PRH_High_Networth_Individuals__c = false,
						PRH_Suppress_and_archive__c = false,
                        PRH_ICT_Account__c = false,
						PRH_Located_in_a_hotel__c = false
					);
					iconicAccounts.add(acc); 
				}
			}	
			insert iconicAccounts;
			
			PRH_Luxury_Accounts__c accountToUpdate; 
            try {         
                // Update account 
                accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Nnn-56%') LIMIT 1]; 
                // Update the owner and owner2
                accountToUpdate.OwnerId = user1.Id;
                accountToUpdate.PRH_Owner_2__c = user2.Id;
                // Make the update call
                update accountToUpdate; 
				
				// Update account 
                accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Nnn-58%') LIMIT 1]; 
                // Update the owner and owner2
                accountToUpdate.OwnerId = user1.Id;
                accountToUpdate.PRH_Owner_2__c = user2.Id;
                // Make the update call
                update accountToUpdate; 
				
				// Update account 
                accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Account-23%') LIMIT 1]; 
                // Update the owner and owner2
                accountToUpdate.OwnerId = user3.Id;
                accountToUpdate.PRH_Owner_2__c = user5.Id;
                // Make the update call
                update accountToUpdate; 
				
				// Update account 
                accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Account-27%') LIMIT 1]; 
                // Update the owner and owner2
                accountToUpdate.OwnerId = user1.Id;
                accountToUpdate.PRH_Owner_2__c = user5.Id;
                // Make the update call
                update accountToUpdate; 
				
				// Update account 
                accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Account-29%') LIMIT 1]; 
                // Update the owner and owner2
                accountToUpdate.OwnerId = user4.Id;
                accountToUpdate.PRH_Owner_2__c = user5.Id;
                // Make the update call
                update accountToUpdate; 
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
		}
    }
	
	@isTest static void Test_firstDisplay() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
			
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			ctl.firstDisplay();
            ctl.displayRecords();
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_PRH_Iconic_Accounts_Controller_1() {
		PRH_Iconic_Accounts_Controller ctl;
		List<PRH_Luxury_Accounts__c> iconic_accs;
		
		User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
			
            Test.startTest();      
		
			PageReference pageRef = Page.PRH_Iconic_Accounts_ReportExcel;
			pageRef.getParameters().put('acc_name','Cccoo-');
			pageRef.getParameters().put('acc_type','Restaurant');
			pageRef.getParameters().put('acc_country','Uruguay');
            pageRef.getParameters().put('acc_nbp','5');
			pageRef.getParameters().put('acc_mc','PR Uruguay');
            pageRef.getParameters().put('acc_owner','');
			pageRef.getParameters().put('acc_owner2','');
			pageRef.getParameters().put('acc_hni','false');
			pageRef.getParameters().put('acc_faap','true');
			pageRef.getParameters().put('acc_lh','true');
			pageRef.getParameters().put('acc_ict','true');
			pageRef.getParameters().put('acc_flc','true');
			pageRef.getParameters().put('acc_lcbp','false');
			pageRef.getParameters().put('acc_region','PR LATAM');
			pageRef.getParameters().put('acc_city','Montevideo');
            pageRef.getParameters().put('export_type','normal');
			
			Test.setCurrentPage(pageRef);
			ctl = new PRH_Iconic_Accounts_Controller();
			iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			Test.stopTest();
		}
	}
    
    @isTest static void Test_PRH_Iconic_Accounts_Controller_4() {
		PRH_Iconic_Accounts_Controller ctl;
		List<PRH_Luxury_Accounts__c> iconic_accs;
		
		User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
			
            Test.startTest();      
		
			PageReference pageRef = Page.PRH_Iconic_Accounts_ReportExcel;
			pageRef.getParameters().put('acc_name','Ccc\'oo-');
			pageRef.getParameters().put('acc_country','Uruguay');
			pageRef.getParameters().put('export_type','normal');
			
			Test.setCurrentPage(pageRef);
			ctl = new PRH_Iconic_Accounts_Controller();
			iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			Test.stopTest();
		}
	}	
						
	@isTest static void Test_affichSearchResult() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
			
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			//ctl.PRH_High_Networth_Individuals = 'Yes';
			//ctl.PRH_Suppress_and_archive = 'Yes';	
			ctl.PRH_ICT_Account = 'Yes';	
			//ctl.PRH_Full_Le_Cercle = 'Yes';
			ctl.PRH_Le_Cercle_Brand_Presence = 'No';
			ctl.affichSearchResult();
            iconic_accs = ctl.getPRH_accounts();
			//System.assertEquals(0, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			
			Integer nbAcc = ctl.getPRH_nbIconicAccounts();
			System.assertEquals(70, nbAcc);
			
			String criteria = null;
			criteria = ctl.getPRH_criteria();
			
            Test.stopTest();
		}   	
    }

	@isTest static void Test_affichSearchResultAlpha() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			//ctl.PRH_High_Networth_Individuals = 'No';
			//ctl.PRH_Suppress_and_archive = 'No';
			ctl.PRH_Located_in_a_hotel = 'No';	
			ctl.affichSearchResultAlpha();
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(45, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			ctl.alpha = 'F';
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(20, iconic_accs.size());
			
			ctl.alpha = 'F';
			ctl.sortOrder = 'Name';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(20, iconic_accs.size());
            
			ctl.alpha = 'F';
			ctl.sortOrder = 'PRH_Owner_2__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_affichSearchResultAlphaAccRegion() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			ctl.PRH_Account_Region = 'PR LATAM';
			ctl.affichSearchResultAlpha();
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(10, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			ctl.alpha = 'P';
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
			ctl.alpha = 'P';
			ctl.sortOrder = 'PRH_Account_Region__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(10, iconic_accs.size());
            
			ctl.alpha = 'P';
			ctl.sortOrder = 'PRH_Owner_2__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_affichSearchResultAlphaAccCountry() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			ctl.PRH_Account_Country = 'USA';
			ctl.affichSearchResultAlpha();
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(5, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			ctl.alpha = 'P';
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
			ctl.alpha = 'P';
			ctl.sortOrder = 'PRH_Account_Country__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
            
			ctl.alpha = 'P';
			ctl.sortOrder = 'PRH_Owner_2__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_affichSearchResultAlphaAccCity() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			ctl.PRH_Account_City = 'Boston';
			ctl.affichSearchResultAlpha();
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(5, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			ctl.alpha = 'P';
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
			ctl.alpha = 'B';
			ctl.sortOrder = 'PRH_City__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(5, iconic_accs.size());
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_affichSearchResultAlphaAccMC() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			ctl.PRH_Account_Market_Company = 'PR USA';
			ctl.affichSearchResultAlpha();
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			ctl.alpha = 'P';
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
			ctl.alpha = 'P';
			ctl.sortOrder = 'PRH_Account_Market_Company__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
            
			ctl.alpha = 'P';
			ctl.sortOrder = 'PRH_Owner_2__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_affichSearchResultAlphaOwner() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			ctl.PRH_Owner = 'User1';
			ctl.affichSearchResultAlpha();
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			ctl.alpha = 'U';
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
			ctl.alpha = 'U';
			ctl.sortOrder = 'Owner.Name';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
            
			ctl.alpha = 'U';
			ctl.sortOrder = 'PRH_Owner_2__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());

			ctl.ViewData();
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_affichSearchResultAlphaOwner2() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl;
			List<PRH_Luxury_Accounts__c> iconic_accs;
		
			ctl = new PRH_Iconic_Accounts_Controller();
			ctl.PRH_Owner_2 = 'User2';
			ctl.affichSearchResultAlpha();
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			System.assertEquals(70, ctl.PRH_nbIconicAccounts);
			ctl.alpha = 'U';
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
			ctl.alpha = 'U';
			ctl.sortOrder = 'PRH_Owner_2__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
            
			ctl.alpha = 'U';
			ctl.sortOrder = 'PRH_Account_Market_Company__c';
			ctl.sortOnColumnToDo = True;
            iconic_accs = ctl.getPRH_accounts();
			System.assertEquals(0, iconic_accs.size());
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_updateUrlExcelExport() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
		String db_query;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
			
            Test.startTest();                 
            
			// Case 1
			String url_param;		
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();
			//ctl1.PRH_High_Networth_Individuals = 'Yes';
			//ctl1.PRH_Suppress_and_archive = 'No';
			ctl1.PRH_Located_in_a_hotel = 'Yes';
			ctl1.PRH_Owner = 'PRH_testuser1';
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl1.updateUrlExcelExport();
			String encoded_acc_owner = EncodingUtil.urlEncode(ctl1.PRH_Owner, 'UTF-8');
			url_param = url_param + 'acc_owner=' + encoded_acc_owner;
			url_param = url_param + '&export_type=' + EncodingUtil.urlEncode('normal', 'UTF-8');
			url_param = '/apex/PRH_Iconic_Accounts_ReportExcel?' + url_param + '&acc_sa=' + ctl1.PRH_Suppress_and_archive;
			System.assertNotEquals(ctl1.url, '');   
			db_query = ctl1.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs1 = Database.query(db_query);
			System.assertEquals(25, iconic_accs1.size());
			
			// Case 2
			PRH_Iconic_Accounts_Controller ctl2 = new PRH_Iconic_Accounts_Controller();
			//ctl2.PRH_High_Networth_Individuals = 'No';
			//ctl2.PRH_Suppress_and_archive = 'No';
			ctl2.PRH_Located_in_a_hotel = 'No';
			ctl2.PRH_Owner_2 = 'PRH_testuser2';
			ctl2.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl2.updateUrlExcelExport();
			System.assertNotEquals(ctl2.url, '');  
			db_query = ctl2.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs2 = Database.query(db_query);
			System.assertEquals(45, iconic_accs2.size());
			
			// Case 3
			PRH_Iconic_Accounts_Controller ctl3 = new PRH_Iconic_Accounts_Controller();
			//ctl3.PRH_High_Networth_Individuals = 'Yes';
			//ctl3.PRH_Suppress_and_archive = 'No';
			ctl3.PRH_Located_in_a_hotel = 'Yes';
			ctl3.PRH_Owner = 'PRH_testuser1';
			ctl3.PRH_Owner_2 = 'PRH_testuser2';
			ctl3.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl3.updateUrlExcelExport();
			System.assertNotEquals(ctl3.url, ''); 			
			db_query = ctl3.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs3 = Database.query(db_query);
			System.assertEquals(25, iconic_accs3.size());
			
			// Case 4
			PRH_Iconic_Accounts_Controller ctl4 = new PRH_Iconic_Accounts_Controller();
			ctl4.PRH_Account_Type = 'Traditional On Trade';
            ctl4.account_Types = new String[]{'Traditional On Trade'};
			ctl4.PRH_Account_Region = 'PR EMEA';
			ctl4.PRH_Account_Country = 'UK';
			ctl4.PRH_Account_Name = 'Pernod-';
			ctl4.PRH_Account_Market_Company = 'PR UK';
			//ctl4.PRH_High_Networth_Individuals = 'Yes';
			//ctl4.PRH_Suppress_and_archive = 'Yes';
			ctl4.PRH_Located_in_a_hotel = 'Yes';
			ctl4.PRH_Owner = 'PRH_testuser1';
			ctl4.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl4.updateUrlExcelExport();
			System.assertNotEquals(ctl4.url, '');
			db_query = ctl4.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs4 = Database.query(db_query);
			System.assertEquals(0, iconic_accs4.size());
			
			// Case 5
			PRH_Iconic_Accounts_Controller ctl5 = new PRH_Iconic_Accounts_Controller();
			ctl5.PRH_Account_Type = 'Restaurant,Traditional On Trade,High Energy Bar';
            ctl5.account_Types = new String[]{'Restaurant', 'Traditional On Trade','High Energy Bar'};
			ctl5.PRH_Account_Region = 'PR EMEA';
			ctl5.PRH_Account_Country = 'UK';
			ctl5.PRH_Account_Name = 'Pernod-';
			ctl5.PRH_Account_Market_Company = 'PR UK';
			//ctl5.PRH_High_Networth_Individuals = 'No';
			ctl5.PRH_Located_in_a_hotel = 'No';
			//ctl5.PRH_Suppress_and_archive = 'No';
			ctl5.PRH_Owner = 'PRH_testuser1';
			ctl5.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl5.updateUrlExcelExport();
			System.assertNotEquals(ctl5.url, '');
			db_query = ctl5.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs5 = Database.query(db_query);
			System.assertEquals(0, iconic_accs5.size());
			
			// Case 6
			PRH_Iconic_Accounts_Controller ctl6 = new PRH_Iconic_Accounts_Controller();
			ctl6.PRH_Account_Region = 'PR EMEA';
			ctl6.PRH_Account_Country = 'UK';
			ctl6.PRH_Account_Name = 'Pernod-';
			ctl6.PRH_Account_Market_Company = 'PR UK';
			ctl6.PRH_Account_City = 'London';
			//ctl6.PRH_High_Networth_Individuals = 'No';
			//ctl6.PRH_Suppress_and_archive = 'No';
			ctl6.PRH_Owner = 'PRH_testuser1';
			ctl6.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl6.updateUrlExcelExport();
			System.assertNotEquals(ctl6.url, '');
			db_query = ctl6.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs6 = Database.query(db_query);
			System.assertEquals(0, iconic_accs6.size());

			// Case 7
			PRH_Iconic_Accounts_Controller ctl7 = new PRH_Iconic_Accounts_Controller();
			ctl7.PRH_Account_Type = 'Traditional On Trade';
            ctl7.account_Types = new String[]{'Traditional On Trade'};
			//ctl7.PRH_High_Networth_Individuals = 'No';
			//ctl7.PRH_Suppress_and_archive = 'No';
			ctl7.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl7.updateUrlExcelExport();
			System.assertNotEquals(ctl7.url, '');
			db_query = ctl7.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs7 = Database.query(db_query);
			System.assertEquals(0, iconic_accs7.size());			
            Test.stopTest();
			
			// Case 8
			PRH_Iconic_Accounts_Controller ctl8 = new PRH_Iconic_Accounts_Controller();
			ctl8.PRH_Account_Region = 'PR EMEA';
			ctl8.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
			//ctl8.PRH_High_Networth_Individuals = 'No';
			ctl8.PRH_Located_in_a_hotel = 'Yes';
			//ctl8.PRH_Suppress_and_archive = 'No';
            ctl8.updateUrlExcelExport();
			System.assertNotEquals(ctl8.url, '');
			db_query = ctl8.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs8 = Database.query(db_query);
			System.assertEquals(0, iconic_accs8.size());
			
			// Case 9
			PRH_Iconic_Accounts_Controller ctl9 = new PRH_Iconic_Accounts_Controller();
			ctl9.PRH_Account_Region = 'PR EMEA';
			ctl9.PRH_Account_Market_Company = 'PR UK';
			//ctl9.PRH_High_Networth_Individuals = 'No';
			//ctl9.PRH_Suppress_and_archive = 'Yes';
			ctl9.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl9.updateUrlExcelExport();
			System.assertNotEquals(ctl9.url, '');
			db_query = ctl9.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs9 = Database.query(db_query);
			System.assertEquals(0, iconic_accs9.size());
			
			// Case 10
			PRH_Iconic_Accounts_Controller ctl10 = new PRH_Iconic_Accounts_Controller();
			ctl10.PRH_Owner_2 = 'PRH_testuser2';
			//ctl10.PRH_High_Networth_Individuals = 'Yes';
			//ctl10.PRH_Suppress_and_archive = 'No';
			ctl10.PRH_ICT_Account = 'Yes';
            ctl10.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl10.updateUrlExcelExport();
			db_query = ctl10.constructRequest('');
			System.assertNotEquals(ctl10.url, '');
			List<PRH_Luxury_Accounts__c> iconic_accs10 = ctl10.getPRH_accounts();
			System.assertEquals(10, iconic_accs10.size());
			
			// Case 11
			PRH_Iconic_Accounts_Controller ctl11 = new PRH_Iconic_Accounts_Controller();
			ctl11.PRH_Account_Name = 'Zoo-';
			ctl11.PRH_ICT_Account = 'No';
			ctl11.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl11.updateUrlExcelExport();
			db_query = ctl11.constructRequest('');
			System.assertNotEquals(ctl11.url, '');
			List<PRH_Luxury_Accounts__c> iconic_accs11 = ctl11.getPRH_accounts();
			System.assertEquals(10, iconic_accs11.size());
			
			// Case 12
			PRH_Iconic_Accounts_Controller ctl12 = new PRH_Iconic_Accounts_Controller();
			ctl12.PRH_Account_Market_Company = 'PR New Zealand';
			ctl12.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl12.updateUrlExcelExport();
			db_query = ctl12.constructRequest('');
			System.assertNotEquals(ctl12.url, '');
			//List<PRH_Luxury_Accounts__c> iconic_accs12 = ctl12.getPRH_accounts();
			//System.assertEquals(0, iconic_accs12.size());
			
			// Case 13
			PRH_Iconic_Accounts_Controller ctl13 = new PRH_Iconic_Accounts_Controller();
			ctl13.PRH_Account_Country = 'Hungary';
			ctl13.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl13.updateUrlExcelExport();
			db_query = ctl13.constructRequest('');
			System.assertNotEquals(ctl13.url, '');
			
			// Case 14
			PRH_Iconic_Accounts_Controller ctl14 = new PRH_Iconic_Accounts_Controller();
			ctl14.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl14.updateUrlExcelExport();
			db_query = ctl14.constructRequest('');
			System.assertNotEquals(ctl14.url, '');
			
			// Case 15
			PRH_Iconic_Accounts_Controller ctl15 = new PRH_Iconic_Accounts_Controller();
			ctl15.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
			db_query = ctl15.constructRequest('');
            ctl15.updateUrlExcelExport();
			System.assertNotEquals(ctl15.url, '');
			
			// Case 16
			PRH_Iconic_Accounts_Controller ctl16 = new PRH_Iconic_Accounts_Controller();
			//ctl16.PRH_Suppress_and_archive = 'Yes';
			ctl16.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl16.updateUrlExcelExport();
			db_query = ctl16.constructRequest('');
			System.assertNotEquals(ctl16.url, '');
			
			// Case 17
			PRH_Iconic_Accounts_Controller ctl17 = new PRH_Iconic_Accounts_Controller();
			ctl17.PRH_Account_Region = 'PR EMEA';
			ctl17.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
            ctl17.updateUrlExcelExport();
			db_query = ctl17.constructRequest('');
			System.assertNotEquals(ctl17.url, '');
            
            // Case 18
			PRH_Iconic_Accounts_Controller ctl18 = new PRH_Iconic_Accounts_Controller();
			ctl18.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL_ALL;
            ctl18.PRH_Account_Region = 'PR EMEA';
            db_query = ctl18.constructRequest('');
			
			// Case 21
			PRH_Iconic_Accounts_Controller ctl21 = new PRH_Iconic_Accounts_Controller();
			ctl21.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL_ALL;
            ctl21.PRH_Account_Market_Company = 'PR UK';
            db_query = ctl21.constructRequest('');
			
            // Case 22
			PRH_Iconic_Accounts_Controller ctl22 = new PRH_Iconic_Accounts_Controller();
			ctl22.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL_ALL;
            db_query = ctl22.constructRequest('');
			
			// Case 23
			PRH_Iconic_Accounts_Controller ctl23 = new PRH_Iconic_Accounts_Controller();
			ctl23.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL_ALL;
            ctl23.PRH_Account_Country = 'UK';
            db_query = ctl23.constructRequest('');
            
            // Case 24
			PRH_Iconic_Accounts_Controller ctl24 = new PRH_Iconic_Accounts_Controller();
			ctl24.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
			ctl24.PRH_Located_in_a_hotel = 'Yes';
            ctl24.updateUrlExcelExport();
			System.assertNotEquals(ctl24.url, '');
			db_query = ctl24.constructRequest('');

			// Case 25
			PRH_Iconic_Accounts_Controller ctl25 = new PRH_Iconic_Accounts_Controller();
			ctl25.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
			ctl25.PRH_Located_in_a_hotel = 'No';
            ctl25.updateUrlExcelExport();
			System.assertNotEquals(ctl25.url, '');
			db_query = ctl25.constructRequest('');

			// Case 26
			PRH_Iconic_Accounts_Controller ctl26 = new PRH_Iconic_Accounts_Controller();
			ctl26.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
			//ctl26.PRH_Full_Le_Cercle = 'No';
			ctl26.PRH_Le_Cercle_Brand_Presence = 'Yes';
			//ctl26.PRH_Suppress_and_archive = 'No';
            ctl26.updateUrlExcelExport();
			System.assertNotEquals(ctl26.url, '');
			db_query = ctl26.constructRequest('');

			// Case 27
			PRH_Iconic_Accounts_Controller ctl27 = new PRH_Iconic_Accounts_Controller();
			ctl27.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
			//ctl27.PRH_Full_Le_Cercle = 'Yes';
			ctl27.PRH_Le_Cercle_Brand_Presence = 'Yes';
			//ctl27.PRH_Suppress_and_archive = 'No';
            ctl27.updateUrlExcelExport();
			System.assertNotEquals(ctl27.url, '');
			db_query = ctl27.constructRequest('');

			// Case 28
			PRH_Iconic_Accounts_Controller ctl28 = new PRH_Iconic_Accounts_Controller();
			ctl28.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL;
			//ctl28.PRH_Full_Le_Cercle = 'Yes';
			ctl28.PRH_Collect_Not_Modified_Since = '3 months';
			//ctl28.PRH_Suppress_and_archive = 'No';
            ctl28.updateUrlExcelExport();
			System.assertNotEquals(ctl28.url, '');
			db_query = ctl28.constructRequest('');
		}   
    }
	
	@isTest static void Test_updateUrlExcelExportAll() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();				
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.EXPORT_EXCEL_ALL;
			String db_query;
            ctl1.updateUrlExcelExportAll();
			string url_param = '/apex/PRH_Iconic_Accounts_ReportExcel?' + 'export_type=' + EncodingUtil.urlEncode('all', 'UTF-8');
			System.assertEquals(ctl1.url, url_param);
			
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
    
    @isTest static void Test_constructRequest() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
				
        System.runAs(ic_myUser) {         
			
			Test.startTest();  
			// First request
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();
			//ctl1.PRH_High_Networth_Individuals = 'No';
			//ctl1.PRH_Suppress_and_archive = 'Yes';
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.ONLOAD;
			String db_query;
			db_query = ctl1.constructRequest('C');
			List<PRH_Luxury_Accounts__c> iconic_accs1 = Database.query(db_query);
			System.assertEquals(10, iconic_accs1.size());
						
			// Second request
			PRH_Iconic_Accounts_Controller ctl2 = new PRH_Iconic_Accounts_Controller();
			//ctl2.PRH_High_Networth_Individuals = 'No';
			//ctl2.PRH_Suppress_and_archive = 'No';
			ctl2.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
			ctl2.displayRecords();
			String db_query2;
			db_query2 = ctl2.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs2 = Database.query(db_query2);
			System.assertEquals(70, iconic_accs2.size());

			// Third request
			PRH_Iconic_Accounts_Controller ctl3 = new PRH_Iconic_Accounts_Controller();
			ctl3.PRH_Account_Market_Company = 'Pernod and Ricard';
			//ctl3.PRH_High_Networth_Individuals = 'No';
			//ctl3.PRH_Suppress_and_archive = 'No';
			ctl3.PRH_Account_Type = 'Restaurant,Traditional On Trade,High Energy Bar';
            ctl3.account_Types = new String[]{'Restaurant', 'Traditional On Trade','High Energy Bar'};
			ctl3.PRH_Account_Region = 'France';
			ctl3.PRH_Account_Country = 'France';
			ctl3.PRH_Account_City = 'Paris';
			ctl3.PRH_Owner = 'PRH_testuser1';
			ctl3.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl3.affichSearchResult();
			ctl3.affichSearchResultAlpha();
			String db_query3;
			db_query3 = ctl3.constructRequest('');
			List<PRH_Luxury_Accounts__c> iconic_accs3 = Database.query(db_query3);
			System.assertEquals(0, iconic_accs3.size());
			
			// Fourth request
			PRH_Iconic_Accounts_Controller ctl4 = new PRH_Iconic_Accounts_Controller();
			//ctl4.PRH_High_Networth_Individuals = 'No';
			//ctl4.PRH_Suppress_and_archive = 'Yes';
			ctl4.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
			String db_query4;
			db_query4 = ctl4.constructRequest('C');
			List<PRH_Luxury_Accounts__c> iconic_accs4 = Database.query(db_query4);
			System.assertEquals(10, iconic_accs4.size());
						
            Test.stopTest();
		}   
    }
    
    @isTest static void Test_Pagination() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.affichSearchResult();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
			
            List<PRH_Luxury_Accounts__c> iconic_accs_paginated = ctl1.PRH_accounts_paginated;
            
            if (ctl1.con != null){
                Boolean hn = ctl1.hasNext;
                Boolean hp = ctl1.hasPrevious;
                Integer pn = ctl1.pageNumber;
                ctl1.next();
                ctl1.previous();
                ctl1.first();
                ctl1.last();
                System.assertEquals(true, hn);
                System.assertEquals(false, hp);
                System.assertEquals(1, pn);
            }
            
            Test.stopTest();
		}   
    }
	
	@isTest static void Test_sortByAccountName() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.getSortDirection();
			//ctl1.sortByAccountName();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
	
	/*@isTest static void Test_sortByAccountRegion() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.sortByAccountRegion();
			ctl1.sortByAccountRegion();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
	
	@isTest static void Test_sortByAccountCountry() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.sortByAccountCountry();
			ctl1.sortByAccountCountry();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
	
	@isTest static void Test_sortByAccountCity() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.sortByAccountCity();
			ctl1.sortByAccountCity();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
	
	@isTest static void Test_sortByAccountMarketCompany() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.sortByAccountMarketCompany();
			ctl1.sortByAccountMarketCompany();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
	
	@isTest static void Test_sortByAccountOwner2() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.sortByAccountOwner2();
			ctl1.sortByAccountOwner2();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
	
	@isTest static void Test_sortByAccountOwner() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.sortByAccountOwner();
			ctl1.sortByAccountOwner();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
	
	@isTest static void Test_clearSearchCriteria() {
        PRH_Luxury_Accounts__c[] iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser6%prhtestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
						
            Test.startTest();                 
            				
			PRH_Iconic_Accounts_Controller ctl1 = new PRH_Iconic_Accounts_Controller();	
			ctl1.displayType = PRH_Iconic_Accounts_Controller.Action.SEARCH;
            ctl1.clearSearchCriteria();
			List<PRH_Luxury_Accounts__c> iconic_accs = ctl1.getPRH_accounts();
			System.assertEquals(70, iconic_accs.size());
            
            Test.stopTest();
		}   
    }
    */
	
}