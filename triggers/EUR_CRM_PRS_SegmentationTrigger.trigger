trigger EUR_CRM_PRS_SegmentationTrigger on EUR_CRM_PRS_Segmentation__c (before insert, after insert, before update, after update, after delete,after undelete ) {

    new EUR_CRM_PRSSegmentationTriggerHandler().run();
}