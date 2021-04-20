trigger ASI_CN_NPL_ProductDocument_AfterDelete on ASI_CN_NPL_Product_Document__c (after delete){
	ASI_CN_NPL_AttachDocDeleteChatterFile triggerClass = new ASI_CN_NPL_AttachDocDeleteChatterFile();
     
    System.debug('Start ASI_CN_NPL_ProductDocument_AfterDelete: flagExecutedTrigger = ' + ASI_CN_NPL_TriggerHelperClass.flagExecutedTrigger);
    //if (!ASI_CN_NPL_TriggerHelperClass.flagExecutedTrigger){
      ASI_CN_NPL_TriggerHelperClass.flagExecutedTrigger = true;
      triggerClass.deleteAttachmentFile(trigger.old);
    //}
    System.debug('End ASI_CN_NPL_ProductDocument_AfterDelete: flagExecutedTrigger = ' + ASI_CN_NPL_TriggerHelperClass.flagExecutedTrigger);
}