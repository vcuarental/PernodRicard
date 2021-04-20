trigger ASI_CRM_JP_Sales_Order_Item_BeforeUpdate on ASI_CRM_JP_Sales_Order_Item__c (before update) {
    User u = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId()];
    
	List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(String.isBlank(u.BypassTriggers__c) || 
       u.BypassTriggers__c.contains('ASI_CRM_JP_SOLineItemSetAvailability') == false) {
    		ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_SOLineItemSetAvailability());
    }
    
    ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_SOLineItemSetSKU());
    
    if(String.isBlank(u.BypassTriggers__c) || 
       u.BypassTriggers__c.contains('ASI_CRM_JP_SOLineItemCalUnitPrice') == false) {
    	ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_SOLineItemCalUnitPrice());
    }
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    } 
}