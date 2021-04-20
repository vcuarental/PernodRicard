/*
	SA - Supplier Account
 	OSM - Outlet to Supplier Mapping

	EUR_CRM_AccountToOutletSupplMapBatch selects accounts with at least one populated field
	EUR_CRM_Primary_Route_to_Market_Spirits__c
	EUR_CRM_Primary_Route_to_Market_Champa__c
	EUR_GB_Secondary_Route_to_Market_Spirits__c
	EUR_CRM_Secondary_Route_to_Market_Cham__c

	and creates new EUR_CRM_Outlet_to_Supplier_Mapping__c records for each supplier account in mentioned fields.
	If selected account has related EUR_CRM_Outlet_to_Supplier_Mapping__c with
	osm.EUR_CRM_Supplier_Account__c equals to one of the four fields then for that field
	new EUR_CRM_Outlet_to_Supplier_Mapping__c will not be created.

*/

public with sharing class EUR_CRM_AccountToOutletSupplMapBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	private static final String SPIRIT_TYPE_FIELD = 'EUR_CRM_Spirit_Type__c';
	private static final String CHAMPAGNE_TYPE_FIELD = 'EUR_CRM_Champagne_Type__c';
	private static final String PRIMARY = 'Primary';
	private static final String SECONDARY = 'Secondary';
	private static final String GB_OSM_RT = 'EUR_GB_Outlet_to_Supplier_Mapping';

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
			,	EUR_CRM_Primary_Route_to_Market_Spirits__c
			,	EUR_CRM_Primary_Route_to_Market_Champa__c
			,	EUR_GB_Secondary_Route_to_Market_Spirits__c
			,	EUR_CRM_Secondary_Route_to_Market_Cham__c
			,	(
				SELECT
					EUR_CRM_Supplier_Account__c
				,	EUR_CRM_Spirit_Type__c
				,	EUR_CRM_Champagne_Type__c
				FROM Outlet_to_Supplier_Mappings1__r
			)
			FROM EUR_CRM_Account__c
			WHERE EUR_CRM_Country_Code__c = 'GB'
			AND (
				EUR_CRM_Primary_Route_to_Market_Spirits__c != NULL OR
				EUR_CRM_Primary_Route_to_Market_Champa__c != NULL OR
				EUR_GB_Secondary_Route_to_Market_Spirits__c != NULL OR
				EUR_CRM_Secondary_Route_to_Market_Cham__c != NULL
			)
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Account__c> accounts) {
		System.debug('\n accounts.size() => ' + accounts.size() + '\n');
		System.debug('\n accounts => ' + JSON.serializePretty(accounts) + '\n');

		Map<Id, Map<Id, Map<String, String>>> allValByFieldBySAByAcc = this.getValByFieldBySAByAcc(accounts);
		System.debug('\n allValByFieldBySAByAcc.size() => ' + allValByFieldBySAByAcc.size() + '\n');
		System.debug('\n allValByFieldBySAByAcc => ' + JSON.serializePretty(allValByFieldBySAByAcc) + '\n');

		Map<Id, Map<Id, Map<String, String>>> valByFieldBySAByAccToCreateOSM = this.removeSuppliersWhoDontNeedToCreateOSM(accounts, allValByFieldBySAByAcc);
		System.debug('\n valByFieldBySAByAccToCreateOSM.size() => ' + valByFieldBySAByAccToCreateOSM.size() + '\n');
		System.debug('\n valByFieldBySAByAccToCreateOSM => ' + JSON.serializePretty(valByFieldBySAByAccToCreateOSM) + '\n');

		Map<String, Schema.SObjectField> osmFieldByFieldName = Schema.SObjectType.EUR_CRM_Outlet_to_Supplier_Mapping__c.fields.getMap();
		Id osmRtId = Schema.SObjectType.EUR_CRM_Outlet_to_Supplier_Mapping__c.getRecordTypeInfosByDeveloperName().get(GB_OSM_RT).getRecordTypeId();

		List<EUR_CRM_Outlet_to_Supplier_Mapping__c> osmsToInsert = this.makeOSMsToInsert(valByFieldBySAByAccToCreateOSM, osmRtId, osmFieldByFieldName);
		System.debug('\n osmsToInsert.size() => ' + osmsToInsert.size() + '\n');
		System.debug('\n osmsToInsert => ' + JSON.serializePretty(osmsToInsert) + '\n');
		if (osmsToInsert.isEmpty()) { return; }

		this.upsertRecords(osmsToInsert);
	}

	public override void finish(Database.BatchableContext bc) {
		super.finish(bc);
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private Map<Id, Map<Id, Map<String, String>>> getValByFieldBySAByAcc(List<EUR_CRM_Account__c> accounts) {
		Map<Id, Map<Id, Map<String, String>>> valByFieldBySAByAccId = new Map<Id, Map<Id, Map<String, String>>>();
		for (EUR_CRM_Account__c acc : accounts) {
			Id prsId = acc.EUR_CRM_Primary_Route_to_Market_Spirits__c;
			Id srsId = acc.EUR_GB_Secondary_Route_to_Market_Spirits__c;
			Id prcId = acc.EUR_CRM_Primary_Route_to_Market_Champa__c;
			Id srcId = acc.EUR_CRM_Secondary_Route_to_Market_Cham__c;

			Map<Id, Map<String, String>>valByFieldBySA = new Map<Id, Map<String, String>>();
			valByFieldBySA.put(prsId, new Map<String, String>{ SPIRIT_TYPE_FIELD => PRIMARY });

			if ( ! valByFieldBySA.containsKey(srsId)) {
				valByFieldBySA.put(srsId, new Map<String, String>{ SPIRIT_TYPE_FIELD => SECONDARY });
			}
			if (valByFieldBySA.containsKey(prcId)) {
				valByFieldBySA.get(prcId).put(CHAMPAGNE_TYPE_FIELD, PRIMARY);
			} else {
				valByFieldBySA.put(prcId, new Map<String, String>{ CHAMPAGNE_TYPE_FIELD => PRIMARY });
			}
			if (valByFieldBySA.containsKey(srcId) && ( ! valByFieldBySA.get(srcId).containsKey(CHAMPAGNE_TYPE_FIELD))) {
				valByFieldBySA.get(srcId).put(CHAMPAGNE_TYPE_FIELD, SECONDARY);
			}
			if ( ! valByFieldBySA.containsKey(srcId)) {
				valByFieldBySA.put(srcId, new Map<String, String>{ CHAMPAGNE_TYPE_FIELD => SECONDARY });
			}

			valByFieldBySA.remove(null);
			if (valByFieldBySA.isEmpty()) { continue; }
			valByFieldBySAByAccId.put(acc.Id, valByFieldBySA);
		}
		return valByFieldBySAByAccId;
	}

	private Map<Id, Map<Id, Map<String, String>>> removeSuppliersWhoDontNeedToCreateOSM(List<EUR_CRM_Account__c> accounts, Map<Id, Map<Id, Map<String, String>>> valByFieldBySAByAcc) {
		for (EUR_CRM_Account__c acc : accounts) {
			if (acc.Outlet_to_Supplier_Mappings1__r.isEmpty()) { continue; }
			for (EUR_CRM_Outlet_to_Supplier_Mapping__c osm : acc.Outlet_to_Supplier_Mappings1__r) {
				if ( ! valByFieldBySAByAcc.containsKey(acc.Id)) { continue; }
				valByFieldBySAByAcc.get(acc.Id).remove(osm.EUR_CRM_Supplier_Account__c);
			}
		}
		return valByFieldBySAByAcc;
	}

	private List<EUR_CRM_Outlet_to_Supplier_Mapping__c> makeOSMsToInsert(Map<Id, Map<Id, Map<String, String>>> valByFieldBySAByAccToCreateOSM, Id osmRtId, Map<String, SObjectField> osmFieldByFieldName) {
		List<EUR_CRM_Outlet_to_Supplier_Mapping__c> osmsToInsert = new List<EUR_CRM_Outlet_to_Supplier_Mapping__c>();
		for (Id accId : valByFieldBySAByAccToCreateOSM.keySet()) {
			Map<Id, Map<String, String>> valByFieldBySA = valByFieldBySAByAccToCreateOSM.get(accId);
			for (Id saId : valByFieldBySA.keySet()) {
				EUR_CRM_Outlet_to_Supplier_Mapping__c osm = this.makeOSM(osmRtId, accId, saId, valByFieldBySA, osmFieldByFieldName);
				if ( ! osm.isSet('EUR_CRM_Outlet_Account__c')) { continue; }
				osmsToInsert.add(osm);
			}
		}
		return osmsToInsert;
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private EUR_CRM_Outlet_to_Supplier_Mapping__c makeOSM(Id osmRtId, Id accId, Id saId, Map<Id, Map<String, String>> valByFieldBySA, Map<String, SObjectField> osmFieldByFieldName) {
		Map<String, String> valByField = valByFieldBySA.get(saId);
		EUR_CRM_Outlet_to_Supplier_Mapping__c osm = this.makeOSM(osmRtId);
		for (String field : valByField.keySet()) {
			if ( ! osmFieldByFieldName.containsKey(field)) {
				System.debug('No field exists on Outlet to Supplier Mapping object => ' + field);
				continue;
			}
			this.populateOSM(osm, accId, saId, field, valByField.get(field));
		}
		return osm;
	}

	private EUR_CRM_Outlet_to_Supplier_Mapping__c makeOSM(Id osmRtId) {
		return new EUR_CRM_Outlet_to_Supplier_Mapping__c(
			RecordTypeId = osmRtId
		);
	}

	private void populateOSM(EUR_CRM_Outlet_to_Supplier_Mapping__c osm, Id accId, Id saId, String field, String val) {
		osm.EUR_CRM_Outlet_Account__c = accId;
		osm.EUR_CRM_Supplier_Account__c = saId;
		osm.put(field, val);

	}


}