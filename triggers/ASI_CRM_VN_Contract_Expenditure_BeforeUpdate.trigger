/*********************************************************************************
 * Name: ASI_CRM_VN_Contract_Expenditure_BeforeUpdate
 * Description: Before update trigger for contract expenditure
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2017       Hugo Cheung             Created          
*/
trigger ASI_CRM_VN_Contract_Expenditure_BeforeUpdate on ASI_CRM_VN_Contract_Expenditure__c (before update) {
	new ASI_CRM_VN_ContractExpend_Duplication().executeTrigger(Trigger.new, Trigger.oldMap);
	new ASI_CRM_VN_ContractExpenditureThreshold().executeTrigger(Trigger.new, Trigger.oldMap);
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_Capsule')){
         new ASI_CRM_VN_CapsuleCS_populateAmount().executeTrigger(trigger.new, trigger.oldMap);
    }
}