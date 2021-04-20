@isTest
public with sharing class Milestone1_Test_Manager {
    
    static testMethod void testCalendarItem(){
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item('ABCDEFG','UNIT TEST',Date.today(),Milestone1_Calendar_Item.PROJECT_TYPE);
        system.assertEquals('UNIT TEST',calItem.name);
        system.assertEquals('ABCDEFG', calItem.aid);
        system.assertEquals(Date.today(),calItem.theDate);
    }

    static testMethod void TestProjectJson() {
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        Milestone1_Milestone__c m1 = Milestone1_Test_Utility.sampleMilestone(p1);
        insert m1;
        
        Milestone1_Charts_GanttController cls = new Milestone1_Charts_GanttController();
        cls.mytarget = p1.id;

        String ret = cls.getProjectGanttJson();
        
        System.assert(ret.indexOf('ganttData') > -1);
        System.assert(ret.indexOf(m1.Name) > -1);    
        //RSC 2011-05-09 bad test -- fails when there is an interesting dateformat.
        //System.assert(ret.indexOf(Date.today().format().substring(5)) > -1); // Test today's
        String testDateString = 'new Date(' +m1.Kickoff__c.year() +',' + (m1.Kickoff__c.month()-1) +',' + m1.Kickoff__c.day() +')';
        System.assert(ret.indexOf(testDateString) > -1, 'expected: ' + testDateString + ': in: ' + ret);
    
        m1.Complete__c = true;
        update m1;
    
        Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;    
        
        Milestone1_Milestone__c m3 = Milestone1_Test_Utility.sampleMilestone(p1);
        m3.Kickoff__c = Date.today()+1;
        insert m3;            
    
        ret = cls.getProjectGanttJson();
        
        System.assert(ret.indexOf(Milestone1_Charts_GanttController.COLOR_COMPLETE) > -1);
        System.assert(ret.indexOf(Milestone1_Charts_GanttController.COLOR_LATE) > -1);
        System.assert(ret.indexOf(Milestone1_Charts_GanttController.COLOR_FUTURE) > -1);
                
    }
    
    static testMethod void TestMilestoneJson() {
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;   
        
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m2.Id);
        insert t1;
        
        Milestone1_Charts_GanttController cls = new Milestone1_Charts_GanttController();
        cls.mytarget = m2.Id;
        String ret = cls.getProjectGanttJson();
                   
        System.debug(LoggingLevel.Info, '12345:' + ret);
        
        System.assert(ret.indexOf(Milestone1_Charts_GanttController.COLOR_FUTURE) > -1);
    }

    static testMethod void testController() {
        
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Basic Sample For Test' + DateTime.now().getTime());
        insert proj;
        
        ApexPages.StandardController stc = new ApexPages.StandardController(proj);
        Milestone1_Charts_Gantt_Helper cont = new Milestone1_Charts_Gantt_Helper(stc);
        System.assert(cont.myId != null);
    }

    static testMethod void testTruncateString(){
        String example = 'NEW DESCRIPTION 1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ THIS IS LONG DESCRIPTION GREATER THAN 80 CHARACTER LIMIT FOR NAME TEST TRUNCATING';
        String nameString = Milestone1_General_Utility.processTaskName(example);
        system.AssertEquals('NEW DESCRIPTION 1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ THIS IS LONG...',nameString);
    } 

    public static testmethod void testMilestoneBatchDelete(){
        // Create a project with milestones
        Milestone1_Project__c         project = Milestone1_Test_Utility.sampleProject('My Test Project'); 
        List<Milestone1_Milestone__c> mList   = new List<Milestone1_Milestone__c>();
        
        insert project;
        
        for(Integer i = 0; i < 200; i++){
            mList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, null, 'My Test Milestone ' + i) );
        }
        
        insert mList;
        
        Test.StartTest();
        Database.executeBatch( new Milestone1_Milestone_Batch_Delete(mList) );
        Test.StopTest();
    }

    public static testmethod void testMilestoneBatchUpdate(){
        // Create a project with milestones
        Milestone1_Project__c         project = Milestone1_Test_Utility.sampleProject('My Project');
        List<Milestone1_Milestone__c> mList   = new List<Milestone1_Milestone__c>();
        
        insert project;
        
        for(Integer i = 0; i < 200; i++){
            mList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, null, 'My Test Milestone ' + i) );
        }
        
        insert mList;
        
        // Extract milestones Ids and run in batch
        Set<Id> idSet = new Set<Id>();
        
        for(Milestone1_Milestone__c m : mList){
            idSet.add( m.Id );
        }
        
        Test.StartTest();

        Database.executeBatch( new Milestone1_Milestone_Batch_Update(idSet) );

        Test.StopTest();

        // Test records were updated
        List<Milestone1_Milestone__c> result = [SELECT Id, LastModifiedDate, CreatedDate FROM Milestone1_Milestone__c WHERE Project__c = :project.Id];
        
        idSet.clear();
        for(Milestone1_Milestone__c m : result){
            if( m.LastModifiedDate > m.CreatedDate ){
                idSet.add( m.Id );
            }
        }
         
        System.AssertEquals( 200, idSet.size() );
    }

    public static testmethod void testMilestoneBatchUpdateClass(){

        User us;
        List<User> usrs = [Select id,BypassVR__c from User where username = 'nicolas.renault@pernod-ricard.com'];
        if(!usrs.isEmpty()){
            us = usrs[0];
        }else{
            us = Utils_TestMethods.createUserWithProfile('alias', 'System Administrator');
            us.username = 'Milestone1_Test_Manager@pernod-ricard.com';
            us.BypassVR__c = true;
            insert us;
        }
        System.runas(us){

            // Create project
            Milestone1_Project__c project = Milestone1_Test_Utility.sampleProject('My Project');
            project.RIC_Coordinateur__c = Userinfo.getUserId();
            project.Kickoff__c  =   Date.today().addDays(-14);
            project.Deadline__c =   Date.today().addDays(14);
            insert project;
            
            // Create parent milestones
            List<Milestone1_Milestone__c> pList = new List<Milestone1_Milestone__c>();
            
            for(Integer i = 0; i < 101; i++){
                pList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, null, 'My Parent Milestone ' + i) ); 
            }

            try{
                insert pList;
            }
            catch(Exception e){
                system.assert( false, e.getMessage() );
            }

            // Create milestones
            List<Milestone1_Milestone__c> mList = new List<Milestone1_Milestone__c>();
            
            for(Integer j = 0; j < 101; j++){
                mList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, pList.get(j).Id, 'My Milestone ' + j ) );
            }
            
            try{
                insert mList;
            }
            catch(Exception e){
                system.assert( false, e.getMessage() );
            }
            
            try{
                update [SELECT Id FROM Milestone1_Milestone__c WHERE Id IN :mList];
                system.assert(true, 'Milestones update successful');
            }
            catch(Exception e){
                system.assert( false, e.getMessage() );
            }
            
            Milestone1_Task__c task = new Milestone1_Task__c();
            task.Project_Milestone__c = pList.get(0).Id;
            insert task;
            
            pList.get(0).Okay_to_Reparent__c = true;
            update pList.get(0);
            
            delete pList.get(0);
            Milestone1_Milestone_Trigger_Utility.milestonePermissions('Milestone1_Project__c');
        }
    }

    static testMethod void testMe() {
         Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today().addDays(-1);
        testTask.Due_Date__c = Date.today().addDays(-1);
        
        insert testTask;
        
        Milestone1_Month m = new Milestone1_Month( Date.today());
        system.assert(m!=null); 
        List<Milestone1_Month.Week> l = m.getWeeks(); 
        for(Milestone1_Month.Week w : l)
        {
            List<Milestone1_Month.Day> days = w.getDays();
            for(Milestone1_Month.Day d : days)
            {
                system.debug(d.getDayOfYear());
                system.debug(d.getDayOfMonth());
                system.debug(d.getDayNumber());
                system.debug(d.getCSSName());
            }
        }
        system.debug(m.getFirstDate());
        system.debug(m.getWeekdayNames());
        system.debug(m.getYearName());
        system.debug(m.getMonthName());
        system.assert(m.getWeeks() != null);
        system.assert(m.getWeeks().size() > 3);
    }

    public static testmethod void testMilestoneProjectBatchUpdate(){
        // Create projects
        List<Milestone1_Project__c> pList = new List<Milestone1_Project__c>();
        
        for(Integer i = 0; i < 200; i++){
            pList.add( Milestone1_Test_Utility.sampleProject('My Project ' + i) );
        }
        
        insert pList;
        
        // Extract project Ids and run in batch
        Set<Id> idSet = new Set<Id>();
        
        for(Milestone1_Project__c p : pList){
            idSet.add( p.Id );
        }
        
        Test.StartTest();

        Database.executeBatch( new Milestone1_Project_Batch_Update(idSet) );

        Test.StopTest();

        // Test records were updated
        List<Milestone1_Project__c> result = [SELECT Id, LastModifiedDate, CreatedDate FROM Milestone1_Project__c WHERE Id IN :idSet];
        Set<Id> idRes = new Set<Id>();
        
        for(Milestone1_Project__c p : result){
            if( p.LastModifiedDate > p.CreatedDate ){
                idRes.add( p.Id );
            }
        }
         
        System.Assert( idSet.containsAll(idRes) && idRes.containsAll(idSet) );
    }


    static testMethod void testControllerRepeatCon()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
           
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
  }
  
  static testMethod void testControllerFilterTasks()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
        */ 
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'My Tasks Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        List<Id> mIds=new List<Id>();
        mIds.add(testMilestone.id);
        List<Milestone1_Task__c> tasksList=[Select Id from Milestone1_Task__c where Assigned_To__c =:Userinfo.getUserId() and Project_Milestone__c in : mIds ];
        for(Milestone1_Task__c task:tasksList)
        {
            if(testTask.id==task.id)
            system.assertEquals(task.id,testTask.id);
        }
  }
  
  static testMethod void testControllerFilterMilestones()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
        */ 
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'My Milestones Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
         Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
       //system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
  }
  
  static testMethod void testControllerFilterMyProjects()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
        */ 
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'My Projects And Sub-Project Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
  }
  
   /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
   */ 
    static testMethod void testControllerFilterAllItems()
    {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'All Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
      
    }
  
  static testMethod void testControllerFilterAllItemsWithBlankProject()
    {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
        Milestone1_Project__c testProject1 = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject1.Status__c = 'Active';
        testProject1.Deadline__c = Date.today();
        insert testProject1;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
        
        Milestone1_Milestone__c testMilestone1 = Milestone1_Test_Utility.sampleMilestone(testProject1.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone1.Deadline__c = Date.today();
        testMilestone1.Complete__c = false;
        insert testMilestone1;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        Milestone1_Task__c testTask1 = Milestone1_Test_Utility.sampleTask(testMilestone1.Id);
        testTask1.Complete__c = false;
        testTask1.Start_Date__c = Date.today();
        testTask1.Due_Date__c = Date.today();
        insert testTask1;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = null;
        controller.filterItem = 'All Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(projMap.containsKey(testProject1.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone1.id),true);
        Milestone1_Task__c task=[Select id,name from Milestone1_Task__c where id =: testTask.id];
        system.assertEquals(testTask.id,task.id);
        
    }


static testMethod void testControllerFilterMyProjectsWithBlankProject()
  {
         Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
        Milestone1_Project__c testProject1 = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject1.Status__c = 'Active';
        testProject1.Deadline__c = Date.today();
        insert testProject1;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = 'AllProjects';
        controller.filterItem = 'My Projects And Sub-Project Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(projMap.containsKey(testProject1.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        Milestone1_Task__c task=[Select id,name from Milestone1_Task__c where id =: testTask.id];
        system.assertEquals(testTask.id,task.id);
  }
  
  static testMethod void testControllerFilterMilestonesWithBlankProject()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
         Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
        
        Milestone1_Milestone__c testMilestone1 = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone1.Deadline__c = Date.today();
        testMilestone1.Complete__c = false;
        insert testMilestone1;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = null;
        controller.filterItem = 'My Milestones Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone1.id),true);
        
        
  }
  
  static testMethod void testControllerFilterTasksWithBlankProject()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
    
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        Milestone1_Task__c testTask1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask1.Complete__c = false;
        testTask1.Start_Date__c = Date.today();
        testTask1.Due_Date__c = Date.today();
        insert testTask1;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = 'AllProjects';
        controller.filterItem = 'My Tasks Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        Milestone1_Task__c task=[Select id,name from Milestone1_Task__c where id =: testTask.id];
        system.assertEquals(testTask.id,task.id);
        task=[Select id,name from Milestone1_Task__c where id =: testTask1.id];
        system.assertEquals(testTask1.id,task.id);
  }
    
  static testmethod void testMoveExceptionClass(){

  	String ALREADY_ASSIGNED_PROJECT_Var = Milestone1_Move_Exception.ERROR_MILESTONE_ALREADY_ASSIGNED_PROJECT;
  	String TASK_ALREADY_ASSIGNED_MILESTONE_Var = Milestone1_Move_Exception.ERROR_TASK_ALREADY_ASSIGNED_MILESTONE;
  	String COMPLETE_Var = Milestone1_Move_Exception.ERROR_MILESTONE_COMPLETE;
  	String HAS_SUCCESSORS_Var = Milestone1_Move_Exception.ERROR_MILESTONE_HAS_SUCCESSORS;
  	String HAS_PREDECESSOR_Var = Milestone1_Move_Exception.ERROR_MILESTONE_HAS_PREDECESSOR;

  }

}