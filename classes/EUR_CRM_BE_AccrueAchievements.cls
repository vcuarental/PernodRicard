global class EUR_CRM_BE_AccrueAchievements implements Database.Batchable<sObject>{

	/*static Map<String, String> validRecordTypesVolumeAPIMapping = new Map<String, String>{
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display' => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard' 	 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles' 	 => 'EUR_CRM_Sell_In_Volume_SKUs__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons' 	 => 'EUR_CRM_Sell_In_Volume_SKUs__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays'	 => 'EUR_CRM_Sell_In_Volume_SKUs__c'
	};*/

	//Value are prioritized to only accual the first one if more than one in capture field
	//VA : RecordType to fields that capture value 
	static Map<String,String> validOPRecordTypes = New Map<String,String>{
		'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Sell_In_Volume_Displays__c',
		'EUR_BE_OFF_Secondary_Placement_ConfParticipation' => 'EUR_CRM_No_of_Spyder_Displays_Placed__c',
		'EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Quantity_of_Kits__c'
	};
    
    //Fields updated in a trigger
    static Set<String> qtyFieldsInTrigger = new Set<String>{'EUR_CRM_Sell_In_Volume_Bottles__c','EUR_CRM_Sell_In_Volume_Displays__c'};

	//Visit Action Capture Field to OPTarget Accrual Field
	static Map<String,String> accualQtyToTargetMap = New Map<String,String>{
		'EUR_CRM_Sell_In_Volume_Bottles__c' => 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_CRM_Sell_In_Volume_Displays__c' => 'EUR_CRM_Actual_Volume_Displays__c',
		'EUR_CRM_No_of_Spyder_Displays_Placed__c' => 'EUR_CRM_Actual_Quantity_Spyder__c',
		'EUR_CRM_Quantity_of_Kits__c' => 'EUR_CRM_Actual_Quantity_Promo_Kits__c'
	};
	//VA : RecordType to Require Product Or Not
	static Map<String,Boolean> productKeyRequired = New Map<String,Boolean>{
		'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty' => true,
		'EUR_BE_OFF_Secondary_Placement_ConfParticipation' => false
	};


	static Set<String> validRecordTypes = validOPRecordTypes.keySet();

	global static String generateQuery() {
		String query = 'SELECT Id, Name, EUR_CRM_Visit_Id__c, EUR_CRM_Account__c, EUR_CRM_Account__r.ownerId, ' +
						'EUR_CRM_ObjPromo__c, EUR_CRM_ObjPromo__r.EUR_CRM_Status__c, EUR_CRM_Status__c, ' +
						'EUR_CRM_ObjPromo_Target__c, EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Sell_In_Volume_Displays__c, EUR_CRM_Sell_In_Volume_SKUs__c,EUR_CRM_No_of_Spyder_Displays_Placed__c,EUR_CRM_Quantity_of_Kits__c, ' +
						'EUR_CRM_SKU__c, EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c , EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c, OwnerId, RecordType.DeveloperName ' +
						'FROM EUR_CRM_Visit_Action__c ' +
						'WHERE RecordType.DeveloperName IN :validRecordTypes ' +
						'AND EUR_CRM_Is_Accrued__c = false';

		//System.Debug(query);
		return query;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
	    return Database.getQueryLocator(generateQuery());
	}
	
	global void execute(Database.BatchableContext BC, List<sObject>scope){
	    accrue((List<EUR_CRM_Visit_Action__c> )scope);
	}
	
	global void finish(Database.BatchableContext BC){
		EUR_CRM_BE_MassDeactivateOPAccMapping batchJob = new EUR_CRM_BE_MassDeactivateOPAccMapping();
	    Id batchId = Database.executeBatch(batchJob,200);
	}

	global static void accrue(List<EUR_CRM_Visit_Action__c> visitActions) {
        //System.Debug('@@@Start Accrual');
		Map<String, Id> visitActionRecordTypes = new Map<String, Id>();
		List<EUR_CRM_Visit_Action__c> visitActionsToUpdate = new List<EUR_CRM_Visit_Action__c>();
		Set<Id> validOPIds = new Set<Id>();
		Set<Id> validVisitActionOwnerIds = new Set<Id>(); 
		Set<EUR_CRM_ObjPromo__c> OPSpyderTargetachievedSet = New Set<EUR_CRM_ObjPromo__c>();

		//If no visit action : Exit 
		if(visitActions == null || visitActions.size() == 0) {
            //System.Debug('@@@No VA');
			return;
		}

		// Retrieve Visit Action Record Types
		for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_Visit_Action__c')) {
			if(validRecordTypes.contains(rt.DeveloperName)) {
				visitActionRecordTypes.put(rt.DeveloperName, rt.Id);
			}
		}
		//System.Debug('###VisitActions:Scope:' + visitActions);
		//System.Debug('###Valid Visit Action:' + visitActionRecordTypes);

		//Filter Visit Action By Record Type / Get list of op / Get List of target owner / Mark VA to accrued
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

		//System.Debug('###Owner' + validVisitActionOwnerIds);
		//System.Debug('###Visit Action to UPdate:' + visitActionsToUpdate);
		//System.Debug('###Valid Op Ids:' + validOpIds);

		//If there is valid visit action
		if(visitActionsToUpdate.size() > 0) {
			Map<String, EUR_CRM_ObjPromo_Target__c> opTargetMap = new Map<String, EUR_CRM_ObjPromo_Target__c>();
			Map<Id, EUR_CRM_ObjPromo_Target__c> opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
			Set<Id> parentOps = new Set<Id>();

			//Create target mapping, key = ObjPromo + targetOwner + product
			for(EUR_CRM_ObjPromo_Target__c target: [select id,Name,EUR_CRM_O_P_Target__c,EUR_CRM_Visit_Targets__c, EUR_CRM_BQS__c,EUR_CRM_BQ__c,EUR_CRM_SKU__c,EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c,
				EUR_CRM_Actual_Volume_Bottles__c,EUR_CRM_Actual_Volume_Displays__c , EUR_CRM_Actual_Quantity_Spyder__c,EUR_CRM_Actual_Quantity_Promo_Kits__c, EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c,
				EUR_CRM_Target_Quantity_Spyders__c, EUR_CRM_ObjPromo__c,EUR_CRM_Target_Owner__c 
				from EUR_CRM_ObjPromo_Target__c 
                where EUR_CRM_Target_Owner__c in :validVisitActionOwnerIds AND EUR_CRM_ObjPromo__c in :validOPIds
                AND recordType.developername = 'EUR_BE_SR_Volume_Target']) {

				//System.Debug('>>>Create Key For:' + target);

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

				//System.Debug('### target key: ' + key);
				opTargetMap.put(key, target);

				parentOps.add(target.EUR_CRM_O_P_Target__c);
				parentOps.add(target.EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c);
			}

			//System.Debug(parentOps);
			//System.Debug(opTargetMap);

			opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>([SELECT Id,NAme, EUR_CRM_ObjPromo__c, EUR_CRM_Visit_Targets__c, EUR_CRM_Actual_Volume_Bottles__c,
																		 EUR_CRM_Actual_Volume_Displays__c,EUR_CRM_Actual_Quantity_Spyder__c,EUR_CRM_Actual_Quantity_Promo_Kits__c, EUR_CRM_O_P_Target__c,
																		 EUR_CRM_Target_Quantity_Spyders__c
																		 FROM EUR_CRM_ObjPromo_Target__c
																		 WHERE Id IN :parentOps]);
			//System.Debug(opParentTargetMap);

			//For each Visit action, get the target by key
			for(EUR_CRM_Visit_Action__c visitAction: visitActionsToUpdate) {
				//System.Debug('>>>>>>');
				//System.Debug('>>>Visit Avtion:' + visitAction);
				String key = '' + visitAction.EUR_CRM_ObjPromo__c + visitAction.EUR_CRM_Account__r.ownerId;
				String prodKey = '';

				//System.Debug(visitAction);

				/*if(visitAction.EUR_CRM_Brand_Quality__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality__c;
				} else */
				if(visitAction.EUR_CRM_Brand_Quality_Size__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality_Size__c;
				} else if(visitAction.EUR_CRM_SKU__c != null) {
					prodKey = visitAction.EUR_CRM_SKU__c;
				} else if(visitAction.EUR_CRM_Brand_Quality__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality__c;
				}
				key += prodKey;

				//System.Debug(key);
				EUR_CRM_ObjPromo_Target__c srtarget = opTargetMap.get(key);
				String quantityCaptureField = validOPRecordTypes.get(visitAction.recordType.DeveloperName);
				//System.Debug('srtarget:' + srtarget);
				//System.Debug('VA rt:' + visitAction.recordType.DeveloperName);
				//System.Debug('Capture field:' + quantityCaptureField);
				//System.debug(visitAction.get(quantityCaptureField));
				if(srtarget != null && quantityCaptureField != null) {
					List<String> qtyCaptureFieldList = quantityCaptureField.Split(',');
					//System.Debug('>>Capture:' + quantityCaptureField);
					For(String qtyCaptureField : qtyCaptureFieldList){
						//System.Debug('>>Capture field:' + qtyCaptureField);
						Decimal capturedValue = (Decimal)visitAction.get(qtyCaptureField);
						If(capturedValue != null && capturedValue > 0){
							Decimal currentQty = (Decimal)srtarget.get(accualQtyToTargetMap.get(qtyCaptureField)) == null ? 0 : (Decimal)srtarget.get(accualQtyToTargetMap.get(qtyCaptureField));
							srtarget.put(accualQtyToTargetMap.get(qtyCaptureField), currentQty + capturedValue); //Accual to SR Target

							//System.Debug('+++OPSR1:' + srtarget.Name +  '|' + accualQtyToTargetMap.get(qtyCaptureField) + '|' + currentQty + capturedValue);

							opTargetsToUpdate.add(srtarget);
							//System.Debug('>>>opTargetsToUpdate added:' + srtarget);
							EUR_CRM_ObjPromo_Target__c objectiveTarget = opParentTargetMap.get(srtarget.EUR_CRM_O_P_Target__c);

							if(objectiveTarget != null && !qtyFieldsInTrigger.contains(qtyCaptureField)) {
								//Decimal currentObjQty = (Decimal)objectiveTarget.get(accualQtyToTargetMap.get(qtyCaptureField)) == null ? 0 : (Decimal)objectiveTarget.get(accualQtyToTargetMap.get(qtyCaptureField));
								//objectiveTarget.put(accualQtyToTargetMap.get(qtyCaptureField), currentObjQty + capturedValue); //Accual to OP Target

								//Handle Spyder, If Target archived, Turn OP to Under Evaluation
								If(objectiveTarget.EUR_CRM_Target_Quantity_Spyders__c <= objectiveTarget.EUR_CRM_Actual_Quantity_Spyder__c){
                                    try{
                                        OPSpyderTargetachievedSet.add(New EUR_CRM_ObjPromo__c(
																		Id=objectiveTarget.EUR_CRM_ObjPromo__c,
																		EUR_CRM_Status__c = 'Under Evaluation'));
                                    }Catch(Exception e){
                                        //System.Debug('@@@@Avoid Duplicate');
                                    }

								}


								//System.Debug('+++OPT1:' + objectiveTarget.Name +  '|' + accualQtyToTargetMap.get(qtyCaptureField) + '|' + objectiveTarget.get(accualQtyToTargetMap.get(qtyCaptureField)));

								//System.Debug('>>>objectiveTarget updated:' + objectiveTarget);
							}

							/*SPECIAL HANDLING FOR DISPLAY TO BOTTLES*/
							If(qtyCaptureField == 'EUR_CRM_Sell_In_Volume_Displays__c'){
								Decimal currentBottleQty = (Decimal)srtarget.get('EUR_CRM_Actual_Volume_Bottles__c') == null ? 0 : (Decimal)srtarget.get('EUR_CRM_Actual_Volume_Bottles__c');
								srtarget.put('EUR_CRM_Actual_Volume_Bottles__c',currentBottleQty + (capturedValue * srtarget.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c));

								//System.Debug('+++OPSR2:' + srtarget.Name +  '|EUR_CRM_Actual_Volume_Bottles__c|' + currentBottleQty + (capturedValue * srtarget.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c));

								if(objectiveTarget != null) {
									Decimal currentObjBottleQty = (Decimal)objectiveTarget.get('EUR_CRM_Actual_Volume_Bottles__c') == null ? 0 : (Decimal)objectiveTarget.get('EUR_CRM_Actual_Volume_Bottles__c');
									objectiveTarget.put('EUR_CRM_Actual_Volume_Bottles__c', currentObjBottleQty + (capturedValue * srtarget.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c)); //Accual to OP Target

									//System.Debug('+++OPT2:' + objectiveTarget.Name +  '|EUR_CRM_Actual_Volume_Bottles__c|' + objectiveTarget.get('EUR_CRM_Actual_Volume_Bottles__c'));

									//System.Debug('>>>objectiveTarget updated Bottle:' + objectiveTarget);
								}
							}

							

							break; //Only do the first qtyCapturefield
						}
					}
				}
			}

			if(opParentTargetMap != null && opParentTargetMap.values() != null && opParentTargetMap.values().size() > 0) {
				//System.Debug(opParentTargetMap);
				opTargetsToUpdate.addAll(opParentTargetMap.values());
			}

			//System.Debug('opTargetsToUpdate:' + opTargetsToUpdate);
			//System.Debug('visitActionsToUpdate:' + visitActionsToUpdate);

			Savepoint sp = Database.setSavepoint();
			try {
				if(visitActionsToUpdate != null && visitActionsToUpdate.size() > 0) {
                    //System.Debug('@@@Update:visitActionsToUpdate');
					update visitActionsToUpdate;
				}

				if(opTargetsToUpdate != null && opTargetsToUpdate.size() > 0) {
					Map<Id, EUR_CRM_ObjPromo_Target__c> opTargetsUpdateMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
					for(EUR_CRM_ObjPromo_Target__c opTarget: opTargetsToUpdate) {
						if(opTargetsUpdateMap.get(opTarget.Id) == null) {
							opTargetsUpdateMap.put(opTarget.Id, opTarget);
						}
					}

					//System.Debug(opTargetsUpdateMap);
                    //System.Debug('@@@Update:opTargetsUpdateMap');
					update opTargetsUpdateMap.values();
				}

				//Trigger MassDeactivteOPAccMapping
				if(OPSpyderTargetachievedSet.Size() > 0){
                    For(EUR_CRM_ObjPromo__c op : OPSpyderTargetachievedSet){
                        //System.Debug('@@@@' + op);
                    }
                    
                    //System.Debug('@@@Update:OPSpyderTargetachievedSet');
                    List<EUR_CRM_ObjPromo__c> OPSpyderList = New List<EUR_CRM_ObjPromo__c>();
                    OPSpyderList.addall(OPSpyderTargetachievedSet);
					Update OPSpyderList;
					
				}
			} catch (DMLException e) {
				Database.rollback(sp);
				//System.Debug('ERROR' + e);
			}
		    
		}


	}

}