/***************************************************************************************************************************
 * Name:        ASI_CRM_EC_Authorization_Req_TriggerTest
 * Description: Apex Test class for ASI_CRM_EC_Authorization_Req_TriggerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-05-14       Rutuja Bardapurkar          Created
 ****************************************************************************************************************************/


@isTest
public class ASI_CRM_EC_Authorization_Req_TriggerTest {
    
    @testSetup static void setup() {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(
            Name = 'OFF MOT',
            ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Code__c = 'CN_OFF MOT',
            ASI_CRM_External_ID__c = 'CN_OFF MOT',
            ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;

        User currentUser = [SELECT Id, Name, ManagerId, ASI_CRM_CN_Prefix__c FROM User WHERE Id =:UserInfo.getUserId()];

   

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> LUser = new List<User>();
        LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ManagerId=UserInfo.getUserId(),
            LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',
            TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
        insert LUser[0];

        List<User> userList= new List<User> ();
        userList.add(new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, ManagerId = LUser[0].Id,
            TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c2@testing123.com', ASI_CRM_Sales_Team__c = 'a'));
        userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c3@testing123.com',  ASI_CRM_Sales_Team__c = 'a'));
        insert userList;

      

        List<ASI_CRM_Fix_Approval_Route__c> approvalRoutes = new List<ASI_CRM_Fix_Approval_Route__c>();
        approvalRoutes.add(new ASI_CRM_Fix_Approval_Route__c(
            ASI_CRM_Sales_Team__c = 'a',
            ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_6__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_7__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_8__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_9__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_10__c = userList[1].Id,
            ASI_CRM_RVP__c= userList[1].Id,
            ASI_CRM_CN_Regional_BA__c= UserInfo.getUserId(),
            ASI_CRM_CN_Type__c = 'EC Authorization Request'
            
        )
        );
        insert approvalRoutes;


        Date PO_Start_Date = Date.newInstance(System.today().year(), System.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        Id RecordTypeId1 = Schema.SObjectType.ASI_CRM_EC_AUTHORIZATION_REQUEST__c.getRecordTypeInfosByName().get('CN China').getRecordTypeId();
        ASI_CRM_EC_AUTHORIZATION_REQUEST__c EAR = new ASI_CRM_EC_AUTHORIZATION_REQUEST__c(
            ASI_CRM_Status__c = 'Draft',
            OwnerId = userList[0].Id,
            ASI_CRM_From__c = PO_Start_Date,
            ASI_CRM_To__c =PO_End_Date
                        );
		EAR.RecordTypeId = RecordTypeId1;         
        insert EAR;

        System.debug('Limits.getQueries() ' + Limits.getQueries());

    

        Date PO_Start_Date2 = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(2);
        Date PO_End_Date2 = PO_Start_Date2.addMonths(1)-1;

        Test.startTest();
        ASI_CRM_EC_AUTHORIZATION_REQUEST__c EAR2 = new ASI_CRM_EC_AUTHORIZATION_REQUEST__c(
            ASI_CRM_Status__c = 'Draft',
            ASI_CRM_From__c = PO_Start_Date2,
            ASI_CRM_To__c =PO_End_Date2
            );
        insert EAR2;

        Test.stopTest();

    }

 

    static testMethod void ASI_CRM_EC_Authorization_Req_TriggerTest(){
        Test.startTest();

        List<ASI_CRM_EC_AUTHORIZATION_REQUEST__c> EAR = [SELECT Id, ASI_CRM_Status__c from ASI_CRM_EC_AUTHORIZATION_REQUEST__c];

        EAR[0].ASI_CRM_Status__c = 'Submitted';
        
        update EAR[0];


        for (Integer i = 0; i <= 10; i++) {
            ASI_CRM_ECAuthorizationReq_TriggerClass.setApproverByCount(EAR[0], i, UserInfo.getUserId());
            
        }
        Test.stopTest();

    }



}