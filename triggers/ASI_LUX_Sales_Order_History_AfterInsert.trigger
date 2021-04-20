/*********************************************************************************
 * Name:ASI_LUX_Sales_Order_History_AfterInsert
 * Description: Sales Order History Trigger After Insert: Redirection based on record types
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/10/2014       Laputa: Conrad          Created
 * 09/02/2015       Laputa: Conrad          Add SG Recordtype
*********************************************************************************/

trigger ASI_LUX_Sales_Order_History_AfterInsert on ASI_HK_CRM_Sales_Order_History__c (after insert) {

  List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
  
  // Filter recordtype based on LUX HK and TW record types
  if (trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_HK_CRM')
                                               || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')
                                                   || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG'))) {
      triggerClasses.add(new ASI_LUX_CalculateScoreTrigger());
  }
  
  for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
    triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
  }

}