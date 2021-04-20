/*
 * Trigger : à la création d'une campagne de type MMPJ Extranet Vigneron Viticulteur, les status des membres de campagne sont ceux définis dans la metadata Status_Campain_Members__mdt
 */
trigger MMPJ_XRM_defautCampaignStatusTrigger on Campaign (before insert, after insert) {
    Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Campaign.getRecordTypeInfosById();
    if (Trigger.isBefore && Trigger.isInsert) {
        Map<Id, Schema.RecordTypeInfo> campaignMembersRecordTypes = Schema.SObjectType.CampaignMember.getRecordTypeInfosById();
        Id validRecordTypeId = null;
        for (Id rtId : campaignMembersRecordTypes.keySet()) {
            Schema.RecordTypeInfo rtInfo = campaignMembersRecordTypes.get(rtId);
            if (rtInfo.getDeveloperName() == 'MMPJ_Ext_Vign_CampaignMember') {
                validRecordTypeId = rtId;
                break;
            }
        }

        for (Campaign c: trigger.new){
            String type = rtMap.get(c.RecordTypeId).getName();
            System.debug(LoggingLevel.DEBUG, type);
            if (type != 'MMPJ Extranet Vigneron Viticulteur') {
                continue;
            }
            c.CampaignMemberRecordTypeId = validRecordTypeId;
        }
    } else
    if (Trigger.isAfter && Trigger.isInsert) {
        Map<Id, Campaign> mapOfValidCampaigns = new Map<Id, Campaign>();
        for (Campaign c: trigger.new){
            String type = rtMap.get(c.RecordTypeId).getName();
            System.debug(LoggingLevel.DEBUG, type);
            if (type != 'MMPJ Extranet Vigneron Viticulteur' || !c.isClone()) {
                // ignore this campaign
                continue;
            }

            mapOfValidCampaigns.put(c.Id, c);
        }

        if (mapOfValidCampaigns.isEmpty()) {
            // No valid campaigns
            return;
        }

        Integer orderItem = 3;
        //List des status à insérer
        List<CampaignMemberStatus> insertStatus = new List<CampaignMemberStatus>();
        Map<String,CampaignMemberStatus> existStatus = new Map<String,CampaignMemberStatus>();
        System.debug(LoggingLevel.DEBUG, 'DefautCampagin');

        List<MMPJ_XRM_Status_Campain_Members__mdt> statusItems = [SELECT MasterLabel, MMPJ_XRM_Isdefaut__c, MMPJ_XRM_Responded__c FROM MMPJ_XRM_Status_Campain_Members__mdt];
        Map<Id, List<CampaignMemberStatus>> mapOfCampaignMembersByCampaignId = new Map<Id, List<CampaignMemberStatus>>();

        for (CampaignMemberStatus CMS : [SELECT Id, CampaignId, Label FROM CampaignMemberStatus WHERE CampaignId IN :mapOfValidCampaigns.keyset()]) {
            List<CampaignMemberStatus> memberStatuses = mapOfCampaignMembersByCampaignId.get(CMS.CampaignId);
            if (memberStatuses == null) {
                mapOfCampaignMembersByCampaignId.put(CMS.CampaignId, new List<CampaignMemberStatus> { CMS });
                continue;
            }
            memberStatuses.add(CMS);
        }

        List<CampaignMemberStatus> campaignMemberStatusesToDelete = new List<CampaignMemberStatus>();

        for (Campaign c: mapOfValidCampaigns.values()) {
            existStatus.clear();
            List<CampaignMemberStatus> memberStatuses = mapOfCampaignMembersByCampaignId.get(c.Id);
            if (memberStatuses != null) {
                for(CampaignMemberStatus CMS : memberStatuses) {
                    //on ajoute pour la suppression les status existants
                    existStatus.put(CMS.Label, CMS);
                    System.debug(LoggingLevel.DEBUG, 'Put : '+CMS);
                    campaignMemberStatusesToDelete.add(CMS);
                    //On incrémente l'ordre pour insérer après les status existants
                    orderItem++;
                }
            }

            for(MMPJ_XRM_Status_Campain_Members__mdt statusItem : statusItems){
                if (!existStatus.containsKey(statusItem.MasterLabel)) {
                    //On ajoute les status de Metadata pour insertion (s'il n'existe pas en tant que status par défaut)
                    CampaignMemberStatus cmsLoop = new CampaignMemberStatus(
                        CampaignId = c.Id,
                        Label = statusItem.MasterLabel,
                        SortOrder = orderItem,
                        isDefault = Boolean.ValueOf(statusItem.MMPJ_XRM_IsDefaut__c),
                        HasResponded = Boolean.valueOf(statusItem.MMPJ_XRM_Responded__c)
                    );
                    insertStatus.add(cmsLoop);
                    System.debug(LoggingLevel.DEBUG, 'Loop : '+cmsLoop);
                    orderItem++;
                }
            }
        }
        if (!insertStatus.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'insertStatus : ' + insertStatus);
            // Insertion des status définies dans la metadata
            insert insertStatus;
        }

        if (!campaignMemberStatusesToDelete.isEmpty()) {
            //Suppression des status existant (par défaut)
            delete campaignMemberStatusesToDelete;
        }
    }
}