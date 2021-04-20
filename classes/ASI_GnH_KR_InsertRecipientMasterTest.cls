@isTest
public class ASI_GnH_KR_InsertRecipientMasterTest{
    
    static testMethod void insertRecipient(){
        List<User> tempUsers = ASI_TnE_KR_TestClassHelper.createTestUser(); 
        List<ASI_GnH_Request__c> gnhRequestList = ASI_TnE_KR_TestClassHelper.createGnHRequest(tempUsers);
        List<ASI_GnH_Recipient_Master__c> tempRecipientMaster = ASI_TnE_KR_TestClassHelper.createRecipientMasterData();
        
        Id requestrecipientId = Global_RecordTypeCache.getRtId('ASI_GnH_Request_Recipient__cASI_GnH_KR_Request_Recipient');
        
        List<ASI_GnH_Request_Recipient__c> recipientList = new List<ASI_GnH_Request_Recipient__c>();
        
        Test.startTest();
        ASI_GnH_Request_Recipient__c recipient1 = new ASI_GnH_Request_Recipient__c(ASI_GnH_Request__c = gnhRequestList[0].Id,
                                                                                   RecordTypeId = requestrecipientId,
                                                                                   ASI_GnH_Sys_Name__c = 'test1',
                                                                                   ASI_GnH_Sys_Organization__c = 'organisation1',
                                                                                   ASI_GnH_Sys_Title__c = 'title1',
                                                                                   ASI_GnH_Sys_Mobile__c = '12345678',
                                                                                   ASI_GnH_Sys_Email__c = 'test1@test.com'                                                                                  
                                                                                  );

        ASI_GnH_Request_Recipient__c recipient2 = new ASI_GnH_Request_Recipient__c(ASI_GnH_Request__c = gnhRequestList[0].Id,
                                                                                   RecordTypeId = requestrecipientId,
                                                                                   ASI_GnH_Sys_Name__c = 'test10',
                                                                                   ASI_GnH_Sys_Organization__c = 'organisation10',
                                                                                   ASI_GnH_Sys_Title__c = 'title10',
                                                                                   ASI_GnH_Sys_Mobile__c = '123456789',
                                                                                   ASI_GnH_Sys_Email__c = 'test10@test.com'  
                                                                                  );
        
        recipientList.add(recipient1);
        recipientList.add(recipient2);
        insert recipientList;  
        Test.stopTest();
    }
}