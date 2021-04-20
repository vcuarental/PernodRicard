trigger ASI_CTY_CN_Vendor_Purchase_Line_AfterUpdate on ASI_MFM_Purchase_Request_Line__c(after update) {
    if (trigger.new[0].recordTypeid != null){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CN_Vendor_Purchase_Request_Line')){ 
        	ASI_CTY_CN_Vendor_PRLine_TriggerClass.afterUpdateMethod(Trigger.new, Trigger.oldMap);
       	}
   	}
}