@isTest
private class RIC_AP01_RIC_Projet_TEST {
private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    private static testMethod void myTestMethod() {
        
       
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('test');
        p1.RIC_Status__c='En attente de validation';
        p1.RIC_Code_article__c='2';
        insert p1; 
        
      
         RIC_Article__c article = new RIC_Article__c();
        article.RIC_Project__c = p1.Id;
        article.RecordTypeId=Produit_Fini;
        article.RIC_Duplique__c=true;
        article.RIC_Code_Article__c='12';
        article.RIC_Statut__c = 'A finaliser/';
        article.RIC_Description_2__c = 'Test'; 
        article.RIC_Tech_isLocked__c = true;
        insert article; 
             Test.startTest();
            p1.RIC_Code_article__c='7';
        update p1;
          Test.stopTest();
    }
}