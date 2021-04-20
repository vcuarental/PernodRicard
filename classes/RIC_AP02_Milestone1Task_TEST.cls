@isTest
private class RIC_AP02_Milestone1Task_TEST {

    private static testMethod void myTestMethod() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('SampleProject');
        p1.RIC_Status__c = 'En création';
        insert p1;
        
        Milestone1_Milestone__c phase1 = Milestone1_Test_Utility.sampleMilestone(p1.Id,null,'SamplePhase');
        insert phase1 ;
        
        Milestone1_Task__c action = new Milestone1_Task__c();
        action.Project_Milestone__c = phase1.Id;
        action.RIC_Status__c = 'En cours';
        insert action;
        
        p1.RIC_Status__c = 'Clôturé';
        update p1;
        Test.stopTest();
    }
}