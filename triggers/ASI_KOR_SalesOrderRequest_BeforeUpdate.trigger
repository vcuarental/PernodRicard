trigger ASI_KOR_SalesOrderRequest_BeforeUpdate on ASI_KOR_Sales_Order_Request__c (before update) {
    
    List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
        new ASI_KOR_SalesOrderRequestEDIAutoNumGen()
    };
    
    for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClassesSG = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_SO_Increment_Rev()        
        };
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Wholesaler') 
			|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_TBCN') 
				|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_CA') 
					|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_IN') 
						|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_LA') 
							|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_MM') 
								|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_MY') 
									|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_PH') 
										|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_VI') 
											|| Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_VIDF')) {
            triggerClassesSG.add(new ASI_CRM_SG_PopulateCustomer());
        }       

        for (ASI_CRM_SG_TriggerAbstract triggerClassSG : triggerClassesSG) {
            triggerClassSG.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    // CN CRM
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_SalesOrderTriggerClass.beforeUpdateMethod(trigger.new, trigger.oldMap);
    }
}