/*********************************************************************************
 * Name: ASI_CRM_VN_GiftBoxRequestBeforeInsertTest
 * Description: Test Class for ASI_CRM_VN_GiftBoxRequestBeforeInsert
 *
 * Version History
 * Date                Developer             Comments
 * ---------------  --------------------  --------------------------------------------------------------------------------
 * 30/10/2015          Neha Sonawane         Created      
 * 
*********************************************************************************/


@isTest
   
public class ASI_CRM_VN_GiftBoxReqBeforeInsertTest{
    

    public static testMethod void populateHrFinanceMarketingUsersTest(){
        
        //List of Gift Box/POSM Requests
        list<ASI_GiftBox_Request_Header__c> giftBoxList = new list<ASI_GiftBox_Request_Header__c>();
        giftBoxList  = [Select Name from ASI_GiftBox_Request_Header__c];
        Integer gSize = giftBoxList.size();
        
        //List of Gift Box Notification User
        list<ASI_GiftBox_Notification_Mapping__c> mappingList = new list<ASI_GiftBox_Notification_Mapping__c>();
        mappingList = [Select Notification_Id__c from ASI_GiftBox_Notification_Mapping__c];
        Integer mSize = mappingList.size();
        
        //RecordType Id for Gift Box Request
        String RecordTypeIdGiftBox = Schema.SObjectType.ASI_GiftBox_Request_Header__c.getRecordTypeInfosByName().
                                                                                     get('ASI POSM VN Request').getRecordTypeId();
        //RecordType Id for Customer
        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
        Date orderDate = Date.newInstance(2015,30,10);
        Profile profileCRMStdUser = [Select Id from Profile where Name = 'ASI TH CRM Standard User'];
        Profile profileTHStdUser = [Select Id from Profile where Name = 'ASI TH Standard User'];
        Profile profileHKCRMStandardPlatformUser = [Select Id from Profile where Name = 'ASI HK CRM Standard Platform User'];
        
        //Create users
        User financeUser = ASI_CRM_VN_TestDataFactory.getUser('tstU1','testFinanceUser@test123456789.com','Unicode (UTF-8)','Finance','en_US','en_US','America/Mexico_City','testFinanceUser@test123456789.com',profileCRMStdUser.Id);
        User hrUser = ASI_CRM_VN_TestDataFactory.getUser('tstU2','testHrUser@test123456789.com','Unicode (UTF-8)','HR','en_US','en_US','America/Mexico_City','testHrUser@test123456789.com',profileTHStdUser.Id);
        User marketingUser = ASI_CRM_VN_TestDataFactory.getUser('tstU3','testMarketingUser@test123456789.com','Unicode (UTF-8)','HR','en_US','en_US','America/Mexico_City','testMarketingUser@test123456789.com',profileHKCRMStandardPlatformUser.Id); 
        User newUser = [Select Id,Name,UserRole.Name from User  where UserRole.Name = 'ASI HK CRM' LIMIT 1];
       
        //Instance of Service Pack Object
        ASI_CRM_ServicePack__c servicePackObj = ASI_CRM_VN_TestDataFactory.getServicePack('servicePackTest','restaurant',12,1,3,5,7,4,9,3,14,15,11,1,'Visiblity',7,65,'Attack'); 
                
        //Instance of Customer Object
        ASI_CRM_AccountsAdditionalField__c customerObj = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer , servicePackObj.Id );
  
        //Instance of Running Number Object
        ASI_HK_CRM_Running_Number__c runningObj = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,15);
        insert runningObj ;
        
        //Instance of Gift Box Notification Users Object
        Test.startTest();
        ASI_GiftBox_Notification_User__c testNotifcationUser = ASI_CRM_VN_TestDataFactory.getGiftBoxNotificationUser('Notification User Test', financeUser.Id, hrUser.Id, marketingUser.Id );
        insert testNotifcationUser ;
        
        //Instance of Gift Box Notification Mappings Object
        ASI_GiftBox_Notification_Mapping__c  mappingObj = ASI_CRM_VN_TestDataFactory.getMapping('ASI_HK_CRM', testNotifcationUser.Id);
        insert mappingObj ;
          
        list<ASI_GiftBox_Notification_Mapping__c> newMappingList = new list<ASI_GiftBox_Notification_Mapping__c>();
        newMappingList  = [Select Notification_Id__c from ASI_GiftBox_Notification_Mapping__c];
        Integer mNewSize = newMappingList.size();
        
        //Instance of Gift Box Request Object 
        ASI_GiftBox_Request_Header__c objGiftBox = ASI_CRM_VN_TestDataFactory.getGiftBox(orderDate,customerObj.Id, RecordTypeIdGiftBox);
        insert objGiftBox;
        
        list<ASI_GiftBox_Request_Header__c> newGiftBoxList = [Select Name from ASI_GiftBox_Request_Header__c ];
        Integer gNewSize =  newGiftBoxList.size();
       // System.runAs(newUser ) {
       // System.debug('Current User: ' + UserInfo.getUserName());
        //}
        Test.stopTest();
        
        System.assert(gSize < gNewSize);
        System.assert(mSize < mNewSize );
        System.assertEquals(objGiftBox.ASI_GiftBox_Finance_User__c, financeUser.Id);
        System.assertEquals(objGiftBox.ASI_GiftBox_HR_User__c, hrUser.Id);
        System.assertEquals(objGiftBox.ASI_GiftBox_Marketing_User__c, marketingUser.Id);
        
        }
        
      
}