/**
 * 1. Select EUR_CRM_Account__c with the specified RecordType.DeveloperNames and EUR_CRM_Status__c != 'Inactive'
 * 2. Get PRS lookup fields from each account.
 * 3. Select EUR_CRM_JB_Template_Criteria__c where lookups from (2) and EUR_JB_Active__c = true
 * 4. For each account take PRS lookup fields as a key and find EUR_CRM_JB_Template_Criteria__c with equal key then
 * 5. Assign EUR_CRM_Account__c.EUR_CRM_Listing_Template__c = EUR_CRM_JB_Template_Criteria__c.EUR_JB_Template__c
 */

global with sharing class EUR_CRM_AccountListingTemplateBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	private Map<String, String> templateCriteriaRtByAccRt;
	private Set<Id> groupOutletTypeIds = new Set<Id>();
	private Set<Id> outletTypeIds = new Set<Id>();
	private Set<Id> imageLevelIds = new Set<Id>();
	private Set<Id> volumePotentialIds = new Set<Id>();

	global EUR_CRM_AccountListingTemplateBatch(Map<String, String> templateCriteriaRtByAccRt) {
		this.templateCriteriaRtByAccRt = templateCriteriaRtByAccRt;
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
			,	EUR_CRM_PRS_Group_Outlet_Type__c
			,	EUR_CRM_PRS_Outlet_Type__c
			,	EUR_CRM_PRS_Image_Level__c
			,	EUR_CRM_PRS_Volume_Potential__c
			,	EUR_CRM_Listing_Template__c
			,	RecordType.DeveloperName
			FROM EUR_CRM_Account__c
			WHERE RecordType.DeveloperName IN :this.templateCriteriaRtByAccRt.keySet()
			AND EUR_CRM_Status__c != 'Inactive'
		]);
	}

	global void execute(Database.BatchableContext bc, List<EUR_CRM_Account__c> accounts) {
		this.getAccountsPrs(accounts);

		Map<String, String> templateByPrsKey = this.getTemplateByPrsKey(this.selectTemplateCriteriaWherePrs());
		System.debug('\n templateCriteriaByPrsKey.size() => ' + templateByPrsKey.size() + '\n');
		System.debug('\n templateCriteriaByPrsKey => ' + JSON.serializePretty(templateByPrsKey) + '\n');
		if (templateByPrsKey.isEmpty()) { return; }

		List<EUR_CRM_Account__c> updatedAccounts = this.assignTemplate(accounts, templateByPrsKey);
		System.debug('\n updatedAccounts.size() => ' + updatedAccounts.size() + '\n');
		System.debug('\n updatedAccounts => ' + JSON.serializePretty(updatedAccounts) + '\n');
		if (updatedAccounts.isEmpty()) { return; }
		this.upsertRecords(updatedAccounts);

	}

	global override void finish(Database.BatchableContext bc) {
		super.finish(bc);
	}


	private void getAccountsPrs(List<EUR_CRM_Account__c> accsToUpdate) {
		for (EUR_CRM_Account__c acc : accsToUpdate) {
			groupOutletTypeIds.add(acc.EUR_CRM_PRS_Group_Outlet_Type__c);
			outletTypeIds.add(acc.EUR_CRM_PRS_Outlet_Type__c);
			imageLevelIds.add(acc.EUR_CRM_PRS_Image_Level__c);
			volumePotentialIds.add(acc.EUR_CRM_PRS_Volume_Potential__c);
		}
	}

	private String getAccountPrsKey(EUR_CRM_Account__c acc) {
		return (String) acc.EUR_CRM_PRS_Group_Outlet_Type__c
			+ (String) acc.EUR_CRM_PRS_Outlet_Type__c
			+ (String) acc.EUR_CRM_PRS_Image_Level__c
			+ (String) acc.EUR_CRM_PRS_Volume_Potential__c;
	}

	private Map<String, String> getTemplateByPrsKey(List<EUR_CRM_JB_Template_Criteria__c> templateCriteria) {
		System.debug('\n templateCriteria.size() => ' + templateCriteria.size() + '\n');
		System.debug('\n templateCriteria => ' + JSON.serializePretty(templateCriteria) + '\n');
		if (templateCriteria.isEmpty()) { return new Map<String, String>(); }

		Map<String, String> templateByPrsKey = new Map<String, String>();
		for (EUR_CRM_JB_Template_Criteria__c criterion : templateCriteria) {
			templateByPrsKey.put(
				(String) criterion.EUR_CRM_PRS_Group_Outlet_Type__c
					+ (String) criterion.EUR_CRM_PRS_Outlet_Type__c
					+ (String) criterion.EUR_CRM_PRS_Seg_Aspect_IL__c
					+ (String) criterion.EUR_CRM_PRS_Seg_Aspect_VP__c, (String) criterion.EUR_JB_Template__c);
		}
		return templateByPrsKey;
	}

	private List<EUR_CRM_Account__c> assignTemplate(List<EUR_CRM_Account__c> accsToUpdate, Map<String, String> templateByPrsKey) {
		List<EUR_CRM_Account__c> updatedAccounts = new List<EUR_CRM_Account__c>();
		for (EUR_CRM_Account__c acc : accsToUpdate) {
			String accPrsKey = this.getAccountPrsKey(acc);
			if ( ! templateByPrsKey.containsKey(accPrsKey)) { continue; }
			acc.EUR_CRM_Listing_Template__c = templateByPrsKey.get(accPrsKey);
			updatedAccounts.add(acc);
		}
		return updatedAccounts;
	}

	private List<EUR_CRM_JB_Template_Criteria__c> selectTemplateCriteriaWherePrs() {
		return [
			SELECT Name
				,   EUR_JB_Template__c
				,   EUR_CRM_PRS_Group_Outlet_Type__c
				,   EUR_CRM_PRS_Group_Outlet_Type_Name__c
				,   EUR_CRM_PRS_Outlet_Type__c
				,   EUR_CRM_PRS_Outlet_Type_Name__c
				,   EUR_CRM_PRS_Seg_Aspect_IL__c
				,   EUR_CRM_PRS_Segmentation_IL_Aspect_Name__c
				,   EUR_CRM_PRS_Seg_Aspect_VP__c
				,   EUR_CRM_PRS_Segmentation_VP_Aspect_Name__c
				,   EUR_JB_Active__c
			FROM EUR_CRM_JB_Template_Criteria__c
			WHERE EUR_CRM_PRS_Group_Outlet_Type__c IN :groupOutletTypeIds
			AND EUR_CRM_PRS_Outlet_Type__c IN :outletTypeIds
			AND EUR_CRM_PRS_Seg_Aspect_IL__c IN :imageLevelIds
			AND EUR_CRM_PRS_Seg_Aspect_VP__c IN :volumePotentialIds
			AND EUR_JB_Active__c = true
			AND RecordTYpe.DeveloperName IN :templateCriteriaRtByAccRt.values()
		];
	}

}