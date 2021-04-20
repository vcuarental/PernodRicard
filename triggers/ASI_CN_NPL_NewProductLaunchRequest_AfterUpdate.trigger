trigger ASI_CN_NPL_NewProductLaunchRequest_AfterUpdate on ASI_CN_NPL_NPL_Request__c (after update) {
        
    if (trigger.new[0].RecordTypeId != null && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_NPL_KR_New_SKU_Launch')){//20180223 Introv, to exclude KR record from China logic
        // Michael Yip 28May2013 Kick off customized approval email send
        //*****************************//
        List<id> LID= new List<id>();
        for(ASI_CN_NPL_NPL_Request__c npl : trigger.new){   
            //Wilken Lee 20130925 Update email notification to cater sequential approval                
            if((npl.ASI_CN_NPL_Approval_In_Progress__c && !trigger.oldMap.get(npl.id).ASI_CN_NPL_Approval_In_Progress__c) ||
               (npl.ASI_CN_NPL_Step_1_Approved__c && !trigger.oldMap.get(npl.id).ASI_CN_NPL_Step_1_Approved__c) ||
               (npl.ASI_CN_NPL_Step_2_Approved__c && !trigger.oldMap.get(npl.id).ASI_CN_NPL_Step_2_Approved__c) ||
               (npl.ASI_CN_NPL_Step_3_Approved__c && !trigger.oldMap.get(npl.id).ASI_CN_NPL_Step_3_Approved__c) ||
               (npl.ASI_CN_NPL_Step_4_Approved__c && !trigger.oldMap.get(npl.id).ASI_CN_NPL_Step_4_Approved__c) ||
               (npl.ASI_CN_NPL_Step_5_Approved__c && !trigger.oldMap.get(npl.id).ASI_CN_NPL_Step_5_Approved__c)){
                   
                   if(npl.ASI_CN_NPL_Attachment_File_Size__c >= 10000)
                       npl.addError('Attachment File Size too Large. Please only select attachment with total size less than 10MB');
                   else
                       LID.add(npl.id); 
               }       
        }
        if(LID != null && LID.size()>0 && !test.isRunningTest()){
            system.debug('Start Send Notification');
            //ASI_CN_NPL_HandleApprovalEmail.sendEmail(LID, 'ASI_CN_NPL_NPL_Request__c');
        }
        //******************************//
        ASI_CN_NPL_RequestTriggerAbstract.executeAfterUpdateTriggerAction(trigger.new, trigger.oldmap);
    }
}