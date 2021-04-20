/***************************************************************************************************************************
 * Name:        ASI_MFM_POReceipt_BeforeUpdate
 * Description: 
 * Test Class: ASI_MFM_CAP_POReceipt_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-21       Wilken Lee           	[WL 1.0] Only auto create payment line if there is no payment line created by user
 ****************************************************************************************************************************/
trigger ASI_MFM_POReceipt_BeforeUpdate on ASI_MFM_PO_Receipt__c (before update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_POReceipt_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){ //[WL 1.0]
        ASI_MFM_CAP_POReceipt_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
}