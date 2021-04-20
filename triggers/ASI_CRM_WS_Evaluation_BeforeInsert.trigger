trigger ASI_CRM_WS_Evaluation_BeforeInsert on ASI_CRM_WS_Evaluation__c (before insert,before update) {

    // lokman 4/5/2014
    //if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_WS_Evaluation__cASI_CRM_OFF') ||
     //   trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_WS_Evaluation__cASI_CRM_ON')){
        ASI_CRM_WS_Evaluation_TriggerClass.routineBeforeInsert(Trigger.new);
    //}

}