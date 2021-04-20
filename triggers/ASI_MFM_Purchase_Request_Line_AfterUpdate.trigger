trigger ASI_MFM_Purchase_Request_Line_AfterUpdate on ASI_MFM_Purchase_Request_Line__c(after update) {
    
    if (trigger.new[0].recordTypeid != null){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CN_Vendor_Purchase_Request_Line')){  
            
            ASI_CTY_CN_Vendor_PurLine_TriggerClass pur = new ASI_CTY_CN_Vendor_PurLine_TriggerClass();
            // Change merge quotation quantity When pr line item changes in quantity number
            if(trigger.isAfter && trigger.isUpdate)
            {
               pur.afterUpdateBudil(trigger.new, trigger.oldMap);
            }
        }  
    } 
}