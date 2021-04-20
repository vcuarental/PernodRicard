public with sharing class MMPJ_XRM_LCR04_CheckIn {

    /**
    * fetch all campaigns in progress or starting today or starting the days after todays. 
     */
    @AuraEnabled
    public static List <Campaign> fetchCampaigns(String searchKeyWord) {
        String searchKey = '%' + searchKeyWord + '%';  


        return [
            SELECT
                Id,
                Name,
                Owner.Name,
                StartDate,
                EndDate,
                MMPJ_Ext_Vign_Cible__c
            FROM Campaign
            WHERE Name LIKE :searchKey AND (StartDate >= TODAY OR EndDate >= TODAY)
            ORDER BY Name DESC LIMIT 100 
        ]; 
    }

    @AuraEnabled
    public static Campaign fetchCampaignInfos(String campaignId) {
        return [
            SELECT
                Id,
                Name,
                StartDate,
                (
                    SELECT
                        Id,
                        FirstName,
                        LastName,
                        Status,
                        MMPJ_Ext_Vign_Presence__c,
                        MMPJ_Ext_Vign_Participation__c,
                        ContactId,
                        MMPJ_XRM_Code_Spirit__c,
                        MMPJ_XRM_Responsable_Societe__c,
                        MMPJ_Ext_Accompagnants__c,
                        Contact.MMPJ_Ext_Vign_Telephone_portable_perso__c, 
                        Contact.MMPJ_Ext_Vign_Telephone_fixe__c, 
                        MMPJ_XRM_Societe__r.Name
                    FROM CampaignMembers
                    ORDER BY MMPJ_Ext_Vign_Presence__c ASC 
                )
            FROM Campaign
            WHERE Id = :campaignId
        ];
    }
    //récupérer la liste des sociétés à partir de l'id de la société 
    @AuraEnabled
    public static List<MMPJ_Ext_Vign_Societe__c> getCompanyInfos(List<String> societIds){
        return [SELECT id, Name FROM MMPJ_Ext_Vign_Societe__c WHERE id IN :societIds]; 
    }


    @AuraEnabled
    public static List<MMPJ_Ext_Vign_Societe_Contact__c> fetchSocietesInfos(List<String> contactIds) {
        return [
            SELECT
                Id,
                MMPJ_Ext_Vign_Contact__c,
                MMPJ_Ext_Vign_Societe__r.Name,
                MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_SOCIETE_Spirit__c,
                MMPJ_Ext_Vign_Societe__r.Owner.Name,
                MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c
            FROM MMPJ_Ext_Vign_Societe_Contact__c
            WHERE MMPJ_Ext_Vign_Contact__c IN :contactIds
        ];
    }

    @AuraEnabled
    public static void updateCampaignMember(String campaignMemberId, Boolean campaignMemberIsHere) {
       
        CampaignMember campaignMemberToUpdate = new CampaignMember (Id = campaignMemberId,
                                                                    Status = 'Répondue');
        if(campaignMemberIsHere){
            campaignMemberToUpdate.MMPJ_Ext_Vign_Presence__c = 'Venu'; 
        } else {
             campaignMemberToUpdate.MMPJ_Ext_Vign_Presence__c = 'Non venu'; 
        }
       
        update campaignMemberToUpdate;
    }
    /***
    * lorsqu'il y a modification du nombre d'accompagnants dans le composant, on met à jour le champ : 
        MMPJ_Ext_Accompagnants__c
     */
    @AuraEnabled
    public static void updateCampaignMemberAccompNumber(List<CampaignMember> campaignMemb){
        update campaignMemb;
    }
    /*mise à jour du nombre d'accompagnant du campaign member
    @AuraEnabled
    public static void updateNumberOfparticipants(String campaignmembId,Integer accompagnant){
        CampaignMember campmember = [SELECT Id, MMPJ_Ext_Accompagnants__c FROM CampaignMember WHERE Id = :campaignmembId]; 
        if(accompagnant != null){
            campmember.MMPJ_Ext_Accompagnants__c = accompagnant;
        }
        update campmember;

    }*/


}