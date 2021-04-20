/*********************************************************************************
 * Name: ASI_Luxury_Account_BeforeUpdate
 * Description: Account LUX Trigger Before Update: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/10/2014       Laputa: Conrad          Created
 * 07/11/2014       Laputa: Conrad          Add MY Campaign record type
*********************************************************************************/
trigger ASI_Luxury_Account_BeforeUpdate on Account (before update) {

    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
    List<ASI_BRD_Generic_TriggerAbstract > triggerClassesBrd = new List<ASI_BRD_Generic_TriggerAbstract >();
  
    // Filter recordtype based on LUX record types
    if (trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_HK')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_TW')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_REG')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_Luxury_Account_MY')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_LUX_SG'))) {
        triggerClasses.add(new ASI_LUX_CalculateScoreAccTrigger());
        triggerClassesBrd.add(new ASI_BRD_Generic_AccountAssignRT());
    }
  
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
    for (ASI_BRD_Generic_TriggerAbstract  triggerClass : triggerClassesBrd) {
        triggerClass.executeTriggerAction(ASI_BRD_Generic_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }


}