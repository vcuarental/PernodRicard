/*********************************************************************************
 * Name: ASI_Luxury_CampaignMember_AfterDelete
 * Description: CampaignMember LUX Trigger After delete: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/10/2014       Laputa: Conrad          Created
*********************************************************************************/
trigger ASI_Luxury_CampaignMember_AfterDelete on CampaignMember (after delete) {


    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
  
    // Filter recordtype based on LUX record types
    if (trigger.old[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_LUX_HK_Campaign_Member')|| Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_LUX_Regional_Campaign_Member')|| Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_BRD_SG_Campaign_Member'))) {
        triggerClasses.add(new ASI_LUX_JP_CalcAttendedEvents());
        triggerClasses.add(new ASI_LUX_CalculateSegmentationTrigger());
    }
  
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.After_DELETE, trigger.old, trigger.oldmap, null);
    }

}