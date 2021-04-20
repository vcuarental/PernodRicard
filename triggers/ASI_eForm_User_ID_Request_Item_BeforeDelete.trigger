trigger ASI_eForm_User_ID_Request_Item_BeforeDelete on ASI_eForm_User_ID_Request_Item__c (before delete) {
ASI_eForm_GenericTriggerClass.validateDetailStatus(Trigger.oldMap.values(), 'ASI_eForm_User_ID_Request__c', 
         'ASI_eForm_Status__c', 'ASI_eForm_User_ID_Request__c', new Set<String>{'Complete','Final'},'ASI_eForm_IT_Action__c');
}