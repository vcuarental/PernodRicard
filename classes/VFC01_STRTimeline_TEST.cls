@isTest
private class VFC01_STRTimeline_TEST {

    static testMethod void testStreamTimelineController() {
        //Setup test data
        User testUser = Utils_TestMethods.createStandardUser('tst');
        //testUser.BypassVR__c = true;
        //testUser.BypassWF__c = true;
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {              
        insert testUser;
}        
        
        ESNProject__c Project = Utils_TestMethods.createProject();
// FTR : Dates are now mandatory
Date today = Date.today();
Project.StartDate__c = today;
Project.EndDate__c = today.addDays(30);     
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){         
        insert Project ;
}       
        
        ESNStream__c Stream = Utils_TestMethods.createStream(project.id);
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){     
        insert Stream ;
}
        
        //Organization org = [Select id from Organization][0];
        //CS001_TimelineConfig__c config = new CS001_TimelineConfig__c(); 
        //config.SetupOwnerId = org.Id;
        //config.PriorityTaskFilter__c = 'All';
        
        Datetime myDate = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        Utils_TestMethods.createEventOnProject(myDate, stream.Id, testUser.Id,500, 3, 'Subject' );
        Utils_TestMethods.createTaskOnProject(myDate, stream.Id, testUser.Id,500, 3, 'Subject' );
        //Initialise controller etc.
        PageReference pageRef = Page.VFP01_STRJSONTimelineItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', stream.Id);
        VFC01_STRTimeline c = new VFC01_STRTimeline(new ApexPages.StandardController(stream));
        
        c.getStreamItems();
        
        
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
        Utils_TestMethods.createTaskOnProject(myDate, stream.Id, testUser.Id,10, 3, 'Subject' );
        //Initialise controller etc.
        //PageReference pageRef = Page.VFP01_STRJSONTimelineItems;
        //Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id', stream.Id);
        c = new VFC01_STRTimeline(new ApexPages.StandardController(stream));
        
        c.getStreamItems();
        
        
        config.PriorityTaskFilter__c = 'Low';
        config.TypeTaskFilter__c='Call';
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){         
        update config;
}
        c = new VFC01_STRTimeline(new ApexPages.StandardController(stream));
        
        c.getStreamItems();
        
        config.PriorityTaskFilter__c = 'All';
        config.TypeTaskFilter__c='Call';
// FTR : Solving MIXED_DML_OPERATION error
system.runas(testUser){         
        update config;
}
        c = new VFC01_STRTimeline(new ApexPages.StandardController(stream));
        
        c.getStreamItems();
    }
}