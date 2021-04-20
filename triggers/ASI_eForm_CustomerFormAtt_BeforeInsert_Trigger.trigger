/***************************************************************************************************************************
 * Name: ASI_eForm_CustomerFormAtt_BeforeInsert_Trigger
 * Description: trigger for ASI_eForm_Customer_Form_Attachment__c
 * Test Class: ASI_eForm_CustomerForm_TriggerClassTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-08-29       Wilken Lee              [WL 1.0] Created to fix incorrect FileID for Customer Form attachment created from WebForm system
****************************************************************************************************************************/
trigger ASI_eForm_CustomerFormAtt_BeforeInsert_Trigger on ASI_eForm_Customer_Form_Attachment__c (before insert) {
    //[WL 1.0] Attachment controller did not assign recordType
    //if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeID).DeveloperName.contains('ASI_eForm_HK_Customer'))
        ASI_eForm_CustomerFormAtt_TriggerClass.routineBeforeInsert(trigger.new);   
}