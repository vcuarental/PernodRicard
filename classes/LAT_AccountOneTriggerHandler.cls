/**
 * Class that handles the accounts and recordtypes for LATAM
 */
public with sharing class LAT_AccountOneTriggerHandler {
	
	// Keep adding migrated record types
	public static  Set<String> LAT_RECORDTYPES = new Set<String> {'LAT_MX_ACC_OffTrade', 'LAT_MX_ACC_OnTrade'};
	public Set<Id> latRecordTypesId;
	public Map<Id, Account> oldAccountMap;
	public Map<Id, List<Account>> accountByRecordType;
	public Map<Id, Lat_Account__c> latAccountByAccountId {get;set;}
	public Map<Id, List<LAT_BR_ClientChannelSegmentation2__c>> segmentationsByAccId {get;set;}
	public Map<Id, LAT_BR_ClientChannelSegmentation2Result__c> segmentationsResultByAccId {get;set;}
	public boolean isInsert {get;set;}
	public boolean isUpdate {get;set;}
	public boolean isDelete {get;set;}
	public boolean isBefore {get;set;}
	public boolean isAfter {get;set;}
	public Set<Id> accsIds {get;set;}

	/**
	 * Constructor 
	 */
	public LAT_AccountOneTriggerHandler(List<Account> triggerNew, 
										Map<Id, Account> triggerOldMap,
										boolean isInsert,
										boolean isUpdate,
										boolean isDelete,
										boolean isBefore,
										boolean isAfter
										) {
		this.isInsert = isInsert;
		this.isUpdate = isUpdate;
		this.isDelete = isDelete;
		this.isBefore = isBefore;
		this.isAfter = isAfter;
		oldAccountMap = triggerOldMap;
		system.debug('triggerOldMap++' + triggerOldMap) ;
		accountByRecordType = new Map<Id, List<Account>>();
		LAT_RECORDTYPES.addAll(AP01_Account_BR.BR_RECORDTYPES);
		latRecordTypesId = Global_RecordTypeCache.getRtIdSet('Account', LAT_RECORDTYPES);
		system.debug('all the ids++' + latRecordTypesId.size());
		if (!isDelete) {
			for (Account acc:triggerNew){

				// DO NOT ADD TO THE MAP IF IT'S NOT A LAT ACCOUNT
				if (latRecordTypesId.contains(acc.RecordTypeId) && !acc.TriggerRun__c){
					
					// create List if empty
					if (accountByRecordType.get(acc.RecordTypeId) == null) {
						accountByRecordType.put(acc.RecordTypeId, new List<Account>());
					}

					//add account to listx
					accountByRecordType.get(acc.RecordTypeId).add(acc);
				}
			}
			if(accountByRecordType.size() == 0) return;
			//Avoid places where no id exists
			if (!(isInsert && isBefore)){
				setAccIds(triggerNew);
				system.debug('triggerNew++' + triggerNew) ;
				latAccountByAccountId = Lat_Utils.getLatAccountMapByAccId(triggerNew);
				segmentationsByAccId = getSegmentationByAccount(accsIds);
				segmentationsResultByAccId = getSegmenatationResultByAccount(accsIds);
			}
			


		} else {
			for (Account acc : triggerOldMap.values()){
				// DO NOT ADD TO THE MAP IF IT'S NOT A LAT ACCOUNT
				if (latRecordTypesId.contains(acc.RecordTypeId) && !acc.TriggerRun__c){
					
					// create List if empty
					if (accountByRecordType.get(acc.RecordTypeId) == null) {
						accountByRecordType.put(acc.RecordTypeId, new List<Account>());
					}

					//add account to list
					accountByRecordType.get(acc.RecordTypeId).add(acc);
				}
			}
		}
	}
	

	public void setAccIds(List<Account> triggerNew){
		accsIds = new Set<Id>();
		for (Account acc:triggerNew){
			accsIds.add(acc.Id);
		}
	}
	/**
	 * get Accounts for a certain RecordTypeName
	 * @param record type developer name
	 * @return the accounts of that recordtype
	 */
	public List<Account> getAccountsForRt(String recordTypeName) {
		return getAccountsForRts(new Set<String>{recordTypeName});
	} 

	/**
	 * get Accounts for a several RecordTypes
	 * @param record type list developer name
	 * @return the accounts of that recordtypes
	 */
	public List<Account> getAccountsForRts(Set<String> recordTypesName) {
		set<Id> recordTypesToProcess = Global_RecordTypeCache.getRtIdSet('Account', recordTypesName);
		List<Account> retAccs = new List<Account>();
		for (String rt: recordTypesToProcess){
			if (accountByRecordType.get(rt) != null ){
				retAccs.addAll(accountByRecordType.get(rt));
			}
		}
		return retAccs;
	} 

	public static Map<Id, List<LAT_BR_ClientChannelSegmentation2__c>> getSegmentationByAccount(Set<Id> accsId){
		Map<Id, List<LAT_BR_ClientChannelSegmentation2__c>> retMap = new Map<Id, List<LAT_BR_ClientChannelSegmentation2__c>>();
		List<LAT_BR_ClientChannelSegmentation2__c> allSegm= [SELECT Id, 
										Q1_canal_negocio__c,
										Account__c,
										Status__c,
										q2_relacao_comercial__c,
										q3_Qual_o_principal_escopo_do_neg_cio__c,
										q4_Qual_a_principal_rea_abordagem__c,
										q5_Qual_o_principal_p_blico__c,
										q6_Qual_o_formato_do_negocio__c,
										q7_Qual_modelo_de_neg_cio_do_cliente__c,
										q8_cliente_possui_benefcio_Fiscal__c,
										Beneficio_Fiscal__c,
										Channel__c,
										Client_type__c,
										Estrategia_comercial__c,
										FORMATO__c,
										Perfil__c,
										POLiTICA_DE_PRECO__c,
										PRIOR_DE_INVESTIMENTO__c,
										Segment__c,
										Sub_channel__c,
										q9_Qual_a_importancia_do_cliente_para_PR__c
								FROM LAT_BR_ClientChannelSegmentation2__c WHERE Account__c In :accsId];
								for (LAT_BR_ClientChannelSegmentation2__c seg:allSegm){
									if (retMap.get(seg.Account__c) == null){
										retMap.put(seg.Account__c, new List<LAT_BR_ClientChannelSegmentation2__c>());
									}
									retMap.get(seg.Account__c).add(seg);

								}
								return retMap;

	}

	public static Map<Id, LAT_BR_ClientChannelSegmentation2Result__c> getSegmenatationResultByAccount(Set<Id> accsId){
		Map<Id, LAT_BR_ClientChannelSegmentation2Result__c> retMap = new Map<Id, LAT_BR_ClientChannelSegmentation2Result__c>();
		List<LAT_BR_ClientChannelSegmentation2Result__c> segmentResult = 

		[SELECT Account__c,
									Beneficio_Fiscal__c,
									Channel__c,
									Client_type__c,
									Estrategia_comercial__c,
									FORMATO__c,
									Perfil__c,
									POLiTICA_DE_PRECO__c,
									PRIOR_DE_INVESTIMENTO__c,
									Segment__c,
									Sub_channel__c,
									Obtained_Layout__c,
									Politica_Preco_Origin__c,
         							POLiTICA_DE_PRECO_Used__c,
									Obtained_POLiTICA_DE_PRECO_Udc__c
						FROM LAT_BR_ClientChannelSegmentation2Result__c 
						WHERE Account__c IN :accsId];

						for (LAT_BR_ClientChannelSegmentation2Result__c seg:segmentResult){
							retMap.put(seg.Account__c, seg);

						}
						return retMap;
	}

	/**
	 * Returns if the trigger has lat accounts on it
	 */
	public boolean hasLatAccounts(){
		return !accountByRecordType.isEmpty();
	}

	public Map<Id, Account> getOldMap(){
		return oldAccountMap;	
	}
	
}