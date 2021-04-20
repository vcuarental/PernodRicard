@isTest
public with sharing class MMPJ_XRM_SMSStatusBatch_Test {
    
    @testSetup static void initRecords() {
        insert new MMPJ_XRM_Marketing_API__c(MMPJ_XRM_Numero_definition_message__c=0,SetupOwnerId=UserInfo.getOrganizationId(),MMPJ_XRM_Client_id__c='test',MMPJ_XRM_Client_secret__c='test');
        Campaign ca = new Campaign();
        ca.Name = 'testCampaign';
        insert ca;

        Contact contact = new Contact();
        contact.LastName = 'Contact';
        contact.FirstName = 'test';

        insert contact;

        MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c();
        societe.Name = 'Test société';
        insert societe;

        MMPJ_Ext_Vign_Societe_Contact__c linkSocieteContact = new MMPJ_Ext_Vign_Societe_Contact__c();
        linkSocieteContact.MMPJ_Ext_Vign_Contact__c = contact.Id;
        linkSocieteContact.MMPJ_Ext_Vign_Societe__c = societe.id;
        insert linkSocieteContact;

        MMPJ_XRM_SMS_Envoye__c smsEnvoye = new MMPJ_XRM_SMS_Envoye__c(
            MMPJ_XRM_Campaign__c=ca.Id,
            MMPJ_XRM_Contenu__c = 'test',
            MMPJ_XRM_Date_envoi__c=DateTime.now(),
            MMPJ_XRM_Initiateur_de_l_envoi__c= UserInfo.getUserId(),
            MMPJ_XRM_Nb_destinataires__c = 1
        );
        insert smsEnvoye;

        insert new MMPJ_XRM_SMS__c(MMPJ_XRM_SMS_Envoye__c=smsEnvoye.Id,MMPJ_XRM_Date_envoi__c = Date.today(),MMPJ_XRM_SMS_Message_Key__c='1');
        insert new MMPJ_XRM_SMS__c(MMPJ_XRM_SMS_Envoye__c=smsEnvoye.Id,MMPJ_XRM_Date_envoi__c = Date.today(),MMPJ_XRM_SMS_Message_Key__c='2');
        insert new MMPJ_XRM_SMS__c(MMPJ_XRM_SMS_Envoye__c=smsEnvoye.Id,MMPJ_XRM_Date_envoi__c = Date.today(),MMPJ_XRM_SMS_Message_Key__c='3');

    }

    @isTest
    private static void testStatusBatch(){


        HttpResponse res1 = new HttpResponse();
        HttpResponse res2 = new HttpResponse();
        HttpResponse res3 = new HttpResponse();
        HttpResponse res4 = new HttpResponse();

        res1.setBody('{"requestId": "77431635-1b6b-44db-a16d-420361a43dc1","eventCategoryType": "TransactionalSendEvents.SMSSent","timestamp": "2018-08-03T13:41:18.55","compositeId": "1F3631D4-5497-E811-80E4-1402EC6B9540.214435.228431.1.231481617","messageKey": "bcX0qaEp0USGciEnUJTW0w","contactKey": "Astro25"}');
        res2.setBody('{"requestId": "fcdbb2f9-438b-4d52-a380-2eade2f46396","eventCategoryType": "TransactionalSendEvents.SMSQueued","timestamp": "2018-08-16T10:44:41.2196"}');
        res3.setBody('{"requestId": "30486456-ed41-46ba-96eb-06c4ff3b95d9","eventCategoryType": "TransactionalSendEvents.SMSNotSent","timestamp": "2018-07-24T06:26:58.463","compositeId": "56941A9F-3A8F-E811-80E0-1402EC6B9529.4647028.622338.1.318768528","messageKey": "9a-zUvWf3UKxLpwwIrqTmQ","contactKey": "ec25a8c8-6d4e-42f0-84c3-4ea23564cbe5","statusCode": 16,"statusMessage": "InvalidAttributeValue"}');
        res4.setBody('{"access_token" : "1234"}');
        Map<String, HttpCalloutMock> endpointTestResp = new Map<String,HttpCalloutMock>();

        endpointTestResp.put('http://test-niji-marketing.com/messaging/v1/sms/messages/1', new MMPJ_XRM_MarketingCloudAPIMock(res1));
        endpointTestResp.put('http://test-niji-marketing.com/messaging/v1/sms/messages/2', new MMPJ_XRM_MarketingCloudAPIMock(res1));
        endpointTestResp.put('http://test-niji-marketing.com/messaging/v1/sms/messages/3', new MMPJ_XRM_MarketingCloudAPIMock(res3));
        endpointTestResp.put('http://test-niji-marketing.com/v2/token', new MMPJ_XRM_MarketingCloudAPIMock(res4));
        HttpCalloutMock mock = new MMPJ_XRM_MarketingCloudAPIMultiMock(endpointTestResp);
        

        Test.startTest();
        test.setMock(HttpCalloutMock.class, mock);
        Database.executeBatch(new MMPJ_XRM_SMSStatusBatch(),100);
        Test.stopTest();
    }
}