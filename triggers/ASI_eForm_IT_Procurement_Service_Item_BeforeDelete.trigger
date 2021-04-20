trigger ASI_eForm_IT_Procurement_Service_Item_BeforeDelete on ASI_eForm_IT_Procurement_Service_Item__c (before delete) {
    ASI_eForm_GenericTriggerClass.validateDetailStatus(Trigger.oldMap.values(), 'ASI_eForm_IT_Procurement_Service_Request__c', 
         'ASI_eForm_Status__c', 'ASI_eForm_IT_Procurement_Service_Request__c', new Set<String>{'Complete','Final'},'ASI_eForm_IT_Action__c');
}