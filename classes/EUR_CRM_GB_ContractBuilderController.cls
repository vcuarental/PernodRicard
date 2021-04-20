/*
	C, c, Cs, cs - EUR_CRM_Contract__c (singular or plural)
	CAI, CAIs, cais - EUR_CRM_Contract_Activity_Item__c (singular or plural)
	CPI, CPIs, cpi, cpis - EUR_CRM_Contract_Product_Item__c (singular or plural)
	MT, MTs, mt, mts - EUR_CRM_Mechanic_Type__c (singular or plural)
	M, Ms, m, ms - EUR_CRM_Mechanic__c (singular or plural)
	BQ, BQs, bq, bqs - EUR_CRM_Quality__c (Brand Quality - singular or plural)
	SDM, SDMs, sdm, sdms - EUR_CRM_Stock_Deal_Mechanic__c (singular or plural)
	CM, cm, CMs, cms - EUR_CRM_Contract_Mechanic__c (singular or plural)
	cs - EUR_CRM_CTM_Contract_setting__mdt
*/
public with sharing class EUR_CRM_GB_ContractBuilderController {


	public Id contrId { get; private set; }
	public EUR_CRM_Contract__c contract { get; private set; }
	public Map<String, MechanicTypeWrapper> mtWrapByMtExtId { get;private set; }

	public static final String CPI_TABLE_PREFIX { get { return 'CPI_Table_'; }}
	public static final String BQ_TABLE_PREFIX {get { return 'BQ_Table_'; }}
	public static final String MT_EXT_ID { get { return 'MT_EXT_ID'; }}
	public static final String BQ_ID { get { return 'BQ_ID'; }}
	public static final String BRAND_QUALITIES_TITLE { get { return 'Brand Qualities'; }}
	public static final String EDIT_CPI_TITLE { get { return 'Edit Contract Product Items'; }}
	public static final String IS_QUICK_SAVE {get { return 'IS_QUICK_SAVE'; }}

	private transient Map<Id,EUR_CRM_Quality__c> allBqById = new Map<Id,EUR_CRM_Quality__c>();
	@TestVisible private transient Map<Id, EUR_CRM_Mechanic_Type__c> allMtById = new Map<Id, EUR_CRM_Mechanic_Type__c>();
	@TestVisible private transient Map<String, EUR_CRM_Mechanic_Type__c> allMtByMtExtId = new Map<String, EUR_CRM_Mechanic_Type__c>();
	private transient Map<String, EUR_CRM_CTM_Contract_setting__mdt> csByMtExtId = new Map<String, EUR_CRM_CTM_Contract_setting__mdt>();

	private static final String NONE = '--None--';
	private static final String errorTemplate = '{0}. EUR_CRM_GB_ContractBuilderController.cls line: {1}';

	@TestVisible private List<EUR_CRM_Contract_Activity_Item__c> caiToUpsert = new List<EUR_CRM_Contract_Activity_Item__c>();
	@TestVisible private List<EUR_CRM_Contract_Product_Item__c> cpiToUpsert = new List<EUR_CRM_Contract_Product_Item__c>();
	@TestVisible private List<EUR_CRM_Contract_Product_Item__c> cpiToDelete = new List<EUR_CRM_Contract_Product_Item__c>();

	private Map<String, EUR_CRM_Contract_Activity_Item__c> caiByMtExtId = new Map<String, EUR_CRM_Contract_Activity_Item__c>();
	private Map<String, EUR_CRM_Contract_Activity_Item__c> clonedCaiByMtExtId = new Map<String, EUR_CRM_Contract_Activity_Item__c>();

//	private static final Map<String, String> DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID = new Map<String, String> {
//		'GB_Must_Stock_Item' => 'GB_Cocktail'
//	};

//	private static final Map<String, String> DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID = new Map<String, String>{
//		'GB_Must_Stock_Item' => 'GB_May_Stock_Item'
//		,	'GB_May_Stock_Item' => 'GB_Must_Stock_Item'
//	};

	@TestVisible private static final Set<String> MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST = new Set<String>{
		'GB_House_Pouring_Champagne'
	,	'GB_House_Pouring_Spirits'
	,	'GB_Premium_Pouring_Spirits'
	};

	@TestVisible private static final Set<String> MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST = new Set<String>{
		'GB_Educations'
	,	'GB_Trips'
	};

	private static final Set<String> MT_EXT_IDS_WITHOUT_CPIS = new Set<String>{
		'GB_Bar_support'
	,	'GB_Lump_Sum'
	};

	private static final Map<String, String> DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID = EUR_CRM_RecordTypeHelper_v2.getSettingsMap('EUR_CRM_GB_ContractBuilderController', 'DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID');
	private static final Map<String, String> DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID = EUR_CRM_RecordTypeHelper_v2.getSettingsMap('EUR_CRM_GB_ContractBuilderController', 'DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID');

	public EUR_CRM_GB_ContractBuilderController(ApexPages.StandardController stndController) {
		this.contrId = (Id) stndController.getId();
		if (this.contrId == null){
			this.addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
		} else {
			this.contract = this.selectContract(this.contrId);
			this.caiByMtExtId = this.getCaiByMtExtId(this.contrId);
			this.clonedCaiByMtExtId = this.cloneCaiByMtExtId(this.caiByMtExtId);
			this.allMtById = this.selectMtById();
			this.allMtByMtExtId = this.getAllMtByMtExtId(this.allMtById);
			this.csByMtExtId = this.getCsByMtExtId();
			this.mtWrapByMtExtId = this.populateMtWrapperByMtExtIdMap(this.allMtById);
			System.debug('\n this.mtWrapByMtExtId.size() => ' + this.mtWrapByMtExtId.size() + '\n');
		}
	}

	private Map<String, EUR_CRM_Mechanic_Type__c> getAllMtByMtExtId(Map<Id, EUR_CRM_Mechanic_Type__c> mtById) {
		Map<String, EUR_CRM_Mechanic_Type__c> allMtByMtExtId = new Map<String, EUR_CRM_Mechanic_Type__c>();
		for (EUR_CRM_Mechanic_Type__c mt : mtById.values()) {
			allMtByMtExtId.put(mt.EUR_CRM_External_ID__c, mt);
		}
		return allMtByMtExtId;
	}


	/* ========================================================= */
	/*      Interfaces
	/* ========================================================= */
	public Map<Id, EUR_CRM_Quality__c> getBqByIdToCalculateTotalFreeCases() {
		Map<Id, EUR_CRM_Quality__c> bqById = new Map<Id, EUR_CRM_Quality__c>();
		for (String mtExtId : this.mtWrapByMtExtId.keySet()) {
			if ( ! MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) { continue; }
			this.populateBQbyIdMap(this.mtWrapByMtExtId.get(mtExtId).bqWrapperByBqIdAvailable, bqById);
			this.populateBQbyIdMap(this.mtWrapByMtExtId.get(mtExtId).bqWrapperByBqIdInCPIs, bqById);
		}
		return bqById;
	}

	private void populateBQbyIdMap(Map<Id, BrandQualityWrapper> bqWrapByBqId, Map<Id, EUR_CRM_Quality__c> bqById) {
		for (BrandQualityWrapper bqWrap : bqWrapByBqId.values()) {
			bqById.put(bqWrap.bq.Id, bqWrap.bq);
		}
	}

	public Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> getStockDealMechanicById() {
		Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> sdmById = new Map<Id, EUR_CRM_Stock_Deal_Mechanic__c>();
		for (String mtExtId : this.mtWrapByMtExtId.keySet()) {
			if ( ! MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) { continue; }
			this.populateSdmByIdMap(this.mtWrapByMtExtId.get(mtExtId).bqWrapperByBqIdAvailable, sdmById);
			this.populateSdmByIdMap(this.mtWrapByMtExtId.get(mtExtId).bqWrapperByBqIdInCPIs, sdmById);
		}
		return sdmById;
	}

	private void populateSdmByIdMap(Map<Id, BrandQualityWrapper> bqWrapByBqId, Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> sdmById) {
		for (BrandQualityWrapper bqWrap : bqWrapByBqId.values()) {
			for (EUR_CRM_Stock_Deal_Mechanic__c sdm : bqWrap.bq.Stock_Deal_Mechanics__r) {
				sdmById.put(sdm.Id, sdm);
			}
		}
	}

	public PageReference saveContract() {
		PageReference pr = null;
		Map<String, String> params = ApexPages.currentPage().getParameters();
		Boolean isQuickSave = Boolean.valueOf(params.get(IS_QUICK_SAVE));

		System.Savepoint pSavepoint = Database.setSavepoint();
		try {

			this.setCaiListsForSave();
			Database.upsert(this.caiToUpsert);

			this.setCpiListsForSave();
			System.debug('\n caiToUpsert.size() => ' + caiToUpsert.size() + '\n');
			System.debug('\n cpiToUpsert.size() => ' + cpiToUpsert.size() + '\n');
			System.debug('\n cpiToDelete.size() => ' + cpiToDelete.size() + '\n');
			System.debug('\n caiToUpsert => ' + JSON.serializePretty(caiToUpsert) + '\n');
			System.debug('\n cpiToUpsert => ' + JSON.serializePretty(cpiToUpsert) + '\n');
			System.debug('\n cpiToDelete => ' + JSON.serializePretty(cpiToDelete) + '\n');

			Database.upsert(this.cpiToUpsert);
			Database.delete(this.cpiToDelete);

			if ( ! isQuickSave) {
				pr = new PageReference('/' + this.contrId);
			}
			this.caiToUpsert.clear();
			this.cpiToUpsert.clear();
			this.cpiToDelete.clear();
		} catch (DmlException dmlException) {
			pr = null;
			Database.rollback(pSavepoint);
			String strError = String.format(errorTemplate, new List<Object>{dmlException.getMessage(), dmlException.getLineNumber()});
			System.debug('ERROR DURING SAVING => : ' + dmlException.getTypeName() + '|' + dmlException.getMessage() + ' , line number => ' + dmlException.getLineNumber());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
		} catch (Exception e) {
			pr = null;
			Database.rollback(pSavepoint);
			String strError = String.format(errorTemplate, new List<Object>{e.getMessage(), e.getLineNumber()});
			System.debug('ERROR DURING SAVING => : ' + e.getTypeName() + '|' + e.getMessage() + ' , line number => ' + e.getLineNumber());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
		}
		return pr;
	}

	public PageReference removeProduct() {
		PageReference pr = null;
		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		String mtExtId = pageParams.get(MT_EXT_ID);
		Id bqId = (Id) pageParams.get(BQ_ID);

		if ( ! this.mtWrapByMtExtId.containsKey(mtExtId)) { return pr; }
		MechanicTypeWrapper mtWrap = this.mtWrapByMtExtId.get(mtExtId);

		this.removeBqFromDependentMtWrap(mtExtId, bqId);
		this.addBqAvailableFromBufferToDependentMtWrap(mtExtId, bqId);
		mtWrap.removeProduct(bqId);
		return pr;
	}

	public PageReference addProduct() {
		PageReference pr = null;
		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		String mtExtId = pageParams.get(MT_EXT_ID);
		Id bqId = (Id) pageParams.get(BQ_ID);
//		System.debug('\n mtExtId => ' + mtExtId + '\n');
//		System.debug('\n this.mtWrapByMtExtId.containsKey(mtExtId) => ' + this.mtWrapByMtExtId.containsKey(mtExtId) + '\n');
		if ( ! this.mtWrapByMtExtId.containsKey(mtExtId)) { return pr; }
		MechanicTypeWrapper mtWrap = this.mtWrapByMtExtId.get(mtExtId);

		this.addBqAvailableToDependentMtWrap(mtExtId, bqId);
		this.removeBqAvailableFromDependentMtWrap(this.mtWrapByMtExtId, mtExtId, bqId);
		mtWrap.addProduct(bqId);
		return pr;
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	@TestVisible
	private void setCaiListsForSave() {
		for (MechanicTypeWrapper mtWrap : this.mtWrapByMtExtId.values()) {
			if (mtWrap.isCaiNeedToUpsert(this.clonedCaiByMtExtId)) {
				this.caiToUpsert.add(mtWrap.cai);
			}
		}
	}

	@TestVisible
	private void setCpiListsForSave() {
		Map<String, EUR_CRM_Contract_Activity_Item__c> caiByMtExtId = this.getCaiByMtExtId(this.contrId);
//		System.debug('\n caiByMtExtId.size() => ' + caiByMtExtId.size() + '\n');
//		System.debug('\n caiByMtExtId => ' + JSON.serializePretty(caiByMtExtId) + '\n');
		for (MechanicTypeWrapper mtWrap : this.mtWrapByMtExtId.values()) {
			for (BrandQualityWrapper bqWrap : mtWrap.bqWrapperByBqIdInCPIs.values()) {
//				System.debug('\n mtWrap.mtExtId => ' + JSON.serializePretty(mtWrap.mtExtId) + '\n');
//				System.debug('\n caiByMtExtId.get(mtWrap.mtExtId) => ' + JSON.serializePretty(caiByMtExtId.get(mtWrap.mtExtId)) + '\n');
				if (bqWrap.isCpiWithoutCaiId(caiByMtExtId)) {
					bqWrap.setCpiParentId(caiByMtExtId.get(mtWrap.mtExtId).Id);
				}
				System.debug('\n bqWrap.cpi => ' + JSON.serializePretty(bqWrap.cpi) + '\n');
				if ( ! this.cpiToUpsert.contains(bqWrap.cpi)) {
					this.cpiToUpsert.add(bqWrap.cpi);
				}
			}
			this.cpiToDelete.addAll(mtWrap.cpiToDelete);
		}
	}

	@TestVisible
	private Map<String, MechanicTypeWrapper> populateMtWrapperByMtExtIdMap(Map<Id, EUR_CRM_Mechanic_Type__c> mtById) {
		Map<String, MechanicTypeWrapper> mtWrapperByMtExtIdWithBQs = this.getMtWrapperByMtExtIdWithBQs(mtById);
		for (String mtExtId : this.allMtByMtExtId.keySet()) {
			if ( ! mtWrapperByMtExtIdWithBQs.containsKey(mtExtId)) {
				mtWrapperByMtExtIdWithBQs.put(mtExtId, new MechanicTypeWrapper(this, this.allMtByMtExtId.get(mtExtId), new Set<EUR_CRM_Quality__c>(), this.csByMtExtId.get(mtExtId)));
			}
			MechanicTypeWrapper mtWrapper = mtWrapperByMtExtIdWithBQs.get(mtExtId);
			EUR_CRM_Contract_Activity_Item__c cai = caiByMtExtId.get(mtExtId);
			mtWrapper.setCpis(cai);
		}

		this.populateDependentMtWrapps(mtWrapperByMtExtIdWithBQs);
		this.populateDependentMtWrappsAvailableBqsList(mtWrapperByMtExtIdWithBQs);
		return mtWrapperByMtExtIdWithBQs;
	}

	private void populateDependentMtWrapps(Map<String, MechanicTypeWrapper> mtWrapperByMtExtIdWithBQs) {
		for (String mainMtExtId : DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.keySet()) {
			String dependMtExtId = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mainMtExtId);
			if ( ! (mtWrapperByMtExtIdWithBQs.containsKey(mainMtExtId) && mtWrapperByMtExtIdWithBQs.containsKey(dependMtExtId))) { continue; }
			MechanicTypeWrapper dependMtWrap = mtWrapperByMtExtIdWithBQs.get(dependMtExtId);
			dependMtWrap.bqWrapperByBqIdAvailable.clear();
			MechanicTypeWrapper mainMtWrap = mtWrapperByMtExtIdWithBQs.get(mainMtExtId);
			dependMtWrap.bqWrapperByBqIdAvailable.putAll(mainMtWrap.bqWrapperByBqIdInCPIs);
			for (Id dependBqIdInCPI : dependMtWrap.bqWrapperByBqIdInCPIs.keySet()) {
				dependMtWrap.bqWrapperByBqIdAvailable.remove(dependBqIdInCPI);
			}
		}
	}

	private void populateDependentMtWrappsAvailableBqsList(Map<String, MechanicTypeWrapper> mtWrapperByMtExtIdWithBQs) {
		for (String mtExtId : mtWrapperByMtExtIdWithBQs.keySet()) {
			for (Id bqId : mtWrapperByMtExtIdWithBQs.get(mtExtId).bqWrapperByBqIdInCPIs.keySet()) {
				this.removeBqAvailableFromDependentMtWrap(mtWrapperByMtExtIdWithBQs, mtExtId, bqId);
			}
		}
	}

	private Map<String, EUR_CRM_Contract_Activity_Item__c> getCaiByMtExtId(Id contrId) {
		List<EUR_CRM_Contract_Activity_Item__c> cais = this.selectCAIsWhereContrId(contrId);
		if (cais.isEmpty()) { return new Map<String, EUR_CRM_Contract_Activity_Item__c>(); }

		Map<String, EUR_CRM_Contract_Activity_Item__c> caiByMtExtId = new Map<String, EUR_CRM_Contract_Activity_Item__c>();
		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			caiByMtExtId.put(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c, cai);
		}
		return caiByMtExtId;
	}

	@TestVisible
	private Map<String, MechanicTypeWrapper> getMtWrapperByMtExtIdWithBQs(Map<Id, EUR_CRM_Mechanic_Type__c> mtById) {
		Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>> bQualitiesByMt = this.getBQsByMt(mtById);
		if (bQualitiesByMt.isEmpty()) { return new Map<String, MechanicTypeWrapper>(); }

		Map<String, MechanicTypeWrapper> mtwByMtExtIdWithBQs = new Map<String, MechanicTypeWrapper>();
		for (EUR_CRM_Mechanic_Type__c mt : bQualitiesByMt.keySet()) {
			if (String.isBlank(mt.EUR_CRM_External_ID__c)) { continue; }
			this.populateMtWrapByExtIdWithBQsMap(bQualitiesByMt, mt, this.csByMtExtId, mtwByMtExtIdWithBQs);
		}
		return mtwByMtExtIdWithBQs;
	}

	@TestVisible
	private Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>> getBQsByMt(Map<Id, EUR_CRM_Mechanic_Type__c> mtById) {
		if (mtById.isEmpty()) { return new Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>>(); }

		Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>> bQualitiesByMt = new Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>>();
		List<EUR_CRM_Contract_Mechanic__c> cms = this.selectCMsWhereMtIds(mtById.keySet());
		this.allBqById = new Map<Id, EUR_CRM_Quality__c>(this.selectBQsWhereIds(this.getBqIds(cms)));
		for (EUR_CRM_Quality__c bq : this.allBqById.values()) {
			for (EUR_CRM_Contract_Mechanic__c cm : bq.Contract_Mechanics__r) {
				EUR_CRM_Mechanic_Type__c mt = mtById.get(cm.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c);
				if (bQualitiesByMt.containsKey(mt)) {
					bQualitiesByMt.get(mt).add(bq);
				} else {
					bQualitiesByMt.put(mt, new Set<EUR_CRM_Quality__c>{ bq });
				}
			}
		}
		return bQualitiesByMt;
	}

	private void addBqAvailableToDependentMtWrap(String mtExtId, Id bqId) {
		if ( ! DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) { return; }
		String mtExtIdToAddBq = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
		if ( ! this.mtWrapByMtExtId.containsKey(mtExtIdToAddBq)) { return; }
		MechanicTypeWrapper mtWrapToAddBq = this.mtWrapByMtExtId.get(mtExtIdToAddBq);
		BrandQualityWrapper bqWrapToAdd = this.mtWrapByMtExtId.get(mtExtId).getBqWrapperAvailable(bqId);
		if (bqWrapToAdd != null) {
			BrandQualityWrapper clonedBqWrap = bqWrapToAdd.clone();
			clonedBqWrap.setParent(mtWrapToAddBq);
			System.debug('\n mtWrapToAddBq.mtExtId => ' + mtWrapToAddBq.mtExtId + '\n');
			System.debug('\n clonedBqWrap.cms => ' + JSON.serializePretty(clonedBqWrap.cms) + '\n');
			System.debug('\n bqWrapToAdd.cms => ' + JSON.serializePretty(bqWrapToAdd.cms) + '\n');
			if (mtWrapToAddBq.mtExtId == 'GB_Cocktail') {
				Boolean isCmExists = false;
				for (EUR_CRM_Contract_Mechanic__c cm : clonedBqWrap.cms) {
					if (cm.EUR_CRM_Brand_Quality__c == bqId) {
						isCmExists = true;
					}
				}
				if ( ! isCmExists) {
					this.addMessage(ApexPages.Severity.WARNING, 'Added BQ with name ' + bqWrapToAdd.bq.Name + ' doesn\'t have Coctail Contract Mechanic');
					return;
				}
			}
//			mtWrapToAddBq.bqWrapperByBqIdAvailable.put(bqId, bqWrapToAdd);
			mtWrapToAddBq.bqWrapperByBqIdAvailable.put(bqId, clonedBqWrap);
		}
	}

	private void addBqAvailableFromBufferToDependentMtWrap(String mtExtId, Id bqId) {
		if ( ! DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) { return; }
		String mtExtIdToAddBq = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
		if ( ! this.mtWrapByMtExtId.containsKey(mtExtIdToAddBq)) { return; }
		MechanicTypeWrapper mtWrapToAddBq = this.mtWrapByMtExtId.get(mtExtIdToAddBq);
		BrandQualityWrapper bqWrapBuffered = mtWrapToAddBq.getBqWrapperBuffered(bqId);
		if (bqWrapBuffered != null) {
			mtWrapToAddBq.bqWrapperByBqIdAvailable.put(bqId, bqWrapBuffered);
			mtWrapToAddBq.bqWrapperByBqIdBuffered.remove(bqId);
		}
	}

	private void removeBqAvailableFromDependentMtWrap(Map<String, MechanicTypeWrapper> mtWrapByMtExtId, String mtExtId, Id bqId) {
		if ( ! DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) { return; }
		String mtExtIdToRemoveBq = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
		if ( ! mtWrapByMtExtId.containsKey(mtExtIdToRemoveBq)) { return; }
		MechanicTypeWrapper mtWrapToRemoveBq = mtWrapByMtExtId.get(mtExtIdToRemoveBq);
		BrandQualityWrapper bqWrapToRemove = mtWrapToRemoveBq.getBqWrapperAvailable(bqId);
		if (bqWrapToRemove != null) {
			mtWrapToRemoveBq.bqWrapperByBqIdBuffered.put(bqId, bqWrapToRemove);
			mtWrapToRemoveBq.bqWrapperByBqIdAvailable.remove(bqId);
		}

	}

	private void removeBqFromDependentMtWrap(String mtExtId, Id bqId) {
		if ( ! DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) { return;}
		String mtExtIdToAddBq = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
		if ( ! this.mtWrapByMtExtId.containsKey(mtExtIdToAddBq)) { return; }
		MechanicTypeWrapper mtWrapToAddBq = this.mtWrapByMtExtId.get(mtExtIdToAddBq);
		mtWrapToAddBq.bqWrapperByBqIdAvailable.remove(bqId);
		mtWrapToAddBq.bqWrapperByBqIdInCPIs.remove(bqId);
	}


	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private void populateMtWrapByExtIdWithBQsMap(Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>> bQualitiesByMt, EUR_CRM_Mechanic_Type__c mt, Map<String, EUR_CRM_CTM_Contract_setting__mdt> csByMtExtId, Map<String, MechanicTypeWrapper> mtwByMtExtIdWithBQs) {
		Set<EUR_CRM_Quality__c> bQs = bQualitiesByMt.get(mt);
		EUR_CRM_CTM_Contract_setting__mdt cs = csByMtExtId.get(mt.EUR_CRM_External_ID__c);
		MechanicTypeWrapper mtWrapper = new MechanicTypeWrapper(this, mt, bQs, cs);
		mtwByMtExtIdWithBQs.put(mt.EUR_CRM_External_ID__c, mtWrapper);
	}

	private Map<String, EUR_CRM_CTM_Contract_setting__mdt> getCsByMtExtId() {
		List<EUR_CRM_CTM_Contract_setting__mdt> cSs = this.selectContractSettings();
		if (cSs.isEmpty()) { return new Map<String, EUR_CRM_CTM_Contract_setting__mdt>(); }

		Map<String, EUR_CRM_CTM_Contract_setting__mdt> csByMtExtId = new Map<String, EUR_CRM_CTM_Contract_setting__mdt>();
		for (EUR_CRM_CTM_Contract_setting__mdt cs : cSs) {
			csByMtExtId.put(cs.EUR_CRM_Mechanic_ExtID__c, cs);
		}
		return csByMtExtId;
	}

	private Set<Id> getBqIds(List<EUR_CRM_Contract_Mechanic__c> cms) {
		Set<Id> bqIds = new Set<Id>();
		for (EUR_CRM_Contract_Mechanic__c cm : cms) {
			bqIds.add(cm.EUR_CRM_Brand_Quality__c);
		}
		return bqIds;
	}

	private Map<String, EUR_CRM_Contract_Activity_Item__c> cloneCaiByMtExtId(Map<String, EUR_CRM_Contract_Activity_Item__c> caiByMtExtId) {
		Map<String, EUR_CRM_Contract_Activity_Item__c> clonedCaiByMtExtId = new Map<String, EUR_CRM_Contract_Activity_Item__c>();
		for (String mtExtId : caiByMtExtId.keySet()) {
			clonedCaiByMtExtId.put(mtExtId, caiByMtExtId.get(mtExtId).clone());
		}
		return clonedCaiByMtExtId;
	}


	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private void addMessage(ApexPages.Severity severity, String message){
		ApexPages.addMessage(new ApexPages.Message(severity, message));
	}

	public void clearMessage() {
		ApexPages.getMessages().clear();
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private EUR_CRM_Contract__c selectContract(Id contractId) {
		return [
			SELECT Id
			,	EUR_CRM_Cocktail_Percent__c
			FROM EUR_CRM_Contract__c
			WHERE Id =:contractId
		];
	}

	private List<EUR_CRM_Contract_Activity_Item__c> selectCAIsWhereContrId(Id contractId) {
		return [
			SELECT Id
			,	EUR_CRM_Mechanic_Type_Name__c
			,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	EUR_CRM_Contract__c
			,	EUR_CRM_Total_Value__c
			,	EUR_CRM_Amount__c
			,	EUR_CRM_Total_Spent_Free_cases__c
			,	EUR_CRM_Cocktail_Percent__c
			,	(
				SELECT Id
				,	EUR_CRM_Contract_Activity_Item__c
				,	EUR_CRM_Total_Spend__c
				,	EUR_Min_Qty_Per_Annum_9L__c
				,	EUR_CRM_Retro_Per_9L__c
				,	EUR_CRM_Stock_Deal_Mechanic__r.EUR_CRM_Stock_Deal_Name__c
				,	EUR_CRM_No_of_People__c
				,	EUR_CRM_No_of_Cocktails__c
				,	EUR_CRM_Brand_Quality__r.Name
				,	EUR_CRM_Brand_Quality_Name__c
				,	EUR_CRM_Available_by_the_Glass__c
				,	EUR_CRM_Cocktail_Menu__c
				,	EUR_CRM_Value__c
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c
				,	EUR_CRM_Free_Cases_9L__c
				,	EUR_CRM_POS_type__c
				,	EUR_CRM_Stock_Deal_Mechanic__c
				,	EUR_CRM_Optics__c
				,	EUR_CRM_Total_Spend_inc_free_cases__c
				,	EUR_CRM_Brand_Quality__r.EUR_CRM_OSG__c
			FROM Contract_Product_Items__r
			)
			FROM EUR_CRM_Contract_Activity_Item__c
			WHERE EUR_CRM_Contract__c = :contractId
		];
	}

	private Map<Id, EUR_CRM_Mechanic_Type__c> selectMtById() {
		return new Map<Id, EUR_CRM_Mechanic_Type__c>([
			SELECT Id
			,	Name
			,	EUR_CRM_External_ID__c
			,	(
				SELECT
					Id
				FROM Mechanics__r
			)
			FROM EUR_CRM_Mechanic_Type__c
			WHERE RecordType.DeveloperName = 'EUR_GB_Mechanic_Type'
		]);
	}

	private List<EUR_CRM_CTM_Contract_setting__mdt> selectContractSettings() {
		return [
			SELECT Id
			,	EUR_CRM_Country_Code__c
			,   EUR_CRM_Mechanic_ExtID__c
			,   EUR_CRM_Product_level__c
			,   EUR_CRM_Setting_Type__c
			FROM EUR_CRM_CTM_Contract_setting__mdt
			WHERE EUR_CRM_Country_Code__c = 'GB'
			ORDER BY EUR_CRM_Mechanic_ExtID__c
		];
	}

	private List<EUR_CRM_Contract_Mechanic__c> selectCMsWhereMtIds(Set<Id> mtIds) {
		return [
			SELECT Id
				,	 EUR_CRM_Brand_Quality__c
			FROM EUR_CRM_Contract_Mechanic__c
			WHERE EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c IN :mtIds
		];
	}

	private List<EUR_CRM_Quality__c> selectBQsWhereIds(Set<Id> bqIds) {
		return [
			SELECT Id
			,	Name
			,	EUR_CRM_Category__c
			,	EUR_CRM_OSG__c
			,	(
				SELECT Id
				,	Name
				,	EUR_CRM_Stock_Deal_Name__c
				,	EUR_CRM_Qty_Buy__c
				,	EUR_CRM_Qty_Free__c
				FROM Stock_Deal_Mechanics__r
			)
			,	(
				SELECT Id
				,	EUR_CRM_Mechanic_Name__c
				,	EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
				,	EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c
				,	EUR_CRM_Brand_Quality__c
				FROM Contract_Mechanics__r
			)
			FROM EUR_CRM_Quality__c
			WHERE Id IN :bqIds
		];
	}


	/* ========================================================= */
	/*      MechanicTypeWrapper
	/* ========================================================= */
	public class MechanicTypeWrapper {
		private EUR_CRM_GB_ContractBuilderController parent;
		private Set<EUR_CRM_Contract_Product_Item__c> cpiToDelete = new Set<EUR_CRM_Contract_Product_Item__c>();
		public EUR_CRM_Contract_Activity_Item__c cai { get; set; }
		public List<EUR_CRM_Contract_Product_Item__c> cpis { get; set; }
		public Id mtId { get; private set; }
		public String mtName { get; private set; }
		public String mtExtId { get; private set; }
		public Map<Id, BrandQualityWrapper> bqWrapperByBqIdAvailable { get; private set; }
		public Map<Id, BrandQualityWrapper> bqWrapperByBqIdInCPIs { get; private set; }
		public String productLevel { get; set; }
		public String settingType { get; set; }
		public Map<Id, BrandQualityWrapper> bqWrapperByBqIdBuffered { get; private set; }

		public MechanicTypeWrapper(EUR_CRM_GB_ContractBuilderController parent, EUR_CRM_Mechanic_Type__c mt, Set<EUR_CRM_Quality__c> bQs, EUR_CRM_CTM_Contract_setting__mdt cs) {
			this.parent = parent;
			this.mtId = mt.Id;
			this.mtName = mt.Name;
			this.mtExtId = mt.EUR_CRM_External_ID__c;
			this.bqWrapperByBqIdAvailable = this.getBqWrappers(bQs);
			this.bqWrapperByBqIdInCPIs = new Map<Id, BrandQualityWrapper>();
			this.setBqWrapperByBqIdBuffered();
			if (cs == null) { return; }
			this.productLevel = cs.EUR_CRM_Product_level__c;
			this.settingType = cs.EUR_CRM_Setting_Type__c;
		}


		/* ========================================================= */
		/*      MechanicTypeWrapper Setters
		/* ========================================================= */
		private void setCpis(EUR_CRM_Contract_Activity_Item__c cai) {
			this.setCAI(cai);
			this.cpis = this.cai.Contract_Product_Items__r;
			this.setBqWrapperByBqIdInCPIs(this.cpis);
		}

		private void setBqWrapperByBqIdBuffered() {
			if ( ! DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(this.mtExtId)) { return; }
			this.bqWrapperByBqIdBuffered = new Map<Id, BrandQualityWrapper>();
		}

		private void setCAI(EUR_CRM_Contract_Activity_Item__c cai) {
			this.cai = cai != null ? cai: this.makeCAI();
		}

		private void setBqWrapperByBqIdInCPIs(List<EUR_CRM_Contract_Product_Item__c> cpis) {
			for (EUR_CRM_Contract_Product_Item__c cpi : cpis) {
				Id bqId = cpi.EUR_CRM_Brand_Quality__c;
				if (this.bqWrapperByBqIdAvailable.containsKey(bqId)) {
					BrandQualityWrapper bqWrap = this.bqWrapperByBqIdAvailable.remove(bqId);
					bqWrap.setCpi(cpi);
					this.bqWrapperByBqIdInCPIs.put(bqWrap.bq.Id, bqWrap);
				} else if (this.parent.allBqById.containsKey(bqId)) {
					BrandQualityWrapper bqWrap = new BrandQualityWrapper(this, this.parent.allBqById.get(bqId));
					bqWrap.setCpi(cpi);
					this.bqWrapperByBqIdInCPIs.put(bqWrap.bq.Id, bqWrap);
				}
			}
		}

		private void addProductToDeleted(EUR_CRM_Contract_Product_Item__c cpi) {
			if (cpi.Id != null) {
				this.cpiToDelete.add(cpi);
			}
		}


		/* ========================================================= */
		/*      MechanicTypeWrapper High Level Helpers
		/* ========================================================= */
		private Map<Id, BrandQualityWrapper> getBqWrappers(Set<EUR_CRM_Quality__c> bQs) {
			Map<Id, BrandQualityWrapper> bqWrapperById = new Map<Id, BrandQualityWrapper>();
			for (EUR_CRM_Quality__c bq : bQs) {
				bqWrapperById.put(bq.Id, new BrandQualityWrapper(this, bq));
			}
			return bqWrapperById;
		}

		private void removeProduct(Id bqId) {
			if (this.bqWrapperByBqIdInCPIs.containsKey(bqId)) {
				BrandQualityWrapper bqWrap = this.bqWrapperByBqIdInCPIs.remove(bqId);
				this.bqWrapperByBqIdAvailable.put(bqWrap.bq.Id, bqWrap);
				this.addProductToDeleted(bqWrap.cpi);
			}
		}

		private void addProduct(Id bqId) {
			if (this.bqWrapperByBqIdAvailable.containsKey(bqId)) {
				BrandQualityWrapper bqWrap = this.bqWrapperByBqIdAvailable.remove(bqId);
				bqWrap.setNewCpi(this.cai);
				this.bqWrapperByBqIdInCPIs.put(bqId, bqWrap);
			}
		}


		/* ========================================================= */
		/*      MechanicTypeWrapper Middle Level Helpers
		/* ========================================================= */
		private BrandQualityWrapper getBqWrapperAvailable(Id bqId) {
			if ( ! this.bqWrapperByBqIdAvailable.containsKey(bqId)) { return null;}
			return this.bqWrapperByBqIdAvailable.get(bqId);
		}

		private BrandQualityWrapper getBqWrapperBuffered(Id bqId) {
			if ( ! this.bqWrapperByBqIdBuffered.containsKey(bqId)) { return null;}
			return this.bqWrapperByBqIdBuffered.get(bqId);
		}


		/* ========================================================= */
		/*      MechanicTypeWrapper Low Level Helpers
		/* ========================================================= */
		private Boolean isCaiNeedToUpsert(Map<String, EUR_CRM_Contract_Activity_Item__c> clonedCaiByMtExtId) {
			return this.cai.Id == null || this.isCaiChanged(clonedCaiByMtExtId);
		}

		private Boolean isCaiChanged(Map<String, EUR_CRM_Contract_Activity_Item__c> clonedCaiByMtExtId) {
			return clonedCaiByMtExtId.containsKey(this.mtExtId)
				&& (this.isCocktailPercentChanged(clonedCaiByMtExtId)
				|| (MT_EXT_IDS_WITHOUT_CPIS.contains(this.mtExtId) && this.isLumpSumOrBurAmountChanged(clonedCaiByMtExtId)));
		}

		private Boolean isLumpSumOrBurAmountChanged(Map<String, EUR_CRM_Contract_Activity_Item__c> clonedCaiByMtExtId) {
			return this.cai.EUR_CRM_Amount__c != clonedCaiByMtExtId.get(this.mtExtId).EUR_CRM_Amount__c;
		}

		private Boolean isCocktailPercentChanged(Map<String, EUR_CRM_Contract_Activity_Item__c> clonedCaiByMtExtId) {
			return this.cai.EUR_CRM_Cocktail_Percent__c != clonedCaiByMtExtId.get(this.mtExtId).EUR_CRM_Cocktail_Percent__c;
		}


		/* ========================================================= */
		/*      MechanicTypeWrapper Makers
		/* ========================================================= */
		private EUR_CRM_Contract_Activity_Item__c makeCAI() {
			Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Contract_Activity_Item').getRecordTypeId();
			return new EUR_CRM_Contract_Activity_Item__c(
				EUR_CRM_Contract__c = this.parent.contrId
			,	EUR_CRM_Mechanic_Type__c = this.mtId
			,	EUR_CRM_Product_level__c = this.productLevel
			,	EUR_CRM_Item_Type__c = this.settingType
			,	RecordTypeId = rtId
			);
		}
	}


	/* ========================================================= */
	/*      BrandQualityWrapper
	/* ========================================================= */
	public class BrandQualityWrapper {
		public EUR_CRM_Quality__c bq { get; set; }
		public List<SelectOption> sdmSelectOptions { get; private set; }
		public List<SelectOption> cmSelectOptions { get; private set; }
		public EUR_CRM_Contract_Product_Item__c cpi { get; private set; }
		public String sdmByIdJSON { get; private set; }
		private MechanicTypeWrapper mtWrapper;
		private List<EUR_CRM_Contract_Mechanic__c> cms;

		public BrandQualityWrapper(MechanicTypeWrapper mtWrapper, EUR_CRM_Quality__c bq) {
			this.mtWrapper = mtWrapper;
			this.bq = bq;
			this.sdmByIdJSON = JSON.serialize(this.getSdmById(bq.Stock_Deal_Mechanics__r));
			this.sdmSelectOptions = this.getSdmSelectOptions(bq.Stock_Deal_Mechanics__r);
			this.setCms(bq);
		}


		/* ========================================================= */
		/*      BrandQualityWrapper Setters
		/* ========================================================= */
		private void setNewCpi(EUR_CRM_Contract_Activity_Item__c cai) {
			this.cpi = this.makeCpi(cai);
		}

		private void setCpi(EUR_CRM_Contract_Product_Item__c cpi) {
			this.cpi = cpi;
		}

		private void setCpiParentId(Id caiId) {
			this.cpi.EUR_CRM_Contract_Activity_Item__c = caiId;
		}

		private void setCms(EUR_CRM_Quality__c bq) {
			this.cms = this.getCurrentContractMechanics(bq.Contract_Mechanics__r);
			this.cmSelectOptions = this.getContractMechanicSelectOptions(this.cms);
		}

		private void setParent(MechanicTypeWrapper mtWrapper) {
			this.mtWrapper = mtWrapper;
			this.setCms(this.bq);
		}


		/* ========================================================= */
		/*      BrandQualityWrapper High Level Helpers
		/* ========================================================= */
		private Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> getSdmById(List<EUR_CRM_Stock_Deal_Mechanic__c> sDMs) {
			if ( ! MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(this.mtWrapper.mtExtId)) { return new Map<Id, EUR_CRM_Stock_Deal_Mechanic__c>(); }
			Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> sdmById = new Map<Id, EUR_CRM_Stock_Deal_Mechanic__c>();
			for (EUR_CRM_Stock_Deal_Mechanic__c sdm : sDMs) {
				sdmById.put(sdm.Id, sdm);
			}
			return sdmById;
		}
		private List<SelectOption> getSdmSelectOptions(List<EUR_CRM_Stock_Deal_Mechanic__c> sDMs) {
			if ( ! MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(this.mtWrapper.mtExtId)) { return new List<SelectOption>(); }
			List<SelectOption> sdmSelectOptions = new List<SelectOption>{ new SelectOption('', NONE) };
			for (EUR_CRM_Stock_Deal_Mechanic__c sdm : sDMs) {
				if (String.isBlank(sdm.EUR_CRM_Stock_Deal_Name__c)) { continue; }
				sdmSelectOptions.add(new SelectOption(sdm.Id, sdm.EUR_CRM_Stock_Deal_Name__c));
			}
			return sdmSelectOptions;
		}

		private List<EUR_CRM_Contract_Mechanic__c> getCurrentContractMechanics(List<EUR_CRM_Contract_Mechanic__c> cMs) {
			List<EUR_CRM_Contract_Mechanic__c> currentCMs = new List<EUR_CRM_Contract_Mechanic__c>();
			for (EUR_CRM_Contract_Mechanic__c cm : cMs) {
				if ( ! this.isContrMechInCurrentMt(cm)) { continue; }
				currentCMs.add(cm);
			}
			return currentCMs;
		}

		private List<SelectOption> getContractMechanicSelectOptions(List<EUR_CRM_Contract_Mechanic__c> cMs) {
			if ( ! MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(this.mtWrapper.mtExtId)) { return new List<SelectOption>(); }
			List<SelectOption> sdmSelectOptions = new List<SelectOption>();
			for (EUR_CRM_Contract_Mechanic__c cm : cMs) {
				sdmSelectOptions.add(new SelectOption(cm.Id, cm.EUR_CRM_Mechanic_Name__c));
			}
			return sdmSelectOptions;
		}


		/* ========================================================= */
		/*      BrandQualityWrapper Low Level Helpers
		/* ========================================================= */
		private Boolean isContrMechInCurrentMt(EUR_CRM_Contract_Mechanic__c cm) {
			return this.mtWrapper.mtExtId == cm.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
		}

		private Boolean isCpiWithoutCaiId(Map<String, EUR_CRM_Contract_Activity_Item__c> caiByMtExtId) {
			return cpi.EUR_CRM_Contract_Activity_Item__c == null && caiByMtExtId.containsKey(this.mtWrapper.mtExtId);
		}


		/* ========================================================= */
		/*      BrandQualityWrapper Makers
		/* ========================================================= */
		private EUR_CRM_Contract_Product_Item__c makeCpi(EUR_CRM_Contract_Activity_Item__c cai) {
			Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Contract_Product_Item').getRecordTypeId();
			return new EUR_CRM_Contract_Product_Item__c(
				EUR_CRM_Brand_Quality__c = this.bq.Id
			, 	EUR_Min_Qty_Per_Annum_9L__c = 0
			, 	EUR_CRM_Retro_Per_9L__c = 0
			, 	EUR_CRM_Contract_Activity_Item__c = cai.Id
			,	EUR_CRM_Available_by_the_Glass__c = false
			,	RecordTypeId = rtId
			,	EUR_CRM_Contract_Mechanic__c = this.cms[0].Id
			);
		}
	}
}