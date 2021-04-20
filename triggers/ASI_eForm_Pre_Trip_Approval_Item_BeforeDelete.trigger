trigger ASI_eForm_Pre_Trip_Approval_Item_BeforeDelete on ASI_eForm_Pre_Trip_Approval_Item__c (before delete) {
    ASI_eForm_GenericTriggerClass.validateDetailStatus(Trigger.oldMap.values(), 'ASI_eForm_Pre_Trip_Approval__c', 
         'ASI_eForm_Status__c', 'ASI_eForm_Pre_Trip_Approval__c', new Set<String>{'Complete','Final'},null);
}