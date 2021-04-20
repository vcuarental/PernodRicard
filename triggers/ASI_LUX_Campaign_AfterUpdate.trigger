/*********************************************************************************
 * Name:ASI_LUX_Campaign_AfterUpdate
 * Description: Campaign Trigger After Update: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/10/2014       Laputa: Conrad          Created
*********************************************************************************/

trigger ASI_LUX_Campaign_AfterUpdate on Campaign (after update) {
    
  List<ASI_LUX_TriggerAbstract> triggerClasses = new List<ASI_LUX_TriggerAbstract>();
  
  // Filter recordtype based on LUX JP Campaign record types for specific logics
  if (trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_LUX_JP_Campaign')
          || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_BRD_SG')
      )) {
        triggerClasses.add(new ASI_LUX_JP_Generate_CampaignContribution());
  }
  
  for (ASI_LUX_TriggerAbstract triggerClass : triggerClasses) {
    triggerClass.executeTriggerAction(ASI_LUX_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
  }
    
}