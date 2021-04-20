/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

trigger EUR_CRM_ContractAuditTrigger on EUR_CRM_Contract_Audit__c (before insert, before update) {
    new EUR_CRM_ContractAuditTriggerHandler().run();
}