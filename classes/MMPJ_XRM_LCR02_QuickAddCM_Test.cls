@isTest
public class MMPJ_XRM_LCR02_QuickAddCM_Test {

    @testSetup
    public static void initData() {
        List<RecordType> vListRts = [Select Id, DeveloperName 
                                        From RecordType 
                                        Where SobjectType IN ('Campaign', 'Contact')
                                        AND DeveloperName IN (:MYPJ_Constants.CAMPAIGN_RT_MYPJ, :MYPJ_Constants.CONTACT_RT_MYPJ)];

        Map<String, Id> vMapRtNameId = new Map<String, Id>();
        for(RecordType vRt : vListRts){
            vMapRtNameId.put(vRt.DeveloperName, vRt.Id);
        }

        Contact contact = new Contact(LastName = 'CONTACT 1');
        insert contact;
        Contact contact2 = new Contact(LastName = 'CONTACT 2');
        insert contact2;
        Contact contact3 = new Contact(LastName = 'CONTACT 3');
        insert contact3;
        Contact contactMypj = new Contact(LastName = 'CONTACT MYPJ', RecordTypeId = vMapRtNameId.get(MYPJ_Constants.CONTACT_RT_MYPJ));
        insert contactMypj;
        MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name = 'SOCIETE 1');
        insert societe;
        MMPJ_Ext_Vign_Societe__c societe2 = new MMPJ_Ext_Vign_Societe__c(Name = 'SOCIETE 2');
        insert societe2;
        MMPJ_Ext_Vign_Societe__c societe3 = new MMPJ_Ext_Vign_Societe__c(Name = 'SOCIETE 3');
        insert societe3;
        MMPJ_Ext_Vign_Societe_Contact__c societeContact = new MMPJ_Ext_Vign_Societe_Contact__c(	MMPJ_Ext_Vign_Contact__c = contact.Id, MMPJ_Ext_Vign_Societe__c = societe.Id);
        insert societeContact;
        MMPJ_Ext_Vign_Societe_Contact__c societeContact2 = new MMPJ_Ext_Vign_Societe_Contact__c(	MMPJ_Ext_Vign_Contact__c = contact2.Id, MMPJ_Ext_Vign_Societe__c = societe.Id);
        insert societeContact2;
        MMPJ_Ext_Vign_Societe_Contact__c societeContact3 = new MMPJ_Ext_Vign_Societe_Contact__c(	MMPJ_Ext_Vign_Contact__c = contact3.Id, MMPJ_Ext_Vign_Societe__c = societe2.Id);
        insert societeContact3;
        MMPJ_Ext_Vign_Societe_Contact__c societeContact4 = new MMPJ_Ext_Vign_Societe_Contact__c(	MMPJ_Ext_Vign_Contact__c = contact.Id, MMPJ_Ext_Vign_Societe__c = societe2.Id);
        insert societeContact4;
        MMPJ_Ext_Vign_Societe_Contact__c societeContactMypj = new MMPJ_Ext_Vign_Societe_Contact__c(	MMPJ_Ext_Vign_Contact__c = contactMypj.Id, MMPJ_Ext_Vign_Societe__c = societe3.Id);
        insert societeContactMypj;
        List<CampaignMember> vListCamMem = new List<CampaignMember>();
        Campaign campaign = new Campaign(Name = 'CAMPAIGN-' + datetime.now().format('yyyyMMdd'));
        Database.insert(campaign);
        CampaignMember cm = new CampaignMember(ContactId=contact.id,CampaignId=campaign.id);
        vListCamMem.add(cm);

        Campaign vCampaignMypj = new Campaign(Name = 'CAMPAIGNMYPJ-' + datetime.now().format('yyyyMMdd'), RecordtypeId = vMapRtNameId.get(MYPJ_Constants.CAMPAIGN_RT_MYPJ));
        Database.insert(vCampaignMypj);

        CampaignMember vCmMypj = new CampaignMember(ContactId = contact.id, CampaignId = vCampaignMypj.id);
        vListCamMem.add(vCmMypj);

        Database.insert(vListCamMem);
    }

    @isTest static void fetchSocieteContactFinal() {
       
        Id contactId = [SELECT Id FROM Contact WHERE LastName = 'CONTACT 1'].Id;
        Campaign c = [select Id from Campaign Where RecordType.DeveloperName != :MYPJ_Constants.CAMPAIGN_RT_MYPJ];
        List<MMPJ_XRM_LCR02_QuickAddCampaignMembers.contactClass> contacts = MMPJ_XRM_LCR02_QuickAddCampaignMembers.fetchSocieteContactFinal('CONTACT',new List<Id> {contactId}, c.Id);
        System.assertNotEquals(0, contacts.size());
        
    }

    @isTest static void fetchSocieteContactFinalMypj() {
       
        Id contactId = [SELECT Id FROM Contact WHERE LastName = 'CONTACT MYPJ'].Id;
        Campaign c = [select Id from Campaign Where RecordType.DeveloperName = :MYPJ_Constants.CAMPAIGN_RT_MYPJ];
        List<MMPJ_XRM_LCR02_QuickAddCampaignMembers.contactClass> contacts = MMPJ_XRM_LCR02_QuickAddCampaignMembers.fetchSocieteContactFinal('CONTACT',new List<Id> {contactId}, c.Id);
        System.assertNotEquals(0, contacts.size());
        
    }

    @isTest static void addCampaignMemberApex() {
       
        Campaign c = [select Id from Campaign Where RecordType.DeveloperName != :MYPJ_Constants.CAMPAIGN_RT_MYPJ];
        Contact ctc = [select id from Contact where Lastname='CONTACT 3' LIMIT 1];
        MMPJ_Ext_Vign_Societe__c societe = [Select Name FROM MMPJ_Ext_Vign_Societe__c WHERE Name = 'SOCIETE 1' LIMIT 1]; 
        CampaignMember cm = MMPJ_XRM_LCR02_QuickAddCampaignMembers.addCampaignMemberApex(ctc.id, c.Id, true, societe.Id);
        
    }

    @isTest static void isCampMypj() {
        Campaign vCam = [select Id from Campaign Where RecordType.DeveloperName = :MYPJ_Constants.CAMPAIGN_RT_MYPJ];
        Boolean isCampMypj = MMPJ_XRM_LCR02_QuickAddCampaignMembers.isMypjCampaign(vCam.Id);
        System.assert(isCampMypj);
    }

}