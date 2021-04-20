@isTest
private class RIC_AP02_RIC_Article_TEST {
    private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    private static testMethod void myTestMethod() {
        user u=new user(id=UserInfo.getUserId());
        u.BypassVR__c=true;
        update u;
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('test');
        insert p1;
        
        RIC_Article__c article = new RIC_Article__c();
        article.RIC_Project__c = p1.Id;
        article.RecordTypeId=Produit_Fini;
        article.RIC_Duplique__c=true;
        article.RIC_Code_Article__c='12';
        article.RIC_Statut__c = 'A finaliser/';
        article.RIC_Description_2__c = 'Test'; 
        article.RIC_Tech_isLocked__c = true;
        
        article.RIC_Tech_LockingUser__c = UserInfo.getUserId();
        insert article;
        article.RIC_Code_Article__c='1';
        update article;
        RIC_Article__c article1 = new RIC_Article__c();
        article1.RIC_Project__c = p1.Id;
        article1.RecordTypeId=Produit_Fini;
        article1.RIC_Statut__c = 'A finaliser/';
        article1.RIC_Description_2__c = 'Test'; 
        article1.RIC_Tech_isLocked__c = true;
        article1.RIC_Tech_LockingUser__c = UserInfo.getUserId();
        Database.insert(article1, false) ; 
        
        article1.RIC_Duplique__c=true;
        Database.update(article1, false) ; 
        Test.stopTest();
    }
}