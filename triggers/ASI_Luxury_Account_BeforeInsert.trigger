/*********************************************************************************
 * Name: ASI_Luxury_Account_BeforeInsert
 * Description: Account LUX Trigger Before Insert: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/10/2014       Laputa: Conrad          Created
 * 07/11/2014       Laputa: Conrad          Add MY Campaign record type
*********************************************************************************/
trigger ASI_Luxury_Account_BeforeInsert on Account (before insert) {

    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
  
    // Filter recordtype based on LUX record types
    if (trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_HK')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_TW')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_REG')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_MY')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_LUX_SG'))) {
        triggerClasses.add(new ASI_LUX_CalculateScoreAccTrigger());
    }
  
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
    }

}