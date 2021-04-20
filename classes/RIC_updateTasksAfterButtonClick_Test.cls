/*
Nazim Dabouz nazim.dabouz@bluewolfgroup.com Christophe Averseng christophe.averseng@bluewolfgroup.com

This is a test class for the trigger "RIC_updateTaskAfterButtonClick"
*/  

@isTest
private class RIC_updateTasksAfterButtonClick_Test{
    
    static testMethod void testApprovalSuccess() {
        
        RIC_Brand__c brand = new RIC_Brand__c(); // Create Brand to relate Project to
        brand.Name = 'Ricard';
        brand.RIC_Acheteurs_OPP__c = 'test@tes.com;test@ss.com';
        insert brand;
        
        Milestone1_Project__c a = new Milestone1_Project__c(); //Create new Project
        a.RIC_Task_Status__c = 'No'; 
        a.Name = 'Test Name';
        a.RIC_Brand__c = brand.Id;
        a.RecordTypeId = Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('OPP ou Kit OPP').getRecordTypeId(); //ID for Record Type = INT - OPP ou KIT OPP
		//a.RIC_Coordinateur__c = Userinfo.getUserId();
        a.Deadline__c = Date.today().addDays(50);
        insert a;
        
        Milestone1_Milestone__c b = new Milestone1_Milestone__c(); //Create new Milestone for Project a
        b.Name = 'Test Milestone';
        b.Project__c = a.Id;
        b.Deadline__c = Date.today().addDays(40);
        insert b;
        
        // Create user to assign the task to
        String profileId = [SELECT Id FROM Profile WHERE Name = 'RIC_Workflow Plann\'R' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='Test', Alias='tpbw', Email='test.plannR-98267@bluewolf.com', Username='test.plannR-98267@bluewolf.com', TimeZoneSidKey='Europe/Paris', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=profileId, LanguageLocaleKey='en_US', UserPermissionsMobileUser=false);
        User u2 = new User(FirstName='Test2', LastName='Test2', Alias='tpbw2', Email='test.plannR-9826778@bluewolf.com', Username='test.plannR-9826778@bluewolf.com', TimeZoneSidKey='Europe/Paris', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', ProfileId=profileId, LanguageLocaleKey='en_US', UserPermissionsMobileUser=false);
        insert new List<User> {u, u2};
        
        Milestone1_Task__c c = new Milestone1_Task__c(); //Create new Task for Milestone b
        c.Name = 'Test Task';
        c.Project_Milestone__c = b.Id;
        c.Assigned_To__c = u.Id;
        c.Due_Date__c = Date.today().addDays(-20);
        c.RIC_Type_Action__c = 'Avec Notification'; 
        
        Milestone1_Task__c c2 = new Milestone1_Task__c(); //Create new Task for Milestone b
        c2.Name = 'Test2 Task2';
        c2.Project_Milestone__c = b.Id;
        c2.Assigned_To__c = u.Id;
        c2.Due_Date__c = Date.today().addDays(-20);
        c2.RIC_Type_Action__c = 'Avec Notification';
        insert new List<Milestone1_Task__c>{c,c2};
            
        // Create Acteurs for the task
        RIC_Acteur__c acteur1 = new RIC_Acteur__c();
        acteur1.RIC_Acteur_User__c = u2.Id;
        acteur1.RIC_Action__c = c.Id;
        insert acteur1;
        
        List<Milestone1_Project__c> project = [Select Id, RIC_Task_Status__c, RIC_Go_Achats__c from Milestone1_Project__c where Milestone1_Project__c.id = :a.Id];
        List<Milestone1_Milestone__c> milestone = [Select Id from Milestone1_Milestone__c where Milestone1_Milestone__c.id = :b.Id];
        List<Milestone1_Task__c> task = [Select Id, RIC_Task_Sent__c from Milestone1_Task__c where Milestone1_Task__c.id = :c.Id];
        
        for(Milestone1_Project__c t: project){
            t.RIC_Coordinateur__c = UserInfo.getUserId();
            t.RIC_Status__c = 'Annulé';
            t.RIC_Task_Status__c = 'Sent';
        }
        
        update project;
        
        project[0].RIC_Status__c= 'Validé';
        project[0].RIC_Coordinateur__c= u.Id;
        project[0].RIC_Go_Achats__c = 'GO achats confirmé';
        update project;
        
        Milestone1_Task_Trigger_Utility.checkOWDPermissions(task);
        System.assertEquals(project.size(),1);
        System.assertEquals(milestone.size(),1);
        System.assertEquals(null, c.RIC_Task_Sent__c); //Trigger updates value to Sent and then a Workflow updates value to NULL. This checks it's Null
    }
}