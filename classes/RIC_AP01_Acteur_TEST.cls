@isTest
private class RIC_AP01_Acteur_TEST {
    
    private static testMethod void myTestMethod() {
        
        Test.startTest() ;
        Milestone1_Task__c ctask;
        
        // Create a User
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'testRicardUser1@testRicardUser1.com',
            Username = 'testRicardUser1@testRicardUser1.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        System.runAs(u) { //Run as the created user in order to avoid the MIXED_DML_, error
            // Create a poject
            Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Test Project');
            insert proj;
            
            // Create a milestone
            Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
            insert mstone;
            
            // Create custom setting for the chatter part code coverage (Milestone1_Task_Trigger_Utility)
            Milestone1_Settings__c customSetting = new Milestone1_Settings__c();
            customSetting.Auto_Follow_Task__c = true;
            customSetting.Auto_Follow_Complete_Task__c = true;
            customSetting.Auto_Unfollow_Reassignment__c = true;
            insert customSetting;
            
            //Create task and assign it to user 1
            Milestone1_Task__c ctask2 = Milestone1_Test_Utility.sampleTask(mstone.Id);
            ctask2.Due_Date__c = null;
            ctask2.Start_Date__c = null;
            ctask2.Assigned_To__c = u.Id;
            ctask2.RIC_Type_Action__c = 'Avec Notification';
            insert ctask2;
            
            // Ceate another task and assign it to user 1
            ctask = Milestone1_Test_Utility.sampleTask(mstone.Id);
            ctask.Predecessor_Task__c = ctask2.Id;
            ctask.Assigned_To__c = u.Id;
            ctask.RIC_Type_Action__c = 'Avec Notification';
            insert ctask;
            
            try{
                // Create Acteurs for the task
                RIC_Acteur__c acteur1 = new RIC_Acteur__c();
                acteur1.RIC_Acteur_User__c = u.Id;
                acteur1.RIC_Action__c = ctask.Id;
                
                RIC_Acteur__c acteur2 = new RIC_Acteur__c();
                acteur2.RIC_Acteur_User__c = u.Id;
                acteur2.RIC_Action__c = ctask.Id;
                insert new List<RIC_Acteur__c> {acteur1, acteur2};
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(Label.RIC_Error_UserAlreadyAssigned));
            }
        }
        
        //Create another user in preparation for the assigned field to change
        User u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'testRicardUser2@testRicardUser2.com',
            Username = 'testRicardUser2@testRicardUser2.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u2;
        
        
        //Test Milestone1_Task_Trigger_Utility.checkEditPermissionOnTask
        System.runAs(u2) {
            
            try {
                //EDIT Task: Test the permission on status change for the user
                ctask.RIC_Status__c = 'En cours';
                update ctask;  
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(Label.RIC_Error_UserCantEditTask));
            }
            
            try {
                // Create an Acteur for the User 2
                RIC_Acteur__c acteur3 = new RIC_Acteur__c();
                acteur3.RIC_Acteur_User__c = u2.Id;
                acteur3.RIC_Action__c = ctask.Id;
                insert acteur3;
                
                //EDIT Task: change the assigned to User of the task to test the Already assigned error
                ctask.Assigned_To__c = u2.Id;
                update ctask;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(Label.RIC_Error_UserAlreadyAssigned));
            }
        }
        
        //Test: Milestone1_Task_Trigger_Utility.checkOWDPermissions
        Milestone1_Task_Trigger_Utility.checkOWDPermissions(new List<Milestone1_Task__c> {ctask});
        
        Test.stopTest();
    }
    
    private static testMethod void myTestMethod2() {
        Test.startTest();
        // Create a poject
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Test Project');
        insert proj;
        
        // Create a milestone
        Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
        insert mstone;
        
        //Create task and assign it to user 1
        Milestone1_Task__c ctask2 = Milestone1_Test_Utility.sampleTask(mstone.Id);
        ctask2.Due_Date__c = null;
        ctask2.Start_Date__c = null;
        ctask2.Assigned_To__c = UserInfo.getUserId();
        insert ctask2;
        
        // Create a User
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'testRicardUser1@testRicardUser1.com',
            Username = 'testRicardUser1@testRicardUser1.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        // Create an Acteur for the User 2
        RIC_Acteur__c acteur3 = new RIC_Acteur__c();
        acteur3.RIC_Acteur_User__c = u.Id;
        acteur3.RIC_Action__c = ctask2.Id;
        insert acteur3;
        
        delete acteur3;
        
        Test.stopTest();
    }
}