trigger ASI_MFM_KR_PR_beforeInsert on ASI_MFM_Purchase_Request__c (before insert)
{
    // for debug only ****** Added by 2017-05-23 Linus@Introv
    system.debug('Get RecordType Id: ' + Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId));
    system.debug('Get RecordType Name: ' + Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).DeveloperName);
    // END - for debug only ****** Added by 2017-05-23 Linus@Introv
     if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
          ASI_MFM_KR_PR_TriggerClass.beforeInsertMethod(Trigger.New);
         ASI_MFM_KR_PR_TriggerClass.BeforeUpsertMethod(Trigger.New,null);
     }

      if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('CN_Vendor_Purchase_Request')){
          
           ASI_CTY_CN_Vendor_PR_Trigger.beforeInsertMethod(Trigger.New);
         
     }
   
}//end trigger