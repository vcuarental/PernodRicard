/**
 * trigger that handles doucusing envelope wrapper object
 * this Objects is handled by the Docusign connect for salesforce 
 * @author ernesto@zimmic.com
 */
trigger LAT_Docusign_StatusTrigger on LAT_DocuSign_Status__c ( before update, after update) {
    Map<Id, Lat_Contract2__c> mapContractById = null;
	Set<Id> setContractsIds  = null;

    System.debug('LAT_Docusign_StatusTrigger [] ->');
    System.debug('LAT_Docusign_StatusTrigger [Trigger.new : ' + Trigger.new + ']');

	setContractsIds = new Set<Id>();    

    for (LAT_DocuSign_Status__c objDSStatus : Trigger.new){
        setContractsIds.add(objDSStatus.Lat_Contract2__c);
    }	

    System.debug('LAT_Docusign_StatusTrigger [setContractsIds : ' + setContractsIds + ']');

    mapContractById = LAT_BR_DocusignDataTriggerHandler.getContractsById(setContractsIds);

    System.debug('LAT_Docusign_StatusTrigger [mapContractById : ' + mapContractById + ']');

	if (Trigger.isBefore){
		if(Trigger.isUpdate){
            System.debug('LAT_Docusign_StatusTrigger [updateContractStatus...]');
			// updates the  contract status according to the new status (if there is no assigned contract do nothing)
			LAT_BR_DocusignDataTriggerHandler.updateContractStatus(Trigger.newMap, Trigger.oldMap,mapContractById);
		}
	} else if (Trigger.isAfter){
		if(Trigger.isUpdate){
			// Do nothing
		}
    }

    System.debug('LAT_Docusign_StatusTrigger [] <-');
}