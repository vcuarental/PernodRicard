trigger ASI_CRM_VN_Contract_AfterUpdate on ASI_CRM_VN_Contract__c (after update) {
    new ASI_CRM_VN_ContractLockLineRecord().executeTrigger(Trigger.new, Trigger.oldMap);
}