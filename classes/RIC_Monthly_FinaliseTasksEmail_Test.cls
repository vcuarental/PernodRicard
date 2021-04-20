@isTest
public class RIC_Monthly_FinaliseTasksEmail_Test {
    static testMethod void TestRIC_Monthly_FinaliseTasksEmail(){ 
        //Project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('EmailTest');
        insert proj; 
        //Millestone
        Milestone1_Milestone__c mil = Milestone1_Test_Utility.sampleMilestone(proj);
        insert mil;
        Milestone1_Task__c task = Milestone1_Test_Utility.sampleTask(mil);
        task.RIC_Status__c= Label.RIC_Task_Finalise;
        insert task;
        test.startTest();
        Database.executeBatch(new RIC_Monthly_FinaliseTasksEmail());
        Test.stopTest();  
    }
}