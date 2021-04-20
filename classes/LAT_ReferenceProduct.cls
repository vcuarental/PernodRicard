/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
public with sharing class LAT_ReferenceProduct {

	public static Boolean isFirstTime = true;
	//MIGRATED 17/11/2016
	public static void UniqueProduct(List<LAT_ReferenceProduct__c> rpList, Map<id, LAT_ReferenceProduct__c> oldMap, Boolean isUpdate){
		if(!Utils.wasMigrationDone('1')) {   
			Set<String> skuRefSr = new Set<String>();
			Set<String> schuRefSr = new Set<String>();
			Set<String> keyBrandSr = new Set<String>();

			String rtSellOutId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_BR_SellOut');
			List<LAT_ReferenceProduct__c> rfL= [Select id,  SKURef__c , SchCRef__c,KeyBrandRef__c
														FROM LAT_ReferenceProduct__c WHERE RecordtypeId =: rtSellOutId];

			for(LAT_ReferenceProduct__c rp : rfL){
				if(rp.SKURef__c == NULL && rp.SchCRef__c == NULL && rp.KeyBrandRef__c != NULL){
					keyBrandSr.add(rp.KeyBrandRef__c);
				}
				if(rp.SKURef__c == NULL && rp.SchCRef__c != NULL && rp.KeyBrandRef__c == NULL){	
					schuRefSr.add(rp.SchCRef__c);
				}
				if(rp.SKURef__c != NULL && rp.SchCRef__c == NULL && rp.KeyBrandRef__c == NULL){
					skuRefSr.add(rp.SKURef__c);
				}
			}
			for(LAT_ReferenceProduct__c rp2: rpList){
				 //Errorers de duplicados
				if (rp2.RecordtypeId == rtSellOutId) {
					if ((rp2.KeyBrandRef__c != NULL && keyBrandSr.contains(rp2.KeyBrandRef__c) && rp2.SKURef__c == NULL && rp2.SchCRef__c == NULL)
						 && (!isUpdate || (isUpdate && rp2.KeyBrandRef__c != oldMap.get(rp2.id).KeyBrandRef__c))){
					 	rp2.addError(Label.LAT_DuplicateReferenceProduct);
					}
					else if((rp2.SKURef__c != NULL && skuRefSr.contains(rp2.SKURef__c) && rp2.KeyBrandRef__c == NULL && rp2.SchCRef__c == NULL)
					 		&& (!isUpdate || (isUpdate && rp2.SKURef__c != oldMap.get(rp2.id).SKURef__c))) {
					 	rp2.addError(Label.LAT_DuplicateReferenceProduct);
					}
					else if((rp2.SchCRef__c != NULL && schuRefSr.contains(rp2.SchCRef__c) && rp2.SKURef__c == NULL && rp2.KeyBrandRef__c == NULL)
					 		&& (!isUpdate || (isUpdate && rp2.SchCRef__c != oldMap.get(rp2.id).SchCRef__c))) {
					 	rp2.addError(Label.LAT_DuplicateReferenceProduct);
					}
					//Error todos vacios
					else if(rp2.SchCRef__c == NULL && rp2.SKURef__c == NULL && rp2.KeyBrandRef__c == NULL ){
					 	rp2.addError(Label.LAT_ReferenceProductEmpty);
					}
					//Errores mas de un seleccionado
					else if(rp2.SchCRef__c != NULL && rp2.SKURef__c != NULL){
					 	rp2.addError(Label.LAT_MoreThaOneProductReference);
					}
					else if(rp2.SchCRef__c != NULL && rp2.KeyBrandRef__c != NULL ){
					 	rp2.addError(Label.LAT_MoreThaOneProductReference);
					}
					else if(rp2.SKURef__c != NULL && rp2.KeyBrandRef__c != NULL ){
					 	rp2.addError(Label.LAT_MoreThaOneProductReference);
					}
				}
			}
		}else{
			Set<String> skuRefSr = new Set<String>();
			Set<String> schuRefSr = new Set<String>();
			Set<String> keyBrandSr = new Set<String>();

			String rtSellOutId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_BR_SellOut');
			List<LAT_ReferenceProduct__c> rfL= [Select id,  LAT_Product__c , SchCRef__c,KeyBrandRef__c
														FROM LAT_ReferenceProduct__c WHERE RecordtypeId =: rtSellOutId];

			for(LAT_ReferenceProduct__c rp : rfL){
				if(rp.LAT_Product__c == NULL && rp.SchCRef__c == NULL && rp.KeyBrandRef__c != NULL){
					keyBrandSr.add(rp.KeyBrandRef__c);
				}
				if(rp.LAT_Product__c == NULL && rp.SchCRef__c != NULL && rp.KeyBrandRef__c == NULL){	
					schuRefSr.add(rp.SchCRef__c);
				}
				if(rp.LAT_Product__c != NULL && rp.SchCRef__c == NULL && rp.KeyBrandRef__c == NULL){
					skuRefSr.add(rp.LAT_Product__c);
				}
			}
			for(LAT_ReferenceProduct__c rp2: rpList){
				 //Errorers de duplicados
				if (rp2.RecordtypeId == rtSellOutId) {
					if ((rp2.KeyBrandRef__c != NULL && keyBrandSr.contains(rp2.KeyBrandRef__c) && rp2.LAT_Product__c == NULL && rp2.SchCRef__c == NULL)
						 && (!isUpdate || (isUpdate && rp2.KeyBrandRef__c != oldMap.get(rp2.id).KeyBrandRef__c))){
					 	rp2.addError(Label.LAT_DuplicateReferenceProduct);
					}
					else if((rp2.LAT_Product__c != NULL && skuRefSr.contains(rp2.LAT_Product__c) && rp2.KeyBrandRef__c == NULL && rp2.SchCRef__c == NULL)
					 		&& (!isUpdate || (isUpdate && rp2.LAT_Product__c != oldMap.get(rp2.id).LAT_Product__c))) {
					 	rp2.addError(Label.LAT_DuplicateReferenceProduct);
					}
					else if((rp2.SchCRef__c != NULL && schuRefSr.contains(rp2.SchCRef__c) && rp2.LAT_Product__c == NULL && rp2.KeyBrandRef__c == NULL)
					 		&& (!isUpdate || (isUpdate && rp2.SchCRef__c != oldMap.get(rp2.id).SchCRef__c))) {
					 	rp2.addError(Label.LAT_DuplicateReferenceProduct);
					}
					//Error todos vacios
					else if(rp2.SchCRef__c == NULL && rp2.LAT_Product__c == NULL && rp2.KeyBrandRef__c == NULL ){
					 	rp2.addError(Label.LAT_ReferenceProductEmpty);
					}
					//Errores mas de un seleccionado
					else if(rp2.SchCRef__c != NULL && rp2.LAT_Product__c != NULL){
					 	rp2.addError(Label.LAT_MoreThaOneProductReference);
					}
					else if(rp2.SchCRef__c != NULL && rp2.KeyBrandRef__c != NULL ){
					 	rp2.addError(Label.LAT_MoreThaOneProductReference);
					}
					else if(rp2.LAT_Product__c != NULL && rp2.KeyBrandRef__c != NULL ){
					 	rp2.addError(Label.LAT_MoreThaOneProductReference);
					}
				}
			}
		}
	}

	public static Boolean uniqueGroupByRecordType(List<LAT_ReferenceProduct__c> rpList) {
		Boolean ret = true;
		List<Id> listGruopsIds = new List<Id>();
		Map<Id, LAT_ReferenceProduct__c> mapGroupsById = new Map<Id, LAT_ReferenceProduct__c>();
		for (LAT_ReferenceProduct__c rp: rpList) {
			listGruopsIds.add(rp.ReferenceGrouping__c);
			mapGroupsById.put(rp.ReferenceGrouping__c, rp);
		}
		for (LAT_ReferenceProduct__c existingRefProd : [SELECT id, ReferenceGrouping__c, RecordTypeId FROM LAT_ReferenceProduct__c 
														WHERE ReferenceGrouping__c in :listGruopsIds]) {
			if (existingRefProd.RecordTypeId == mapGroupsById.get(existingRefProd.ReferenceGrouping__c).RecordTypeId ) {
				System.debug('%%%%%%%% Hay un grupo ya existente : '+existingRefProd.Id);
				mapGroupsById.get(existingRefProd.ReferenceGrouping__c).addError('Já existe um Agrupamento de mesmo nome para este Tipo de Registro');
				ret = false;
			}
		}
		return ret;

	}

	public static void InsertValues(List<LAT_ReferenceProduct__c> rpList){	
		List<Id> listGruopsIds = new List<Id>();
		Map<Id, String> mapGroupsById = new Map<Id, String>();
		for (LAT_ReferenceProduct__c rp: rpList) {
			listGruopsIds.add(rp.ReferenceGrouping__c);
		}
		for (LAT_ReferenceProductGrouping__c rpg : [SELECT Id, Name FROM LAT_ReferenceProductGrouping__c WHERE id IN :listGruopsIds]) {
			mapGroupsById.put(rpg.Id, rpg.Name);
		}
		if(!Utils.wasMigrationDone('1')) {  
			for(LAT_ReferenceProduct__c rp: rpList){
				if(rp.KeyBrandRef__c !=NULL){
					rp.Type__c='KeyBrand';
				}else if(rp.SKURef__c != NULL){
					rp.Type__c = 'SKU';
				}else{
					rp.Type__c='SchC';
				}
				rp.ExternalId__c = rp.RefKey__c+'-'+rp.Type__c+'-'+mapGroupsById.get(rp.ReferenceGrouping__c);

			}
		}else{
			for(LAT_ReferenceProduct__c rp: rpList){
				if(rp.KeyBrandRef__c !=NULL){
					rp.Type__c='KeyBrand';
				}else if(rp.LAT_Product__c != NULL){
					rp.Type__c = 'SKU';
				}else{
					rp.Type__c='SchC';
				}
				rp.ExternalId__c = rp.LAT_RefKey__c+'-'+rp.Type__c+'-'+mapGroupsById.get(rp.ReferenceGrouping__c);
			}
		}


	}

	public static void validateGrouping(List<LAT_ReferenceProduct__c> rpList, Boolean isUpdate){

		Map<id, LAT_ReferenceProduct__c> refList = new Map<id, LAT_ReferenceProduct__c>([SELECT id, Type__c, ReferenceGrouping__c, ReferenceGrouping__r.GroupType__c
																								FROM LAT_ReferenceProduct__c WHERE id IN: rpList]);
		Map<id, List<LAT_ReferenceProduct__c>> mapGroupRefList = new Map<id, List<LAT_ReferenceProduct__c>>();
		for (LAT_ReferenceProduct__c rp: [SELECT id, Type__c, ReferenceGrouping__c, ReferenceGrouping__r.GroupType__c
				     									FROM LAT_ReferenceProduct__c]) {
			if (mapGroupRefList.get(rp.ReferenceGrouping__c) != null) {
				mapGroupRefList.get(rp.ReferenceGrouping__c).add(rp);
			} else {
				mapGroupRefList.put(rp.ReferenceGrouping__c, new List<LAT_ReferenceProduct__c>{rp});
			}
		}

		List<String> groupingIds = new List<String>();
		for (LAT_ReferenceProduct__c rp: rpList) {
			groupingIds.add(rp.ReferenceGrouping__c);
			if (!isUpdate) {
				if (mapGroupRefList.get(rp.ReferenceGrouping__c) != null) {
					mapGroupRefList.get(rp.ReferenceGrouping__c).add(rp);
				} else {
					mapGroupRefList.put(rp.ReferenceGrouping__c, new List<LAT_ReferenceProduct__c>{rp});
				}
			}
			
		}

		Map<id, LAT_ReferenceProductGrouping__c> mapReferenceProduct = new Map<id, LAT_ReferenceProductGrouping__c>([SELECT id, GroupType__c FROM LAT_ReferenceProductGrouping__c WHERE id IN: groupingIds]);
		
		List<LAT_ReferenceProductGrouping__c> toUpdate = new List<LAT_ReferenceProductGrouping__c>();
		
		String rtVolumeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_Volumen');
		for (LAT_ReferenceProduct__c rp: rpList) {
			if ( mapGroupRefList.get(rp.ReferenceGrouping__c) != null 
				&& mapReferenceProduct.get(rp.ReferenceGrouping__c).GroupType__c != ''
				&& mapReferenceProduct.get(rp.ReferenceGrouping__c).GroupType__c != 'No Type'
				&& mapGroupRefList.get(rp.ReferenceGrouping__c).size() > 1) {
				
				if (rp.Type__c != mapReferenceProduct.get(rp.ReferenceGrouping__c).GroupType__c && rp.RecordtypeId != rtVolumeId) {
					rp.addError(Label.LAT_ReferenceProductGroupingValidation);
				}

			} else if ( mapGroupRefList.get(rp.ReferenceGrouping__c) != null ){
				
				mapReferenceProduct.get(rp.ReferenceGrouping__c).GroupType__c = rp.Type__c;
				toUpdate.add(mapReferenceProduct.get(rp.ReferenceGrouping__c));
			}

		}

		update toUpdate;
	}

	/*
	* @descp: Deactivate reference products based on Agrupamento Produtos Sellout, 
			  This means that we should look for records with the same value on Agrupamento Produtos Sellout. 
			  If so, we should remove Active checkbox from those records
			  Also, we will check if a SKU already existing regardless of the Agrupamento. 
	*/
	public static void deactivateRecords (List<LAT_ReferenceProduct__c> rpList, Map<id, LAT_ReferenceProduct__c> oldMap, Boolean isUpdate){
		if(!Utils.wasMigrationDone('1')) { 
			Set<String> agrupamentosAlreadyActivacted = new Set<String>();
			Set<Id> refProdIds = new Set<Id>();
			Set<String> existingSku = new Set<String>();
			String rtVolumeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_Volumen');

			if(isUpdate){
				for(LAT_ReferenceProduct__c l : rpList){
					if(rtVolumeId == l.recordTypeId){
					refProdIds.add(l.Id);
					if( oldMap.get(l.Id).IsActive__c != l.IsActive__c && l.IsActive__c)
						agrupamentosAlreadyActivacted.add(l.ReferenceGrouping__c);
					}
				}
			}else{
				for(LAT_ReferenceProduct__c l : rpList){
					if(rtVolumeId == l.recordTypeId){
						refProdIds.add(l.Id);
						if(l.IsActive__c) agrupamentosAlreadyActivacted.add(l.ReferenceGrouping__c);
					}
					
				}
			}
			//To avoid recursively update itself - Variable just set in the context instance being executed. 
			if(isFirstTime){
				isFirstTime = false;
				//This will check for Reference products to be deactivated
				List<LAT_ReferenceProduct__c> listLRPToupdate = new List<LAT_ReferenceProduct__c>();
				for(LAT_ReferenceProduct__c lrp : [Select Id,
														  Type__c,
														  SKURef__c,
														  IsActive__c, 
														  ReferenceGrouping__c 
												   From LAT_ReferenceProduct__c 
												   Where id NOT IN :refProdIds AND RecordType.DeveloperName = 'LAT_Volumen']){
					//Check for Ref Products already activated
					if(agrupamentosAlreadyActivacted.contains(lrp.ReferenceGrouping__c)){
						lrp.IsActive__c = false;
						listLRPToupdate.add(lrp);
					}
					//Add SKU to the list 
					existingSku.add(lrp.SKURef__c);
				}
				for(LAT_ReferenceProduct__c lrpNew : rpList){
				 	if(existingSku.contains(lrpNew.SKURef__c) && lrpNew.RecordType.Name == 'LAT_BR_SellOut'){
				 		lrpNew.addError('O SKU em questão já está registrado para outro Agrupamento.');
				 	}
				}
				if(!listLRPToupdate.isEmpty()) update listLRPToupdate;
			}
		}else{
			Set<String> agrupamentosAlreadyActivacted = new Set<String>();
			Set<Id> refProdIds = new Set<Id>();
			Set<String> existingSku = new Set<String>();
			String rtVolumeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_Volumen');

			if(isUpdate){
				for(LAT_ReferenceProduct__c l : rpList){
					if(rtVolumeId == l.recordTypeId){
					refProdIds.add(l.Id);
					if( oldMap.get(l.Id).IsActive__c != l.IsActive__c && l.IsActive__c)
						agrupamentosAlreadyActivacted.add(l.ReferenceGrouping__c);
					}
				}
			}else{
				for(LAT_ReferenceProduct__c l : rpList){
					if(rtVolumeId == l.recordTypeId){
						refProdIds.add(l.Id);
						if(l.IsActive__c) agrupamentosAlreadyActivacted.add(l.ReferenceGrouping__c);
					}
					
				}
			}
			//To avoid recursively update itself - Variable just set in the context instance being executed. 
			if(isFirstTime){
				isFirstTime = false;
				//This will check for Reference products to be deactivated
				List<LAT_ReferenceProduct__c> listLRPToupdate = new List<LAT_ReferenceProduct__c>();
				for(LAT_ReferenceProduct__c lrp : [Select Id,
														  Type__c,
														  LAT_Product__c,
														  IsActive__c, 
														  ReferenceGrouping__c 
												   From LAT_ReferenceProduct__c 
												   Where id NOT IN :refProdIds AND RecordType.DeveloperName = 'LAT_Volumen']){
					//Check for Ref Products already activated
					if(agrupamentosAlreadyActivacted.contains(lrp.ReferenceGrouping__c)){
						lrp.IsActive__c = false;
						listLRPToupdate.add(lrp);
					}
					//Add SKU to the list 
					existingSku.add(lrp.LAT_Product__c);
				}
				for(LAT_ReferenceProduct__c lrpNew : rpList){
				 	if(existingSku.contains(lrpNew.LAT_Product__c) && lrpNew.RecordType.Name == 'LAT_BR_SellOut'){
				 		lrpNew.addError('O SKU em questão já está registrado para outro Agrupamento.');
				 	}
				}
				try {
					if(!listLRPToupdate.isEmpty()) update listLRPToupdate;
				} catch (Exception e) {

				}
 			}	
		}
	}
}