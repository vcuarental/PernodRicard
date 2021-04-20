trigger ASI_TH_CRM_Contract_AfterUpdate on ASI_TH_CRM_Contract__c (after update) {
   // Modified by Michael Yip (Introv) 26Apr2014 Separate trigger class by recordtype, assume same record type for all records in trigger.new 
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract')){
        ASI_TH_CRM_Contract_TriggerClass.routineAfterAll(trigger.newMap, trigger.oldMap);
    }
    else if(trigger.old[0].recordtypeid != null && Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).developerName.contains('ASI_CRM_SG')){
        //ASI_TH_CRM_Contract_TriggerClass.routineAfterAll(trigger.newMap, trigger.oldMap);
        // Added by Hugo Cheung (Laputa) 23May2016 for updating contract sku price
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
        	new ASI_CRM_SG_Update_ContractSKUPrice(), 
            //new ASI_CRM_SG_RevisedContract_Handler()
            new ASI_CRM_SG_RevisedContract_Approve(),
            new ASI_CRM_SG_UpdateContractTargetByType()
        };
        
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
        	triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newmap, trigger.oldmap);
        }
		
		ASI_CRM_SG_RevisedContract_Approve.relinkOfftakeToContract(trigger.new, trigger.newMap, trigger.oldMap);
    }
	
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')){
         if(trigger.new[0].ASI_TH_CRM_Promotion_Type__c== 'Heavy Contract On' ){ 
             ASI_CRM_CN_HeavyContract_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
         }ELSE{
             ASI_CRM_CN_Contract_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
         }
        
    }
	else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
			|| trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract_Read_Only')
           ){ // laputa:calvin && Vincent
    	ASI_CRM_PH_Contract_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }   
    
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract')){
        ASI_CRM_MO_Contract_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
}