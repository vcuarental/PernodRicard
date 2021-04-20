/*********************************************************************************
 * Name: ASI_Luxury_CampaignMember_BeforeDelete
 * Description: CampaignMember LUX Trigger before delete: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/10/2014       Laputa: Conrad          Created
*********************************************************************************/
trigger ASI_Luxury_CampaignMember_BeforeDelete on CampaignMember (before delete) {


    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
  
    // Filter recordtype based on LUX record types
    if ((trigger.old[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_LUX_HK_Campaign_Member')|| 
                                                 Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_LUX_Regional_Campaign_Member')|| Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_BRD_SG_Campaign_Member')))) {
        triggerClasses.add(new ASI_LUX_JP_CampaignMember_DeleteAction());
    }
  
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, trigger.oldmap, null);
    }

}