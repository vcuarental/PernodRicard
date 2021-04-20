@isTest 
public class ASI_CRM_MY_EventAtt_Test 
{
    static testMethod void doGetTest() 
    {
        ASI_CRM_EVENTCapture__c  testEvent = new ASI_CRM_EVENTCapture__c ();
   		date mydate = Date.today();
        testEvent.name='test Event 1';
        //testEvent.CloseDate=mydate ;
        insert testEvent;

        
        Attachment  testAtt =new Attachment ();

        testAtt.name='Event Test Attachment 1';
        testAtt.Description= 'test description';
        testAtt.ParentId= testEvent.Id;
        Blob bodyBlob=Blob.valueOf('Testing Body of Attachment');
        testAtt.body = bodyBlob;
        insert testAtt;


        ASI_CRM_MY_REST_EventAttachment reqst = new ASI_CRM_MY_REST_EventAttachment();
        String JsonMsg = JSON.serialize(reqst);

        Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Attachment/'+testAtt.id;  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        ASI_CRM_MY_REST_EventAttachment.doGet();



        req.requestURI = '/services/apexrest/Attachment/'+testAtt.id+'_2018-05-30+10%3A00%3A00';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        ASI_CRM_MY_REST_EventAttachment.doGet();

        Test.stopTest();
    }
}