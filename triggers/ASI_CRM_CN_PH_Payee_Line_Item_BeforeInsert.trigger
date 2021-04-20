trigger ASI_CRM_CN_PH_Payee_Line_Item_BeforeInsert on ASI_CRM_CN_PH_Payee_Line_Item__c (before insert) {
if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_Payee')){
       ASI_CRM_CN_Payee_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);   
   }
}