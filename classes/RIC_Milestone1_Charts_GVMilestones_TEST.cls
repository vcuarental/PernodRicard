@isTest
private class RIC_Milestone1_Charts_GVMilestones_TEST {
    
    private static testMethod void myTestMethod() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        Milestone1_Milestone__c m1 = Milestone1_Test_Utility.sampleMilestone(p1);
        insert m1;
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m1.Id);
        t1.Complete__c = true;
        t1.RIC_Type_Action__c = 'Avec Notification';
        insert t1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        RIC_Milestone1_Charts_GVMilestones testAccPlan = new RIC_Milestone1_Charts_GVMilestones(sc);
        Test.stopTest();
    }
    
    private static testMethod void myTestMethod2() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        Milestone1_Milestone__c m1 = Milestone1_Test_Utility.sampleMilestone(p1);
        insert m1;
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m1.Id);
        t1.RIC_Type_Action__c = 'Avec Notification';
        t1.Due_Date__c = Date.today().addDays(-2);
        insert t1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(m1);
        RIC_Milestone1_Charts_GVMilestones testAccPlan = new RIC_Milestone1_Charts_GVMilestones(sc);
        Test.stopTest();
    }
}