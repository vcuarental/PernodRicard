@isTest
private class RIC_DiffuserAction_Controller_TEST {
    
    static testMethod void myTestMethod1() {
        
        Test.startTest();
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'ricTst', Email='standarduserRricard@testorgRicard.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserRricard@testorgRicard.com');
        System.runAs(u) {
            Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
            insert p1;
            
            Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
            m2.Deadline__c = Date.today()-1;
            insert m2;   
            
            Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m2.Id);
            insert t1;
            
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'RIC_Action_Diffusee_Notif';
            validEmailTemplate.DeveloperName = 'RIC_Action_Diffusee_Notif';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
            
            ApexPages.StandardController std = new ApexPages.StandardController(t1);
            RIC_DiffuserAction_Controller controller = new RIC_DiffuserAction_Controller(std);
            controller.diffuserAction();
            controller.annuler();
        }
        
        Test.stopTest();
    }
    
    static testMethod void myTestMethod2() {
        
        Test.startTest();
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'ricTst', Email='standarduserRricard@testorgRicard.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserRricard@testorgRicard.com');
        System.runAs(u) {
            Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
            P1.RIC_Coordinateur__c = UserInfo.getUserId();
            p1.RIC_Status__c = 'En cours';
            insert p1;
            
            Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
            m2.Deadline__c = Date.today()-1;
            insert m2;   
            
            Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m2.Id);
            insert t1;
            
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'RIC_Action_Diffusee_Notif';
            validEmailTemplate.DeveloperName = 'RIC_Action_Diffusee_Notif';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
            
            ApexPages.StandardController std = new ApexPages.StandardController(t1);
            RIC_DiffuserAction_Controller controller = new RIC_DiffuserAction_Controller(std);
            controller.diffuserAction();
        }
        Test.stopTest();
    }
}