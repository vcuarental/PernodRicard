trigger MMPJ_Ext_Vign_ContentDocumentLinkAfterInsert on ContentDocumentLink (after insert) {
    System.debug(LoggingLevel.DEBUG, '>>> Trigger contentDocumentLinkAfterInsert');
	
    // Set<Id> setCampRt = Global_RecordTypeCache.getRtIdSet('Campaign',new set<String>{'MMPJ_Ext_Vign_Campaign'});
    List<String> objIdLst = new List<String>();
    for(ContentDocumentLink l:trigger.new){
    	objIdLst.add(l.LinkedEntityId);
    }
    
    Map<ID, Campaign> processCampaign = new Map<ID, Campaign>();    
    for(Campaign cmp : [Select id,recordtypeId from Campaign where id =: objIdLst]){
        processCampaign.put(cmp.id, cmp);
    }
    Map<Id, MMPJ_Ext_Vign_Documents_Fournis__c> processDoc = new Map<Id, MMPJ_Ext_Vign_Documents_Fournis__c>();    
    for(MMPJ_Ext_Vign_Documents_Fournis__c doc : [SELECT Id, RecordTypeId FROM MMPJ_Ext_Vign_Documents_Fournis__c WHERE Id = :objIdLst]){
        processDoc.put(doc.id, doc);
    }
    
    String sObjectName = null;
    Schema.SObjectType campaignSObjType = Campaign.getSObjectType();
    Schema.SObjectType documentFourniSObjType = MMPJ_Ext_Vign_Documents_Fournis__c.getSObjectType();
    Schema.SObjectType currentLinkedSObjType = null;
    Id rtIdDoc = Schema.SObjectType.MMPJ_Ext_Vign_Documents_Fournis__c.getRecordTypeInfosByDeveloperName().get('MMPJ_XRM_Document_Salesforce').getRecordTypeId();
    Id rtIdCamp = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Campaign').getRecordTypeId();
    Map<Id, Id> mapOfContentDocumentIdsWithEntityIds = new Map<Id, Id>();
    for(ContentDocumentLink l:trigger.new)
    {
        System.debug(LoggingLevel.DEBUG, 'ContentDocumentLink : ' + l);
        currentLinkedSObjType = l.LinkedEntityId.getSObjectType();
        sObjectName = currentLinkedSObjType.getDescribe().getName();
        System.debug(LoggingLevel.DEBUG, 'FileSharing : sObjectName: ' + sObjectName);
        // if(currentLinkedSObjType != campaignSObjType || !setCampRt.contains(processCampaign.get(l.LinkedEntityId).recordTypeId)) {
        if ((currentLinkedSObjType != campaignSObjType || processCampaign.get(l.LinkedEntityId).recordTypeId != rtIdCamp)
            && (currentLinkedSObjType != documentFourniSObjType || processDoc.get(l.LinkedEntityId).recordTypeId != rtIdDoc)) {
            // Not covered
            continue;
        }

        mapOfContentDocumentIdsWithEntityIds.put(l.ContentDocumentId, l.LinkedEntityId);
    }
    
    if(mapOfContentDocumentIdsWithEntityIds.size() != 0){
    	MMPJ_Ext_Vign_FileSharing.insertDocuments(mapOfContentDocumentIdsWithEntityIds);
    }
}