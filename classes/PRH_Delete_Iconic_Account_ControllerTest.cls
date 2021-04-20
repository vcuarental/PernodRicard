/*
* Created Date: July 16,2020
*
* Description: Test class for PRH_Delete_Iconic_Account_Controller class
*
*/
@isTest(SeeAllData = false) 
private class PRH_Delete_Iconic_Account_ControllerTest{

    @testSetup static void setUpUsers() {
        List<PRH_Luxury_Accounts__c> iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        DateTime dt = DateTime.now(); 
        String dateTimeStr = dt.format('YYMMDD_hhmmss'); 
        Profile adminp = [select id from profile where Name = 'System Administrator' limit 1];    
        System.debug('dateTimeStr : '+ dateTimeStr);
        
        // Creation of 1 user (iconic account's owners)
        Profile p1 = [SELECT Id FROM Profile WHERE Name='PRH_Iconic_Platform']; 
        User u1 = new User(Alias = 'user1', Email='PRH_testuser1'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser1'+dateTimeStr+'@prhtestorg.com');
        insert u1;

        Profile p2 = [SELECT Id FROM Profile WHERE Name='PRH_Iconic_Platform']; 
        User u2 = new User(Alias = 'user2', Email='PRH_testuser2'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser2'+dateTimeStr+'@prhtestorg.com');
        insert u2;
        
        PermissionSet ps = [Select Id From PermissionSet Where Name = 'PRH_Iconic_Platform_PR_Holding_Admin' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId = u2.Id;
        insert psa;
        
        User user1 = [SELECT Name, Id FROM User WHERE (UserName LIKE 'PRH_testuser1%') LIMIT 1];
        System.debug('==> user1.Id : '+ user1.Id);
                
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
        System.runAs(ic_myUser) {         
            // Creation of the Iconic Accounts
            for (Integer i=0; i < 70; i++) { 
                	 acc = new PRH_Luxury_Accounts__c(
                        Name = 'NoSuppressAccount-'+i,
                        PRH_High_Networth_Individuals__c = false,
                        PRH_Suppress_and_archive__c = false,
                        PRH_ICT_Account__c = false,
                        PRH_Located_in_a_hotel__c = false
                    );
                    iconicAccounts.add(acc); 

            }    
            // Creation of the Iconic Accounts
            for (Integer i=0; i < 70; i++) { 
                	 acc = new PRH_Luxury_Accounts__c(
                        Name = 'SuppressAccount-'+i,
                        PRH_High_Networth_Individuals__c = false,
                        PRH_Suppress_and_archive__c = true,
                        PRH_ICT_Account__c = false,
                        PRH_Located_in_a_hotel__c = false
                    );
                    iconicAccounts.add(acc); 

            }   
            insert iconicAccounts;
        }
    }
    
    @isTest static void loadAccounts(){
        PRH_Delete_Iconic_Account_Controller ctl;
        PRH_Luxury_Accounts__c[] accounts;

        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
        
        System.runAs(ic_myUser) {         
           
            Test.startTest(); 
            
			accounts  = [SELECT Name, PRH_Suppress_and_archive__c FROM PRH_Luxury_Accounts__c WHERE Name LIKE 'Account%'];
            PageReference pageRef = Page.PRH_Delete_Iconic_Account; 
            
            Test.setCurrentPage(pageRef);
            ctl = new PRH_Delete_Iconic_Account_Controller(new ApexPages.StandardSetController(accounts));
            ctl.selectedAccounts = accounts;
            
            //System.assertEquals(0, accounts.size());
			//System.debug(accounts.size());
            pageRef = ctl.loadAccount();
            Test.stopTest();
        }       
    }
    
    @isTest static void updateAccountsNoAccess(){
        PRH_Delete_Iconic_Account_Controller ctl;
        PRH_Luxury_Accounts__c[] accounts;

        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
        
        System.runAs(ic_myUser) {         
            Test.startTest();      
			accounts  = [SELECT Name, PRH_Suppress_and_archive__c FROM PRH_Luxury_Accounts__c WHERE Name LIKE 'Account%'];
            PageReference pageRef = Page.PRH_Delete_Iconic_Account; 
            
            Test.setCurrentPage(pageRef);
            ctl = new PRH_Delete_Iconic_Account_Controller(new ApexPages.StandardSetController(accounts));
            ctl.selectedAccounts = accounts;
            
            //System.assertEquals(0, accounts.size());
			//System.debug(accounts.size());
            pageRef = ctl.updateAccounts();
            Test.stopTest();
        }       
    }
    
    @isTest static void updateAccountsNoSuppress(){
        PRH_Delete_Iconic_Account_Controller ctl;
        PRH_Luxury_Accounts__c[] accounts;

        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser2%prhtestorg.com' LIMIT 1];
        
        System.runAs(ic_myUser) {         
            Test.startTest();         
			accounts  = [SELECT Name, PRH_Suppress_and_archive__c FROM PRH_Luxury_Accounts__c WHERE Name LIKE 'NoSuppressAccount%'];
            PageReference pageRef = Page.PRH_Delete_Iconic_Account; 
            
            Test.setCurrentPage(pageRef);
            ctl = new PRH_Delete_Iconic_Account_Controller(new ApexPages.StandardSetController(accounts));
            ctl.selectedAccounts = accounts;
            
            //System.assertEquals(0, accounts.size());
			//System.debug(accounts.size());
            pageRef = ctl.updateAccounts();
            Test.stopTest();
        }       
    }
    
    @isTest static void updateAccountsSuccess(){
        PRH_Delete_Iconic_Account_Controller ctl;
        PRH_Luxury_Accounts__c[] accounts;

        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser2%prhtestorg.com' LIMIT 1];
        
        System.runAs(ic_myUser) {              
            Test.startTest(); 
			accounts  = [SELECT Name, PRH_Suppress_and_archive__c FROM PRH_Luxury_Accounts__c WHERE Name LIKE 'SuppressAccount%'];
            PageReference pageRef = Page.PRH_Delete_Iconic_Account; 
            
            Test.setCurrentPage(pageRef);
            ctl = new PRH_Delete_Iconic_Account_Controller(new ApexPages.StandardSetController(accounts));
            ctl.selectedAccounts = accounts;
            
            //System.assertEquals(0, accounts.size());
			//System.debug(accounts.size());
            pageRef = ctl.updateAccounts();
            Test.stopTest();
        }       
    }
    
    @isTest static void getPrivilege(){
        PRH_Delete_Iconic_Account_Controller ctl;
        PRH_Luxury_Accounts__c[] accounts;

        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser1%prhtestorg.com' LIMIT 1];
        
        System.runAs(ic_myUser) {        
            Test.startTest();            
			accounts  = [SELECT Name, PRH_Suppress_and_archive__c FROM PRH_Luxury_Accounts__c WHERE Name LIKE 'SuppressAccount%'];
            PageReference pageRef = Page.PRH_Delete_Iconic_Account; 
            
            Test.setCurrentPage(pageRef);
            ctl = new PRH_Delete_Iconic_Account_Controller(new ApexPages.StandardSetController(accounts));
            ctl.selectedAccounts = accounts;
                       
            ctl.printMessage('no_privilege');
            Test.stopTest();
        }       
    }

}