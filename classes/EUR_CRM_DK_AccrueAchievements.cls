global class EUR_CRM_DK_AccrueAchievements implements Database.Batchable<sObject>{

	static Map<String, String> validRecordTypesVolumeAPIMapping = new Map<String, String>{
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display' => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard' 	 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles' 	 => 'EUR_CRM_Sell_In_Volume_SKUs__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons' 	 => 'EUR_CRM_Sell_In_Volume_SKUs__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays'	 => 'EUR_CRM_Sell_In_Volume_SKUs__c'
	};

	static Set<String> validRecordTypes = validRecordTypesVolumeAPIMapping.keySet();

	global static String generateQuery() {
		String query = 'SELECT Id, Name, EUR_CRM_Visit_Id__c, EUR_CRM_Account__c, EUR_CRM_Account__r.ownerId, ' +
						'EUR_CRM_ObjPromo__c, EUR_CRM_ObjPromo__r.EUR_CRM_Status__c, EUR_CRM_Status__c, ' +
						'EUR_CRM_ObjPromo_Target__c, EUR_CRM_Sell_In_Volume_Bottles__c, EUR_CRM_Sell_In_Volume_SKUs__c, ' +
						'EUR_CRM_SKU__c, EUR_CRM_Brand_Quality_Size__c, OwnerId, RecordType.DeveloperName ' +
						'FROM EUR_CRM_Visit_Action__c ' +
						'WHERE RecordType.DeveloperName IN :validRecordTypes ' +
						'AND EUR_CRM_Is_Accrued__c = false';

		System.debug(query);
		return query;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
	    return Database.getQueryLocator(generateQuery());
	}
	
	global void execute(Database.BatchableContext BC, List<sObject>scope){
	    accrue((List<EUR_CRM_Visit_Action__c> )scope);
	}
	
	global void finish(Database.BatchableContext BC){
	
	}

	global static void accrue(List<EUR_CRM_Visit_Action__c> visitActions) {
		Map<String, Id> visitActionRecordTypes = new Map<String, Id>();
		List<EUR_CRM_Visit_Action__c> visitActionsToUpdate = new List<EUR_CRM_Visit_Action__c>();
		Set<Id> validOPIds = new Set<Id>();
		Set<Id> validVisitActionOwnerIds = new Set<Id>(); 

		if(visitActions == null || visitActions.size() == 0) {
			return;
		}

		// Retrieve Visit Action Record Types
		for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_Visit_Action__c')) {
			if(validRecordTypesVolumeAPIMapping.keySet().contains(rt.DeveloperName)) {
				visitActionRecordTypes.put(rt.DeveloperName, rt.Id);
			}
		}

		System.debug(visitActionRecordTypes);

		for(EUR_CRM_Visit_Action__c visitAction: visitActions) {
			if(visitActionRecordTypes.keySet().contains(visitAction.RecordType.DeveloperName)) {
				validOPIds.add(visitAction.EUR_CRM_ObjPromo__c);
				if(visitAction.EUR_CRM_Account__c != null) {
					validVisitActionOwnerIds.add(visitAction.EUR_CRM_Account__r.OwnerId);
				}

				visitAction.EUR_CRM_Is_Accrued__c = true;
				visitActionsToUpdate.add(visitAction);
			}
		}

		List<EUR_CRM_ObjPromo_Target__c> opTargetsToUpdate = new List<EUR_CRM_ObjPromo_Target__c>();
		Map<Id, EUR_CRM_ObjPromo__c> opsToUpdate = new Map<Id, EUR_CRM_ObjPromo__c>();

		System.debug(validVisitActionOwnerIds);
		System.debug(visitActionsToUpdate);
		System.debug(validOpIds);

		if(visitActionsToUpdate.size() > 0) {
			Map<String, EUR_CRM_ObjPromo_Target__c> opTargetMap = new Map<String, EUR_CRM_ObjPromo_Target__c>();
			Map<Id, EUR_CRM_ObjPromo_Target__c> opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
			Set<Id> parentOps = new Set<Id>();

			for(EUR_CRM_ObjPromo_Target__c target: [select id,EUR_CRM_O_P_Target__c,EUR_CRM_Visit_Targets__c, EUR_CRM_BQS__c,EUR_CRM_BQ__c,EUR_CRM_SKU__c,
				EUR_CRM_Actual_Volume_Bottles__c, EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c,
                EUR_CRM_ObjPromo__c,EUR_CRM_Target_Owner__c from EUR_CRM_ObjPromo_Target__c 
                where EUR_CRM_Target_Owner__c in :validVisitActionOwnerIds AND EUR_CRM_ObjPromo__c in :validOPIds
                AND recordType.developername ='EUR_DK_SR_Volume_Target']) {

				System.debug(target);

				String key = '' + target.EUR_CRM_ObjPromo__c + target.EUR_CRM_Target_Owner__c;
				String prodkey = '';
				if(target.EUR_CRM_BQ__c != null) {
				    prodkey = target.EUR_CRM_BQ__c;
				} else if(target.EUR_CRM_BQS__c != null) {
				    prodkey = target.EUR_CRM_BQS__c;
				} else if(target.EUR_CRM_SKU__c != null) {
				    prodkey = target.EUR_CRM_SKU__c;
				}
				key +=prodkey;

				system.debug('### target key: ' + key);
				opTargetMap.put(key, target);

				parentOps.add(target.EUR_CRM_O_P_Target__c);
				parentOps.add(target.EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c);
			}

			System.debug(parentOps);
			System.debug(opTargetMap);

			opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>([SELECT Id, EUR_CRM_ObjPromo__c, EUR_CRM_Visit_Targets__c, EUR_CRM_Actual_Volume_Bottles__c, EUR_CRM_O_P_Target__c
																			FROM EUR_CRM_ObjPromo_Target__c
																			WHERE Id IN :parentOps]);
			System.debug(opParentTargetMap);

			for(EUR_CRM_Visit_Action__c visitAction: visitActionsToUpdate) {
				String key = '' + visitAction.EUR_CRM_ObjPromo__c + visitAction.EUR_CRM_Account__r.ownerId;
				String prodKey = '';

				System.debug(visitAction);

				/*if(visitAction.EUR_CRM_Brand_Quality__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality__c;
				} else */
				if(visitAction.EUR_CRM_Brand_Quality_Size__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality_Size__c;
				} else if(visitAction.EUR_CRM_SKU__c != null) {
					prodKey = visitAction.EUR_CRM_SKU__c;
				}
				key += prodKey;

				System.debug(key);
				EUR_CRM_ObjPromo_Target__c target = opTargetMap.get(key);
				String quantityCaptureField = validRecordTypesVolumeAPIMapping.get(visitAction.recordType.DeveloperName);
				System.debug(target);
				System.debug(visitAction.recordType.DeveloperName);
				System.debug(quantityCaptureField);
				System.debug(visitAction.get(quantityCaptureField));

				if(target != null && visitAction.get(quantityCaptureField) != null && (Decimal) visitAction.get(quantityCaptureField) > 0) {
					Decimal currentQty = target.EUR_CRM_Actual_Volume_Bottles__c == null ? 0 : target.EUR_CRM_Actual_Volume_Bottles__c; 
					target.EUR_CRM_Actual_Volume_Bottles__c = currentQty + (Decimal) visitAction.get(quantityCaptureField);

					opTargetsToUpdate.add(target);

					//EUR_CRM_ObjPromo_Target__c regionalTarget = opParentTargetMap.get(target.EUR_CRM_O_P_Target__c);

					//System.debug(regionalTarget);
					//System.debug(target);

					//if(regionalTarget != null) {
					//	Decimal currentRegionalQty = regionalTarget.EUR_CRM_Actual_Volume_Bottles__c == null ? 0 : regionalTarget.EUR_CRM_Actual_Volume_Bottles__c;
					//	regionalTarget.EUR_CRM_Actual_Volume_Bottles__c = currentRegionalQty + (Decimal) visitAction.get(quantityCaptureField);

					//	EUR_CRM_ObjPromo_Target__c objectiveTarget = opParentTargetMap.get(regionalTarget.EUR_CRM_O_P_Target__c);
					//	if(objectiveTarget != null) {
					//		Decimal currentObjectiveQty = objectiveTarget.EUR_CRM_Actual_Volume_Bottles__c == null ? 0 : objectiveTarget.EUR_CRM_Actual_Volume_Bottles__c;
					//		objectiveTarget.EUR_CRM_Actual_Volume_Bottles__c = currentObjectiveQty + (Decimal) visitAction.get(quantityCaptureField);
					//	}
					//}
				}
			}

			if(opParentTargetMap != null && opParentTargetMap.values() != null && opParentTargetMap.values().size() > 0) {
				System.debug(opParentTargetMap);	
				opTargetsToUpdate.addAll(opParentTargetMap.values());
			}

			System.debug(opTargetsToUpdate);
			System.debug(visitActionsToUpdate);

			Savepoint sp = Database.setSavepoint();
			try {
				if(visitActionsToUpdate != null && visitActionsToUpdate.size() > 0) {
					update visitActionsToUpdate;
				}

				if(opTargetsToUpdate != null && opTargetsToUpdate.size() > 0) {
					Map<Id, EUR_CRM_ObjPromo_Target__c> opTargetsUpdateMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
					for(EUR_CRM_ObjPromo_Target__c opTarget: opTargetsToUpdate) {
						if(opTargetsUpdateMap.get(opTarget.Id) == null) {
							opTargetsUpdateMap.put(opTarget.Id, opTarget);
						}
					}

					System.debug(opTargetsUpdateMap);
					update opTargetsUpdateMap.values();
				}
			} catch (DMLException e) {
				Database.rollback(sp);
				System.debug('ERROR' + e);
			}
		    
		}
	}

}