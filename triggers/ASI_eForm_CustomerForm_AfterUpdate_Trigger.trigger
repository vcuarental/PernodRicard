/***************************************************************************************************************************
 * Name: ASI_eForm_CustomerForm_AfterUpdate_Trigger
 * Description: trigger for ASI_eForm_Customer_Form__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-05       Fanny Yeung	        	after update
****************************************************************************************************************************/
trigger ASI_eForm_CustomerForm_AfterUpdate_Trigger on ASI_eForm_Customer_Form__c (after update) {
	ASI_eForm_CustomerForm_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
}