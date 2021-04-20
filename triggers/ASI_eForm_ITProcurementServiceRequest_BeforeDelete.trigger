trigger ASI_eForm_ITProcurementServiceRequest_BeforeDelete on ASI_eForm_IT_Procurement_Service_Request__c (before delete) {
    ASI_eForm_GenericTriggerClass.validateHeaderStatus(Trigger.oldMap.values(),'ASI_eForm_Status__c', new Set<String>{'Complete','Final'});
}