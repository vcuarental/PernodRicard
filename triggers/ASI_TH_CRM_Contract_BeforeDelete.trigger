/*
  Test: ASI_CRM_MO_Contract_TEST
        ASI_CRM_PH_Contract_TriggerClass_Test
        ASI_CRM_SG_ContractAfterInsertTest
*/
trigger ASI_TH_CRM_Contract_BeforeDelete on ASI_TH_CRM_Contract__c (before delete) {  
    if(trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')){
        ASI_CRM_CN_Contract_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if(trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract_Read_Only')){
        ASI_CRM_PH_Contract_TriggerClass.routineBeforeDelete(trigger.old);
    }
    
    if(trigger.old[0].recordTypeId != NULL){
        if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_MY')){
            ASI_CRM_MY_Contract_TriggerClass.routineBeforeDelete(trigger.old);
        }
        if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_MO')){
            ASI_CRM_MO_ContractCost_TriggerCls.routineBeforeDelete(trigger.old);
        }
        if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_SG')){
            ASI_CRM_SG_Contract_TriggerClass.routineBeforeDelete(trigger.old);
        }
         if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_KH')){
            ASI_CRM_KH_Contract_TriggerClass.routineBeforeDelete(trigger.old);
        }
    }
}