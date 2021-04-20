// Test class PRH_Iconic_Trigger_Handler
@isTest(SeeAllData = false) 
private class PRH_Iconic_Trigger_Handler_Test {
    @testSetup static void setUpData() {
        List<PRH_Luxury_Accounts__c> iconicAccounts = new List<PRH_Luxury_Accounts__c>();
        PRH_Luxury_Accounts__c acc;
        DateTime dt = DateTime.now(); 
        String dateTimeStr = dt.format('YYMMDD_hhmmss'); 
        List<PRH_Collect__c> listOfNewCollects = new List<PRH_Collect__c >();
        Profile adminp = [select id from profile where Name = 'System Administrator' limit 1];    
        System.debug('dateTimeStr : '+ dateTimeStr);
        
        // Creation of 3 users (iconic account's owners)
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
        //Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
        User u4 = new User(Alias = 'user4', Email='PRH_testuser4'+dateTimeStr+'@prhtestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser4', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = adminp.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='PRH_testuser4'+dateTimeStr+'@prhtestorg.com');
        insert u4;

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
            ib1.PRH_PIM_ID__c = 'PIM001';
            ib1.PRH_Active__c = True;
            ib1.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert ib1;
            
            PRH_Brand_Luxury_Brand__c ib2 = new PRH_Brand_Luxury_Brand__c();
            ib2.Name = 'PJ Belle Epoque and above';
            ib2.PRH_Competitor_Brand__c = false;
            ib2.PRH_Sequence__c = 'LCEB0002';
            ib2.PRH_PIM_ID__c = 'PIM002';
            ib2.PRH_Active__c = True;
            ib2.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert ib2;
            
            PRH_Brand_Luxury_Brand__c ib3 = new PRH_Brand_Luxury_Brand__c();
            ib3.Name = 'Dom Perignon';
            ib3.PRH_Competitor_Brand__c = true;
            ib3.PRH_Sequence__c = 'COMP0001';
            ib3.PRH_PIM_ID__c = 'PIMC001';
            ib3.PRH_Active__c = True;
            ib3.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
            insert ib3;
            
            // Creation of the Iconic Accounts
            for (Integer i = 1; i < 4; i++) { 
                if (i <= 2) {
                    acc = new PRH_Luxury_Accounts__c(
                    Name = 'Iconic-'+i,
                    PRH_High_Networth_Individuals__c = false,
                    PRH_Suppress_and_archive__c = false,
                    PRH_Account_Region__c = 'PR EMEA',
                    PRH_Independent__c = true
                    );
                } else {
                    acc = new PRH_Luxury_Accounts__c(
                        Name = 'Iconic-'+i,
                        PRH_High_Networth_Individuals__c = false,
                        PRH_Suppress_and_archive__c = false,
                        PRH_Account_Region__c = 'PR LATAM',
                        PRH_Independent__c = true
                    );
                }
                iconicAccounts.add(acc); 
            }   
            insert iconicAccounts;

            List <PRH_Iconic_Account_Trigger__c> triggerLst = new List<PRH_Iconic_Account_Trigger__c>();           
            PRH_Iconic_Account_Trigger__c tg5 = new PRH_Iconic_Account_Trigger__c();
            tg5.PRH_Account_Record_Type__c = 'ASI_HK_CRM_Outlet';
            tg5.PRH_Account_Object_API__c = 'Account';
            tg5.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
            triggerLst.add(tg5);

            PRH_Iconic_Account_Trigger__c tg3 = new PRH_Iconic_Account_Trigger__c();
            tg3.PRH_Account_Record_Type__c = 'On_Trade';
            tg3.PRH_Account_Object_API__c = 'Account';
            tg3.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
            triggerLst.add(tg3);

            PRH_Iconic_Account_Trigger__c tg2 = new PRH_Iconic_Account_Trigger__c();
            tg2.PRH_Account_Record_Type__c = 'On_Trade';
            tg2.PRH_Account_Object_API__c = 'Account';
            tg2.PRH_Iconic_Account_Field_API__c = 'PRH_Independent__c';
            triggerLst.add(tg2);  

            PRH_Iconic_Account_Trigger__c tg4 = new PRH_Iconic_Account_Trigger__c();
            tg4.PRH_Account_Record_Type__c = 'ASI_HK_CRM_Outlet';
            tg4.PRH_Account_Object_API__c = 'Account';
            tg4.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
            triggerLst.add(tg4);

            PRH_Iconic_Account_Trigger__c tg6 = new PRH_Iconic_Account_Trigger__c();
            tg6.PRH_Account_Record_Type__c = 'USA_Account';
            tg6.PRH_Account_Object_API__c = 'Account';
            tg6.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
            triggerLst.add(tg6);

            PRH_Iconic_Account_Trigger__c tg7 = new PRH_Iconic_Account_Trigger__c();
            tg7.PRH_Account_Record_Type__c = 'On_Trade';
            tg7.PRH_Account_Object_API__c = 'Account';
            tg7.PRH_Iconic_Account_Field_API__c = 'PRH_Account_Type__c';
            triggerLst.add(tg7);

            PRH_Iconic_Account_Trigger__c tg8 = new PRH_Iconic_Account_Trigger__c();
            tg8.PRH_Account_Record_Type__c = 'On_Trade';
            tg8.PRH_Account_Object_API__c = 'Account';
            tg8.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
            triggerLst.add(tg8);

            PRH_Iconic_Account_Trigger__c tg9 = new PRH_Iconic_Account_Trigger__c();
            tg9.PRH_Account_Record_Type__c = 'On_Trade';
            tg9.PRH_Account_Object_API__c = 'Account';
            tg9.PRH_Iconic_Account_Field_API__c = 'PRH_City__c';
            triggerLst.add(tg9);
            insert triggerLst; 

            ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
            Account acctASIHK = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
            insert acctASIHK;
       
            acctASIHK.ownerID = u4.id;
            update acctASIHK;
        }
    }

    @isTest static void Test_PRH_IconicAcc_LinkedWithASIHKAccount() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithASIHKAccount() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, ASI_HK_CRM_Status__c FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];    
                
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                //accountToUpdate.PRH_Name_of_Contact__c = 'ContactUserName';
                // Make the update call
                update accountToUpdate; 

                account.type = 'Prospect';
                account.ASI_HK_CRM_Status__c = 'Active';
                update account;

                Contact contact = new Contact();
                contact.AccountID = account.Id;
                contact.ASI_HK_CRM_Main_Contact__c = true;

                PRH_Iconic_Account_Trigger__c tg = new PRH_Iconic_Account_Trigger__c();
                tg.PRH_Account_Record_Type__c = 'ASI_HK_CRM_Outlet';
                tg.PRH_Account_Object_API__c = 'Account';
                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
                Boolean returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)account, tg);
                System.assertEquals(false, returnBooleanVal);
                account.ASI_HK_CRM_Status__c = 'Inactive';

                PRH_Iconic_Account_Trigger__c tg3 = new PRH_Iconic_Account_Trigger__c();
                tg3.PRH_Account_Record_Type__c = 'On_Trade';
                tg3.PRH_Account_Object_API__c = 'Account';
                tg3.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
                returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)account, tg3);
                System.assertEquals(false, returnBooleanVal);

                PRH_Iconic_Account_Trigger__c tg2 = new PRH_Iconic_Account_Trigger__c();
                tg2.PRH_Account_Record_Type__c = 'On_Trade';
                tg2.PRH_Account_Object_API__c = 'Account';
                tg2.PRH_Iconic_Account_Field_API__c = 'PRH_Independent__c';
                returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)account, tg2);
                System.assertEquals(true, returnBooleanVal);   

                PRH_Iconic_Account_Trigger__c tg4 = new PRH_Iconic_Account_Trigger__c();
                tg4.PRH_Account_Record_Type__c = 'ASI_HK_CRM_Outlet';
                tg4.PRH_Account_Object_API__c = 'Account';
                tg4.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
                returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)account, tg4);
                System.assertEquals(true, returnBooleanVal);    
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }       
            
    @isTest static void Test_PRH_IconicAcc_LinkedWithUSA_Account() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithUSA_Account() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                account.type = 'Prospect';
                account.BillingCity = 'Charlotte';
                account.BillingStreet = '301 North Tryon Street';
                account.BillingState = 'North Carolina';
                account.BillingPostalCode = '95870';
                account.BillingCountry = 'USA';
                update account;

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                PRH_Iconic_Account_Trigger__c tg = new PRH_Iconic_Account_Trigger__c();
                tg.PRH_Account_Record_Type__c = 'USA_Account';
                tg.PRH_Account_Object_API__c = 'Account';
                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg);
                System.assertEquals('301 North Tryon Street, Charlotte, North Carolina, 95870, USA', returnStringVal);

                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
                Boolean returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)account, tg);
                System.assertEquals(false, returnBooleanVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithBrazil_Account() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithBrazil_Account() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, Segmentation_Type_on_trade__c  FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                account.type = 'Prospect';
                account.Segmentation_Type_on_trade__c = 'Bar';
                update account;
                PRH_Iconic_Account_Trigger__c tg1 = new PRH_Iconic_Account_Trigger__c();
                tg1.PRH_Account_Record_Type__c = 'On_Trade';
                tg1.PRH_Account_Object_API__c = 'Account';
                tg1.PRH_Iconic_Account_Field_API__c = 'PRH_Account_Type__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg1);
                System.assertEquals('Low Energy Bar', returnStringVal);

                account.Segmentation_Type_on_trade__c = 'Bar';
                update account;
                PRH_Iconic_Account_Trigger__c tg2 = new PRH_Iconic_Account_Trigger__c();
                tg2.PRH_Account_Record_Type__c = 'On_Trade';
                tg2.PRH_Account_Object_API__c = 'Account';
                tg2.PRH_Iconic_Account_Field_API__c = 'PRH_Account_Type__c';
                returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg2);
                System.assertEquals('Low Energy Bar', returnStringVal);

                account.Segmentation_Type_on_trade__c = 'Bar Agitado';
                update account;
                PRH_Iconic_Account_Trigger__c tg3 = new PRH_Iconic_Account_Trigger__c();
                tg3.PRH_Account_Record_Type__c = 'On_Trade';
                tg3.PRH_Account_Object_API__c = 'Account';
                tg3.PRH_Iconic_Account_Field_API__c = 'PRH_Account_Type__c';
                returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg3);
                System.assertEquals('High Energy Bar', returnStringVal);

                account.Segmentation_Type_on_trade__c = 'Casa Noturna';
                update account;
                PRH_Iconic_Account_Trigger__c tg4 = new PRH_Iconic_Account_Trigger__c();
                tg4.PRH_Account_Record_Type__c = 'On_Trade';
                tg4.PRH_Account_Object_API__c = 'Account';
                tg4.PRH_Iconic_Account_Field_API__c = 'PRH_Account_Type__c';
                returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg4);
                System.assertEquals('Night Club', returnStringVal);

                account.Segmentation_Type_on_trade__c = 'Restaurante';
                update account;
                PRH_Iconic_Account_Trigger__c tg5 = new PRH_Iconic_Account_Trigger__c();
                tg5.PRH_Account_Record_Type__c = 'On_Trade';
                tg5.PRH_Account_Object_API__c = 'Account';
                tg5.PRH_Iconic_Account_Field_API__c = 'PRH_Account_Type__c';
                returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg5);
                System.assertEquals('Restaurant', returnStringVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithBrazil_Account2() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithBrazil_Account2() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, Revenue_Address__c, Revenue_Number__c, Revenue_Complement__c, Revenue_Neighbourhood__c, Revenue_UF__c FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                account.type = 'Prospect';
                account.Revenue_Address__c = null;
                update account;
                PRH_Iconic_Account_Trigger__c tg1 = new PRH_Iconic_Account_Trigger__c();
                tg1.PRH_Account_Record_Type__c = 'On_Trade';
                tg1.PRH_Account_Object_API__c = 'Account';
                tg1.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg1);
                System.assertEquals(null, returnStringVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithBrazil_Account3() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithBrazil_Account3() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, Revenue_Address__c, Revenue_Number__c, Revenue_Complement__c, Revenue_Neighbourhood__c, Revenue_UF__c FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                account.type = 'Prospect';
                account.Revenue_Number__c = null;
                update account;
                PRH_Iconic_Account_Trigger__c tg1 = new PRH_Iconic_Account_Trigger__c();
                tg1.PRH_Account_Record_Type__c = 'On_Trade';
                tg1.PRH_Account_Object_API__c = 'Account';
                tg1.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg1);
                System.assertEquals(null, returnStringVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithBrazil_Account4() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithBrazil_Account4() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, Revenue_Address__c, Revenue_Number__c, Revenue_Complement__c, Revenue_Neighbourhood__c, Revenue_UF__c FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                account.type = 'Prospect';
                account.Revenue_Complement__c = null;
                update account;
                PRH_Iconic_Account_Trigger__c tg1 = new PRH_Iconic_Account_Trigger__c();
                tg1.PRH_Account_Record_Type__c = 'On_Trade';
                tg1.PRH_Account_Object_API__c = 'Account';
                tg1.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg1);
                System.assertEquals(null, returnStringVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithBrazil_Account5() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithBrazil_Account5() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, Revenue_Address__c, Revenue_Number__c, Revenue_Complement__c, Revenue_Neighbourhood__c, Revenue_UF__c FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                //accountToUpdate.PRH_Name_of_Contact__c = 'ContactUserName';
                // Make the update call
                update accountToUpdate; 

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                account.type = 'Prospect';
                account.Revenue_Neighbourhood__c = null;
                update account;
                PRH_Iconic_Account_Trigger__c tg1 = new PRH_Iconic_Account_Trigger__c();
                tg1.PRH_Account_Record_Type__c = 'On_Trade';
                tg1.PRH_Account_Object_API__c = 'Account';
                tg1.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg1);
                System.assertEquals(null, returnStringVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithBrazil_Account6() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithBrazil_Account6() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, Revenue_Address__c, Revenue_Number__c, Revenue_Complement__c, Revenue_Neighbourhood__c, Revenue_UF__c FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                account.type = 'Prospect';
                account.Revenue_UF__c = '21';
                update account;
                PRH_Iconic_Account_Trigger__c tg1 = new PRH_Iconic_Account_Trigger__c();
                tg1.PRH_Account_Record_Type__c = 'On_Trade';
                tg1.PRH_Account_Object_API__c = 'Account';
                tg1.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg1);
                System.assertEquals('null21', returnStringVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithBrazil_Account7() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithBrazil_Account7() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id, Revenue_Address__c, Revenue_Number__c, Revenue_Complement__c, Revenue_Neighbourhood__c, Revenue_City__c, Revenue_UF__c FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                account.type = 'Prospect';
                update account;
                PRH_Iconic_Account_Trigger__c tg1 = new PRH_Iconic_Account_Trigger__c();
                tg1.PRH_Account_Record_Type__c = 'On_Trade';
                tg1.PRH_Account_Object_API__c = 'Account';
                tg1.PRH_Iconic_Account_Field_API__c = 'PRH_City__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg1);
                System.assertEquals(null, returnStringVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }

    @isTest static void Test_PRH_IconicAcc_LinkedWithEUR_CRM_Account() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser1 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithEUR_CRM_Account() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                ID rtIDEu = Global_RecordTypeCache.getRtID('EUR_CRM_Account__c'+'EUR_GB_FS_Indirect');
                ID rtIDEu2 = Global_RecordTypeCache.getRtID('EUR_CRM_Account__c'+'EUR_EE_DIR_ON_Trade');  

                List<EUR_CRM_Account__c> toInsert = new List<EUR_CRM_Account__c>();
                EUR_CRM_Account__c testEUAcc1 = new EUR_CRM_Account__c(Name = 'accountName1', recordTypeID = rtIDEu,EUR_CRM_Force_Iconic_Account__c = true);       
                toInsert.add(testEUAcc1);
                EUR_CRM_Account__c accEUR = new EUR_CRM_Account__c(EUR_CRM_Postal_Code__c = '12345', Name = 'accountName2', EUR_CRM_Status__c = 'Active', recordTypeID = rtIDEu2, EUR_CRM_Force_Iconic_Account__c = true);       
                //toInsert.add(accEUR); //22-02-2019
                insert toInsert;

                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                EUR_CRM_Account__c account =  
                    [SELECT Name, Id FROM EUR_CRM_Account__c  LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser1.Id;
                accountToUpdate.PRH_Existing_EU_Account__c = account.Id;
                //accountToUpdate.PRH_Name_of_Contact__c = 'ContactUserName';
                // Make the update call
                update accountToUpdate; 

                PRH_Iconic_Account_Trigger__c tg = new PRH_Iconic_Account_Trigger__c();
                tg.PRH_Account_Record_Type__c = 'EUR_GB_FS_Indirect';
                tg.PRH_Account_Object_API__c = 'EUR_CRM_Account__c';
                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Independent__c';
                Boolean returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)accEUR, tg);
                System.assertEquals(false, returnBooleanVal);       //22-02-2019

                PRH_Iconic_Account_Trigger__c tg2 = new PRH_Iconic_Account_Trigger__c();
                tg2.PRH_Account_Record_Type__c = 'On_Trade';
                tg2.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c'; 
                tg2.PRH_Account_Object_API__c = 'EUR_CRM_Account__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)accEUR, tg2);
                System.assertEquals(null, returnStringVal);
                returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)accEUR, tg2);
                System.assertEquals(false, returnBooleanVal);
                
                // Test of class PRH_Account_To_Luxury_Account
                account.EUR_CRM_Force_Iconic_Account__c = false;
                update account;
                
                Id rtId = [select id from recordtype where developername = 'EUR_GB_FS_Indirect' and sobjecttype = 'eur_crm_account__c' limit 1].id;
                EUR_CRM_Group_Outlet_Type__c goutletType = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_Name__c='Restaurant');
                insert goutletType;
                EUR_CRM_Outlet_Type__c outletType = new EUR_CRM_Outlet_Type__c(EUR_CRM_Name__c='Restaurant', EUR_CRM_Group_Outlet_Type__c=goutletType.Id);
                insert outletType;
                EUR_CRM_Image_Level__c imgLevel = new EUR_CRM_Image_Level__c(EUR_CRM_Name__c='Leading');
                insert imgLevel;
                EUR_CRM_Volume_Potential__c volPotential = new EUR_CRM_Volume_Potential__c(EUR_CRM_Name__c='High');
                insert volPotential;
                EUR_CRM_Visit_Frequency__c visitFreq = new EUR_CRM_Visit_Frequency__c(name='once a week');
                insert visitFreq;
                EUR_CRM_Visit_Frequency_Criteria__c visitCriteria = new EUR_CRM_Visit_Frequency_Criteria__c(EUR_CRM_Visit_Frequency__c=visitFreq.Id, 
                    EUR_CRM_Group_Outlet_Type__c=goutletType.Id, EUR_CRM_Outlet_Type__c=outletType.Id, EUR_CRM_Image_Level__c=imgLevel.Id, EUR_CRM_Volume_Potential__c=volPotential.id);
                insert visitCriteria;
                
                EUR_CRM_Account__c acct = new EUR_CRM_Account__c(Name='GB test on trade account');
                acct.EUR_CRM_Group_Outlet_Type__c = goutletType.Id;
                acct.EUR_CRM_Outlet_Type__c = outletType.Id;
                acct.EUR_CRM_Image_Level__c = imgLevel.id;
                acct.EUR_CRM_Volume_Potential__c = volPotential.Id;
                acct.recordtypeid = rtId;
                insert acct;
                
                acct = [Select Id, EUR_CRM_Visit_Frequency__c From EUR_CRM_Account__c Where Id=: acct.Id];
                //system.assertEquals(acct.EUR_CRM_Visit_Frequency__c, visitFreq.Id);
                
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithUSA_Account2() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithASIHKAccount() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                account.type = 'Prospect';
                account.BillingCity = 'Charlotte';
                //account.BillingStreet = '301 North Tryon Street';
                account.BillingState = 'North Carolina';
                account.BillingPostalCode = '95870';
                account.BillingCountry = 'USA';
                update account;

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                PRH_Iconic_Account_Trigger__c tg = new PRH_Iconic_Account_Trigger__c();
                tg.PRH_Account_Record_Type__c = 'USA_Account';
                tg.PRH_Account_Object_API__c = 'Account';
                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg);
                System.assertEquals('Charlotte, North Carolina, 95870, USA', returnStringVal);

                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
                Boolean returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)account, tg);
                System.assertEquals(false, returnBooleanVal);
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }   

    @isTest static void Test_PRH_IconicAcc_LinkedWithUSA_Account3() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithASIHKAccount() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {         
                // Update account 
                PRH_Luxury_Accounts__c accountToUpdate =  
                    [SELECT Name, Id FROM PRH_Luxury_Accounts__c WHERE (Name LIKE 'Iconic-3%') LIMIT 1]; 
                Account account =  
                    [SELECT Name, Id FROM Account WHERE ownerID =: ic_myUser4.Id LIMIT 1];     
                // Update the owner and owner2
                accountToUpdate.OwnerId = ic_myUser.Id;
                accountToUpdate.PRH_Owner_2__c = ic_myUser4.Id;
                accountToUpdate.PRH_Existing_Account__c = account.Id;
                // Make the update call
                update accountToUpdate; 

                account.type = 'Prospect';
                account.BillingState = 'North Carolina';
                account.BillingPostalCode = '95870';
                account.BillingCountry = 'USA';
                update account;

                Contact contact = new Contact();
                contact.AccountID = account.Id;

                PRH_Iconic_Account_Trigger__c tg = new PRH_Iconic_Account_Trigger__c();
                tg.PRH_Account_Record_Type__c = 'USA_Account';
                tg.PRH_Account_Object_API__c = 'Account';
                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Detailed_address__c';
                String returnStringVal = PRH_Iconic_Trigger_Handler.stringCustomLogic((SObject)account, tg);
                System.assertEquals('nullNorth Carolina, 95870, USA', returnStringVal);

                tg.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
                Boolean returnBooleanVal = PRH_Iconic_Trigger_Handler.booleanCustomLogic((SObject)account, tg);
                System.assertEquals(false, returnBooleanVal);
                
                // Call of trigger PRH_Account_To_Luxury_Account BEFORE_DELETE
                delete account;
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }

    @isTest static void Test_PRH_IconicAcc_LinkedWithUSA_Account4() {
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser3%prhtestorg.com' LIMIT 1];
        User ic_myUser4 = [SELECT Id FROM User WHERE Email LIKE 'PRH_testuser4%prhtestorg.com' LIMIT 1];
        System.debug('==> Test_PRH_IconicAcc_LinkedWithASIHKAccount() ic_myUser : '+ ic_myUser);
        
        System.runAs(ic_myUser) {           
            System.Test.startTest(); 

            try {
                ID rtID = Global_RecordTypeCache.getRtID('Account'+'On_Trade');         
                Account acc = new Account();
                acc.RecordTypeID = rtID;
                acc.Name = 'TestAccount';
                acc.PRH_Iconic_Account__c = true;
                insert acc;

                ApexPages.StandardController sc = new ApexPages.standardController(acc);
                PageReference pageRef = new PageReference('/apex/PRH_Acc_Luxury_Account?id=' + acc.Id);
                Test.setCurrentPageReference(pageRef);
                PRH_Acc_Luxury_Account_Controller accCtrl = new PRH_Acc_Luxury_Account_Controller(sc);
                accCtrl.editAll();
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
            System.Test.stopTest(); 
        }
    }               
}