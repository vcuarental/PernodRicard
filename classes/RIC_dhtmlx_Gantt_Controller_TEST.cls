@isTest
private class RIC_dhtmlx_Gantt_Controller_TEST {
    
    static testMethod void TestProjectJson() {
        
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        Milestone1_Milestone__c m1 = Milestone1_Test_Utility.sampleMilestone(p1);
        insert m1;
        
        //RIC_dhtmlx_Gantt_Controller cls = new RIC_dhtmlx_Gantt_Controller();
        RIC_dhtmlx_Gantt_Controller.mytarget = p1.id;
        
        String ret = RIC_dhtmlx_Gantt_Controller.projectGanttJson();
        
        String testDateString = 'new Date(' +m1.Kickoff__c.year() +',' + (m1.Kickoff__c.month()-1) +',' + m1.Kickoff__c.day() +')';
        
        m1.Complete__c = true;
        update m1;
        
        Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;    
        
        Milestone1_Milestone__c m3 = Milestone1_Test_Utility.sampleMilestone(p1);
        m3.Kickoff__c = Date.today()+1;
        insert m3;            
        
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m2.Id);
        t1.RIC_Type_Action__c = 'Avec Notification';
        insert t1;
        
        ret = RIC_dhtmlx_Gantt_Controller.projectGanttJson();
        String tasks = m2.id + '>Tue Feb 28 2017 00:00:00 GMT+0200 (Middle East Standard Time)>Sat Mar 18 2017 00:00:00 GMT+0200 (Middle East Standard Time)>' + m2.Name + '>' + Userinfo.getUserId() + ';';
        RIC_dhtmlx_Gantt_Controller.saveAllTasksToSalesforce(tasks);
        RIC_dhtmlx_Gantt_Controller.retour();
        Test.stopTest();
    }
    
    static testMethod void TestMilestoneJson() {
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;   
        
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m2.Id);
        t1.RIC_Type_Action__c = 'Avec Notification';
        insert t1;
        
        //RIC_dhtmlx_Gantt_Controller cls = new RIC_dhtmlx_Gantt_Controller();
        RIC_dhtmlx_Gantt_Controller.mytarget = m2.Id;
        String ret = RIC_dhtmlx_Gantt_Controller.projectGanttJson();
        String tasks = t1.id + '>Tue Feb 28 2017 00:00:00 GMT+0200 (Middle East Standard Time)>Sat Mar 18 2017 00:00:00 GMT+0200 (Middle East Standard Time)>' + t1.Name + '>' + Userinfo.getUserId() + ';';
        RIC_dhtmlx_Gantt_Controller.saveAllTasksToSalesforce(tasks);
        Test.stopTest();
    }
}