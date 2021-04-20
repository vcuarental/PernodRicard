trigger ASI_CRM_Image_Outlet_Request_BeforeDelete on ASI_CRM_Image_Outlet_Request__c (before delete) {
	// Added by KF Leung (Introv) 4May2014 CN CRM 
	list<ASI_CRM_Image_Outlet_Request__c> trigger_new_cn = new list<ASI_CRM_Image_Outlet_Request__c>();
    for(ASI_CRM_Image_Outlet_Request__c iom: trigger.old) {
		if(iom.recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_OFF') ||
		   iom.recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_ON')){
        	trigger_new_cn.add(iom);
        }
	}
	ASI_CRM_CN_IOMRequest_TriggerClass.routineBeforeDelete(trigger_new_cn);
}