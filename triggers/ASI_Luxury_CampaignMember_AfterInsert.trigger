/*********************************************************************************
 * Name: ASI_Luxury_CampaignMember_AfterInsert
 * Description: CampaignMember LUX Trigger after Insert: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/10/2014       Laputa: Conrad          Created
*********************************************************************************/
trigger ASI_Luxury_CampaignMember_AfterInsert on CampaignMember (after insert) {


    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
  
    // Filter recordtype based on LUX record types
    if (trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_LUX_HK_Campaign_Member')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_LUX_Regional_Campaign_Member')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_BRD_SG_Campaign_Member'))) {
        triggerClasses.add(new ASI_LUX_CalculateSegmentationTrigger());
        triggerClasses.add(new ASI_LUX_JP_CalcAttendedEvents());
        triggerClasses.add(new ASI_LUX_JP_CampaignContribution_Member());
    }
  
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
    }

}