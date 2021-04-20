trigger ASI_TnE_KR_ProxyDriving_BeforeInsert on ASI_TnE_Proxy_Driving_Request__c(Before Insert) {
    
    
    ASI_TnE_KR_ProxyDriving_TriggerClass.beforeInsertMethod(trigger.new);
    /*list<ASI_eForm_HR_MDM__c> MDM = new list<ASI_eForm_HR_MDM__c>([SELECT id,Name,ASI_eForm_Employee_Work_Email__c From ASI_eForm_HR_MDM__c]);
    for(ASI_TnE_Proxy_Driving_Request__c claimHeader : trigger.new){
        for(ASI_eForm_HR_MDM__c obj : MDM){
            if(claimHeader.ASI_TnE_Requester_ID__c==obj.Name){
                claimHeader.ASI_TnE_Requestor_Record__c=obj.id;
                claimHeader.ASI_TnE_KR_PD_Requester_eMail__c=obj.ASI_eForm_Employee_Work_Email__c;
            }
        }
        if(claimHeader.ASI_TnE_Requestor_Record__c==null){
            claimHeader.addError('Employee ID : ' +claimHeader.ASI_TnE_Requester_ID__c + ' not found in MDM.');
        }
    }*/
}