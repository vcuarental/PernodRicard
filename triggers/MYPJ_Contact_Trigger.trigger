trigger MYPJ_Contact_Trigger on Contact (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {

        Id rtIdCampMember = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('MYPJ').getRecordTypeId();
        Id rtIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MYPJ_Contact').getRecordTypeId();

        List<RecordType> vListRts = [Select Id, DeveloperName 
                                        From RecordType 
                                        Where SobjectType IN ('Contact', 'CampaignMember')
                                        AND DeveloperName IN (:MYPJ_Constants.CONTACT_RT_MYPJ, :MYPJ_Constants.CAMPAIGNMEM_RT_MYPJ)];

        Map<String, Id> vMapRtNameId = new Map<String, Id>();
        for(RecordType vRt : vListRts){
            vMapRtNameId.put(vRt.DeveloperName, vRt.Id);
        }

        Map<Id,Integer> mapContactCampaignMember = new Map<Id,Integer>();
        for (AggregateResult ar : [SELECT ContactId, COUNT(Id) Nb 
                                    FROM CampaignMember 
                                    WHERE 
                                    RecordTypeId = :vMapRtNameId.get(MYPJ_Constants.CAMPAIGNMEM_RT_MYPJ)
                                    AND 
                                    ContactId In :Trigger.new GROUP BY ContactId]) {

            mapContactCampaignMember.put((Id)ar.get('ContactId'), (Integer)ar.get('Nb'));
        }

        for (Contact contact : [SELECT Id FROM Contact WHERE Id IN :Trigger.new AND RecordTypeId = :vMapRtNameId.get(MYPJ_Constants.CONTACT_RT_MYPJ)]) {

            Integer nbMember = mapContactCampaignMember.get(contact.Id);
            // contact.MYPJ_Total_events_participation__c = (nbMember != null ? nbMember : 0);
            Trigger.newMap.get(contact.Id).MYPJ_Total_events_participation__c = (nbMember != null ? nbMember : 0);
        }
    }
}