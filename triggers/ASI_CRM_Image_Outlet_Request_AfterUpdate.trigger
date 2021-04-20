trigger ASI_CRM_Image_Outlet_Request_AfterUpdate on ASI_CRM_Image_Outlet_Request__c (after update) {
ASI_CRM_CN_IOMRequest_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
}