/*******
 * Jay Updated 2016-11-09
 * 1. Add Checking Before Creating OP ACC Mapping
 * 2. Only Create mapping when the account is Active
 * Jay Updated 2017-03-03
 * 1. Limit the scope
 * 
 ******/

global class EUR_CRM_MassUpdateEMObjective implements Database.Batchable<sObject> {

	Set<String> NOACTION = New Set<String>{'Ended','Deactivated'};
	Set<String> SET_PUBLISHED = New Set<String>{'Draft','Committed'};
	Set<String> SET_ACTIVE = New Set<String>{'Draft','Committed','Published '};
	Set<String> SET_ENDED = New Set<String>{'Active'};
	Set<String> IS_ENDED = New Set<String>{'Ended','Deactivated'};
	Set<String> TARGET_RT = New Set<String>{'EUR_DK_Off_Trade_EM_Price_Promotion'};

	global final String query;
	// TODO: Refactor validRecordTypes when other countries start using it
	global final Set<String> validRecordTypes = new Set<String>{
		'EUR_DK_Off_Trade_EM_Price_Promotion'
	};

	/*global EUR_CRM_MassUpdateEMObjective() {
		query = 'SELECT Id, EUR_CRM_Active_End_Date__c, EUR_CRM_Active_Start_Date__c, EUR_CRM_Preparation_Start_Date__c, ' +
				'EUR_CRM_CustomerTaxonomy_Chain__c, EUR_CRM_Customer_Taxonomy_Sub_Chain__c,EUR_CRM_Status__c ' +
				'FROM EUR_CRM_ObjPromo__c WHERE recordtype.developername = :validRecordTypes AND ()';
	}*/

	global EUR_CRM_MassUpdateEMObjective() {
		query = 'SELECT Id, EUR_CRM_Active_End_Date__c, EUR_CRM_Active_Start_Date__c, EUR_CRM_Preparation_Start_Date__c, ' +
				'EUR_CRM_CustomerTaxonomy_Chain__c, EUR_CRM_Customer_Taxonomy_Sub_Chain__c ,EUR_CRM_Status__c '+
				'FROM EUR_CRM_ObjPromo__c WHERE recordtype.developername IN : TARGET_RT '+
				'AND EUR_CRM_Status__c NOT IN : IS_ENDED '+
				'AND ( '+
				'(EUR_CRM_Status__c IN: SET_PUBLISHED AND EUR_CRM_Preparation_Start_Date__c <= TODAY) OR ' +
				'(EUR_CRM_Status__c IN: SET_ACTIVE AND EUR_CRM_Active_Start_Date__c <= TODAY) OR '+
				'(EUR_CRM_Status__c IN: SET_ENDED AND EUR_CRM_Active_End_Date__c <= TODAY)) ';
	}
	
	/*SELECT Id, EUR_CRM_Active_End_Date__c, EUR_CRM_Active_Start_Date__c, EUR_CRM_Preparation_Start_Date__c,
	EUR_CRM_CustomerTaxonomy_Chain__c, EUR_CRM_Customer_Taxonomy_Sub_Chain__c ,EUR_CRM_Status__c
	FROM EUR_CRM_ObjPromo__c WHERE recordtype.developername = 'EUR_DK_Off_Trade_EM_Price_Promotion'
	AND EUR_CRM_Status__c NOT IN ('Ended','Deactivated') 
	AND (
	(EUR_CRM_Status__c IN: SET_PUBLISHED AND EUR_CRM_Preparation_Start_Date__c <= TODAY) OR 
	(EUR_CRM_Status__c IN: SET_ACTIVE AND EUR_CRM_Active_Start_Date__c <= TODAY) OR 
	(EUR_CRM_Status__c IN: SET_ENDED AND EUR_CRM_Active_End_Date__c <= TODAY)
	)*/

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('@@EUR_CRM_MassUpdateEMObjective:scope:'+scope.size());
        System.debug(query);
		List<EUR_CRM_ObjPromo__c> objPromoList = (List<EUR_CRM_ObjPromo__c>) scope;
		List<EUR_CRM_ObjPromo__c> objPromoToUpdate = new List<EUR_CRM_ObjPromo__c>();
		List<EUR_CRM_ObjPromo__c> objPromoToPublish = new List<EUR_CRM_ObjPromo__c>();
		List<EUR_CRM_ObjPromo__c> objPromoToActivate = new List<EUR_CRM_ObjPromo__c>();
		List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMapToUpdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
		List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMapToCreate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMapToActualCreate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

		Set<Id> expiredObjPromoIds = new Set<Id>();


		for(EUR_CRM_ObjPromo__c op: objPromoList) {
			if(SET_PUBLISHED.contains(op.EUR_CRM_Status__c) && op.EUR_CRM_Preparation_Start_Date__c == Date.Today()) {
				// Create O/P Mapping based on customer taxonomy
				objPromoToPublish.add(op);
				op.EUR_CRM_Status__c = 'Published';
			}
			
			if(op.EUR_CRM_Active_End_Date__c <= Date.Today()) {
				// Deactivate all op account mapping
				expiredObjPromoIds.add(op.Id);
				op.EUR_CRM_Status__c = 'Ended';
				objPromoToUpdate.add(op);
			} else if(op.EUR_CRM_Active_Start_Date__c <= Date.Today()) {
				op.EUR_CRM_Status__c = 'Active';
				objPromoToActivate.add(op);
			}
		}

		System.debug(objPromoToPublish);
		if(objPromoToPublish.size() > 0) {
			opAccountMapToCreate = createOPMapping(objPromoToPublish);

			System.debug(opAccountMapToCreate);
			if(opAccountMapToCreate.size() > 0) {
                
                //OP MAPPING EXISTENCE CHECKING
                Set<Id> newMapAccountList = new Set<Id>();
                Set<Id> newMapOpList = new Set<Id>();
                Set<String> opExistenceCheck = New Set<String>();
                
                for(EUR_CRM_ObjPromo_Account_Mapping__c oaMap: opAccountMapToCreate)
                {
                    newMapAccountList.add(oaMap.EUR_CRM_Account__c);
                    newMapOpList.add(oaMap.EUR_CRM_ObjPromo__c);
                    
                }

                
                Id opAccountMappingRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c' + 'EUR_DK_OP_Account_Mapping');
                List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMapCreated = [SELECT EUR_CRM_Account__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE recordTypeId =: opAccountMappingRecordTypeId AND (EUR_CRM_Account__c in :newMapAccountList OR EUR_CRM_ObjPromo__c in : newMapOpList)];
                System.Debug('@@newMapAccountList:' + newMapAccountList);
                System.Debug('@@newMapOpList'+ newMapOpList);
                System.Debug('@@MappingCreated:' + opAccountMapCreated);
                System.Debug('@@opExistenceCheck:' + opExistenceCheck);
                //>>Remove Op which is matched

                for(EUR_CRM_ObjPromo_Account_Mapping__c oaMap: [SELECT EUR_CRM_Account__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE recordTypeId =: opAccountMappingRecordTypeId AND (EUR_CRM_Account__c in :newMapAccountList OR EUR_CRM_ObjPromo__c in : newMapOpList)]){
                	opExistenceCheck.add(oaMap.EUR_CRM_ObjPromo__c + ':' + oaMap.EUR_CRM_Account__c);
                }

                
                for(EUR_CRM_ObjPromo_Account_Mapping__c oaMap: opAccountMapToCreate){
                	//System.Debug(oaMap.EUR_CRM_ObjPromo__c + ':' + oaMap.EUR_CRM_Account__c + '=' + opExistenceCheck.contains(oaMap.EUR_CRM_ObjPromo__c + ':' + oaMap.EUR_CRM_Account__c));
                    if(!opExistenceCheck.contains(oaMap.EUR_CRM_ObjPromo__c + ':' + oaMap.EUR_CRM_Account__c))
                    {
                    	opAccountMapToActualCreate.add(oaMap);
                    }
                    /*for(EUR_CRM_ObjPromo_Account_Mapping__c oaMapCreated: opAccountMapCreated){
                        System.Debug('@@Found?>>' + oaMapCreated.EUR_CRM_Account__c + ' VS ' + oaMap.EUR_CRM_Account__c + ' & ' +  oaMapCreated.EUR_CRM_ObjPromo__c + ' VS ' + oaMap.EUR_CRM_ObjPromo__c);
                        if(oaMapCreated.EUR_CRM_Account__c == oaMap.EUR_CRM_Account__c && oaMapCreated.EUR_CRM_ObjPromo__c == oaMap.EUR_CRM_ObjPromo__c){
                            System.Debug('@@Found!');
                            Found = true;
                            break;
                        }
                    }
                    if(!Found){
                        System.Debug('@@Not Found!');
                        opAccountMapToActualCreate.add(oaMap);
                    }*/
                }
                
                //OP MAPPING EXISTENCE CHECKING
				System.debug(opAccountMapToCreate);
				//insert opAccountMapToCreate;
				insert opAccountMapToActualCreate;
			}

			System.debug(objPromoToPublish);
			update objPromoToPublish;
		}

		System.debug(expiredObjPromoIds);
		if(expiredObjPromoIds.size() > 0) {
			for(EUR_CRM_ObjPromo_Account_Mapping__c opMap: [SELECT Id, EUR_CRM_Is_Active__c
															FROM EUR_CRM_ObjPromo_Account_Mapping__c
															WHERE EUR_CRM_ObjPromo__c IN :expiredObjPromoIds]) {
				opMap.EUR_CRM_Is_Active__c = false;
				opAccountMapToUpdate.add(opMap);
			}

			System.debug(opAccountMapToUpdate);
			if(opAccountMapToUpdate.size() > 0) {
				update opAccountMapToUpdate;
			}

			System.debug(objPromoToUpdate);
			update objPromoToUpdate;
		}

		System.debug(objPromoToActivate);
		if(objPromoToActivate.size() > 0) {
			update objPromoToActivate;
		}
	}

	global List<EUR_CRM_ObjPromo_Account_Mapping__c> createOPMapping(List<EUR_CRM_ObjPromo__c> objPromoList) {
        System.Debug('@@createOPMapping:' + objPromoList);
		// TODO: Refactor for other countries
		Id opAccountMappingRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c' + 'EUR_DK_OP_Account_Mapping');
		List<String> customerTaxonomyChains = new List<String>();
		List<String> customerTaxonomySubChains = new List<String>();
		Map<String, List<EUR_CRM_Account__c>> custTaxChainToAccountMapping = new Map<String, List<EUR_CRM_Account__c>>();
		List<EUR_CRM_ObjPromo_Account_Mapping__c> newOPAccountMapping = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
		Map<Id, EUR_CRM_Customer_Taxonomy__c> custTaxonomies;

		for(EUR_CRM_ObjPromo__c op: objPromoList) {
			customerTaxonomyChains.add(op.EUR_CRM_CustomerTaxonomy_Chain__c);
			customerTaxonomySubChains.add(op.EUR_CRM_Customer_Taxonomy_Sub_Chain__c);
		}

		System.debug(customerTaxonomyChains);
		System.debug(customerTaxonomySubChains);

		custTaxonomies = new Map<Id, EUR_CRM_Customer_Taxonomy__c>([SELECT Id, EUR_CRM_Chain__c, EUR_CRM_Sub_Chain__c
																	FROM EUR_CRM_Customer_Taxonomy__c
																	WHERE EUR_CRM_Chain__c = :customerTaxonomyChains
																	AND EUR_CRM_Sub_Chain__c = :customerTaxonomySubChains]);
		System.debug('@@custTaxonomies:'+custTaxonomies.keySet());
		//Update EUR_CRM_Status__c = 'Active' : Bug 2
		List<EUR_CRM_Account__c> relatedAccounts = [SELECT Id, EUR_JB_Customer_Taxonomy__r.EUR_CRM_Chain__c, EUR_JB_Customer_Taxonomy__r.EUR_CRM_Sub_Chain__c
													FROM EUR_CRM_Account__c 
													WHERE EUR_JB_Customer_Taxonomy__c IN :custTaxonomies.keySet() AND EUR_CRM_Status__c = 'Active'];
		System.debug('@@relatedAccounts:'+relatedAccounts);

		for(EUR_CRM_Account__c acc: relatedAccounts) {
			String chainKey = acc.EUR_JB_Customer_Taxonomy__r.EUR_CRM_Chain__c + acc.EUR_JB_Customer_Taxonomy__r.EUR_CRM_Sub_Chain__c;
			System.debug(chainKey);

			if(custTaxChainToAccountMapping.get(chainKey) == null) {
				custTaxChainToAccountMapping.put(chainKey, new List<EUR_CRM_Account__c>());
			}
			custTaxChainToAccountMapping.get(chainKey).add(acc);
		}

		System.debug('@@custTaxChainToAccountMapping:'+custTaxChainToAccountMapping);

		for(EUR_CRM_ObjPromo__c op: objPromoList) {
			System.debug('@@op:' + op);
			String chainKey = op.EUR_CRM_CustomerTaxonomy_Chain__c + op.EUR_CRM_Customer_Taxonomy_Sub_Chain__c;
			System.debug('@@chainKey"'+chainKey);
			for(EUR_CRM_Account__c acc: custTaxChainToAccountMapping.get(chainKey)) {
				System.debug('@@acc'+acc);
  
				newOPAccountMapping.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
					EUR_CRM_Account__c = acc.Id,
					EUR_CRM_ObjPromo__c = op.Id,
					EUR_CRM_Is_Active__c = true,
					recordTypeId = opAccountMappingRecordTypeId
				));
			}
		}

		System.debug(newOPAccountMapping);
		return newOPAccountMapping;
	}

	global void finish(Database.BatchableContext BC) {
		EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {});
	}

}