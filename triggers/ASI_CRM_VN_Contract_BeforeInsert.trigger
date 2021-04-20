/*********************************************************************************
 * Name: ASI_CRM_VN_Contract_BeforeInsert
 * Description: Before insert trigger for contract 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2017       Hugo Cheung             Created          
*/
trigger ASI_CRM_VN_Contract_BeforeInsert on ASI_CRM_VN_Contract__c (before insert) {
	new ASI_CRM_VN_Contract_Duplication().executeTrigger(Trigger.new, Trigger.oldMap);
	new ASI_CRM_VN_ContractFXRate().executeTrigger(Trigger.new, Trigger.oldMap);
    new ASI_CRM_VN_ContractAssignDefault().executeTrigger(Trigger.new, Trigger.oldMap);
    new ASI_CRM_VN_ContractUpdateValidClaimDate().executeTrigger(Trigger.new, Trigger.oldMap);
}