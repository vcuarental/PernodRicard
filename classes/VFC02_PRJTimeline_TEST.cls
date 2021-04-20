@isTest
private class VFC02_PRJTimeline_TEST {

    static testMethod void testProjectTimelineController() {
        //Setup test data
        User testUser = Utils_TestMethods.createStandardUser('tst');
        //testUser.BypassVR__c = true;
        //testUser.BypassWF__c = true;
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {      
        insert testUser;
}
        
        ESNProject__c projet = Utils_TestMethods.createProject();
        // FTR : Dates are now mandatory
        Date today = Date.today();
        projet.StartDate__c = today;
        projet.EndDate__c = today.addDays(30);
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){ 
        insert projet ;
}
        
        //Organization org = [Select id from Organization][0];
        //CS001_TimelineConfig__c config = new CS001_TimelineConfig__c(); 
        //config.SetupOwnerId = org.Id;
        //config.PriorityTaskFilter__c = 'All';
        
        Datetime myDate = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        Utils_TestMethods.createEventOnProject(myDate, projet.Id, testUser.Id,500, 3, 'Subject' );
        Utils_TestMethods.createTaskOnProject(myDate, projet.Id, testUser.Id,500, 3, 'Subject' );
        //Initialise controller etc.
        PageReference pageRef = Page.VFP01_PRJJSONTimelineItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', projet.Id);
        VFC02_PRJTimeline c = new VFC02_PRJTimeline(new ApexPages.StandardController(projet));
        
        c.getProjectItems();
        
        
        //CS001_TimelineConfig__c config = [Select Id, PriorityTaskFilter__c From CS001_TimelineConfig__c Where SetupOwnerId in (Select id from Organization) limit 1];
        Organization org = [Select id from Organization][0];
        CS001_TimelineConfig__c config = new CS001_TimelineConfig__c(); 
        config.SetupOwnerId = org.Id;
        config.PriorityTaskFilter__c = 'All';
        config.EventSupport__c = true;
        config.TaskSupport__c = true;
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){ 
        insert config;
}
        Utils_TestMethods.createTaskOnProject(myDate, projet.Id, testUser.Id,10, 3, 'Subject' );
        //Initialise controller etc.
        //PageReference pageRef = Page.VFP01_PRJJSONTimelineItems;
        //Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id', projet.Id);
        c = new VFC02_PRJTimeline(new ApexPages.StandardController(projet));
        
        c.getProjectItems();
        
        
        config.PriorityTaskFilter__c = 'Low';
        config.TypeTaskFilter__c='Call';
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){ 
        update config;
}
        c = new VFC02_PRJTimeline(new ApexPages.StandardController(projet));
        
        c.getProjectItems();
        
        config.PriorityTaskFilter__c = 'All';
        config.TypeTaskFilter__c='Call';
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){ 
        update config;
}
        c = new VFC02_PRJTimeline(new ApexPages.StandardController(projet));
        
        c.getProjectItems();
    }
}