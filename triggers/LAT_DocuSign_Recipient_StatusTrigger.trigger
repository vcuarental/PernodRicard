/**
 * Docusign Recipient updates
 * this trigger is meant to be used by the docusign connect for salesforce API
 * from docusing some fields will be updated according to the events that happend with a certain recipient
 * we should handle the events logic in this trigger
 * @author ernesto@zimmic.com
 */
trigger LAT_DocuSign_Recipient_StatusTrigger on LAT_DocuSign_Recipient_Status__c ( before update, after update) {
	Map<Id, Lat_Contract2__c> mapContractById = null;
	Set<Id> setContractsIds  = null;
    Set<Id> setDocusingStatusIds = null;

    System.debug('LAT_DocuSign_Recipient_StatusTrigger [] ->');
    System.debug('LAT_DocuSign_Recipient_StatusTrigger [Trigger.new : ' + Trigger.new + ']');

	setContractsIds = new Set<Id>();    
    setDocusingStatusIds = new Set<Id> ();
    
    for (LAT_DocuSign_Recipient_Status__c objDSRecipientStatus : Trigger.new){
        setDocusingStatusIds.add(objDSRecipientStatus.Parent_Status_Record__c);
        setContractsIds.add(objDSRecipientStatus.Lat_Contract2__c);
    }	

    System.debug('LAT_DocuSign_Recipient_StatusTrigger [setContractsIds : ' + setContractsIds + ']');
    System.debug('LAT_DocuSign_Recipient_StatusTrigger [setDocusingStatusIds : ' + setDocusingStatusIds + ']');

    mapContractById = LAT_BR_DocusignDataTriggerHandler.getContractsById(setContractsIds);

    System.debug('LAT_DocuSign_Recipient_StatusTrigger [mapContractById : ' + mapContractById + ']');

	if (Trigger.isBefore){
		if(Trigger.isUpdate){
            System.debug('LAT_DocuSign_Recipient_StatusTrigger [updateSignataryAndProcessStatus...]');
			// updates the  contract status according to the new status (if there is no assigned contract do nothing)
			LAT_BR_DocusignDataTriggerHandler.updateSignataryAndProcessStatus(Trigger.newMap, Trigger.oldMap, mapContractById, setDocusingStatusIds);
		}
	} else if (Trigger.isAfter){
		if(Trigger.isUpdate){
			// Do nothing
		}
    }
    
    System.debug('LAT_DocuSign_Recipient_StatusTrigger [] <-');
}