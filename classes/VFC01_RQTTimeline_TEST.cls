@isTest
private class VFC01_RQTTimeline_TEST {

    static testMethod void testRequestTimelineController() {
        //Setup test data
        User testUser = Utils_TestMethods.createStandardUser('tst');
        //testUser.BypassVR__c = true;
        //testUser.BypassWF__c = true;
        insert testUser;
        
        Request__c Request = Utils_TestMethods.createRequest();
        insert Request ;
        
        //Organization org = [Select id from Organization][0];
        //CS001_TimelineConfig__c config = new CS001_TimelineConfig__c(); 
        //config.SetupOwnerId = org.Id;
        //config.PriorityTaskFilter__c = 'All';
        
        Datetime myDate = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        Utils_TestMethods.createEventOnProject(myDate, Request.Id, testUser.Id,500, 3, 'Subject' );
        Utils_TestMethods.createTaskOnProject(myDate, Request.Id, testUser.Id,500, 3, 'Subject' );
        //Initialise controller etc.
        PageReference pageRef = Page.VFP01_RQTJSONTimelineItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', Request.Id);
        VFC01_RQTTimeline c = new VFC01_RQTTimeline(new ApexPages.StandardController(Request));
        
        c.getRequestItems();
        
        
        //CS001_TimelineConfig__c config = [Select Id, PriorityTaskFilter__c From CS001_TimelineConfig__c Where SetupOwnerId in (Select id from Organization) limit 1];
        Organization org = [Select id from Organization][0];
        CS001_TimelineConfig__c config = new CS001_TimelineConfig__c(); 
        config.SetupOwnerId = org.Id;
        config.PriorityTaskFilter__c = 'All';
        config.EventSupport__c = true;
        config.TaskSupport__c = true;
        insert config;
        Utils_TestMethods.createTaskOnProject(myDate, Request.Id, testUser.Id,10, 3, 'Subject' );
        //Initialise controller etc.
        //PageReference pageRef = Page.VFP01_RQTJSONTimelineItems;
        //Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id', Request.Id);
        c = new VFC01_RQTTimeline(new ApexPages.StandardController(Request));
        
        c.getRequestItems();
        
        
        config.PriorityTaskFilter__c = 'Low';
        config.TypeTaskFilter__c='Call';
        update config;
        c = new VFC01_RQTTimeline(new ApexPages.StandardController(Request));
        
        c.getRequestItems();
        
        config.PriorityTaskFilter__c = 'All';
        config.TypeTaskFilter__c='Call';
        update config;
        c = new VFC01_RQTTimeline(new ApexPages.StandardController(Request));
        
        c.getRequestItems();
    }
}