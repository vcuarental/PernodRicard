trigger ASI_KOR_VMS_Interface_File_BeforeUpdate on ASI_KOR_VMS_Interface_File__c (before update) {
	List<ASI_KOR_VMS_Interface_File__c> vmsList = trigger.new;
    Map<Id, ASI_KOR_VMS_Interface_File__c> vmsMap = trigger.oldMap;
    
    List<ASI_KOR_VMS_Interface_File__c> validateVMSList = new List<ASI_KOR_VMS_Interface_File__c>();
    for(ASI_KOR_VMS_Interface_File__c i : vmsList) {
        ASI_KOR_VMS_Interface_File__c oldVMS  = vmsMap.get(i.Id);
        if(oldVMS.ASI_KOR_VMS_Sync__c && !i.ASI_KOR_VMS_Sync__c){
            validateVMSList.add(i);
        }
          
    }
    
    if(validateVMSList.size() > 0) ASI_KOR_VMSInterfaceFile_Service.getInstance().validationVMSSyncFlag(validateVMSList); 
}