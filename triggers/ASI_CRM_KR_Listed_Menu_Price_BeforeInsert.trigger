trigger ASI_CRM_KR_Listed_Menu_Price_BeforeInsert on ASI_CRM_KR_Listed_Menu_Price__c (before insert) {
	ASI_CRM_KR_ListedMenuPrice_TriggerClass.routineBeforeInsert(trigger.new);   
}