trigger ASI_MFM_Purchase_Request_afterUpdate on ASI_MFM_Purchase_Request__c(after update) {
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CN_Vendor_Purchase_Request')){
          
          ASI_CTY_CN_Vendor_PR_Trigger.afterUpdateMethod(Trigger.New,Trigger.oldMap);
         
     }
}