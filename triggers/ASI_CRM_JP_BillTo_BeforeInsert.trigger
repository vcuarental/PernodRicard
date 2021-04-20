trigger ASI_CRM_JP_BillTo_BeforeInsert on ASI_CRM_Bill_To__c (before insert) {
	List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {
    	new ASI_CRM_JP_BillToAutoNumber()
  	};             
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    } 
}