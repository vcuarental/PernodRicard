@isTest
public class ASI_GnH_KR_TestClassHelper{

    public static List<User> createTestUser(){
        Profile tempProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; //profile
        List<User> tempUsers = new List<User>(); //user list

        User tempUser1 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', 
                                  FirstName='Test1', LastName='666', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = tempProfile.Id, ASI_KOR_User_Branch_Code__c='311',
                                  TimeZoneSidKey = 'Asia/Seoul',UserName='standarduser666@testorg.com', 
                                  ASI_KOR_Commission_Code__c='1234567', CompanyName = 'Test Company', ASI_GnH_Department__c = 'Kyunggi WS-TL', Country = 'Korea');
        insert tempUser1;
        User tempUser2 = new User(Alias = '777', Email='standarduser777@testorg.com', EmailEncodingKey='UTF-8', 
                                  FirstName='Test2', LastName='777', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = tempProfile.Id, 
                                  TimeZoneSidKey = 'Asia/Seoul', UserName='standarduser777@testorg.com', 
                                  ASI_KOR_Commission_Code__c='1112223', ManagerId = tempUser1.id,
                                  CompanyName = 'Test Company', Country = 'Korea', ASI_GnH_Department__c = 'Kyunggi WS', ASI_KOR_User_Branch_Code__c='506');
        insert tempUser2;
        User tempUser3 = new User(Alias = '888', Email='standarduser888@testorg.com', EmailEncodingKey='UTF-8', 
                                  FirstName='Test3', LastName='888', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = tempProfile.Id, 
                                  TimeZoneSidKey = 'Asia/Seoul',UserName='standarduser888@testorg.com', 
                                  ASI_KOR_Commission_Code__c='2223334', ManagerId = tempUser2.id, 
                                  CompanyName = 'Test Company', Country = 'Korea', ASI_GnH_Department__c = 'Purchasing', ASI_KOR_User_Branch_Code__c='523');
        insert tempUser3;
        User tempUser4 = new User(Alias = '999', Email='standarduser999@testorg.com', EmailEncodingKey='UTF-8', 
                                  FirstName='Test4', LastName='999', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = tempProfile.Id, 
                                  TimeZoneSidKey = 'Asia/Seoul',UserName='standarduser999@testorg.com', 
                                  ASI_KOR_Commission_Code__c='3334445', ManagerId = tempUser2.id, 
                                  CompanyName = 'Test Company', Country = 'Korea', ASI_GnH_Department__c = 'Logistics', ASI_KOR_User_Branch_Code__c='523');
        insert tempUser4;

        User tempUser5 = [select id, Name, ASI_KOR_Commission_Code__c, ProfileId from user where id = :userInfo.getUserId()];
        tempUsers.add(tempUser1); //add to user list
        tempUsers.add(tempUser2); //add to user list
        tempUsers.add(tempUser3); //add to user list
        tempUsers.add(tempUser4); //add to user list
        tempUsers.add(tempUser5); //add to user list
        //insert tempUsers;
        return tempUsers;
    }

    public static ASI_GnH_Request__c createGnHRequest(){
        Id recordTypeId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c'+'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c newGnHRequest = new ASI_GnH_Request__c(ASI_GnH_Recipient_Type__c = 'Others',
                                                                  ASI_GnH_Type__c = 'Gifts',
                                                                  ASI_GnH_Amount_per_Recipient__c = 2000,
                                                                  ASI_GnH_PAX__c = 1,
                                                                  recordTypeId =recordTypeId);

        return newGnHRequest;
    }

    public static List<ASI_GnH_Recipient_Master__c> createRecipientMasterList(Integer numberOfRecord, String name , String organisation, String title){
        List<ASI_GnH_Recipient_Master__c> recipientMasterList = new List<ASI_GnH_Recipient_Master__c>();
        Id recordTypeId = Global_RecordTypeCache.getRtId('ASI_GnH_Recipient_Master__c'+'ASI_GnH_KR_Recipient_Master');
        for (Integer i = 0; i<numberOfRecord; i++ ){
            ASI_GnH_Recipient_Master__c newRecipientMaster = new ASI_GnH_Recipient_Master__c(recordTypeid = recordTypeId,
                                                                                             Name = name+i,
                                                                                             ASI_GnH_Organization__c = organisation+i,
                                                                                             ASI_GnH_Title__c = title+i,
                                                                                             ASI_GnH_Company_Address__c = 'test address',
                                                                                             ASI_GnH_Mobile__c = '65432109',
                                                                                             ASI_GnH_Email__c = 'testing@test.com');
            recipientMasterList.add(newRecipientMaster);        
        }
        return recipientMasterList;
    }

    public static List<ASI_GnH_Request_Recipient__c> createRequestRecipientList(Integer numberOfRecord, Id requestId, String name, String organisation, String title){
        List<ASI_GnH_Request_Recipient__c> requestRecipientList = new List<ASI_GnH_Request_Recipient__c>();
        Id recordTypeId = Global_RecordTypeCache.getRtId('ASI_GnH_Request_Recipient__c'+'ASI_GnH_KR_Request_Recipient');
        for (Integer i = 0; i<numberOfRecord; i++ ){
            ASI_GnH_Request_Recipient__c newRequestRecipient = new ASI_GnH_Request_Recipient__c(recordTypeid = recordTypeId,
                                                                                                ASI_GnH_Request__c = requestId,
                                                                                                ASI_GnH_Sys_Name__c = name+i,
                                                                                                ASI_GnH_Sys_Organization__c = organisation+i,
                                                                                                ASI_GnH_Sys_Title__c = title+i,
                                                                                                ASI_GnH_Sys_Company_Address__c = 'test address',
                                                                                                ASI_GnH_Sys_Mobile__c = '65432109',
                                                                                                ASI_GnH_Sys_Email__c = 'testing@test.com');
            requestRecipientList.add(newRequestRecipient); 
        }
        return requestRecipientList;
    }

}