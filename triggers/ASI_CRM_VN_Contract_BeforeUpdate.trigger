/*********************************************************************************
 * Name: ASI_CRM_VN_Contract_BeforeUpdate
 * Test Class: ASI_CRM_VN_ContractTriggerTest
 * Description: Before update trigger for contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2017       Hugo Cheung             Created
 * 07/01/2019       Andy Zhang              Revise trigger execution sequence
 * 03/05/2019       Wilken Lee              [WL 1.0] ASI_CRM_VN_ContractExtendEndDate need to be executed before ASI_CRM_VN_ContractUpdateValidClaimDate 
                                             because ContractExtendEndDate update End Date field, which is a criteria in ContractUpdateValidClaimDate
*/
trigger ASI_CRM_VN_Contract_BeforeUpdate on ASI_CRM_VN_Contract__c (before update) {
    new ASI_CRM_VN_ContractSetDraft().executeTrigger(Trigger.new, Trigger.oldMap);
    new ASI_CRM_VN_Contract_Duplication().executeTrigger(Trigger.new, Trigger.oldMap);
    new ASI_CRM_VN_ContractFXRate().executeTrigger(Trigger.new, Trigger.oldMap);
    new ASI_CRM_VN_ContractClosed().executeTrigger(Trigger.new, Trigger.oldMap);
    /*[WL 1.0] BEGIN*/
    new ASI_CRM_VN_ContractExtendEndDate().executeTrigger(Trigger.new, Trigger.oldMap);
    new ASI_CRM_VN_ContractUpdateValidClaimDate().executeTrigger(Trigger.new, Trigger.oldMap);
    /*[WL 1.0] BEGIN*/
}