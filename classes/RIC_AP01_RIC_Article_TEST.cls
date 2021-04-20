@isTest
private class RIC_AP01_RIC_Article_TEST {

    private static testMethod void myTestMethod() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        RIC_Article__c article = new RIC_Article__c();
        article.RIC_Project__c = p1.Id;
        article.RIC_Statut__c = 'A finaliser/';
        article.RIC_Description_2__c = 'Test';
        article.RIC_Tech_isLocked__c = true;
        article.RIC_Tech_LockingUser__c = UserInfo.getUserId();
        insert article;
        
        article.RIC_Tranches_T5_N__c = 0.0;
        update article;
        Test.stopTest();
    }
}