/**
 * Contract Activity Item Trigger class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
trigger EUR_ISP_ContractActivityItemTrigger on EUR_CRM_Contract_Activity_Item__c (before insert, after insert, after update, after delete, after undelete) {

	new EUR_CRM_ContrActivItemTriggerHandler().run();

}