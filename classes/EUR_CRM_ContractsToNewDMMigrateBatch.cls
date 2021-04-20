global class EUR_CRM_ContractsToNewDMMigrateBatch implements Database.Batchable<sObject> {

//    Database.executeBatch(new EUR_CRM_ContractsToNewDMMigrateBatch('DE'), 50);

    @TestVisible private static Map<String, String> HOUSE_POURING_MECHANIC_TYPE_BE_COUNTRY_CODE = new Map<String, String> {
        'DE' => 'EUR_DE_House_Pouring'
    };

    @TestVisible private static Map<String, String> LISTING_MECHANIC_TYPE_BE_COUNTRY_CODE = new Map<String, String> {
        'DE' => 'EUR_DE_Listing'
    };

    private String countryCode;
    private Integer timePeriod; // where < 0 == past time (last 1 year); 0 == today; > 0 == future time; null == all periods

    global EUR_CRM_ContractsToNewDMMigrateBatch(String countryCode) {
        this.countryCode = countryCode;
        this.timePeriod = null;
    }

    global EUR_CRM_ContractsToNewDMMigrateBatch(String countryCode, Integer period) {
        this.countryCode = countryCode;
        this.timePeriod = period;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (this.timePeriod != null) {
            if (this.timePeriod < 0) {
                return Database.getQueryLocator([
                    SELECT Id
                    ,   EUR_CRM_Contract__c
                    ,   EUR_CRM_Pouring__c
                    ,   EUR_CRM_Listing__c
                    ,   EUR_CRM_Brand_Quality__c
                    ,   EUR_CRM_Contract__r.EUR_CRM_Country_Code__c
                    FROM EUR_CRM_Contract_Listing_Pouring__c
                    WHERE EUR_CRM_Brand_Quality__c != NULL
                        AND EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = :this.countryCode
                        AND EUR_CRM_Contract__r.EUR_CRM_End_Date__c >= :Date.today().addYears(-1)
                        AND EUR_CRM_Contract__r.EUR_CRM_End_Date__c < TODAY
                ]);
            } else if (this.timePeriod == 0) {
                return Database.getQueryLocator([
                    SELECT Id
                    ,   EUR_CRM_Contract__c
                    ,   EUR_CRM_Pouring__c
                    ,   EUR_CRM_Listing__c
                    ,   EUR_CRM_Brand_Quality__c
                    ,   EUR_CRM_Contract__r.EUR_CRM_Country_Code__c
                    FROM EUR_CRM_Contract_Listing_Pouring__c
                    WHERE EUR_CRM_Brand_Quality__c != NULL
                        AND EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = :this.countryCode
                        AND EUR_CRM_Contract__r.EUR_CRM_End_Date__c = TODAY
                ]);
            } else {
                return Database.getQueryLocator([
                    SELECT Id
                    ,   EUR_CRM_Contract__c
                    ,   EUR_CRM_Pouring__c
                    ,   EUR_CRM_Listing__c
                    ,   EUR_CRM_Brand_Quality__c
                    ,   EUR_CRM_Contract__r.EUR_CRM_Country_Code__c
                    FROM EUR_CRM_Contract_Listing_Pouring__c
                    WHERE EUR_CRM_Brand_Quality__c != NULL
                        AND EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = :this.countryCode
                        AND EUR_CRM_Contract__r.EUR_CRM_End_Date__c >= TODAY
                ]);
            }
        }

        return Database.getQueryLocator([
            SELECT Id
            ,   EUR_CRM_Contract__c
            ,   EUR_CRM_Pouring__c
            ,   EUR_CRM_Listing__c
            ,   EUR_CRM_Brand_Quality__c
            ,   EUR_CRM_Contract__r.EUR_CRM_Country_Code__c
            FROM EUR_CRM_Contract_Listing_Pouring__c
            WHERE EUR_CRM_Brand_Quality__c != NULL
                AND EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = :this.countryCode
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings) {
        Map<String, Id> mechanicTypeIdByExternalId = getMechanicTypeIdByExternalId();
        System.debug('\n\n mechanicTypeIdByExternalId.size() => ' + JSON.serializePretty(mechanicTypeIdByExternalId.size()) + '\n');
        if (mechanicTypeIdByExternalId.isEmpty()) { return ; }
        System.debug('\n\n mechanicTypeIdByExternalId => ' + JSON.serializePretty(mechanicTypeIdByExternalId) + '\n');

        System.debug('\n\n contractListingPourings.size() => ' + JSON.serializePretty(contractListingPourings.size()) + '\n');
        System.debug('\n\n contractListingPourings => ' + JSON.serializePretty(contractListingPourings) + '\n');

        Map<Id, Map<String, List<EUR_CRM_Contract_Listing_Pouring__c>>> contractListingPouringsByMechanicTypeContractId = this.convertToContractListingPouringsByMechanicTypeContractId(contractListingPourings);
        System.debug('\n\n contractListingPouringsByMechanicTypeContractId.size() => ' + JSON.serializePretty(contractListingPouringsByMechanicTypeContractId.size()) + '\n');
        if (contractListingPouringsByMechanicTypeContractId.isEmpty()) { return ; }
        System.debug('\n\n contractListingPouringsByMechanicTypeContractId => ' + JSON.serializePretty(contractListingPouringsByMechanicTypeContractId) + '\n');

        Map<Id, Map<String, List<EUR_CRM_Contract_Activity_Item__c>>> contractActivityItemsByMechanicTypeByContractId = this.getContractActivityItemsByMechanicTypeByContractId(contractListingPouringsByMechanicTypeContractId.keySet());
        System.debug('\n\n contractActivityItemsByMechanicTypeByContractId.size() => ' + JSON.serializePretty(contractActivityItemsByMechanicTypeByContractId.size()) + '\n');
        System.debug('\n\n contractActivityItemsByMechanicTypeByContractId => ' + JSON.serializePretty(contractActivityItemsByMechanicTypeByContractId) + '\n');

        Id contractActivityItemRTID = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Activity_Item').getRecordTypeId();
        Id contractProductItemRTID = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();

        Map<String, EUR_CRM_Contract_Activity_Item__c> contractActivityItemToInsertByContractIdAndMechanicType = new Map<String, EUR_CRM_Contract_Activity_Item__c>();
        Map<String, EUR_CRM_Contract_Product_Item__c> contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId = new Map<String, EUR_CRM_Contract_Product_Item__c>();
        List<EUR_CRM_Contract_Product_Item__c> contractProductItemsToInsert = new List<EUR_CRM_Contract_Product_Item__c>();

        for (Id contractId : contractListingPouringsByMechanicTypeContractId.keySet()) {
            Map<String, List<EUR_CRM_Contract_Listing_Pouring__c>> contractListingPouringsByMechanicType = contractListingPouringsByMechanicTypeContractId.get(contractId);

            for (String mechanicType : contractListingPouringsByMechanicType.keySet()) {
                if ( ! mechanicTypeIdByExternalId.containsKey(mechanicType)) { continue; }

                for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPouringsByMechanicType.get(mechanicType)) {
                    if (contractActivityItemsByMechanicTypeByContractId.containsKey(contractId)) {
                        if (contractActivityItemsByMechanicTypeByContractId.get(contractId).containsKey(mechanicType)) {
                            List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = contractActivityItemsByMechanicTypeByContractId.get(contractId).get(mechanicType);

                            Boolean matchedBQexist = false;
                            for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
                                for (EUR_CRM_Contract_Product_Item__c contractProductItem : contractActivityItem.Contract_Product_Items__r) {
                                    if (contractProductItem.EUR_CRM_Brand_Quality__c == contractListingPouring.EUR_CRM_Brand_Quality__c) {
                                        matchedBQexist = true;
                                    }
                                }
                            }
                            if (matchedBQexist == false) {
                                // needs to create just one CPI under the very first CAI
                                contractProductItemsToInsert.add(makeContractProductItem(contractProductItemRTID, contractActivityItems[0].Id, contractListingPouring.EUR_CRM_Brand_Quality__c));
                            }
                        } else {
                            // create new CAT + CPI
                            contractActivityItemToInsertByContractIdAndMechanicType.put(
                                contractId + '_' + mechanicType,
                                makeContractActivityItem(contractActivityItemRTID, contractId, mechanicTypeIdByExternalId.get(mechanicType))
                            );

                            contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId.put(
                                contractId + '_' + mechanicType + '_' + contractListingPouring.Id,
                                makeContractProductItem(contractProductItemRTID, null, contractListingPouring.EUR_CRM_Brand_Quality__c)
                            );
                        }
                    } else {
                        // create new CAT + CPI
                        contractActivityItemToInsertByContractIdAndMechanicType.put(
                            contractId + '_' + mechanicType,
                            makeContractActivityItem(contractActivityItemRTID, contractId, mechanicTypeIdByExternalId.get(mechanicType))
                        );

                        contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId.put(
                            contractId + '_' + mechanicType + '_' + contractListingPouring.Id,
                            makeContractProductItem(contractProductItemRTID, null, contractListingPouring.EUR_CRM_Brand_Quality__c)
                        );
                    }
                }
            }
        }

        System.debug('\n\n contractActivityItemToInsertByContractIdAndMechanicType.size() => ' + JSON.serializePretty(contractActivityItemToInsertByContractIdAndMechanicType.size()) + '\n');
        System.debug('\n\n contractActivityItemToInsertByContractIdAndMechanicType => ' + JSON.serializePretty(contractActivityItemToInsertByContractIdAndMechanicType) + '\n');
        insert contractActivityItemToInsertByContractIdAndMechanicType.values();

        for (String contractIdAndMechanicType : contractActivityItemToInsertByContractIdAndMechanicType.keySet()) {
            EUR_CRM_Contract_Activity_Item__c insertedContractActivityItem = contractActivityItemToInsertByContractIdAndMechanicType.get(contractIdAndMechanicType);
            for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
                String key = contractIdAndMechanicType + '_' + contractListingPouring.Id;
                if (contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId.containsKey(key)) {
                    contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId.get(key).put('EUR_CRM_Contract_Activity_Item__c', insertedContractActivityItem.Id);
                }
            }
        }

        System.debug('\n\n contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId.size() => ' + JSON.serializePretty(contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId.size()) + '\n');
        System.debug('\n\n contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId => ' + JSON.serializePretty(contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId) + '\n');
        for (EUR_CRM_Contract_Product_Item__c contractProductItem : contractProductItemToInsertByContractIdAndMechanicTypeAndContractListingPouringId.values()) {
            contractProductItemsToInsert.add(contractProductItem);
        }

        System.debug('\n\n contractProductItemsToInsert.size() => ' + JSON.serializePretty(contractProductItemsToInsert.size()) + '\n');
        System.debug('\n\n contractProductItemsToInsert => ' + JSON.serializePretty(contractProductItemsToInsert) + '\n');
        insert contractProductItemsToInsert;
    }

    global virtual void finish(Database.BatchableContext BC) {}


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, Map<String, List<EUR_CRM_Contract_Listing_Pouring__c>>> convertToContractListingPouringsByMechanicTypeContractId(List<EUR_CRM_Contract_Listing_Pouring__c> contractListingPourings) {
        Map<Id, Map<String, List<EUR_CRM_Contract_Listing_Pouring__c>>> contractListingPouringsByMaechTypeByContractId = new Map<Id, Map<String, List<EUR_CRM_Contract_Listing_Pouring__c>>>();
        for (EUR_CRM_Contract_Listing_Pouring__c contractListingPouring : contractListingPourings) {
            Set<String> currentMechanicTypes = new Set<String>();
            if (contractListingPouring.EUR_CRM_Pouring__c == true) { currentMechanicTypes.add(HOUSE_POURING_MECHANIC_TYPE_BE_COUNTRY_CODE.get(this.countryCode)); }
            if (contractListingPouring.EUR_CRM_Listing__c == true) { currentMechanicTypes.add(LISTING_MECHANIC_TYPE_BE_COUNTRY_CODE.get(this.countryCode)); }
            if (currentMechanicTypes.isEmpty()) { continue; }

            for (String mechanicType : currentMechanicTypes) {
                if (contractListingPouringsByMaechTypeByContractId.containsKey(contractListingPouring.EUR_CRM_Contract__c)) {
                    if (contractListingPouringsByMaechTypeByContractId.get(contractListingPouring.EUR_CRM_Contract__c).containsKey(mechanicType)) {
                        contractListingPouringsByMaechTypeByContractId.get(contractListingPouring.EUR_CRM_Contract__c).get(mechanicType).add(contractListingPouring);
                    } else {
                        contractListingPouringsByMaechTypeByContractId.get(contractListingPouring.EUR_CRM_Contract__c).put(mechanicType, new List<EUR_CRM_Contract_Listing_Pouring__c> { contractListingPouring });
                    }
                } else {
                    contractListingPouringsByMaechTypeByContractId.put(
                        contractListingPouring.EUR_CRM_Contract__c, new Map<String, List<EUR_CRM_Contract_Listing_Pouring__c>> {
                            mechanicType => new List<EUR_CRM_Contract_Listing_Pouring__c> { contractListingPouring }
                        }
                    );
                }
            }
        }
        return contractListingPouringsByMaechTypeByContractId;
    }

    private Map<Id, Map<String, List<EUR_CRM_Contract_Activity_Item__c>>> getContractActivityItemsByMechanicTypeByContractId(Set<Id> contractIds) {
        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = selectContractActivityItemsWhereContractIds(contractIds);
        System.debug('\n\n contractActivityItems.size() => ' + JSON.serializePretty(contractActivityItems.size()) + '\n');
        System.debug('\n\n contractActivityItems => ' + JSON.serializePretty(contractActivityItems) + '\n');

        Map<Id, Map<String, List<EUR_CRM_Contract_Activity_Item__c>>> contractActivityItemsByMechanicTypeByContractId = new Map<Id, Map<String, List<EUR_CRM_Contract_Activity_Item__c>>>();
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            if (contractActivityItemsByMechanicTypeByContractId.containsKey(contractActivityItem.EUR_CRM_Contract__c)) {
                if (contractActivityItemsByMechanicTypeByContractId.get(contractActivityItem.EUR_CRM_Contract__c).containsKey(contractActivityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c)) {
                    contractActivityItemsByMechanicTypeByContractId.get(contractActivityItem.EUR_CRM_Contract__c).get(contractActivityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c).add(contractActivityItem);
                } else {
                    contractActivityItemsByMechanicTypeByContractId.get(contractActivityItem.EUR_CRM_Contract__c).put(contractActivityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c, new List<EUR_CRM_Contract_Activity_Item__c> { contractActivityItem });
                }
            } else {
                contractActivityItemsByMechanicTypeByContractId.put(
                    contractActivityItem.EUR_CRM_Contract__c, new Map<String, List<EUR_CRM_Contract_Activity_Item__c>> {
                        contractActivityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c => new List<EUR_CRM_Contract_Activity_Item__c> { contractActivityItem }
                    }
                );
            }
        }
        return contractActivityItemsByMechanicTypeByContractId;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<String, Id> getMechanicTypeIdByExternalId() {
        List<EUR_CRM_Mechanic_Type__c> mechanicTypes = selectMechanicTypes();
        Map<String, Id> mechanicTypeIdByExternalId = new Map<String, Id>();
        for (EUR_CRM_Mechanic_Type__c mechanicType : mechanicTypes) {
            mechanicTypeIdByExternalId.put(mechanicType.EUR_CRM_External_ID__c, mechanicType.Id);
        }
        return mechanicTypeIdByExternalId;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private EUR_CRM_Contract_Product_Item__c makeContractProductItem(Id rtId, Id contractActivityItemId, Id bqId) {
        return new EUR_CRM_Contract_Product_Item__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Contract_Activity_Item__c = contractActivityItemId
        ,   EUR_CRM_Brand_Quality__c = bqId
        );
    }

    private EUR_CRM_Contract_Activity_Item__c makeContractActivityItem(Id rtId, Id contractId, Id mechanicTypeId) {
        return new EUR_CRM_Contract_Activity_Item__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Contract__c = contractId
        ,   EUR_CRM_Mechanic_Type__c = mechanicTypeId
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Mechanic_Type__c> selectMechanicTypes() {
        return [
            SELECT Id
            ,   EUR_CRM_External_ID__c
            FROM EUR_CRM_Mechanic_Type__c
            WHERE EUR_CRM_External_ID__c IN (:HOUSE_POURING_MECHANIC_TYPE_BE_COUNTRY_CODE.get(this.countryCode), :LISTING_MECHANIC_TYPE_BE_COUNTRY_CODE.get(this.countryCode))
        ];
    }

    private List<EUR_CRM_Contract_Activity_Item__c> selectContractActivityItemsWhereContractIds(Set<Id> contractIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Contract__c
            ,   EUR_CRM_Mechanic_Type__c
            ,   EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
            ,   (
                SELECT Id
                ,   EUR_CRM_Brand_Quality__c
                FROM Contract_Product_Items__r
            )
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__c IN :contractIds
                AND EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c IN (:HOUSE_POURING_MECHANIC_TYPE_BE_COUNTRY_CODE.get(this.countryCode), :LISTING_MECHANIC_TYPE_BE_COUNTRY_CODE.get(this.countryCode))
        ];
    }

}