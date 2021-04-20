@isTest 
public class ASI_CRM_MY_EventReportTest 
{
    static testMethod void EventReportTest() 
    {
        //1. define sample records
        date mydate = Date.today();
        //
        ASI_CRM_EVENTCapture__c recEventCapture = new ASI_CRM_EVENTCapture__c();
        recEventCapture.Name = 'Test Event Today';
        recEventCapture.ASI_CRM_MY_PRMorCompetitor__c = 'PRM Activity';
        recEventCapture.ASI_CRM_MY_ActivationStartDate__c = System.today();
        recEventCapture.ASI_CRM_MY_ActivationEndDate__c = System.today();
        recEventCapture.ASI_CRM_MY_Remarks__c = 'event remark';
        recEventCapture.ASI_CRM_MY_Outlet__r = null;
        recEventCapture.ASI_CRM_MY_Subbrand__r = null;
        recEventCapture.ASI_CRM_MY_TypeActivation__c = 'Promotion';
        insert recEventCapture;
        
        
        Attachment testAtt = new Attachment ();
        
        testAtt.name='Event Test Attachment 1';
        testAtt.Description= 'test description';
        testAtt.ParentId= recEventCapture.Id;
        Blob bodyBlob=Blob.valueOf('Testing Body of Attachment');
        testAtt.body = bodyBlob;
        insert testAtt;
        
        List<ASI_CRM_EVENTCapture__c> listEvent = new List<ASI_CRM_EVENTCapture__c>();
        listEvent.add(recEventCapture);
        
        //2. load controller
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listEvent);
        apexpages.currentpage().getparameters().put('name', String.valueOf(recEventCapture.Name));
        apexpages.currentpage().getparameters().put('activity', String.valueOf(recEventCapture.ASI_CRM_MY_PRMorCompetitor__c));
        apexpages.currentpage().getparameters().put('startdate', String.valueOf('2018-07-01'));
        apexpages.currentpage().getparameters().put('enddate', String.valueOf(System.today()));
        apexpages.currentpage().getparameters().put('pdf', String.valueOf('true'));
        
        
        //3. run test
        Test.startTest();
        ASI_CRM_MY_EventReport eventController = new  ASI_CRM_MY_EventReport (sc);
        List<SelectOption> listActivty = eventController.getActivitys();
        eventController.name = 'Test';
        eventController.activity = recEventCapture.ASI_CRM_MY_PRMorCompetitor__c;
        eventController.startdate = (System.today()).addDays(-1000);
        eventController.enddate = (System.today());
        eventController.searchRec = recEventCapture;
        eventController.keysearch = 'Test';
        eventController.searchEvents();
        eventController.getEventsReport();
        
        eventController.getBranchlist();
        
        //@RemoteAction
        ASI_CRM_MY_EventReport.getAttachments();
        ASI_CRM_MY_EventReport.getXMLFiles('Test', 'PRM Activity', 'Test', null, '2018-01-01', '2018-09-01');
        
        Test.stopTest();
    }
}