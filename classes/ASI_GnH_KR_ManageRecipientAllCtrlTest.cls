@isTest
public class ASI_GnH_KR_ManageRecipientAllCtrlTest{
    @testSetUp static void initData(){
        List<User> testUserList = ASI_GnH_KR_TestClassHelper.createTestUser();
        //insert testUserList;
        
        ASI_GnH_Request__c testGnHRequest = ASI_GnH_KR_TestClassHelper.createGnHRequest();
        insert testGnHRequest;
        
        List<ASI_GnH_Recipient_Master__c> recipientMasterList = ASI_GnH_KR_TestClassHelper.createRecipientMasterList(5,'test name','test organisation','test title');
        insert recipientMasterList;
        
        List<ASI_GnH_Request_Recipient__c> recipientRecipientList = ASI_GnH_KR_TestClassHelper.createRequestRecipientList(5,testGnHRequest.Id,'test name','test organisation','test title');
        insert recipientRecipientList;
        
        
    }
    static testMethod void testDoSave(){
        ASI_GnH_Request__c gnhRequest = [select id from ASI_GnH_Request__c where ASI_GnH_Recipient_Type__c = 'Others'];
        List<ASI_GnH_Request_Recipient__c> recipients = [select Id from ASI_GnH_Request_Recipient__c limit 2];
        
        ASI_GnH_Request_Recipient__c newTestRecipient = ASI_GnH_KR_TestClassHelper.createRequestRecipientList(1,gnhRequest.Id,'newName','newOrganisation','newTitle').get(0);
        insert newTestRecipient;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.ASI_GnH_KR_ManageRecipientAll);	
        Apexpages.currentPage().getParameters().put('Id',gnhRequest.Id);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(recipients);
        ASI_GnH_KR_ManageRecipientAllCtrl controller = new ASI_GnH_KR_ManageRecipientAllCtrl(sc);
        String paxNo = controller.paxNoJSON;
        ASI_GnH_KR_ManageRecipientAllCtrl.getRecipientMaster();
        ASI_GnH_KR_ManageRecipientAllCtrl.getGnHRecipient(gnhRequest.Id);
        ASI_GnH_KR_ManageRecipientAllCtrl.findList('ASI_GnH_Recipient_Master__c',' Id',' where Name != null');
        Map<Integer,ASI_GnH_Request_Recipient__c> requestRecipientMap = new Map<Integer,ASI_GnH_Request_Recipient__c>();
        requestRecipientMap.put(1,newTestRecipient);        
        ASI_GnH_KR_ManageRecipientAllCtrl.doCashSave(requestRecipientMap,'');
        
        Test.stopTest();
        
    }
    
    static testMethod void testDelete(){
        ASI_GnH_Request__c gnhRequest = [select id from ASI_GnH_Request__c where ASI_GnH_Recipient_Type__c = 'Others'];
        List<ASI_GnH_Request_Recipient__c> recipients = [select Id from ASI_GnH_Request_Recipient__c limit 2];
        
        ASI_GnH_Request_Recipient__c newTestRecipient = ASI_GnH_KR_TestClassHelper.createRequestRecipientList(1,gnhRequest.Id,'newName','newOrganisation','newTitle').get(0);
        insert newTestRecipient;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.ASI_GnH_KR_ManageRecipientAll);	
        Apexpages.currentPage().getParameters().put('Id',gnhRequest.Id);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(recipients);
        ASI_GnH_KR_ManageRecipientAllCtrl controller = new ASI_GnH_KR_ManageRecipientAllCtrl(sc);
        ASI_GnH_KR_ManageRecipientAllCtrl.findList('ASI_GnH_Threshold__c',' Id, ASI_GnH_Threshold_Amount__c',' where ASI_GnH_Threshold_Amount__c != null');        
        ASI_GnH_KR_ManageRecipientAllCtrl.findList('ASI_GnH_Recipient_Master__c',' Id',null);
        String delIdJSON = '["'+ newTestRecipient.id +'"]';
        ASI_GnH_KR_ManageRecipientAllCtrl.doCashSave(null,delIdJSON);
        
        Test.stopTest();
        
    }
    
    /*static testMethod void testException(){
        
        ASI_GnH_Request__c gnhRequest = [select id from ASI_GnH_Request__c where ASI_GnH_Recipient_Type__c = 'Others'];
        List<ASI_GnH_Request_Recipient__c> recipients = [select Id from ASI_GnH_Request_Recipient__c limit 2];
        
        ASI_GnH_Request_Recipient__c newTestRecipient = ASI_GnH_KR_TestClassHelper.createRequestRecipientList(1,gnhRequest.Id,'newName','newOrganisation','newTitle').get(0);
        newTestRecipient.ASI_GnH_Sys_Email__c = 'test';
        //insert newTestRecipient;
        
        Test.startTest();
        //ASI_GnH_Request_Recipient__c currentRecipient = [select Id,ASI_GnH_Sys_Email__c from ASI_GnH_Request_Recipient__c where Name = 'newName' limit 1];
        //currentRecipient.ASI_GnH_Sys_Email__c = 'test';
        //update currentRecipient;
        
        Test.setCurrentPage(Page.ASI_GnH_KR_ManageRecipientAll);	
        Apexpages.currentPage().getParameters().put('Id',gnhRequest.Id);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(recipients);
        ASI_GnH_KR_ManageRecipientAllCtrl controller = new ASI_GnH_KR_ManageRecipientAllCtrl(sc);
        
        Map<Integer,ASI_GnH_Request_Recipient__c> requestRecipientMap = new Map<Integer,ASI_GnH_Request_Recipient__c>();
        requestRecipientMap.put(1,newTestRecipient);
        
        ASI_GnH_KR_ManageRecipientAllCtrl.remoteActionResult testResult = new ASI_GnH_KR_ManageRecipientAllCtrl.remoteActionResult();   
        //ASI_GnH_KR_ManageRecipientAllCtrl.doCashSave(null,newTestRecipient.id);
        testResult = ASI_GnH_KR_ManageRecipientAllCtrl.doCashSave(requestRecipientMap,null);
        
        system.assert(false==testResult.SuccessFlag);
        system.assert(testResult.errorMessages[0].contains('error'));
               
        
        Test.stopTest();        
        
    }*/
}