@isTest
public class RIC_FusionNonSignAnnule_Test {
    private static testMethod void myTestMehod2() {
        id RIC_PER_DDO_RecordType=Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('PER - DDO').getRecordTypeId();
         
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
        proj.RecordTypeId=RIC_PER_DDO_RecordType;
        proj.RIC_Brand__c=marque.id;
        insert proj;
        
        Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
		insert mstone;
        user u=new user(id=UserInfo.getUserId());
     
        Milestone1_Task__c act = new Milestone1_Task__c(); //Create new Task for Milestone b
        act.Name = 'Test Task';
        act.Project_Milestone__c = mstone.Id;
        act.RIC_Type_Action__c = 'Avec Notification'; 
        act.Due_Date__c = Date.today().addMonths(3);
        act.Assigned_To__c=currUser.id;
        act.RIC_Status__c='Non significatif';
        insert act;
        
        Test.startTest();
        Database.executeBatch(new RIC_FusionNonSignAnnule());
        Test.stopTest();  
        currUser.BypassVR__c = false;
        update currUser;
    }
}