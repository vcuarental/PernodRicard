/*
	VF - Visit Frequency
	VFC - Visit Frequency Criteria
	CT - Customer Taxonomy
	GOT - Group Outlet Type
	OT - Outlet Type
	IL - Image Level
	VP - Volume Potential
* */

public with sharing class EUR_CRM_AccountVisitFrequencyHandler extends EUR_CRM_TriggerAbstract{
	
	public EUR_CRM_AccountVisitFrequencyHandler(){
        super('EUR_CRM_AccountVisitFrequencyHandler');
    }

	private static final String CLASS_NAME = 'EUR_CRM_AccountVisitFrequencyHandler';
    private final static Set<String> ACC_RT_TO_ASSIGN_VF = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'ACC_RT_TO_ASSIGN_VF');
//    private final static Set<String> ACC_RT_TO_ASSIGN_VF = new Set<String>{
//    	'EUR_GB_FS_Indirect',
//    	'EUR_BG_Modern_Off_Trade',
//    	'EUR_BG_Wholesaler',
//    	'EUR_BE_Off_Trade'
//    };

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(ACC_RT_TO_ASSIGN_VF);
            
            return TRt;
        }private set;
    }


	//before insert and before update trigger
	//UK on trade FS accounts, visit frequency depends on the PROS segment; once PROS is defined, visit frequency will be automatically selected
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
		System.Debug('EUR_CRM_AccountVisitFrequencyHandler');
		List<EUR_CRM_Account__c> accounts = (List<EUR_CRM_Account__c>) sObjList;
		Map<Id, RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById();
		Set<String> prosGOTids = new Set<String>();
		Set<String> prosOTids = new Set<String>();
		Set<String> prosILids = new Set<String>();
		Set<String> prosVPids = new Set<String>();
		Set<String> prsGOTids = new Set<String>();
		Set<String> prsOTids = new Set<String>();
		Set<String> prsILids = new Set<String>();
		Set<String> prsVPids = new Set<String>();
		Set<String> cts = new Set<String>();
		Set<String> vfRTs = new Set<String>();
		List<EUR_CRM_Account__c> accsToUpdateVFviaPROS = new List<EUR_CRM_Account__c>();
		List<EUR_CRM_Account__c> accsToUpdateVFviaPRS = new List<EUR_CRM_Account__c>();
		List<EUR_CRM_Account__c> accsToUpdateVFviaProsTaxonomy = new List<EUR_CRM_Account__c>();
		List<EUR_CRM_Account__c> accsToUpdateVFviaDelivery = new List<EUR_CRM_Account__c>();

		if(tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE){
			for(EUR_CRM_Account__c acc : accounts){
				if ( ! this.isValidRTtoAssignVF(rtInfoById, acc)){ continue; }
				system.debug('record verified to use PROS assign visit frequency');

				if (this.isNeedToUpdateViaDelivery(rtInfoById, acc)){
					vfRTs.add('EUR_' + acc.EUR_CRM_Country_Code__c + '_Visit_Frequency');
					accsToUpdateVFviaDelivery.add(acc);
				}
				if (this.isNeedToUpdateByPros(acc, rtInfoById)) {
					prosGOTids.add(acc.EUR_CRM_Group_Outlet_Type__c);
					prosOTids.add(acc.EUR_CRM_Outlet_Type__c);
					prosILids.add(acc.EUR_CRM_Image_Level__c);
					prosVPids.add(acc.EUR_CRM_Volume_Potential__c);
					accsToUpdateVFviaPROS.add(acc);
				}
				if (this.isNeedToUpdateByPrs(acc)) {
					prsGOTids.add(acc.EUR_CRM_PRS_Group_Outlet_Type__c);
					prsOTids.add(acc.EUR_CRM_PRS_Outlet_Type__c);
					prsILids.add(acc.EUR_CRM_PRS_Image_Level__c);
					prsVPids.add(acc.EUR_CRM_PRS_Volume_Potential__c);
					accsToUpdateVFviaPRS.add(acc);
					System.debug('\n accsToUpdateVFviaPRS.size() => ' + accsToUpdateVFviaPRS.size() + '\n');
					System.debug('\n accsToUpdateVFviaPRS => ' + JSON.serializePretty(accsToUpdateVFviaPRS) + '\n');
				}
				if (this.isNeedToUpdateByCustomerTaxonomy(acc)) {
					// For BG Modern Off Trade Visit Frequency Assignment
					cts.add(acc.EUR_JB_Customer_Taxonomy__c);
					vfRTs.add('EUR_' + acc.EUR_CRM_Country_Code__c + '_Visit_Frequency');
					accsToUpdateVFviaProsTaxonomy.add(acc);
				}
			}

			if( ! accsToUpdateVFviaDelivery.isEmpty()){ this.assignVisitFreqViaDeliveryType(accsToUpdateVFviaDelivery, vfRTs); }
			if( ! accsToUpdateVFviaPROS.isEmpty()){ this.assignVisitFreqViaPROS(accsToUpdateVFviaPROS, prosGOTids, prosOTids, prosILids, prosVPids); }
			if( ! accsToUpdateVFviaPRS.isEmpty()) { this.assignVisitFreqViaPRS(accsToUpdateVFviaPRS, prsGOTids, prsOTids, prsILids, prsVPids); }
			if( ! accsToUpdateVFviaProsTaxonomy.isEmpty()) { this.assignVisitFreqViaTaxonomy(accsToUpdateVFviaProsTaxonomy, vfRTs, cts); }
		}
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	/**
	*  function: assignVisitFreqViaProsSegmentation
	*  Assigns visit frequency to Account based on PROS segmentation lookups (Group Outlet Type, Outlet Type, Image Level, Volume Potential)
	*  Input: List of accounts, and Set of prosGOT, prosOT, prosIL, prosVP
	*/
	private void assignVisitFreqViaPROS(List<EUR_CRM_Account__c> accounts, Set<String> prosGOTids, Set<String> prosOTids, Set<String> prosILids, Set<String> prosVPids) {
		Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByCustomProsKey = this.getVFCbyCustomProsKey(prosGOTids, prosOTids, prosILids, prosVPids);
		System.debug('\n vfcByCustomProsKey.size() => ' + vfcByCustomProsKey.size() + '\n');
		System.debug('\n vfcByCustomProsKey => ' + JSON.serializePretty(vfcByCustomProsKey) + '\n');
		if (vfcByCustomProsKey.isEmpty()) { return; }

		this.assignAccountVFbyPros(accounts, vfcByCustomProsKey);
	}

	/**
	*  function: assignVisitFreqViaPrsSegmentation
	*  Assigns visit frequency to Account based on PRS segmentation lookups (PRS Group Outlet Type, PRS Outlet Type, PRS Image Level, PRS Volume Potential)
	*  Input: List of accounts, and Set of prsGOT, prsOT, prsIL, prsVP
	*/
	private void assignVisitFreqViaPRS(List<EUR_CRM_Account__c> accounts, Set<String> prsGOTids, Set<String> prsOTids, Set<String> prsILids, Set<String> prsVPids) {
		Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByCustomPrsKey = this.getVFCbyCustomPrsKey(prsGOTids, prsOTids, prsILids, prsVPids);
		System.debug('\n vfcByCustomPrsKey.size() => ' + vfcByCustomPrsKey.size() + '\n');
		System.debug('\n vfcByCustomPrsKey => ' + JSON.serializePretty(vfcByCustomPrsKey) + '\n');
		if (vfcByCustomPrsKey.isEmpty()) { return; }

		this.assignAccountVFbyPrs(accounts, vfcByCustomPrsKey);
	}

	/**
	*  function: assignVisitFreqViaDeliveryType
	*  Assigns visit frequency to Account based on each account's delivery type and record types
	*  Input: List of accounts, and Set of visit frequency record types
	*/
	private void assignVisitFreqViaDeliveryType(List<EUR_CRM_Account__c> acctList, Set<String> recordTypeFrequency){
		System.Debug('>>>assignVisitFreqViaDeliveryType');
		List<EUR_CRM_Visit_Frequency__c> visitFrequencies = this.selectVFCwhereRT(recordTypeFrequency);
		for(EUR_CRM_Account__c acc : acctList){
			if(acc.EUR_CRM_Delivery_Type__c == 'Direct'){
				for(EUR_CRM_Visit_Frequency__c vf : visitFrequencies){
					if(vf.name == 'Once a week') acc.EUR_CRM_Visit_Frequency__c = vf.Id;
				}
			} else if(acc.EUR_CRM_Delivery_Type__c == 'Indirect'){
				for(EUR_CRM_Visit_Frequency__c vf : visitFrequencies){
					if(vf.name == 'Once every 2 weeks') acc.EUR_CRM_Visit_Frequency__c = vf.Id;
				}
			}
		}
	}

	/**
	*  function: assignVisitFreqViaTaxonomy
	*  Assigns visit frequency to Account based on each account's customer taxonomy and record types
	*  Input: List of accounts, Set of visit frequency record types, and set of customer taxonomy record types
	*/
	private void assignVisitFreqViaTaxonomy(List<EUR_CRM_Account__c> accVisitFreqUpdate, Set<String> visitFrequencyRecordTypeSet, Set<String> customerTaxonomySet) {
		// Retrieves Visit Frequency Records based on the record types
		Map<Id,EUR_CRM_Visit_Frequency__c> vfById = this.selectVFbyIdWhereRTs(visitFrequencyRecordTypeSet);
		System.debug('\n vfById.size() => ' + vfById.size() + '\n');
		System.debug('\n vfById => ' + JSON.serializePretty(vfById) + '\n');

		// Retrieves Customer Taxonomy based on the record types
		Map<Id, EUR_CRM_Customer_Taxonomy__c> ctById = this.selectCTbyIdWhereIds(customerTaxonomySet);

		EUR_CRM_Visit_Frequency__c biWeeklyVisitFrequency;
		EUR_CRM_Visit_Frequency__c onceAMonthVisitFrequency;

		for(EUR_CRM_Visit_Frequency__c vf: vfById.values()) {
			if(vf.Name == 'Once every 1 month') {
				onceAMonthVisitFrequency = vf;
			} else if(vf.Name == 'Once every 2 weeks') {
				biWeeklyVisitFrequency = vf;
			}
		}

		for(EUR_CRM_Account__c acc: accVisitFreqUpdate) {
			// Special case for BG OFF Indirect KA customer taxonomy
			if(ctById.get(acc.EUR_JB_Customer_Taxonomy__c).Name == 'BG_OFF_Indirect KAs') {
				if(acc.EUR_CRM_Status__c == 'Active') {
					acc.EUR_CRM_Visit_Frequency__c = biWeeklyVisitFrequency == null ? null : biWeeklyVisitFrequency.Id;
				} else if(acc.EUR_CRM_Status__c == 'Prospect') {
					acc.EUR_CRM_Visit_Frequency__c = onceAMonthVisitFrequency == null ? null : onceAMonthVisitFrequency.Id;
				}
			} else if (ctById.containsKey(acc.EUR_JB_Customer_Taxonomy__c)){
				acc.EUR_CRM_Visit_Frequency__c = ctById.get(acc.EUR_JB_Customer_Taxonomy__c).EUR_CRM_Visit_Frequency__c;
			}
		}
	}


	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private Map<String, EUR_CRM_Visit_Frequency_Criteria__c> getVFCbyCustomProsKey(
		Set<String> prosGOTids, Set<String> prosOTids, Set<String> prosILids, Set<String> prosVPids) {

		Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByCustomProsKey = new Map<String, EUR_CRM_Visit_Frequency_Criteria__c>();
		for (EUR_CRM_Visit_Frequency_Criteria__c vfc : this.selectVFCsWherePros(prosGOTids, prosOTids, prosILids, prosVPids)) {
			String key = createKey(vfc.EUR_CRM_Group_Outlet_Type__c, vfc.EUR_CRM_Outlet_Type__c, vfc.EUR_CRM_Image_Level__c, vfc.EUR_CRM_Volume_Potential__c);
			vfcByCustomProsKey.put(key, vfc);
		}
		return vfcByCustomProsKey;
	}

	private Map<String, EUR_CRM_Visit_Frequency_Criteria__c> getVFCbyCustomPrsKey(
		Set<String> prsGOTids, Set<String> prsOTids, Set<String> prsILids, Set<String> prsVPids) {

		Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByCustomProsKey = new Map<String, EUR_CRM_Visit_Frequency_Criteria__c>();
		for (EUR_CRM_Visit_Frequency_Criteria__c vfc : this.selectVFCsWherePrs(prsGOTids, prsOTids, prsILids, prsVPids)) {
			String key = createKey(vfc.EUR_CRM_PRS_Group_Outlet_Type_EU__c, vfc.EUR_CRM_PRS_Outlet_Type_EU__c, vfc.EUR_CRM_PRS_IL_Segmentation_Aspect_EU__c, vfc.EUR_CRM_PRS_VP_Segmentation_Aspect_EU__c);
			vfcByCustomProsKey.put(key, vfc);
		}
		return vfcByCustomProsKey;
	}

	private void assignAccountVFbyPros(List<EUR_CRM_Account__c> accounts, Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByCustomProsKey) {
		for (EUR_CRM_Account__c acc : accounts) {
			String key = createKey(acc.EUR_CRM_Group_Outlet_Type__c, acc.EUR_CRM_Outlet_Type__c, acc.EUR_CRM_Image_Level__c, acc.EUR_CRM_Volume_Potential__c);
			acc.EUR_CRM_Visit_Frequency__c = vfcByCustomProsKey.containsKey(key) ? vfcByCustomProsKey.get(key).EUR_CRM_Visit_Frequency__c : null;
		}
	}

	private void assignAccountVFbyPrs(List<EUR_CRM_Account__c> accounts, Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByCustomPrsKey) {
		for (EUR_CRM_Account__c acc : accounts) {
			String key = createKey(acc.EUR_CRM_PRS_Group_Outlet_Type__c, acc.EUR_CRM_PRS_Outlet_Type__c, acc.EUR_CRM_PRS_Image_Level__c, acc.EUR_CRM_PRS_Volume_Potential__c);
			acc.EUR_CRM_Visit_Frequency__c = vfcByCustomPrsKey.containsKey(key) ? vfcByCustomPrsKey.get(key).EUR_CRM_Visit_Frequency__c : null;
		}
	}


	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private Boolean isNeedToUpdateViaDelivery(Map<Id, RecordTypeInfo> rtInfoById, EUR_CRM_Account__c acc) {
		return rtInfoById.get(acc.RecordTypeId).getDeveloperName() == 'EUR_BG_Wholesaler';
	}

	private Boolean isNeedToUpdateByCustomerTaxonomy(EUR_CRM_Account__c acc) {
		return acc.EUR_JB_Customer_Taxonomy__c != null && acc.EUR_CRM_Status__c != null;
	}

	private Boolean isNeedToUpdateByPros(EUR_CRM_Account__c acc, Map<Id, RecordTypeInfo> rtInfoById) {
		return acc.EUR_CRM_Group_Outlet_Type__c != null
			&& acc.EUR_CRM_Outlet_Type__c != null
			&& acc.EUR_CRM_Volume_Potential__c != null
			&& acc.EUR_CRM_Image_Level__c != null
			&& rtInfoById.get(acc.RecordTypeId).getDeveloperName() != 'EUR_BE_Off_Trade';
	}

	private Boolean isNeedToUpdateByPrs(EUR_CRM_Account__c acc) {
		return acc.EUR_CRM_PRS_Group_Outlet_Type__c != null
			&& acc.EUR_CRM_PRS_Outlet_Type__c != null
			&& acc.EUR_CRM_PRS_Image_Level__c != null
			&& acc.EUR_CRM_PRS_Volume_Potential__c != null;
	}

	private Boolean isValidRTtoAssignVF(Map<Id, RecordTypeInfo> rtInfoById, EUR_CRM_Account__c acc) {
		return ACC_RT_TO_ASSIGN_VF.contains(rtInfoById.get(acc.RecordTypeId).getDeveloperName());
	}

	private String createKey(String g, String o, String i, String v) {
		String key = g+'-'+o+'-'+i+'-'+v;
		system.debug('print key: '+key);
		return key;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_Visit_Frequency_Criteria__c> selectVFCsWherePros(Set<String> prosGOTids, Set<String> prosOTids, Set<String> prosILids, Set<String> prosVPids) {
		return [
			SELECT Id
				,	EUR_CRM_Group_Outlet_Type__c
				,	EUR_CRM_Image_Level__c
				,	EUR_CRM_Outlet_Type__c
				,	EUR_CRM_Visit_Frequency__c
				,	EUR_CRM_Volume_Potential__c
			FROM EUR_CRM_Visit_Frequency_Criteria__c
			WHERE EUR_CRM_Group_Outlet_Type__c IN :prosGOTids
				AND EUR_CRM_Outlet_Type__c IN :prosOTids
				AND EUR_CRM_Image_Level__c IN :prosILids
				AND EUR_CRM_Volume_Potential__c IN :prosVPids
			LIMIT 10000
		];
	}

	private List<EUR_CRM_Visit_Frequency_Criteria__c> selectVFCsWherePrs(Set<String> prsGOTids, Set<String> prsOTids, Set<String> prsILids, Set<String> prsVPids) {
		return [
			SELECT Id
				,	EUR_CRM_PRS_Group_Outlet_Type_EU__c
				,	EUR_CRM_PRS_Outlet_Type_EU__c
				,	EUR_CRM_PRS_IL_Segmentation_Aspect_EU__c
				,	EUR_CRM_PRS_VP_Segmentation_Aspect_EU__c
				,	EUR_CRM_Visit_Frequency__c
			FROM EUR_CRM_Visit_Frequency_Criteria__c
			WHERE EUR_CRM_PRS_Group_Outlet_Type_EU__c IN :prsGOTids
			AND EUR_CRM_PRS_Outlet_Type_EU__c IN :prsOTids
			AND EUR_CRM_PRS_IL_Segmentation_Aspect_EU__c IN :prsILids
			AND EUR_CRM_PRS_VP_Segmentation_Aspect_EU__c IN :prsVPids
			LIMIT 10000
		];
	}

	private List<EUR_CRM_Visit_Frequency__c> selectVFCwhereRT(Set<String> recordTypeFrequency) {
		return [
			SELECT Id, Name
			FROM EUR_CRM_Visit_Frequency__c
			WHERE RecordType.DeveloperName
				IN :recordTypeFrequency
		];
	}

	private Map<Id, EUR_CRM_Customer_Taxonomy__c> selectCTbyIdWhereIds(Set<String> customerTaxonomySet) {
		return new Map<Id, EUR_CRM_Customer_Taxonomy__c>([
			SELECT Id, EUR_CRM_Visit_Frequency__c, Name
			FROM EUR_CRM_Customer_Taxonomy__c
			WHERE Id IN :customerTaxonomySet
		]);
	}

	private Map<Id, EUR_CRM_Visit_Frequency__c> selectVFbyIdWhereRTs(Set<String> visitFrequencyRecordTypeSet) {
		return new Map<Id, EUR_CRM_Visit_Frequency__c>([
			SELECT Id, Name
			FROM EUR_CRM_Visit_Frequency__c
			WHERE Recordtype.Developername IN :visitFrequencyRecordTypeSet
		]);
	}
}