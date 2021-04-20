/*
VT - EUR_CRM_GB_Volume_Tracker__c
VTLI - EUR_CRM_GB_Volume_Tracker_Line_Item__c
B - EUR_CRM_Brand__c (Brand (EU))
BQ - EUR_CRM_Quality__c (Brand-Quality (EU))
BQS - EUR_CRM_Size__c (Brand-Quality-Size (EU))
SKU - EUR_CRM_SKU__c (SKU (EU))
CAI - EUR_CRM_Contract_Activity_Item__c (Contract Activity Item (EU))
CPI - EUR_CRM_Contract_Product_Item__c (Contract Product Item (EU))
MT - EUR_CRM_Mechanic_Type__c (Mechanic Type (EU))
*/
public with sharing class EUR_CRM_VolumeTrackerLineItemBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject> {

    private String vtliRT;
    @TestVisible
    private final Set<String> VALID_MECHANIC_TYPES = new Set<String>{
            'Pouring Refund Spirits', 'Pouring Refund Wines',
            'Selection Brands Spirits', 'Selection Brands Wines'
    };

    public EUR_CRM_VolumeTrackerLineItemBatch(String vtliRT) {
        this.vtliRT = vtliRT;
    }

    public EUR_CRM_VolumeTrackerLineItemBatch() {
        this.vtliRT = 'EUR_FI_Volume_Tracker_Line_Item';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT Id
                        , EUR_CRM_Brand__r.EUR_CRM_External_ID__c
                        , EUR_CRM_Brand_Quality__r.EUR_CRM_External_ID__c
                        , EUR_CRM_Brand_Quality_Size__r.EUR_CRM_External_ID__c
                        , EUR_CRM_Brand_Quality_Size__c
                        , EUR_CRM_SKU__r.EUR_CRM_External_ID__c
                        , EUR_CRM_Mechanic_Type_Name__c
                        , EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c
                FROM EUR_CRM_GB_Volume_Tracker_Line_Item__c
                WHERE RecordType.DeveloperName = :this.vtliRT
//			AND (
//				EUR_CRM_Brand__r.EUR_CRM_External_ID__c != NULL OR
//				EUR_CRM_Brand_Quality__r.EUR_CRM_External_ID__c != NULL OR
//				EUR_CRM_Brand_Quality_Size__r.EUR_CRM_External_ID__c != NULL OR
//				EUR_CRM_SKU__r.EUR_CRM_External_ID__c != NULL
//			)
                AND EUR_CRM_Contract_Product__c = NULL
                AND EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis) {
        System.debug('\n vtlis.size() => ' + vtlis.size() + '\n');
        System.debug('\n vtlis => ' + JSON.serializePretty(vtlis) + '\n');

        List<EUR_CRM_Contract_Activity_Item__c> cais = getCAIsFromVTLIs(vtlis);
        System.debug('\n cais.size() => ' + cais.size() + '\n');
        System.debug('\n cais => ' + JSON.serializePretty(cais) + '\n');
        if (cais.isEmpty()) {
            return;
        }

        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> cPIsByContractId = createCPIsByContractIdFromCAIs(cais);
        System.debug('\n CPIsByContractId.size() => ' + cPIsByContractId.size() + '\n');
        System.debug('\n CPIsByContractId => ' + JSON.serializePretty(cPIsByContractId) + '\n');
        if (cPIsByContractId.isEmpty()) {
            return;
        }

        List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vTLIsToUpdate = updateContractProductFieldOnVTLIs(vtlis,
                cPIsByContractId);
        System.debug('\n vTLIsToUpdate.size() => ' + vTLIsToUpdate.size() + '\n');
        System.debug('\n vTLIsToUpdate => ' + JSON.serializePretty(vTLIsToUpdate) + '\n');

        if (! vTLIsToUpdate.isEmpty()) {
            this.upsertRecords(vTLIsToUpdate);
        }

//		Map<Id, Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>>> vtlisByCustKeyByContrId = this.getVtlisByCustKeyByContrId(vtlis);
//		System.debug('\n vtlisByCustKeyByContrId.size() => ' + vtlisByCustKeyByContrId.size() + '\n');
//		System.debug('\n vtlisByCustKeyByContrId => ' + JSON.serializePretty(vtlisByCustKeyByContrId) + '\n');
//		if (vtlisByCustKeyByContrId.isEmpty()) { return; }
//
//		Map<String, EUR_CRM_Contract_Product_Item__c> cpisByCustKey = this.getCpisByCustKey(vtlisByCustKeyByContrId.keySet());
//		System.debug('\n cpisByCustKey.size() => ' + cpisByCustKey.size() + '\n');
//		System.debug('\n cpisByCustKey => ' + JSON.serializePretty(cpisByCustKey) + '\n');
//		if (cpisByCustKey.isEmpty()) { return; }
//
//		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlisToUpdate = this.getVtlisToUpdate(vtlisByCustKeyByContrId, cpisByCustKey);
//		System.debug('\n vtlisToUpdate.size() => ' + vtlisToUpdate.size() + '\n');
//		System.debug('\n vtlisToUpdate => ' + JSON.serializePretty(vtlisToUpdate) + '\n');
//		if (vtlisToUpdate.isEmpty()) { return; }
//		this.upsertRecords(vtlisToUpdate);


        this.finish(bc);
    }


    /* ========================================================= */
    /*      High Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Contract_Activity_Item__c> getCAIsFromVTLIs
            (List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vTLIs) {
        Set<Id> contractIds = new Set<Id>();
        for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vTLIs) {
            contractIds.add(vtli.EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c);
        }
        return selectCAIsWhereContrIdsAndValidMechTypes(contractIds);
    }

    private Map<Id, List<EUR_CRM_Contract_Product_Item__c>> createCPIsByContractIdFromCAIs
            (List<EUR_CRM_Contract_Activity_Item__c> cAIs) {
        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> result = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();

        for (EUR_CRM_Contract_Activity_Item__c cai : cAIs) {
            if (cai.Contract_Product_Items__r.isEmpty()) {
                continue;
            }
            if (result.containsKey(cai.EUR_CRM_Contract__c)) {
                result.get(cai.EUR_CRM_Contract__c).add(cai.Contract_Product_Items__r);
            } else {
                result.put(cai.EUR_CRM_Contract__c, cai.Contract_Product_Items__r);
            }
        }
        return result;
    }

    private List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> updateContractProductFieldOnVTLIs(List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vTLIs,
            Map<Id, List<EUR_CRM_Contract_Product_Item__c>> cPIsByContractId) {
        List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> result = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();

        for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vTLI : vTLIs) {
            if (cPIsByContractId.get(vTLI.EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c) == null ||
                    cPIsByContractId.get(vTLI.EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c).isEmpty()) {
                continue;
            }
            List<EUR_CRM_Contract_Product_Item__c> cPIs = cPIsByContractId.get(vTLI.EUR_CRM_Volume_Tracker__r
                    .EUR_CRM_Contract__c);

            for(EUR_CRM_Contract_Product_Item__c cPI: cPIs) {

                if (cPI.EUR_CRM_Brand_Quality_Size__c == vTLI.EUR_CRM_Brand_Quality_Size__c) {
                    vTLI.EUR_CRM_Contract_Product__c = cPI.Id;
                    result.add(vTLI);
                    break;
                }

            }
        }

        return result;
    }

//    private Map<Id, Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>>> getVtlisByCustKeyByContrId(List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis) {
//        Map<Id, Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>>> vtliByCustKeyByContrId = new Map<Id, Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>>>();
//
//        for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
//            String prodExtId = this.getProductExtId(vtli);
//            if (String.isBlank(prodExtId)) {
//                continue;
//            }
//            Id contrId = vtli.EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c;
//            this.populateVtlisByCustKeyByContrIdMap(vtliByCustKeyByContrId, contrId, this.getVtliCustKey(vtli, prodExtId), vtli);
//        }
//        return vtliByCustKeyByContrId;
//    }
//
//    private Map<String, EUR_CRM_Contract_Product_Item__c> getCpisByCustKey(Set<Id> contrIds) {
//        Map<String, EUR_CRM_Contract_Product_Item__c> cpisByCustKey = new Map<String, EUR_CRM_Contract_Product_Item__c>();
//        List<EUR_CRM_Contract_Activity_Item__c> cais = this.selectCAIsWhereContrIdsAndValidMechTypes(contrIds);
//        if (cais.isEmpty()) {
//            return new Map<String, EUR_CRM_Contract_Product_Item__c>();
//        }
//
//        for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
//            if (cai.Contract_Product_Items__r.isEmpty()) {
//                continue;
//            }
//            for (EUR_CRM_Contract_Product_Item__c cpi : cai.Contract_Product_Items__r) {
//                if (String.isBlank(cpi.EUR_CRM_External_ID__c)) {
//                    continue;
//                }
//                cpisByCustKey.put(this.getCpiCustKey(cai, cpi), cpi);
//            }
//        }
//        return cpisByCustKey;
//    }
//
//    private List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> getVtlisToUpdate(Map<Id, Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>>> vtlisByCustKeyByContrId, Map<String, EUR_CRM_Contract_Product_Item__c> cpisByCustKey) {
//        List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlisToUpdate = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
//        for (Id contrId : vtlisByCustKeyByContrId.keySet()) {
//            Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>> vtlisBuCustKey = vtlisByCustKeyByContrId.get(contrId);
//
//            for (String vtliCustKey : vtlisBuCustKey.keySet()) {
//                for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlisBuCustKey.get(vtliCustKey)) {
//                    String custKey = contrId + vtliCustKey;
//                    if (!cpisByCustKey.containsKey(custKey)) {
//                        continue;
//                    }
//                    vtli.EUR_CRM_Contract_Product__c = cpisByCustKey.get(custKey).Id;
//                    vtlisToUpdate.add(vtli);
//                }
//
//            }
//        }
//        return vtlisToUpdate;
//    }


    /* ========================================================= */
    /*      Middle Level Helpers
    /* ========================================================= */
//    private void populateVtlisByCustKeyByContrIdMap(Map<Id, Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>>> vtliByCustKeyByContrId, Id contrId, String custKey, EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli) {
//        if (vtliByCustKeyByContrId.containsKey(contrId)) {
//            Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>> vtlisByCustKey = vtliByCustKeyByContrId.get(contrId);
//            this.populateVtlisByCustKeyMap(vtlisByCustKey, custKey, vtli);
//        } else {
//            vtliByCustKeyByContrId.put(contrId, new Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>>{
//                    custKey => new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{
//                            vtli
//                    }
//            });
//        }
//    }

//    private void populateVtlisByCustKeyMap(Map<String, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>> vtlisByCustKey, String custKey, EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli) {
//        if (vtlisByCustKey.containsKey(custKey)) {
//            vtlisByCustKey.get(custKey).add(vtli);
//        } else {
//            vtlisByCustKey.put(custKey, new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{
//                    vtli
//            });
//        }
//    }

//    private String getProductExtId(EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli) {
//        if (vtli.EUR_CRM_Brand__c != null) {
//            return vtli.EUR_CRM_Brand__r.EUR_CRM_External_ID__c;
//        }
//        if (vtli.EUR_CRM_Brand_Quality__c != null) {
//            return vtli.EUR_CRM_Brand_Quality__r.EUR_CRM_External_ID__c;
//        }
//        if (vtli.EUR_CRM_Brand_Quality_Size__c != null) {
//            return vtli.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_External_ID__c;
//        }
//        if (vtli.EUR_CRM_SKU__c != null) {
//            return vtli.EUR_CRM_SKU__r.EUR_CRM_External_ID__c;
//        }
//        return '';
//    }


    /* ========================================================= */
    /*      Low Level Helpers
    /* ========================================================= */
//    private String getVtliCustKey(EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli, String prodExtId) {
//        return vtli.EUR_CRM_Mechanic_Type_Name__c + prodExtId;
//    }
//
//    private String getCpiCustKey(EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Product_Item__c cpi) {
//        return cai.EUR_CRM_Contract__c + cai.EUR_CRM_Mechanic_Type__r.Name + cpi.EUR_CRM_External_ID__c;
//    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Contract_Activity_Item__c> selectCAIsWhereContrIdsAndValidMechTypes(Set<Id> contrIds) {
        return [
                SELECT Id
                        , EUR_CRM_Contract__c
                        , EUR_CRM_Mechanic_Type__r.Name
                        , (
                        SELECT Id
                                , EUR_CRM_External_ID__c
                                , EUR_CRM_Brand_Quality_Size__c
                        FROM Contract_Product_Items__r
                )
                FROM EUR_CRM_Contract_Activity_Item__c
                WHERE EUR_CRM_Contract__c IN :contrIds
                AND EUR_CRM_Mechanic_Type__r.Name IN :VALID_MECHANIC_TYPES
        ];
    }
}