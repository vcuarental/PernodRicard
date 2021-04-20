@IsTest
public class PJ_ByFor_EmailService_Event_Test {

    	public static testMethod void EmailServiceTester(){

        // Create a new email and envelope object
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Set up your data if you need to
         List<PJ_ByFor_Client__c> clientList = PJ_ByFor_TestDataFactory.createClientsWithExp(1,1,'Prospect');
         Event[] evt = PJ_ByFor_TestDataFactory.createEvents(1, clientList, 'Confirmed', 'Epernay');
            
        // Create the email body
        email.plainTextBody = 'This should become a note';
        email.fromAddress ='test@test.com';
        String contactEmail = 'jsmith@salesforce.com';
        email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
        email.subject = evt[0].Id;
        
        PJ_ByFor_EmailService_Event  edr = new PJ_ByFor_EmailService_Event ();
        
        Test.startTest();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        Test.stopTest();
        
        /*System.assert (result.success, 'InboundEmailResult returned a failure message');
        
        Account [] accDb = [select ID from Account where name=:email.subject];
        System.assertEquals (1, accDb.size(),'Account was not inserted');
        Contact [] cDb = [select firstname,lastname from Contact where email=:contactEmail];
        System.assertEquals (1, cDb.size(),'Contact was not inserted!');
        Contact c = CDb[0];
        System.assertEquals ('Jon', c.firstName);
        System.assertEquals ('Smith', c.LastName);
        Note [] nDb = [select body from Note where ParentID=:accDb[0].id];
        System.assertEquals (1,nDb.size(), 'A note should have been attached');
        System.assertEquals (email.plainTextBody, nDb[0].body);*/
    } 
}