public with sharing class EUR_CRM_FI_LumpSumBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{
	@TestVisible private static final String FI_MARKETING_ACTIVITY_SPIRITS = 'EUR_FI_Mktg_Activity_Spirits';
	@TestVisible private static final String FI_MARKETING_ACTIVITY_WINES = 'EUR_FI_Mktg_Activity_Wines';
	@TestVisible private static final String LUMPSUM_SPIRITS = 'Lumpsum Spirits';
	@TestVisible private static final String LUMPSUM_WINE = 'Lumpsum Wine';
	@TestVisible private static final String FI_CPI_RT = 'EUR_FI_Contract_Product_Item';

	@TestVisible private static final Map<String, String> CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS = new Map<String, String>{
		FI_MARKETING_ACTIVITY_SPIRITS => LUMPSUM_SPIRITS
	,	FI_MARKETING_ACTIVITY_WINES => LUMPSUM_WINE
	};

	private List<EUR_CRM_Contract_Product_Item__c> cpisToUpdate = new List<EUR_CRM_Contract_Product_Item__c>();

	public Iterable<SObject> start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
			,	EUR_CRM_Lumpsum_Value__c
			,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	(
				SELECT Id
				,	EUR_CRM_Brand__r.Name
				,	EUR_CRM_Marketing_Amount__c
				FROM Contract_Product_Items__r
			)
			FROM EUR_CRM_Contract_Activity_Item__c
			WHERE EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = 'FI'
			AND EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c IN :CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.keySet()
			AND EUR_CRM_Contract__r.EUR_CRM_Status__c != 'Cancelled'
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Contract_Activity_Item__c> cais) {
		RecordTypeInfo cpiRtInfo = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(FI_CPI_RT);
		if (cpiRtInfo == null) { return; }
		Id cpiRtId = cpiRtInfo.getRecordTypeId();
		List<EUR_CRM_Contract_Activity_Item__c> caiToCreateCpi = this.getCaisToCreateLumpSumCpi(cais);
		System.debug('\n caiToCreateCpi.size() => ' + caiToCreateCpi.size() + '\n');
		System.debug('\n caiToCreateCpi => ' + JSON.serializePretty(caiToCreateCpi) + '\n');

		System.debug('\n this.cpisToUpdate.size() => ' + this.cpisToUpdate.size() + '\n');
		System.debug('\n this.cpisToUpdate => ' + JSON.serializePretty(this.cpisToUpdate) + '\n');
		if ( ! this.cpisToUpdate.isEmpty()) { this.upsertRecords(this.cpisToUpdate); }
		if (caiToCreateCpi.isEmpty()) { return; }

		List<EUR_CRM_Contract_Product_Item__c> lumpSumCpisToInsert = this.makeCpis(cpiRtId, caiToCreateCpi);
		System.debug('\n lumpSumCpisToInsert.size() => ' + lumpSumCpisToInsert.size() + '\n');
		System.debug('\n lumpSumCpisToInsert => ' + JSON.serializePretty(lumpSumCpisToInsert) + '\n');

		this.upsertRecords(lumpSumCpisToInsert);

		this.finish(bc);
	}

	public List<EUR_CRM_Contract_Activity_Item__c> clearCaisLumpsumValue() {
		List<EUR_CRM_Contract_Activity_Item__c> caisToClear = this.getCaisToClearLumpSumValue();
		System.debug('\n caisToClear.size() => ' + caisToClear.size() + '\n');
		System.debug('\n caisToClear => ' + JSON.serializePretty(caisToClear) + '\n');
		if (caisToClear.isEmpty()) { return caisToClear;}
		for (EUR_CRM_Contract_Activity_Item__c cai : caisToClear) {
			cai.EUR_CRM_Lumpsum_Value__c = null;
		}
		System.debug('\n caisToClear.size() => ' + caisToClear.size() + '\n');
		System.debug('\n caisToClear => ' + JSON.serializePretty(caisToClear) + '\n');
		this.upsertRecords(caisToClear);
		return caisToClear;
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_Contract_Activity_Item__c> getCaisToCreateLumpSumCpi(List<EUR_CRM_Contract_Activity_Item__c> cais) {
		List<EUR_CRM_Contract_Activity_Item__c> filteredCais = new List<EUR_CRM_Contract_Activity_Item__c>();
		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			String mtExtId = cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			if ( ! this.isCaiValid(cai)) { continue; }
			if ( ! this.isLumpSumCpiExist(mtExtId, cai)) {
				filteredCais.add(cai);
			}
		}
		return filteredCais;
	}

	private Map<String, EUR_CRM_Brand__c> getLumpSumBrandByName() {
		Map<String, EUR_CRM_Brand__c> lsBrandByName = new Map<String, EUR_CRM_Brand__c>();
		List<EUR_CRM_Brand__c> lsBrands = this.selectLumpSumBrands();
		if (lsBrands.isEmpty()) {
			return lsBrandByName;
		}
		for (EUR_CRM_Brand__c brand : lsBrands) {
			lsBrandByName.put(brand.Name, brand);
		}
		return lsBrandByName;
	}

	private List<EUR_CRM_Contract_Activity_Item__c> getCaisToClearLumpSumValue() {
		List<EUR_CRM_Contract_Product_Item__c> cpisToClearCais = this.selectCpisToClearCais();
		System.debug('\n cpisToClearCais.size() => ' + cpisToClearCais.size() + '\n');
		System.debug('\n cpisToClearCais => ' + JSON.serializePretty(cpisToClearCais) + '\n');
		if (cpisToClearCais.isEmpty()) { return new List<EUR_CRM_Contract_Activity_Item__c>(); }

		Set<Id> caiIds = new Set<Id>();
		for (EUR_CRM_Contract_Product_Item__c cpi : cpisToClearCais) {
			String mtExtId = cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			String brandName = CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.get(mtExtId);
			if (brandName != null && brandName == cpi.EUR_CRM_Brand__r.Name) {
				caiIds.add(cpi.EUR_CRM_Contract_Activity_Item__c);
			}
		}
		return this.selectCaisWhereIds(caiIds);
	}


	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private Boolean isLumpSumCpiExist(String mtExtId, EUR_CRM_Contract_Activity_Item__c cai) {
		String mockedBrandName = CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.get(mtExtId);
		if (mockedBrandName == null) { return false; }

		for (EUR_CRM_Contract_Product_Item__c cpi : cai.Contract_Product_Items__r) {
			if ( ! this.isLumpSumCpi(mockedBrandName, cpi)) { continue; }
			if (this.isMarketingAmountEquals(cpi, cai.EUR_CRM_Lumpsum_Value__c)) {
				return true;
			} else {
				this.updateCpi(cpi, cai);
				return true;
			}
		}
		return false;
	}

	private void updateCpi(EUR_CRM_Contract_Product_Item__c cpi, EUR_CRM_Contract_Activity_Item__c cai) {
		cpi.EUR_CRM_Marketing_Amount__c = cai.EUR_CRM_Lumpsum_Value__c;
		this.cpisToUpdate.add(cpi);
	}

	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private Boolean isCaiValid(EUR_CRM_Contract_Activity_Item__c cai) {
		return this.isCaiMtValid(cai) && this.isNotBlank(cai.EUR_CRM_Lumpsum_Value__c);
	}

	private Boolean isCaiMtValid(EUR_CRM_Contract_Activity_Item__c cai) {
		return CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.containsKey(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
	}
	private Boolean isNotBlank(Decimal val) {
		return ! (val == null || val == 0);
	}

	private Boolean isLumpSumCpi(String mockedBrandName, EUR_CRM_Contract_Product_Item__c cpi) {
		return cpi.EUR_CRM_Brand__r.Name == mockedBrandName;
	}

	private Boolean isMarketingAmountEquals(EUR_CRM_Contract_Product_Item__c cpi, Decimal caiLumpSumVal) {
		return cpi.EUR_CRM_Marketing_Amount__c == caiLumpSumVal;
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private List<EUR_CRM_Contract_Product_Item__c> makeCpis(Id rtId, List<EUR_CRM_Contract_Activity_Item__c> cais) {
		List<EUR_CRM_Contract_Product_Item__c> cpis = new List<EUR_CRM_Contract_Product_Item__c>();
		Map<String, EUR_CRM_Brand__c> lumpSumBrandByName = this.getLumpSumBrandByName();
		if (lumpSumBrandByName.isEmpty()) { return cpis; }

		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			String mtExtId = cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			String mockedBrandName = CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.get(mtExtId);
			if (String.isNotBlank(mockedBrandName) && lumpSumBrandByName.containsKey(mockedBrandName)) {
				cpis.add(this.makeCpi(rtId, cai, lumpSumBrandByName.get(mockedBrandName).Id));
			}
		}
		return cpis;
	}

	private EUR_CRM_Contract_Product_Item__c makeCpi(Id rtId, EUR_CRM_Contract_Activity_Item__c cai, Id brandId) {
		return new EUR_CRM_Contract_Product_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Contract_Activity_Item__c = cai.Id
		,	EUR_CRM_Brand__c = brandId
		,	EUR_CRM_Marketing_Amount__c = cai.EUR_CRM_Lumpsum_Value__c
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_Brand__c> selectLumpSumBrands() {
		return [
			SELECT Id
			,	Name
			FROM EUR_CRM_Brand__c
			WHERE Name IN :CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.values()
		];
	}

	private List<EUR_CRM_Contract_Product_Item__c> selectCpisToClearCais() {
		return [
			SELECT Id
			,	EUR_CRM_Marketing_Amount__c
			,	EUR_CRM_Brand__r.Name
			,	EUR_CRM_Contract_Activity_Item__c
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			FROM EUR_CRM_Contract_Product_Item__c
			WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = 'FI'
			AND EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c IN :CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.keySet()
			AND EUR_CRM_Marketing_Amount__c != NULL
			AND EUR_CRM_Brand__r.Name IN :CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.values()
		];
	}

	private List<EUR_CRM_Contract_Activity_Item__c> selectCaisWhereIds(Set<Id> ids) {
		return [
			SELECT Id
			,	EUR_CRM_Lumpsum_Value__c
			FROM EUR_CRM_Contract_Activity_Item__c
			WHERE Id IN :ids
		];
	}
}