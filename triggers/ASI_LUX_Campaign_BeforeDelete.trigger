/*********************************************************************************
 * Name:ASI_LUX_Campaign_beforeDelete
 * Description: Campaign Trigger before DELETE: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/03/2015       Laputa: Conrad          Created
*********************************************************************************/

trigger ASI_LUX_Campaign_BeforeDelete on Campaign (before delete) {
    
  List<ASI_LUX_TriggerAbstract> triggerClasses = new List<ASI_LUX_TriggerAbstract>();
  
  // Filter recordtype based on LUX JP Campaign record types for specific logics
  if (trigger.old[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_LUX_JP_Campaign')
          || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_BRD_SG')
              || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_LUX_SG')
      )) {
        triggerClasses.add(new ASI_LUX_CampaignDelete_EventsCalc());
  }
  
  for (ASI_LUX_TriggerAbstract triggerClass : triggerClasses) {
    triggerClass.executeTriggerAction(ASI_LUX_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, null);
  }
    
}