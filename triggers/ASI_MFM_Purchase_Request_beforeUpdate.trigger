trigger ASI_MFM_Purchase_Request_beforeUpdate on ASI_MFM_Purchase_Request__c(before update) {

	 if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CN_Vendor_Purchase_Request')){
          
           ASI_CTY_CN_Vendor_PR_Trigger.beforeUpdateMethod(Trigger.New,Trigger.oldMap);
         
     }
    
}