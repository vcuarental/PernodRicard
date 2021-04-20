trigger ASI_TH_CRM_Contract_AfterInsert on ASI_TH_CRM_Contract__c (after insert) {
    // Modified by Michael Yip (Introv) 26Apr2014 Separate trigger class by recordtype, assume same record type for all records in trigger.new 
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract')){
        ASI_TH_CRM_Contract_TriggerClass.routineAfterAll(trigger.newMap, trigger.oldMap);
    } 
	else if(trigger.new[0].recordtypeid != null && Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).developerName.contains('ASI_CRM_SG')){
        //ASI_TH_CRM_Contract_TriggerClass.routineAfterAll(trigger.newMap, trigger.oldMap);
        // Added by Hugo Cheung (Laputa) 23May2016 for updating contract sku price
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
        	new ASI_CRM_SG_Update_ContractSKUPrice()
        };
        
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
        	triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newmap, null);
        }
	
        ASI_CRM_SG_ContractAfterInsertHandler.executeTrigger(trigger.new);    

		ASI_CRM_SG_RevisedContract_Approve.relinkOfftakeToContract(trigger.new, trigger.newMap, null);
    }
	
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')){
        if(trigger.new[0].ASI_TH_CRM_Promotion_Type__c== 'Heavy Contract On' ){
            ASI_CRM_CN_HeavyContract_TriggerClass.routineAfterInsert(trigger.new);
        } else if (Trigger.new[0].ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract') {
            ASI_CRM_CN_HeavyContractOff_TriggerClass.routineAfterInsert(Trigger.new);
        }
		else{
            ASI_CRM_CN_Contract_TriggerClass.routineAfterInsert(trigger.new);
            ASI_CRM_CN_Contract_TriggerClass.routineAfterAll(trigger.new, null);
        }
    }
	else if( trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract') ){
        ASI_CRM_CN_HeavyLocalContract_TriggerCls.routineAfterInsert(trigger.new);
    }
}