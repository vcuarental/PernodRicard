@isTest
public class PJ_ByFor_SendEmail_Test {
    static testMethod void testSendEmailController() {
        
        // Define the willing environment (page and controller)
        PageReference pageRef = Page.PJ_ByFor_SendEmail;
        Test.setCurrentPage(pageRef);
        PJ_ByFor_SendEmail mycontroller = new PJ_ByFor_SendEmail();
        
        
        System.debug('## >>> Test data setup   <<< ');
        PJ_ByFor_Client__c[] choosenClient = PJ_ByFor_TestDataFactory.createClientsWithExp(1, 0, 'Friend');
        Attachment[] att_List = PJ_ByFor_TestDataFactory.createAttachments(1);
        
        
        System.debug('## >>> Perform test  <<< ');
        Test.startTest();
        
        System.debug('## >>> calling init method and lauch the process <<< ');  
        mycontroller.init();
        
        
        PJ_ByFor_SendEmail.toAddresses = choosenClient[0].PJ_ByFor_Email__c;
        PJ_ByFor_SendEmail.subject =  'Test Class';    
        
        
        mycontroller.templateID = System.Label.PJ_ByFor_TemplateId_First;
        PJ_ByFor_SendEmail.rId = choosenClient[0].id;
        mycontroller.getBodyEmailTemplate();
        
        PJ_ByFor_SendEmail.Message = 'My Message';
        
        
        PJ_ByFor_SendEmail.fileName = att_List[0].name;
        PJ_ByFor_SendEmail.blo = att_List[0].body;
        
        PJ_ByFor_SendEmail.attachment = att_List[0];
        
        
        
        // Send a normal correct email 
        mycontroller.sendEmail();
        
        //PJ_ByFor_SendEmail.toAddresses = 'test@email';
        
        // Send a email with a wrong email address format  
        //mycontroller.sendEmail();
       
        
        
        Test.stopTest();
   
    }
}