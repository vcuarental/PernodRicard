/* Test class for Milestone2_Charts_GanttController */
/* christophe.averseng@bluewolf.com - 24/06/2015    */

    @istest
    private class Milestone2_Charts_GanttController_TEST
    {
        static testmethod void Milestone2_Charts_GanttController_TEST()
        {
            // Create a sample Project with one Milestone and one Task
            RIC_Brand__c brand = new RIC_Brand__c(Name='Ricard');
            insert brand;
            Milestone1_Project__c project = new Milestone1_Project__c(RIC_Brand__c = brand.Id, Name='Test project');
            insert project;
            Milestone1_Milestone__c milestone = new Milestone1_Milestone__c(Name='Test Phase',Project__c=project.Id,KickOff__c=Date.Today(),Deadline__c=Date.Today()+10);
            insert milestone;
            Milestone1_Milestone__c milestone2 = new Milestone1_Milestone__c(Name='Test Phase 2',Project__c=project.Id,KickOff__c=Date.Today()+11,Deadline__c=Date.Today()+20, Predecessor_Milestone__c=milestone.Id);
            insert milestone2;
            Milestone1_Task__c task = new Milestone1_Task__c(Name='Test Task',Project_Milestone__c=milestone.Id);
            insert task;
            
            Test.startTest();
            
            // Display gantt chart at Project level
            PageReference m2 = Page.Milestone2_Charts_GanttMilestones;
            Test.setCurrentPage(m2);
            ApexPages.currentPage().getParameters().put('Id', project.Id);
            Milestone2_Charts_GanttController m2c = new Milestone2_Charts_GanttController();
            m2c.myTarget = project.Id;
            m2c.Init();
            
            // Display gantt chart at Milestone level
            PageReference m3 = Page.Milestone2_Charts_GanttMilestones;
            Test.setCurrentPage(m3);
            ApexPages.currentPage().getParameters().put('Id', milestone.Id);
            Milestone2_Charts_GanttController m3c = new Milestone2_Charts_GanttController();
            m3c.myTarget = milestone.Id;
            m3c.Init();
            
            Test.stopTest();
        }
    }