/***************************************************************************************************************************
 * Name: ASI_eForm_CustomerForm_BeforeInsertAndUpdate_Trigger
 * Description: trigger for ASI_eForm_Customer_Form__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-05       Fanny Yeung	        	before insert or before update
****************************************************************************************************************************/
trigger ASI_eForm_CustomerForm_BeforeInsertAndUpdate_Trigger on ASI_eForm_Customer_Form__c (before insert, before update) {
    if (Trigger.isInsert) {
        ASI_eForm_CustomerForm_TriggerClass.routineBeforeInsert(trigger.new);
    }else if (Trigger.isUpdate) {
        ASI_eForm_CustomerForm_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }
}