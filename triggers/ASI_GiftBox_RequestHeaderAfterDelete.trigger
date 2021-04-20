trigger ASI_GiftBox_RequestHeaderAfterDelete on ASI_GiftBox_Request_Header__c (after delete) {
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_VN_CS'))
    {
        new ASI_CRM_VN_CSRequest_UnlinkActualOfftake().executeTrigger(Trigger.oldMap);
    }
}