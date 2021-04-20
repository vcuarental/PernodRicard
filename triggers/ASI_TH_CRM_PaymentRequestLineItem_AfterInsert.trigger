/***************************************************************************************************************************
* Name:        ASI_TH_CRM_PaymentRequestLineItem_AfterInsert 
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-12-13       Canter Duan             Created
****************************************************************************************************************************/
trigger ASI_TH_CRM_PaymentRequestLineItem_AfterInsert on ASI_TH_CRM_PaymentRequestLineItem__c (after insert) {
    if(trigger.new[0].recordTypeID != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeID).DeveloperName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_PaymentRequestLine_TriggerCls.fillCodeAutomatic(trigger.new);
        ASI_CRM_CN_PaymentRequestLine_TriggerCls.ItemExclude(trigger.new);
    }
}