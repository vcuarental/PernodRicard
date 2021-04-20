trigger ASI_eForm_Pre_Trip_Approval_BeforeDelete on ASI_eForm_Pre_Trip_Approval__c (before delete) {
 ASI_eForm_GenericTriggerClass.validateHeaderStatus(Trigger.oldMap.values(),'ASI_eForm_Status__c', new Set<String>{'Complete','Final'});
}