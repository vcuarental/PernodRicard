trigger MYPJ_CampaignMember_Trigger on CampaignMember (after insert, after update) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

        Id rtId = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('MYPJ').getRecordTypeId();

        List<RecordType> vListRts = [Select Id 
                                        From RecordType 
                                        Where SobjectType = 'CampaignMember'
                                        AND DeveloperName = :MYPJ_Constants.CAMPAIGNMEM_RT_MYPJ];
        
        Map<Id,Contact> mapContact = new Map<Id,Contact>();
        // for (CampaignMember member : [SELECT ContactId FROM CampaignMember WHERE Id IN :Trigger.new AND RecordTypeId = :rtId]) {
        for (CampaignMember member : [SELECT ContactId FROM CampaignMember WHERE Id IN :Trigger.new AND RecordTypeId = :vListRts[0].Id]) {

            mapContact.put(member.ContactId, new Contact(Id = member.ContactId));
        }

        update mapContact.values();
    }
}