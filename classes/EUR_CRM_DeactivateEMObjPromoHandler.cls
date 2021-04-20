public without sharing class EUR_CRM_DeactivateEMObjPromoHandler extends EUR_CRM_TriggerAbstract{

	public EUR_CRM_DeactivateEMObjPromoHandler() {
		super('EUR_CRM_DeactivateEMObjPromoHandler');
	}

	// TODO: Refactor using RecordTypeHelper
	private final Set<String> validRecordTypes = new Set<String>{
		'EUR_DK_Off_Trade_EM_Price_Promotion'
	};

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
		Set<Id> deactivatedObjPromoIds = new Set<Id>();

		for(EUR_CRM_ObjPromo__c op : (List<EUR_CRM_ObjPromo__c>)sObjList){
			if(op.EUR_CRM_Status__c == 'Deactivated' && op.EUR_CRM_Status__c != ((EUR_CRM_ObjPromo__c)oldMap.get(op.Id)).EUR_CRM_Status__c) {
				// Deactivate all O/P Account Mappings

				deactivatedObjPromoIds.add(op.Id);
			}
		}

		System.debug(deactivatedObjPromoIds);
		if(deactivatedObjPromoIds.size() > 0) {
			List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingToDeactivate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

			for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : [SELECT Id, EUR_CRM_Is_Active__c
															FROM EUR_CRM_ObjPromo_Account_Mapping__c
															WHERE EUR_CRM_ObjPromo__c IN :deactivatedObjPromoIds AND EUR_CRM_Is_Active__c=true]) {

				System.debug(opMap);
				opMap.EUR_CRM_Is_Active__c = false;
				opAccountMappingToDeactivate.add(opMap);
			}

			System.debug(opAccountMappingToDeactivate);
			if(opAccountMappingToDeactivate.size() > 0) {
				update opAccountMappingToDeactivate;
			}

		}
	}

}