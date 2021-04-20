@isTest
private class VFC01_RLSTimeline_TEST {

    static testMethod void testReleaseTimelineController() {
        //Setup test data
        User testUser = Utils_TestMethods.createStandardUser('tst');
        //testUser.BypassVR__c = true;
        //testUser.BypassWF__c = true;
        insert testUser;
        
        Release__c Release = Utils_TestMethods.createRelease();
        insert Release ;
        
        //Organization org = [Select id from Organization][0];
        //CS001_TimelineConfig__c config = new CS001_TimelineConfig__c(); 
        //config.SetupOwnerId = org.Id;
        //config.PriorityTaskFilter__c = 'All';
        
        Datetime myDate = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        Utils_TestMethods.createEventOnProject(myDate, Release.Id, testUser.Id,500, 3, 'Subject' );
        Utils_TestMethods.createTaskOnProject(myDate, Release.Id, testUser.Id,500, 3, 'Subject' );
        //Initialise controller etc.
        PageReference pageRef = Page.VFP01_RLSJSONTimelineItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', Release.Id);
        VFC01_RLSTimeline c = new VFC01_RLSTimeline(new ApexPages.StandardController(Release));
        
        c.getReleaseItems();
        
        
        //CS001_TimelineConfig__c config = [Select Id, PriorityTaskFilter__c From CS001_TimelineConfig__c Where SetupOwnerId in (Select id from Organization) limit 1];
        Organization org = [Select id from Organization][0];
        CS001_TimelineConfig__c config = new CS001_TimelineConfig__c(); 
        config.SetupOwnerId = org.Id;
        config.PriorityTaskFilter__c = 'All';
        config.EventSupport__c = true;
        config.TaskSupport__c = true;
        insert config;
        Utils_TestMethods.createTaskOnProject(myDate, Release.Id, testUser.Id,10, 3, 'Subject' );
        //Initialise controller etc.
        //PageReference pageRef = Page.VFP01_RLSJSONTimelineItems;
        //Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id', Release.Id);
        c = new VFC01_RLSTimeline(new ApexPages.StandardController(Release));
        
        c.getReleaseItems();
        
        
        config.PriorityTaskFilter__c = 'Low';
        config.TypeTaskFilter__c='Call';
        update config;
        c = new VFC01_RLSTimeline(new ApexPages.StandardController(Release));
        
        c.getReleaseItems();
        
        config.PriorityTaskFilter__c = 'All';
        config.TypeTaskFilter__c='Call';
        update config;
        c = new VFC01_RLSTimeline(new ApexPages.StandardController(Release));
        
        c.getReleaseItems();
    }
}