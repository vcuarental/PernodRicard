public without sharing class EUR_CRM_GB_ContractSummaryController {

	public EUR_CRM_Contract__c contractObj { get; private set; }
	public Id contrId { get; private set; }
	public Map<String, MechanicTypeWrapper> mtWrapByMtExtId { get; private set; }
	public String currencyCode { get { return String.valueOf(contractObj.CurrencyIsoCode); }}

	private static final Set<String> MARKETING_PACKAGE_MTS_EXTID = new Set<String>{
		'GB_Bar_support'
		,'GB_Lump_Sum'
		,'GB_Free_Stock'
		,'GB_Point_of_Sales'
		,'GB_Educations'
		,'GB_Trips'
		,'GB_Marketing_Support'
	};

	public static final String CPI_TABLE_PREFIX { get{ return 'CPI_Table_'; }}

	public EUR_CRM_GB_ContractSummaryController(ApexPages.StandardController stdController){
		this.contrId = stdController.getId();
		if (this.contrId == null){
			addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
		} else {
			initContract();
			initContractContent();
		}
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private void initContract() {
		this.contractObj = this.selectContract(this.contrId);
	}
	private void initContractContent() {
		List<EUR_CRM_Contract_Activity_Item__c> cais = this.selectCAIsWhereContrId(this.contractObj.Id);
		this.mtWrapByMtExtId = new Map<String, MechanicTypeWrapper>();

		Map<String, EUR_CRM_Mechanic_Type__c> mtByMtExtId = this.getMtByMtExtId();
		for (String mtExtId : mtByMtExtId.keySet()) {
			this.mtWrapByMtExtId.put(mtExtId, new MechanicTypeWrapper(mtByMtExtId.get(mtExtId)));
		}
		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			if ( ! this.mtWrapByMtExtId.containsKey(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c)) { continue; }
			if (this.mtWrapByMtExtId.get(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c).mechanicTypeName == 'Other Support') {
				this.mtWrapByMtExtId.get(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c).setOtherSupportMtWrapper(cai);
			} else {
				this.mtWrapByMtExtId.get(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c).setMtWrapper(cai);
			}
		}
		System.debug('\n mtWrapByMtName.size() => ' + mtWrapByMtExtId.size() + '\n');
	}

	private Map<String, EUR_CRM_Mechanic_Type__c> getMtByMtExtId() {
		List<EUR_CRM_Mechanic_Type__c> mts = this.selectMts();
		Map<String, EUR_CRM_Mechanic_Type__c> mtByMtExtId = new Map<String, EUR_CRM_Mechanic_Type__c>();
		for (EUR_CRM_Mechanic_Type__c mt : mts) {
			mtByMtExtId.put(mt.EUR_CRM_External_ID__c, mt);
		}
		return mtByMtExtId;
	}


	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private void addMessage(ApexPages.Severity severity, String message){
		ApexPages.addMessage(new ApexPages.Message(severity, message));
	}

	public Boolean getIsShowMarketingPackage() {
		if (this.mtWrapByMtExtId.isEmpty()) { return false; }
		for (String marketingtMtExtId : MARKETING_PACKAGE_MTS_EXTID) {
			if ( ! this.mtWrapByMtExtId.containsKey(marketingtMtExtId)) { continue; }
			if (this.mtWrapByMtExtId.get(marketingtMtExtId).cpisSize > 0 || this.isShowLumpSumOrBarSupport(marketingtMtExtId)) {
				return true;
			}
		}
		return false;
	}
	@TestVisible
	private Boolean isShowLumpSumOrBarSupport(String marketingtMtExtId) {
		return this.isLumpSumOrBurSupport(marketingtMtExtId)
			&& this.mtWrapByMtExtId.get(marketingtMtExtId).cai.EUR_CRM_Amount__c != 0;
	}
	@TestVisible
	private Boolean isLumpSumOrBurSupport(String mtExtId) {
		return mtExtId == 'GB_Bar_support'
			|| mtExtId == 'GB_Lump_Sum';
	}
	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private EUR_CRM_Contract__c selectContract(Id contrId) {
		return [
			SELECT Id
			,	Name
			,	EUR_CRM_Account__c
			,	EUR_CRM_Contact__c
			,	EUR_CRM_End_Date__c
			,	EUR_CRM_Nominated_Supplier__c
			,	EUR_CRM_Payment_Method__c
			,	EUR_CRM_Start_Date__c
			,	EUR_CRM_Status__c
			,	EUR_CRM_Marketing_Package_Lump_Sum__c
			,	EUR_CRM_Mktg_Package_Mechanic_Handling__c
			,	EUR_CRM_Active__c
			,	EUR_CRM_Contract_Approved_Date__c
			,	EUR_CRM_Total_Contract_Line_Items__c
			,	EUR_CRM_Cocktail_Percent__c
			,	EUR_CRM_Customer_Agreed_With_No_Sign_off__c
			,	EUR_CRM_Country_Code__c
			,	EUR_CRM_Agrees_with_TC__c
			,	EUR_CRM_Contract_Uploaded__c
			,	EUR_CRM_Total_Contract_Value__c
			,	CurrencyIsoCode
			FROM EUR_CRM_Contract__c
			WHERE Id =: contrId
		];
	}
	private List<EUR_CRM_Contract_Activity_Item__c> selectCAIsWhereContrId(Id contractId) {
		return [
				SELECT Id
						, EUR_CRM_Mechanic_Type_Name__c
						, EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
						, EUR_CRM_Contract__c
						, EUR_CRM_Total_Value__c
						, EUR_CRM_Amount__c
						, EUR_CRM_Total_Spent_Free_cases__c
						, EUR_CRM_Description__c
						, EUR_CRM_Min_Percentage_Share_of_MRM_Menu__c
						, EUR_CRM_Product_Qty_Total__c
						, EUR_CRM_Total_Free_Bottles__c
						, EUR_CRM_Total_Value_Support_GB__c
						, (
						SELECT Id
								, EUR_CRM_Total_Spend__c
								, EUR_Min_Qty_Per_Annum_9L__c
								, EUR_CRM_Retro_Per_9L__c
								, EUR_CRM_Stock_Deal_Mechanic__r.EUR_CRM_Stock_Deal_Name__c
								, EUR_CRM_No_of_People__c
								, EUR_CRM_No_of_Cocktails__c
								, EUR_CRM_Brand_Quality__r.Name
								, EUR_CRM_Brand_Quality_Name__c
								, EUR_CRM_Available_by_the_Glass__c
								, EUR_CRM_Cocktail_Menu__c
								, EUR_CRM_Value__c
								, EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c
								, EUR_CRM_Free_Cases_9L__c
								, EUR_CRM_Optics__c
								, EUR_CRM_Brand__r.Name
								, EUR_CRM_Quantity__c
								, EUR_CRM_Activation__c
								, EUR_CRM_Type_of_Support__c
								, EUR_CRM_ZA_Payment_Terms__c
								, EUR_CRM_Product_Name__c
								, EUR_CRM_Timing__c
								, EUR_CRM_Total_Spend_inc_free_cases__c
								, EUR_CRM_Minimum_Bottles_To_Purchase__c
								, EUR_CRM_Mechanic_Value__c
								, EUR_CRM_No_of_Bottles__c
								, EUR_CRM_POS_type__c
								, EUR_CRM_Total_Free_Stock__c
						FROM Contract_Product_Items__r
				)
				FROM EUR_CRM_Contract_Activity_Item__c
				WHERE EUR_CRM_Contract__c = :contractId
		];
	}

	private List<EUR_CRM_Mechanic_Type__c> selectMts() {
		return [
			SELECT Id
			,	EUR_CRM_External_ID__c
			,	Name
			FROM EUR_CRM_Mechanic_Type__c
			WHERE EUR_CRM_Country_Code__c = 'GB'
		];
	}


	/* ========================================================= */
	/*      Wrappers
	/* ========================================================= */
	public class MechanicTypeWrapper {
		public EUR_CRM_Contract_Activity_Item__c cai {get; set;}
		public List<EUR_CRM_Contract_Activity_Item__c> otherCais {get; set;}
		public List<EUR_CRM_Contract_Product_Item__c> cpis {get; set;}
		public Integer cpisSize {get; set;}
		public Id mtId {get; set;}
		public String mechanicTypeName {get; set; }

		public MechanicTypeWrapper(EUR_CRM_Mechanic_Type__c mt) {
			this.cai = new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 0);
			this.cpis = this.cai.Contract_Product_Items__r;
			this.cpisSize = this.cpis.size();
			this.mtId = mt.Id;
			this.mechanicTypeName = mt.Name;
		}

		public MechanicTypeWrapper(EUR_CRM_Contract_Activity_Item__c cai) {
			this.cai = cai;
			this.cpis = cai.Contract_Product_Items__r;
			this.cpisSize = this.cpis.size();
			this.mtId = cai.EUR_CRM_Mechanic_Type__c;
			this.mechanicTypeName = cai.EUR_CRM_Mechanic_Type_Name__c;
		}

		private void setMtWrapper(EUR_CRM_Contract_Activity_Item__c cai) {
			this.cai = cai;
			this.cpis = cai.Contract_Product_Items__r;
			this.cpisSize = this.cpis.size();
			this.mtId = cai.EUR_CRM_Mechanic_Type__c;
			this.mechanicTypeName = cai.EUR_CRM_Mechanic_Type_Name__c;
		}

		private void setOtherSupportMtWrapper(EUR_CRM_Contract_Activity_Item__c cai) {
			if (this.otherCais == null) {
				otherCais = new List<EUR_CRM_Contract_Activity_Item__c>{cai};
				this.mtId = cai.EUR_CRM_Mechanic_Type__c;
				this.mechanicTypeName = cai.EUR_CRM_Mechanic_Type_Name__c;
			} else {
				otherCais.add(cai);
			}
		}
	}
}