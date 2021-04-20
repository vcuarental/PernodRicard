@isTest
private class RIC_Article_Edit_Controller_TEST {
    
    private static testMethod void myTestMehod1() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        RIC_Article__c article = new RIC_Article__c();
        article.RIC_Project__c = p1.Id;
        article.RIC_Statut__c = 'A finaliser';
        article.RIC_Description_2__c = 'Test';
        article.RIC_Tech_isLocked__c = true;
        article.RIC_Tech_LockDateTIme__c = DateTime.now();
        article.RIC_Tech_LockingUser__c = UserInfo.getUserId();
        insert article;
        
        ApexPages.StandardController std = new ApexPages.StandardController(article);
        RIC_Article_Edit_Controller controller = new RIC_Article_Edit_Controller(std);
        controller.verifyEditPermission();
        controller.unlockRecordOnLoad();
        Test.stopTest();
    }
    
    private static testMethod void myTestMehod2() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        RIC_Article__c article = new RIC_Article__c();
        article.RIC_Project__c = p1.Id;
        article.RIC_Statut__c = 'A finaliser';
        article.RIC_Description_2__c = 'Test';
        article.RIC_Tech_LockDateTIme__c = DateTime.now();
        article.RIC_Tech_LockingUser__c = UserInfo.getUserId();
        insert article;
        
        ApexPages.StandardController std = new ApexPages.StandardController(article);
        RIC_Article_Edit_Controller controller = new RIC_Article_Edit_Controller(std);
        controller.verifyEditPermission();
        Test.stopTest();
    }
    
    private static testMethod void myTestMehod3() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        RIC_Article__c article = new RIC_Article__c();
        article.RIC_Project__c = p1.Id;
        article.RIC_Statut__c = 'A finaliser';
        article.RIC_Description_2__c = 'Test';
        article.RIC_Tech_isLocked__c = true;
        article.RIC_Tech_LockDateTIme__c = DateTime.now().addMinutes(-2);
        article.RIC_Tech_LockingUser__c = UserInfo.getUserId();
        insert article;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='GDT EMPTY PROFILE SALESFORCE']; 
        User u = new User(Alias = 'stadandt', Email='standarduserasdre@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testiddng', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserasdre@testorg.com');
        
        System.runAs(u) {
            ApexPages.StandardController std = new ApexPages.StandardController(article);
            RIC_Article_Edit_Controller controller = new RIC_Article_Edit_Controller(std);
            controller.verifyEditPermission();
            
            article.RIC_Tech_isLocked__c = true;
            article.RIC_Tech_LockDateTIme__c = DateTime.now();
            update article;
            ApexPages.StandardController std2 = new ApexPages.StandardController(article);
            RIC_Article_Edit_Controller controller2 = new RIC_Article_Edit_Controller(std2);
            controller2.unlockRecordOnLoad();
        }
        
        Test.stopTest();
    }
}