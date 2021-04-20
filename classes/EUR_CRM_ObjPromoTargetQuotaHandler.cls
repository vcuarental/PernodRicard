public with sharing class EUR_CRM_ObjPromoTargetQuotaHandler extends EUR_CRM_TriggerAbstract{

	public EUR_CRM_ObjPromoTargetQuotaHandler() {
		super('EUR_CRM_ObjPromoTargetQuotaHandler');
	}

	private final static Set<String> opTargetValidRecordTypes = new Set<String> {
		'EUR_DK_Manager_Volume_Target',
		'EUR_DK_Objective_Volume_Target',
		'EUR_DK_Objective_Product',
		'EUR_DK_SR_Volume_Target'
	};

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){

		List<Recordtype> opTargetRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo_Target__c');
		Map<Id,Recordtype> opTargetRecordTypesMap = new Map<Id,Recordtype>();

		Set<Id> validObjPromoIds = new Set<Id>();
		Map<Id, EUR_CRM_ObjPromo__c> objPromoMapToUpdate = new Map<Id, EUR_CRM_ObjPromo__c>();
		
		for(Recordtype rt : opTargetRecordTypes ){
		   opTargetRecordTypesMap.put(rt.id,rt);
		}

		for(EUR_CRM_ObjPromo_Target__c opTarget: (List<EUR_CRM_ObjPromo_Target__c>)sObjList){
			String recordTypeDevName = opTargetRecordTypesMap.get(opTarget.recordTypeId).developername;

			if(opTargetValidRecordTypes.contains(recordTypeDevName)) {
				// validObjPromoIds.add(opTarget.EUR_CRM_ObjPromo__c);
				objPromoMapToUpdate.put(opTarget.EUR_CRM_ObjPromo__c, new EUR_CRM_ObjPromo__c(
					Id = opTarget.EUR_CRM_ObjPromo__c
				));
			}
		}

		System.debug(objPromoMapToUpdate);

		if(objPromoMapToUpdate.size() > 0) {
			// Map<Id, List<EUR_CRM_ObjPromo_Target__c>> objPromoToOPTargetMap = new Map<Id, List<EUR_CRM_ObjPromo_Target__c>>();

			for(EUR_CRM_ObjPromo_Target__c opTarget : [SELECT Id, EUR_CRM_Achieved__c, EUR_CRM_ObjPromo__c
														FROM EUR_CRM_ObjPromo_Target__c
														WHERE EUR_CRM_ObjPromo__c IN :objPromoMapToUpdate.keySet()
														AND EUR_CRM_ObjPromo__r.EUR_CRM_Is_Quota__c = true]) {

				System.debug(opTarget);

				if(objPromoMapToUpdate.get(opTarget.EUR_CRM_ObjPromo__c) == null) {
					// Skip O/Ps that are already marked as incomplete (one that has one or more targets achieved == false)
					continue;
				}

				if(opTarget.EUR_CRM_Achieved__c == false) {
					// Remove relevant O/P from the list of O/P to End
					// because this O/P has a target that is not yet achieved
					objPromoMapToUpdate.remove(opTarget.EUR_CRM_ObjPromo__c);
				} else {
					objPromoMapToUpdate.get(opTarget.EUR_CRM_ObjPromo__c).EUR_CRM_Status__c = 'Ended';
				}
			}

			System.debug(objPromoMapToUpdate);

			update objPromoMapToUpdate.values();
		}

	}

}