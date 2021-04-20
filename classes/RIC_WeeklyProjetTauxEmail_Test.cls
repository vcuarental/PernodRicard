/*
Description: Classe de test pour RIC_WeeklyProjetTauxEmail
Author: Joyce Saidy
Date: 06/05/2019
version 1.0 
*/
@isTest
public class RIC_WeeklyProjetTauxEmail_Test {
    static testMethod void testRIC_WeeklyProjetTauxEmail(){ 
        
        User currUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'RIC_Workflow Plann\'R'].Id,
            LastName = 'last',
            Email = 'test@amamama.com',
            Username = 'test@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US' ,
            RIC_SendEmail__c=true
        );
        insert currUser;
        
        system.runAs(currUser)
        {
        //Project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('EmailTest');
        proj.RIC_Status__c ='En cours';
        proj.RIC_Coordinateur__c = currUser.id;
        
        insert proj; 
        
        //Millestone
        Milestone1_Milestone__c mil = Milestone1_Test_Utility.sampleMilestone(proj);
        insert mil;
        
        Milestone1_Task__c task = Milestone1_Test_Utility.sampleTask(mil);
        Task.RIC_Status__c = 'Réalisé';
        task.Due_Date__c = Date.newInstance(2019, 6, 10);
        insert task;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(mil);
        Task2.RIC_Status__c = 'En cours';
        task2.Due_Date__c = Date.newInstance(2019, 6, 10);
        insert task2;
        
        }
        
        test.startTest();
        Database.executeBatch(new RIC_WeeklyProjetTauxEmail());
        Test.stopTest();  
    }
}