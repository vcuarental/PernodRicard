global class EUR_CRM_SE_AccrueAchievements implements Database.Batchable<sObject>{

	//Visit Action => Visit Action Capture Field
	static Map<String,String> validVARecordTypes = New Map<String,String>{
		'EUR_SE_ON_Listing_Agree_To_List' 				=> 'EUR_CRM_Number_of_Listing__c',
		'EUR_SE_ON_Volume_Campaign_Sell_In_Qty' 		=> 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Pallets_Bundles__c',
		'EUR_SE_ON_Slow_Moving_Sell_In_Qty' 			=> 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_SE_ON_Events_Agree_To_Participate' 		=> 'EUR_CRM_Number_of_People__c',
		'EUR_SE_ON_Education_Nb_of_People' 				=> 'EUR_CRM_Number_of_People__c',
		'EUR_SE_ON_Staff_Communication_Nb_of_People' 	=> 'EUR_CRM_Number_of_People__c'
	};

	//Visit Action Record type to OPTarget Accrual Field
	static Map<String,String> VARtToOPTargetActualField = New Map<String,String>{
		'EUR_SE_ON_Listing_Agree_To_List' 				=> 'EUR_CRM_Actual_Quantity_Listing__c',
		'EUR_SE_ON_Volume_Campaign_Sell_In_Qty' 		=> 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty' => 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_SE_ON_Slow_Moving_Sell_In_Qty' 			=> 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_SE_ON_Events_Agree_To_Participate' 		=> 'EUR_CRM_Actual_Number_of_Commitments__c',
		'EUR_SE_ON_Education_Nb_of_People' 				=> 'EUR_CRM_Actual_Quantity_People__c',
		'EUR_SE_ON_Staff_Communication_Nb_of_People' 	=> 'EUR_CRM_Actual_Quantity_People__c'
	};

	//Visit Action Record type to OPTarget Accrual Field
	static Map<String,String> OPTargetTargetField = New Map<String,String>{
		'EUR_SE_Listing_Campaign' 						=> 'EUR_CRM_Target_Quantity_Listing__c',
		'EUR_SE_Volume_Campaign' 						=> 'EUR_CRM_Qty_Sell_in_Amount_Bottle__c',
		'EUR_SE_Volume_Trip_Campaign_Bundle' 			=> 'EUR_CRM_Qty_Sell_in_Amount_Bottle__c',
		'EUR_SE_Volume_Campaign_Slow_moving' 			=> 'EUR_CRM_Qty_Sell_in_Amount_Bottle__c',
		'EUR_SE_Events' 								=> 'EUR_CRM_Visit_Targets__c',
		'EUR_SE_Staff_Training_Education' 				=> 'EUR_CRM_Target_Quantity_People__c',
		'EUR_SE_Staff_Communication' 					=> 'EUR_CRM_Target_Quantity_People__c'
	};

	static Map<String,String> OPTargetActualField = New Map<String,String>{
		'EUR_SE_Listing_Campaign' 						=> 'EUR_CRM_Actual_Quantity_Listing__c',
		'EUR_SE_Volume_Campaign' 						=> 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_SE_Volume_Trip_Campaign_Bundle' 			=> 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_SE_Volume_Campaign_Slow_moving' 			=> 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_SE_Events' 								=> 'EUR_CRM_Actual_Number_of_Commitments__c',
		'EUR_SE_Staff_Training_Education' 				=> 'EUR_CRM_Actual_Quantity_People__c',
		'EUR_SE_Staff_Communication' 					=> 'EUR_CRM_Actual_Quantity_People__c'
	};

	//VA : RecordType to Require Product Or Not
	/*static Map<String,Boolean> productKeyRequired = New Map<String,Boolean>{
		'EUR_SE_ON_Listing_Agree_To_List'				 => true,
		'EUR_SE_ON_Volume_Campaign_Sell_In_Qty'			 => true,
		'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty'	 => false,
		'EUR_SE_ON_Slow_Moving_Sell_In_Qty'				 => true,
		'EUR_SE_ON_Events_Agree_To_Participate'			 => true,
		'EUR_SE_ON_Education_Nb_of_People'				 => true,
		'EUR_SE_ON_Staff_Communication_Nb_of_People'	 => true
	};*/

	//VA Record Type to Field to Check
	static Map<String,String> accrualUnderCondition = New Map<String,String>{
		'EUR_SE_ON_Listing_Agree_To_List'		=> 'EUR_CRM_Status__c',
		'EUR_SE_ON_Events_Agree_To_Participate'	=> 'EUR_CRM_Status__c'
	};

	//VA Record Type to Value for accrual
	static Map<String,String> accrualConditionValue = New Map<String,String>{
		'EUR_SE_ON_Listing_Agree_To_List'		=> 'Yes',
		'EUR_SE_ON_Events_Agree_To_Participate'	=> 'Participating'
	};

	//OP Target Record Type, Set to Achived if Target equal Actual
	/*static Set<String> setTargetToAchived = New Set<String>{
		'EUR_SE_ON_Listing_Agree_To_List'				 ,
		'EUR_SE_ON_Volume_Campaign_Sell_In_Qty'			 ,
		'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty'	 ,
		'EUR_SE_ON_Slow_Moving_Sell_In_Qty'				 ,
		'EUR_SE_ON_Events_Agree_To_Participate'			 ,
		'EUR_SE_ON_Education_Nb_of_People'				 ,
		'EUR_SE_ON_Staff_Communication_Nb_of_People'	 
	};*/

	//OP Target Record Type, Set OP Acc Mapping if 
	/*static Set<String> setSROPAccMapToFalse = New Set<String>{
		'EUR_SE_ON_Listing_Agree_To_List'				 ,
		'EUR_SE_ON_Volume_Campaign_Sell_In_Qty'			 ,
		'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty'	 ,
		'EUR_SE_ON_Slow_Moving_Sell_In_Qty'				 ,
		'EUR_SE_ON_Staff_Communication_Nb_of_People'	 
	};

	static Set<String> setAllOPAccMapToFalse = New Set<String>{
		'EUR_SE_ON_Listing_Agree_To_List'				 ,
		'EUR_SE_ON_Volume_Campaign_Sell_In_Qty'			 ,
		'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty'	 ,
		'EUR_SE_ON_Slow_Moving_Sell_In_Qty'				 ,
		'EUR_SE_ON_Staff_Communication_Nb_of_People'	 
	};*/

	static Set<String> OPTargetRt = New Set<String>{
		'EUR_SE_Objective_Listing_Target',
		'EUR_SE_Objective_Volume_Target',
		'EUR_SE_Objective_Product',
		'EUR_SE_Objective_People_Target',
		'EUR_SE_SR_People_Target'
	};

	static Set<String> objLevelOnly = New Set<String>{
		'EUR_SE_Listing_Campaign',
		'EUR_SE_Volume_Campaign',
		'EUR_SE_Volume_Trip_Campaign_Bundle',
		'EUR_SE_Volume_Campaign_Slow_moving',
		'EUR_SE_Staff_Communication'
	};

	static Set<String> validRecordTypes = validVARecordTypes.keySet();


	global static String generateQuery() {

		String query = 	'SELECT Id, Name, EUR_CRM_Visit_Id__c, EUR_CRM_Account__c, EUR_CRM_Account__r.ownerId, EUR_CRM_Status__c,' +
						'EUR_CRM_Sell_In_Volume_SKUs__c,EUR_CRM_No_of_Spyder_Displays_Placed__c,EUR_CRM_Quantity_of_Kits__c, ' +
						'EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Sell_In_Volume_Displays__c,' +
						'EUR_CRM_SKU__c, EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c , EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c,EUR_CRM_Brand__c, OwnerId, RecordType.DeveloperName, ' +
						'EUR_CRM_Number_of_Listing__c,EUR_CRM_Sell_In_Volume_Pallets_Bundles__c,EUR_CRM_Number_of_People__c, ' + 
					    'EUR_CRM_ObjPromo__c, EUR_CRM_ObjPromo__r.EUR_CRM_Status__c, EUR_CRM_ObjPromo__r.RecordType.DeveloperName,' +
						'EUR_CRM_ObjPromo_Target__c,  EUR_CRM_ObjPromo_Target__r.RecordType.DeveloperName, ' +
						'EUR_CRM_ObjPromo_Target__r.EUR_CRM_Target_Quantity_Listing__c, EUR_CRM_ObjPromo_Target__r.EUR_CRM_Qty_Sell_in_Amount_Bottle__c, ' + 
						'EUR_CRM_ObjPromo_Target__r.EUR_CRM_Visit_Targets__c, EUR_CRM_ObjPromo_Target__r.EUR_CRM_Target_Quantity_People__c, ' + 
						'EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_Listing__c ,EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Volume_Bottles__c, ' + 
						'EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Number_of_Commitments__c , EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_People__c ' +
						'FROM EUR_CRM_Visit_Action__c ' +
						'WHERE RecordType.DeveloperName IN :validRecordTypes ' +
						'AND EUR_CRM_Is_Accrued__c = false';
		System.debug('RecordType:' + validRecordTypes);
		System.debug('Query:' + query);
		return query;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
	    return Database.getQueryLocator(generateQuery());
	}
	
	global void execute(Database.BatchableContext BC, List<sObject>scope){
		System.Debug('Scope:' + scope);
	    accrue((List<EUR_CRM_Visit_Action__c> )scope);
	}
	
	global void finish(Database.BatchableContext BC){
	
	}

	global static void accrue(List<EUR_CRM_Visit_Action__c> visitActions) {
		Map<String, Id> visitActionRecordTypes = new Map<String, Id>();
		List<EUR_CRM_Visit_Action__c> visitActionsToUpdate = new List<EUR_CRM_Visit_Action__c>();
		Set<Id> validOPIds = new Set<Id>();
		Set<Id> validVisitActionOwnerIds = new Set<Id>(); 
		List<EUR_CRM_ObjPromo__c> OPSpyderTargetachievedList = New List<EUR_CRM_ObjPromo__c>();

		//If no visit action : Exit 
		if(visitActions == null || visitActions.size() == 0) {
			return;
		}
		// Retrieve Visit Action Record Types
		for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_Visit_Action__c')) {
			if(validVARecordTypes.containsKey(rt.DeveloperName)) {
				visitActionRecordTypes.put(rt.DeveloperName, rt.Id);
			}
		}
		System.Debug('###VisitActions:Scope:' + visitActions);
		System.debug('###Valid Visit Action:' + visitActionRecordTypes);

		//Filter Visit Action By Record Type / Get list of op / Get List of target owner / Mark VA to accrued
		for(EUR_CRM_Visit_Action__c visitAction: visitActions) {
			If(validVARecordTypes.ContainsKey(visitAction.RecordType.DeveloperName)){
				System.Debug('###Add OP id From VA:' + visitAction.EUR_CRM_ObjPromo__c);
				validOPIds.add(visitAction.EUR_CRM_ObjPromo__c); visitAction.EUR_CRM_Is_Accrued__c = true; visitActionsToUpdate.add(visitAction);
			}
		}

		

		List<EUR_CRM_ObjPromo_Target__c> opTargetsToUpdate = new List<EUR_CRM_ObjPromo_Target__c>(); Map<Id, EUR_CRM_ObjPromo__c> opsToUpdate = new Map<Id, EUR_CRM_ObjPromo__c>();


		System.debug('###validVisitActionOwnerIds:' + validVisitActionOwnerIds);
		System.debug('###validOPIds:' + validOPIds);
		System.debug('###allOPTargetRt:' + OPTargetRt);

		//If there is valid visit action
		if(visitActionsToUpdate.size() > 0) {
			Map<String, EUR_CRM_ObjPromo_Target__c> opTargetMap = new Map<String, EUR_CRM_ObjPromo_Target__c>(); Map<Id, EUR_CRM_ObjPromo_Target__c> opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>(); Set<Id> parentOps = new Set<Id>();

			//Create target mapping, key = ObjPromo + targetOwner + product
			for(EUR_CRM_ObjPromo_Target__c target: [select id,Name,EUR_CRM_O_P_Target__c,EUR_CRM_Visit_Targets__c, EUR_CRM_BQS__c,EUR_CRM_BQ__c,EUR_CRM_SKU__c,EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c,EUR_CRM_Brand__c,
						EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c,EUR_CRM_Target_Level__c,
						EUR_CRM_Actual_Quantity_Listing__c,EUR_CRM_Actual_Number_of_Commitments__c,EUR_CRM_Actual_Volume_Bottles__c,EUR_CRM_Actual_Quantity_People__c,
						EUR_CRM_Target_Quantity_Spyders__c, EUR_CRM_ObjPromo__c,EUR_CRM_Target_Owner__c ,EUR_CRM_ObjPromo__r.Name,EUR_CRM_Account__c, EUR_CRM_ObjPromo__r.RecordType.DeveloperName
						from EUR_CRM_ObjPromo_Target__c 
		                where EUR_CRM_ObjPromo__c in :validOPIds AND recordType.developername in: OPTargetRt]) {

				System.debug('>>>Target Map:' + target);

				String key = '' + target.Id + '_' ;


				system.debug('###key put:' +  key + '[' + target.EUR_CRM_ObjPromo__r.Name + ']');
				opTargetMap.put(key, target);

				parentOps.add(target.EUR_CRM_O_P_Target__c);
				parentOps.add(target.EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c);
			}

			System.debug('###OP Perent ID:' + parentOps);
			System.debug('###OP Target Map:' + opTargetMap);

			opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>([SELECT Id,NAme, EUR_CRM_ObjPromo__c, EUR_CRM_Visit_Targets__c, EUR_CRM_Target_Level__c,
																		 EUR_CRM_O_P_Target__c,
																		 EUR_CRM_Actual_Quantity_Listing__c,EUR_CRM_Actual_Number_of_Commitments__c,
																		 EUR_CRM_Actual_Volume_Bottles__c,EUR_CRM_Actual_Quantity_People__c
																		 FROM EUR_CRM_ObjPromo_Target__c
																		 WHERE Id IN :parentOps]);
			System.debug('###OP Perent:' + opParentTargetMap);

			//For each Visit action, get the target by key
			for(EUR_CRM_Visit_Action__c visitAction: visitActionsToUpdate) {
				System.Debug('>>>>>>VA Loop');
				System.Debug('>>>Visit action:' + visitAction);
				String key = '' + visitAction.EUR_CRM_ObjPromo_Target__c + '_' ;

				System.debug('###key get:' + key);
				EUR_CRM_ObjPromo_Target__c srtarget = opTargetMap.get(key);
				String quantityCaptureField = validVARecordTypes.get(visitAction.recordType.DeveloperName);
				System.debug('srtarget:' + srtarget);
				System.debug('VA rt:' + visitAction.recordType.DeveloperName);
				System.debug('Capture field:' + quantityCaptureField);

				if(srtarget != null && quantityCaptureField != null) {
					List<String> qtyCaptureFieldList = quantityCaptureField.Split(',');
					System.debug('>>Capture:' + quantityCaptureField);
					For(String qtyCaptureField : qtyCaptureFieldList){
						
						Decimal capturedValue = (Decimal)visitAction.get(qtyCaptureField);

						System.debug('>>Capture field:' + qtyCaptureField + '(' + capturedValue + ')');

						If(capturedValue != null && capturedValue > 0){
							Boolean PerformAccrual = True;
							If(accrualUnderCondition.containsKey(visitAction.recordType.DeveloperName)){
								If(visitAction.get(accrualUnderCondition.get(visitAction.recordType.DeveloperName)) != accrualConditionValue.get(visitAction.recordType.DeveloperName)){
										PerformAccrual = False;
								}
							}
							System.Debug('PerformAccrual:' + PerformAccrual + '[' + visitAction.Id);
							If(PerformAccrual){
								Decimal currentQty = (Decimal)srtarget.get(VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName)) == null ? 0 : (Decimal)srtarget.get(VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName));
								srtarget.put(VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName), currentQty + capturedValue); //Accual to SR Target

								System.Debug('+++OPSR1:' + srtarget.Name +  '|' + VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName) + '|' + currentQty + capturedValue);

								System.Debug('>>>opTargetsToUpdate added:' + srtarget);
								EUR_CRM_ObjPromo_Target__c objectiveTarget = opParentTargetMap.get(srtarget.EUR_CRM_O_P_Target__c);
								System.Debug('>>>Objective Target:' + objectiveTarget);
								
								
								opTargetsToUpdate.add(srtarget);


								if(objectiveTarget != null) {
									Decimal currentObjQty = (Decimal)objectiveTarget.get(VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName)) == null ? 0 : (Decimal)objectiveTarget.get(VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName));
									objectiveTarget.put(VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName), currentObjQty + capturedValue); //Accual to OP Target
									System.Debug('+++OPT1:' + objectiveTarget.Id +  '|' + VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName) + '|' + objectiveTarget.get(VARtToOPTargetActualField.get(visitAction.recordType.DeveloperName)));
									System.Debug('>>>objectiveTarget updated:' + objectiveTarget);

								}
							}
							break; //Only do the first qtyCapturefield
						}
					}
				}
				System.Debug('<<<<<<VA Loop');
			}

			if(opParentTargetMap != null && opParentTargetMap.values() != null && opParentTargetMap.values().size() > 0) {
				System.debug(opParentTargetMap);	
				opTargetsToUpdate.addAll(opParentTargetMap.values());
			}


			System.Debug('========Update Value');
			System.debug('opTargetsToUpdate:');
			For(EUR_CRM_ObjPromo_Target__c Opt : opTargetsToUpdate){
				System.Debug(Opt);
			}
			System.debug('visitActionsToUpdate:' + visitActionsToUpdate);


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

	public EUR_CRM_SE_AccrueAchievements() {
		
	}
}