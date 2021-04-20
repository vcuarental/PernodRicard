trigger ASI_MFM_Purchase_Request_Line_BeforeUpdate on ASI_MFM_Purchase_Request_Line__c(before update) {

	if (trigger.new[0].recordTypeid != null){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CN_Vendor_Purchase_Request_Line')){  
            
            ASI_CTY_CN_Vendor_PurLine_TriggerClass pur = new ASI_CTY_CN_Vendor_PurLine_TriggerClass();
            if(trigger.isBefore && trigger.isUpdate)
            {
                pur.beforeUpdateBudil(trigger.new, trigger.oldMap);
                
            }
        }  
    } 
    
}