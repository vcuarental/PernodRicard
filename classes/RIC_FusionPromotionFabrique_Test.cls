@isTest
public class RIC_FusionPromotionFabrique_Test {
    private static testMethod void myTestMehod1() {
        id RIC_PromotionBrandCompanyAvecReprise_RecordType=Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('RIC - Promotion d\'une marque BC avec reprise').getRecordTypeId(); 
         User currUser = [select id,BypassVR__c 
                         from user
                         where id=:UserInfo.getUserId()
                         limit 1];
        currUser.BypassVR__c = true;         
        update currUser;
        RIC_Brand__c marque= new RIC_Brand__c();
        marque.RIC_Code_Marque__c='786';
        marque.RIC_Prefixe__c='pro';
        marque.name='test';
        insert marque; 
        
        Milestone1_Project__c proj = new Milestone1_Project__c();
        proj.Name='TestNew';
        proj.RecordTypeId=RIC_PromotionBrandCompanyAvecReprise_RecordType;
        proj.RIC_Brand__c=marque.id;
        insert proj;
        
        
        Test.startTest();
        Database.executeBatch(new RIC_FusionPromotionFabrique());
        Test.stopTest();  
        currUser.BypassVR__c = false;
        update currUser;
    }
}