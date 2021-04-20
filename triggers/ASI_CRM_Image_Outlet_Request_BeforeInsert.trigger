trigger ASI_CRM_Image_Outlet_Request_BeforeInsert on ASI_CRM_Image_Outlet_Request__c (before insert) {
    
	// Added by Michael Yip (Introv) 3May2014 CN CRM 
	list<ASI_CRM_Image_Outlet_Request__c> trigger_new_cn = new list<ASI_CRM_Image_Outlet_Request__c>();
    for(ASI_CRM_Image_Outlet_Request__c iom: trigger.new) {
		if(iom.recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_OFF') ||
		   iom.recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_ON')){
        	trigger_new_cn.add(iom);
        }
	}
	ASI_CRM_CN_IOMRequest_TriggerClass.routineBeforeInsert(trigger_new_cn);
}