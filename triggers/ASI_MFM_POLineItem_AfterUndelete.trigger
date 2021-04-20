trigger ASI_MFM_POLineItem_AfterUndelete on ASI_MFM_PO_Line_Item__c (after undelete) {
	List<ASI_MFM_PO_Line_Item__c> cnPoLineList = new List<ASI_MFM_PO_Line_Item__c>();
    for(ASI_MFM_PO_Line_Item__c poline : trigger.new) {
        if(Global_RecordTypeCache.getRt(poline.recordTypeId).developerName.contains('ASI_MFM_CN')
          ||Global_RecordTypeCache.getRt(poline.recordTypeId).developerName.contains('ASI_MFM_CAP_CN')) {
            cnPoLineList.add(poline);
        }
    }
    if(cnPoLineList.size()>0) ASI_MFM_CN_POLine_SetPlan_TriggerClass.routineAfterDelete(trigger.new);
}