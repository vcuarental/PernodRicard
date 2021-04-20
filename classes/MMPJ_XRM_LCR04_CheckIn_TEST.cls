@isTest
public with sharing class MMPJ_XRM_LCR04_CheckIn_TEST {
    @TestSetup
    static void makeData() {
        
        Campaign ca = new Campaign();
        ca.Name = 'testCampaign';
        ca.StartDate = Date.today();
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

        CampaignMember campaignMember = new CampaignMember();
        campaignMember.campaignId = ca.Id;
        campaignMember.contactId = contact.Id;
        campaignMember.MMPJ_Ext_Accompagnants__c = 0; 
        insert campaignMember;
    }

    @isTest
    static void fetchCampaignsTest() {
        Test.startTest();
        List<Campaign> campaignsFetched = MMPJ_XRM_LCR04_CheckIn.fetchCampaigns('test');
        System.assertEquals(1, campaignsFetched.size());
        Test.stopTest();
    }

    @isTest
    static void fetchCampaignInfosTest() {
        Id campaignId = [SELECT Id FROM Campaign WHERE Name = 'testCampaign'].Id;
        Test.startTest();
        Campaign campaign = MMPJ_XRM_LCR04_CheckIn.fetchCampaignInfos(campaignId);
        System.assertEquals(1, campaign.CampaignMembers.size());
        Test.stopTest();
    }

    @isTest
    static void fetchSocietesInfosTest() {
        Id contactId = [SELECT Id FROM Contact WHERE LastName = 'Contact'].Id;
        Test.startTest();
        List<MMPJ_Ext_Vign_Societe_Contact__c> societeInfos=  MMPJ_XRM_LCR04_CheckIn.fetchSocietesInfos(new List<String>{contactId});
        System.assertEquals(1, societeInfos.size());
        Test.stopTest();
    }

    @isTest
    static void updateCampaignMemberTest() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Contact'];
        Id campaignMemberId = [SELECT Id FROM CampaignMember WHERE ContactId = :contact.Id].Id;
        Test.startTest();
        MMPJ_XRM_LCR04_CheckIn.updateCampaignMember(campaignMemberId, true);
        Test.stopTest();
        System.assertEquals('Venu', [SELECT Id, MMPJ_Ext_Vign_Presence__c FROM CampaignMember WHERE Id = :campaignMemberId].MMPJ_Ext_Vign_Presence__c);
        //MMPJ_XRM_LCR04_CheckIn.updateCampaignMember(campaignMemberId, false);
        //System.assertEquals('Non venu', [SELECT Id, MMPJ_Ext_Vign_Presence__c FROM CampaignMember WHERE Id = :campaignMemberId].MMPJ_Ext_Vign_Presence__c);
        
    }
    /**
    * when number of accompanist changes, the campaign member is also updated
    */
    @isTest
    static void updateNumberOfAccompanists(){
        List<CampaignMember> lstToUpdate = new List<CampaignMember>(); 
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Contact'];
        CampaignMember campaignMember = [SELECT Id, MMPJ_Ext_Accompagnants__c FROM CampaignMember WHERE ContactId = :contact.Id];
        campaignMember.MMPJ_Ext_Accompagnants__c = 3; 
        lstToUpdate.add(campaignMember); 
        Test.startTest();
       MMPJ_XRM_LCR04_CheckIn.updateCampaignMemberAccompNumber(lstToUpdate); 
        Test.stopTest();
        //verify the number of accompanist has changed; 
        CampaignMember cm = [SELECT Id, MMPJ_Ext_Accompagnants__c FROM CampaignMember WHERE ContactId = :contact.Id];
        System.assertEquals(3, cm.MMPJ_Ext_Accompagnants__c);
    }
}