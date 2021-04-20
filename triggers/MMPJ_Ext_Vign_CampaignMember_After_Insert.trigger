trigger MMPJ_Ext_Vign_CampaignMember_After_Insert on CampaignMember (after insert) {
    Id mmpjRecordTypeId = [select Id from RecordType where sObjectType='Campaign' and DeveloperName='MMPJ_Ext_Vign_Campaign' LIMIT 1].id;

    List<CampaignMember> members = new List<CampaignMember>();
    for(CampaignMember m:trigger.new)
        if(m.MMPJ_Ext_Vign_Campaign_Record_Type__c == mmpjRecordTypeId)
            members.add(m);

    if(members.size() > 0)
        MMPJ_Ext_Vign_Notifications.createCampaignMeberNotification(members);
}