/**
* Name: EUR_CRM_ContractPaymentPlanHandler
* Description: Creates one Payment Plan Record after the insertion of a Contract
* 
* Countries: DE, iSpend
*/
public with sharing class EUR_CRM_ContractPaymentPlanHandler extends EUR_CRM_TriggerAbstract{

	public EUR_CRM_ContractPaymentPlanHandler() {
		super('EUR_CRM_ContractPaymentPlanHandler');
	}

    // TODO: Refactor with RecordTypeHelper in case iSpend is expanded
	private final Set<String> validContractRecordTypes = new Set<String> {
		'EUR_DE_Contract'
	};

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){ 
        List<Recordtype> contractRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Contract__c');
        Map<Id,Recordtype> contractRecordTypesMap = new Map<Id,Recordtype>();
        List<EUR_CRM_Contract_Payment_Plan__c> newContractPaymentPlans = new List<EUR_CRM_Contract_Payment_Plan__c>();

        // Maps all Contract record types to its ID. Used to retrieve the developername
        for(RecordType rt: contractRecordTypes) {
            contractRecordTypesMap.put(rt.id, rt);
        }        

        // For each iSpend Contract, create one Contract Payment Plan record
        for(EUR_CRM_Contract__c euContract: (List<EUR_CRM_Contract__c>) sObjList) {
            String devName = contractRecordTypesMap.get(euContract.recordTypeId).developername;
            String countryCode = devName.split('_')[1];

            if(validContractRecordTypes.contains(devname)) {
                newContractPaymentPlans.add(new EUR_CRM_Contract_Payment_Plan__c(
                    EUR_CRM_Contract__c = euContract.Id,
                    recordTypeId = Global_RecordTypeCache.getRtId(
                        'EUR_CRM_Contract_Payment_Plan__c' + 'EUR_' + countryCode + '_Contract_Payment_Plan'
                    )
                ));
            }
        }

        if(newContractPaymentPlans.size() > 0) {
            //insert without sharing for recoverySync
            EUR_CRM_RecoverySyncWrapper.insertContractPaymentPlansWithoutSharing(newContractPaymentPlans);
        }

    }

}