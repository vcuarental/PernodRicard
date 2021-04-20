@isTest
private class MMPJ_XRM_LCR01_CM_MassAction_Test {
    
    @testSetup
    public static void initData() {

        
        Account accCognac = new Account(Name='Test');
        insert accCognac;
        
        Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;
        
        Contact con1 = new Contact(LastName='Test1',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
        Contact con2 = new Contact(LastName='Test2',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
        Contact con3 = new Contact(LastName='Test3',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Champagne',RecordTYpeId=rtCon);
        insert new List<Contact>{con1,con2,con3};
            
            Id rtCamp = [select id from RecordType where SObjectType='Campaign' and DeveloperName='MMPJ_Ext_Vign_Campaign' LIMIT 1].Id;
        
        Campaign camp = new Campaign(Name='Test',RecordTYpeId=rtCamp);
        insert camp;
        CampaignMember campM1 = new CampaignMember(ContactId=con1.Id,CampaignId=camp.Id,Status='Sent');
        CampaignMember campM3 = new CampaignMember(ContactId=con3.Id,CampaignId=camp.Id,Status='Sent');
        insert new List<CampaignMember>{campM1,campM3};
            }
    
    @isTest static void testGetCampaignMembersEmpty() {
        List<CampaignMember> campaignMembers = MMPJ_XRM_LCR01_CM_MassAction.getCampaignMembers('000000000000000000');
        System.assertEquals(new List<CampaignMember>(),campaignMembers);
    }
    
    @isTest static void testGetStatusValues() {
        Object o = MMPJ_XRM_LCR01_CM_MassAction.getStatusValues();
        Boolean isStringList = o instanceof List<String>;
        System.assertEquals(true, isStringList);
    }
    //ne passe pas =, assertion fail 
    //we test if return is false with an empty list
    @isTest static void testDeleteCM_Apex_false(){
        System.assertEquals(MMPJ_XRM_LCR01_CM_MassAction.deleteCM_Apex(new List<String>()), false);
    }
    
    @isTest static void testMajPresenceParticipationInvites () {
        CampaignMember cm = getOneCampaignMember();
        String cmId= String.valueOf(cm.Id);
        MMPJ_XRM_LCR01_CM_MassAction.majPresenceParticipationInvites(new List<String>{cm.Id}, 'Envoyée', 'Venu', 'Accepté','1','Commentaire');
        cm = getOneCampaignMember();
        //System.assertEquals(cm.Status+cm.MMPJ_Ext_Vign_Presence__c+cm.MMPJ_Ext_Vign_Participation__c, 'EnvoyéeVenuAccepté');
    } 
    
    //we test if return is false with an empty list
    @isTest static void testMajPresenceParticipationInvitesFalse () {
        System.assertEquals(MMPJ_XRM_LCR01_CM_MassAction.majPresenceParticipationInvites(new List<String>(), '', '', '','',''), false);
    }
    
    //get all campaignMembers number
    private static Integer nbCMTotal(){
        List<CampaignMember> lcm = [select Id from CampaignMember];
        return lcm.size();
    }
    
    //get one campaignMemberId
    private static String getOneCampaignMemberId(){
        return String.valueOf(getOneCampaignMember().Id);
    }
    
    //get one campaignMember
    private static CampaignMember getOneCampaignMember(){
        List<CampaignMember> CM= [select Id,Status,MMPJ_Ext_Vign_Presence__c,MMPJ_Ext_Vign_Participation__c from CampaignMember LIMIT 1];
        return CM[0];
    }
    
    @isTest static void testDeleteCM_Apex(){

        Campaign camp = [SELECT id, Name FROM Campaign WHERE Name = 'Test' LIMIT 1]; 
        CampaignMember cm = [SELECT Id, CampaignId FROM CampaignMember WHERE CampaignId =:camp.Id LIMIT 1];
        List<String> listeCMToDelete = new List<String>();
        listeCMToDelete.add((String)cm.Id);
        Boolean supprime = MMPJ_XRM_LCR01_CM_MassAction.deleteCM_Apex(listeCMToDelete);
        
        System.assertEquals(true ,supprime);
    }

    @isTest static void testgetRecordTypeMYPJCampaign() {

        Campaign camp = [SELECT id, Name FROM Campaign WHERE Name = 'Test' LIMIT 1];
        Object o = MMPJ_XRM_LCR01_CM_MassAction.getRecordTypeMYPJCampaign(camp.Id);
        Boolean isBoolean = o instanceof Boolean;
        System.assertEquals(true, isBoolean);
    }
    
}