/*Filename:     ASI_TH_CRM_PaymentStatus_BeforeUpsert  
* Author:       Twinkle LI (Introv Limited)
* Created Date: 07/28/2016
*/

trigger ASI_TH_CRM_PaymentStatus_BeforeUpsert on ASI_TH_CRM_Payment_Status__c (before update, before insert) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Payment_Status__cASI_TH_CRM_Payment_Status')){
           ASI_TH_CRM_PaymentStatus_TriggerCls.routineBeforeUpsert(trigger.new, NULL);
   }  
}