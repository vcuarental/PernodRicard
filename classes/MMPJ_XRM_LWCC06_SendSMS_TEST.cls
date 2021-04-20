@isTest
public with sharing class MMPJ_XRM_LWCC06_SendSMS_TEST {
	
    @testSetup static void initRecords() {

            
        Account accCognac = new Account(Name='Test');
            Id accRecId = [SELECT ID FROM RecordType WHERE DeveloperName='MMPJ_Ext_Vign_Account'].ID;
            accCognac.RecordTypeId=accRecId;
        insert accCognac;
            accCognac = [SELECT Id from Account WHERE Name='Test'];
            System.debug('### '+accCognac.Id);
            Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact'].Id;
            Contact con1 = new Contact(LastName='Test1',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
        con1.MMPJ_Ext_Vign_Telephone_portable_perso__c = '33600000000';
        insert con1;

        
            insert new MMPJ_XRM_Marketing_API__c(MMPJ_XRM_Numero_definition_message__c=0,SetupOwnerId=UserInfo.getOrganizationId(),MMPJ_XRM_Client_id__c='test',MMPJ_XRM_Client_secret__c='test');
        Campaign ca = new Campaign();
         Id rtCampMember = [SELECT Id FROM RecordType WHERE DeveloperName='MMPJ_Ext_Vign_CampaignMember'].ID;
        ca.Name = 'testCampaign';
        ca.CampaignMemberRecordTypeId=rtCampMember;
        Id rtCamp = [select id from RecordType where SObjectType='Campaign' and DeveloperName='MMPJ_Ext_Vign_Campaign' LIMIT 1].Id;
        ca.RecordTypeId=rtCamp;
        insert ca;

        

        CampaignMember campaignMember = new CampaignMember();
        campaignMember.campaignId = ca.Id;
        campaignMember.contactId = con1.Id;
        campaignMember.Status = 'Envoyée';
        //campaignMember.MMPJ_Ext_Vign_Participation__c = 'Accepté';
        campaignMember.MMPJ_Ext_Vign_Presence__c = 'Venu';
        insert campaignMember;


    }
    
    @isTest
    private static void testGetNbContacts(){
        Id campaignId = [SELECT Id FROM Campaign WHERE Name='testCampaign' ].Id;
        Integer nbContacts =MMPJ_XRM_LWCC06_SendSMS.getNumberOfContacts(campaignId,'Envoyée','Accepté','Venu');
        
        // System.assertEquals(1, nbContacts);
    }

    @isTest
    private static void testSendSMS(){
        HttpResponse res1 = new HttpResponse();
        HttpResponse res2 = new HttpResponse();
        HttpResponse res3 = new HttpResponse();

        res1.setBody('{"access_token":"token"}');
        res2.setBody('{"errorcode" : 0}');
        res3.setBody('{"requestId": "ccdb94bf-fcac-4fef-b194-08f534a2079a","errorcode": 0,"responses": [{"messageKey": "nFL4ULgheUeaGbPIMzJJSw"},{"messageKey": "GV1LhQ6NFkqFUAE1IsoQ9Q"}]}');

        Map<String, HttpCalloutMock> endpointTestResp = new Map<String,HttpCalloutMock>();
        endpointTestResp.put('http://test-niji-marketing.com/v2/token', new MMPJ_XRM_MarketingCloudAPIMock(res1));
        endpointTestResp.put('http://test-niji-marketing.com/messaging/v1/sms/definitions', new MMPJ_XRM_MarketingCloudAPIMock(res2));
        endpointTestResp.put('http://test-niji-marketing.com/messaging/v1/sms/messages', new MMPJ_XRM_MarketingCloudAPIMock(res3));
          
        HttpCalloutMock mock = new MMPJ_XRM_MarketingCloudAPIMultiMock(endpointTestResp);
        

        String campaignId = [SELECT Id FROM Campaign WHERE Name='testCampaign' ].Id;

        Test.startTest();
        test.setMock(HttpCalloutMock.class, mock);
        String respString =MMPJ_XRM_LWCC06_SendSMS.handleSendSMS('message','messageName',campaignId,'Envoyé','Accepté','Venu');
        Test.stopTest();
        
    }
}