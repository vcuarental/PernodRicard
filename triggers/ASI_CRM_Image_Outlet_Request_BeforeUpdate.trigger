trigger ASI_CRM_Image_Outlet_Request_BeforeUpdate on ASI_CRM_Image_Outlet_Request__c (before update) {
    ASI_CRM_CN_IOMRequest_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
}