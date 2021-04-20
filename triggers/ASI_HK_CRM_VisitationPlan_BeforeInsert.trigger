trigger ASI_HK_CRM_VisitationPlan_BeforeInsert on ASI_HK_CRM_Visitation_Plan__c (before insert) {
  if (trigger.new[0].recordtypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Visitation_Plan')) ){
        ASI_CRM_VN_VisitationPlan_TriggerClass.routineBeforeInsert(trigger.new);
    }
}