trigger ASI_CRM_ContractTarget_BeforeUpdate on ASI_CRM_ContractTarget__c (before update){
    List<ASI_CRM_ContractTarget__c> l_MY_ContractTarget = new List<ASI_CRM_ContractTarget__c>();
	List<ASI_CRM_ContractTarget__c> l_PH_ContractTarget = new List<ASI_CRM_ContractTarget__c>();
    
    /*
    if(trigger.new[0].recordTypeId != NULL && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_MY')){
        ASI_CRM_MY_ContractTarget_TriggerCls.routineBeforeUpsert(trigger.new);
    }  
	*/
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target')){
        ASI_CRM_SG_ContractTarget_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
    }
    
    for(ASI_CRM_ContractTarget__c c: Trigger.New){
		if (c.recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget')){
			l_MY_ContractTarget.add(c);
		}
		else if(c.recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')){
            l_PH_ContractTarget.add(c);
        }
	}
    
    if(l_MY_ContractTarget.size()>0){
		ASI_CRM_MY_ContractTarget_TriggerCls.routineBeforeUpsert(l_MY_ContractTarget);
	}
    
	if(l_PH_ContractTarget.size()>0){
        ASI_CRM_PH_ContractTarget_TriggerClass.routineBeforeUpsert(l_PH_ContractTarget, trigger.oldMap);
    }    
}