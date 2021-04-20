public with sharing class EUR_CRM_AccountVisitFrequencyService {

    private static final String CURRENT_CLASS_NAME = EUR_CRM_AccountVisitFrequencyService.class.getName();

    private final String EMPTY_VISIT_FREQUENCY = 'Empty Visit Frequency';
    private final String VALID_CHANNEL_AND_OTHER_RELATED_DATA = 'Valid Channel And Other Related Data';

    private final String ON_TRADE_CHANNEL = 'ON TRADE';
    private final String OFF_TRADE_CHANNEL = 'OFF TRADE';

    private final String ON_TRADE_VISIT_F_C_RT_DEV_NAME = 'EUR_NG_Visit_Frequency_Criteria_On_Trade';
    private final String OFF_TRADE_V_F_C_RT_DEV_NAME = 'EUR_NG_Visit_Frequency_Criteria_Off_Trade';

    private final Set<String> FI_ACCOUNT_RECORD_TYPE_DEV_NAMES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'FI_ACCOUNT_RECORD_TYPE_DEV_NAMES');
//    private final Set<String> FI_ACCOUNT_RECORD_TYPE_DEV_NAMES = new Set<String> {
//        'EUR_FI_Direct_Off_Trade'
//        ,   'EUR_FI_Direct_On_Trade'
//        ,   'EUR_FI_Indirect_Off_Trade'
//        ,   'EUR_FI_Indirect_On_Trade'
//    };

    private final Set<String> NG_ACCOUNT_RECORD_TYPE_DEV_NAMES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'NG_ACCOUNT_RECORD_TYPE_DEV_NAMES');
//    private final Set<String> NG_ACCOUNT_RECORD_TYPE_DEV_NAMES = new Set<String> {
//        'EUR_NG_On_Trade'
//        ,   'EUR_NG_Off_Trade_Traditional'
//        ,   'EUR_NG_Off_Trade_Modern'
//    };

    private final Set<String> VISIT_FREQUENCY_CRITERIA_RECORD_TYPE_DEV_NAMES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'VISIT_FREQUENCY_CRITERIA_RECORD_TYPE_DEV_NAMES');
//    private final Set<String> VISIT_FREQUENCY_CRITERIA_RECORD_TYPE_DEV_NAMES = new Set<String> {
//        ON_TRADE_VISIT_F_C_RT_DEV_NAME
//        ,   OFF_TRADE_V_F_C_RT_DEV_NAME
//    };

    private final Set<String> VALID_ACCOUNT_CHANNELS = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'VALID_ACCOUNT_CHANNELS');
//    private final Set<String> VALID_ACCOUNT_CHANNELS = new Set<String> {
//        ON_TRADE_CHANNEL
//        ,   OFF_TRADE_CHANNEL
//    };

    private final Set<String> VISIT_FREQUENCY_NAMES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'VISIT_FREQUENCY_NAMES');
//    private final Set<String> VISIT_FREQUENCY_NAMES = new Set<String> {
//        'Once a quarter'
//        ,   'Once every 6 months'
//    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void updateVisitFrequency(List<EUR_CRM_Account__c> accounts) {
        Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate = this.getAccountByRTIdByTypeOfUpdate(accounts);
        System.debug('\n\n accountsByRTIdByTypeOfUpdate => ' + JSON.serializePretty(accountsByRTIdByTypeOfUpdate) + '\n');
        if (accountsByRTIdByTypeOfUpdate.isEmpty()) { return ; }

        this.doUpdate(accountsByRTIdByTypeOfUpdate);
    }

    public void updateVisitFrequency(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate = this.getAccountByRTIdByTypeOfUpdate(accounts, oldAccountById);
        System.debug('\n\n accountsByRTIdByTypeOfUpdate => ' + JSON.serializePretty(accountsByRTIdByTypeOfUpdate) + '\n');
        if (accountsByRTIdByTypeOfUpdate.isEmpty()) { return ; }

        this.doUpdate(accountsByRTIdByTypeOfUpdate);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void doUpdate(Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate) {
        Map<String, String> rtDevNameById = this.getRTDevNameById(accountsByRTIdByTypeOfUpdate);
        System.debug('\n\n rtDevNameById => ' + JSON.serializePretty(rtDevNameById) + '\n');
        if (rtDevNameById.isEmpty()) { return ; }

        List<EUR_CRM_Account__c> accountsToUpdateViaVF = this.getAccountsToUpdateViaVF(accountsByRTIdByTypeOfUpdate, rtDevNameById);
        System.debug('\n\n accountsToUpdateViaVF => ' + JSON.serializePretty(accountsToUpdateViaVF) + '\n');

        List<EUR_CRM_Account__c> accountsToUpdateViaVFC = this.getAccountsToUpdateViaVFC(accountsByRTIdByTypeOfUpdate, rtDevNameById);
        System.debug('\n\n accountsToUpdateViaVFC => ' + JSON.serializePretty(accountsToUpdateViaVFC) + '\n');

        if( ! accountsToUpdateViaVF.isEmpty()) {
            this.updateAccountsViaVisitFrequency(accountsToUpdateViaVF, rtDevNameById);
        }

        if( ! accountsToUpdateViaVFC.isEmpty()) {
            this.updateAccountsViaVisitFrequencyCriteria(accountsToUpdateViaVFC);
        }
    }

    private void updateAccountsViaVisitFrequency(List<EUR_CRM_Account__c> accountsToUpdate, Map<String, String> rtDevNameById) {
        Map<String, List<EUR_CRM_Account__c>> accountsByCountry = this.getAccountsByCountry(accountsToUpdate, rtDevNameById);
        System.debug('\n\n accountsByCountry => ' + JSON.serializePretty(accountsByCountry) + '\n');

        Set<String> visitFrequencyRTDevNames = this.getVisitFrequencyRTDevNames(accountsByCountry);
        System.debug('\n\n visitFrequencyRTDevNames => ' + JSON.serializePretty(visitFrequencyRTDevNames) + '\n');

        Map<String, Map<String, EUR_CRM_Visit_Frequency__c>> vfByNameByCountry = this.getVisitFrequenciesByNameByCountry(visitFrequencyRTDevNames);
        System.debug('\n\n vfByNameByCountry => ' + JSON.serializePretty(vfByNameByCountry) + '\n');
        if (vfByNameByCountry.isEmpty()) { return ; }

        for (String countryCode : accountsByCountry.keySet()) {
            if (vfByNameByCountry.containsKey(countryCode)) {
                for (EUR_CRM_Account__c acc : accountsByCountry.get(countryCode)) {
                    if (rtDevNameById.containsKey(acc.RecordTypeId)) {
                        String rtDevName = rtDevNameById.get(acc.RecordTypeId);

                        if (countryCode == 'FI') {
                            if (rtDevName.equalsIgnoreCase('EUR_FI_Indirect_Off_Trade') || rtDevName.equalsIgnoreCase('EUR_FI_Direct_Off_Trade')) {
                                if (vfByNameByCountry.get(countryCode).containsKey('Once a quarter')) {
                                    acc.EUR_CRM_Visit_Frequency__c = vfByNameByCountry.get(countryCode).get('Once a quarter').Id;
                                }
                            } else if (rtDevName.equalsIgnoreCase('EUR_FI_Indirect_On_Trade') || rtDevName.equalsIgnoreCase('EUR_FI_Direct_On_Trade')) {
                                if (vfByNameByCountry.get(countryCode).containsKey('Once every 6 months')) {
                                    acc.EUR_CRM_Visit_Frequency__c = vfByNameByCountry.get(countryCode).get('Once every 6 months').Id;
                                }
                            }
                        }

                    }
                }
            }
        }

    }

    private void updateAccountsViaVisitFrequencyCriteria(List<EUR_CRM_Account__c> accountsToUpdate) {
        Map<String, Map<String, EUR_CRM_Visit_Frequency_Criteria__c>> vfcByKeyByRTDevName = this.getVisitFrequencyCriteriaByKeyByRecordTypeDevName();
        System.debug('\n\n vfcByKeyByRTDevName => ' + JSON.serializePretty(vfcByKeyByRTDevName) + '\n');
        if (vfcByKeyByRTDevName.isEmpty()) { return ; }

        for (EUR_CRM_Account__c acc : accountsToUpdate) {
            if (acc.EUR_CRM_Channel__c == OFF_TRADE_CHANNEL) {
                if (vfcByKeyByRTDevName.containsKey(OFF_TRADE_V_F_C_RT_DEV_NAME)) {
                    Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByKey = vfcByKeyByRTDevName.get(OFF_TRADE_V_F_C_RT_DEV_NAME);
                    String key = acc.EUR_CRM_Outlet_Classification__c + ':' + acc.EUR_CRM_Outlet_Classification_Type__c;
                    if (vfcByKey.containsKey(key)) {
                        acc.EUR_CRM_Visit_Frequency__c = vfcByKey.get(key).EUR_CRM_Visit_Frequency__c;
                    }
                }
            } else if (acc.EUR_CRM_Channel__c == ON_TRADE_CHANNEL) {
                if (vfcByKeyByRTDevName.containsKey(ON_TRADE_VISIT_F_C_RT_DEV_NAME)) {
                    Map<String, EUR_CRM_Visit_Frequency_Criteria__c> vfcByKey = vfcByKeyByRTDevName.get(ON_TRADE_VISIT_F_C_RT_DEV_NAME);
                    String key = acc.EUR_CRM_Group_Outlet_Type__c + ':' + acc.EUR_CRM_Image_Level__c + ':' + acc.EUR_CRM_Volume_Potential__c;
                    if (vfcByKey.containsKey(key)) {
                        acc.EUR_CRM_Visit_Frequency__c = vfcByKey.get(key).EUR_CRM_Visit_Frequency__c;
                    }
                }
            }
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<String, Map<Id, List<EUR_CRM_Account__c>>> getAccountByRTIdByTypeOfUpdate(List<EUR_CRM_Account__c> accounts) {
        Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate = new Map<String, Map<Id, List<EUR_CRM_Account__c>>>();

        for (EUR_CRM_Account__c acc : accounts) {
            if (this.isValidChannel(acc) && (this.isValidOutletClassification(acc) || this.isValidOutletGroupAndImageLevelAndVolumePotential(acc))) {
                this.initMapAccountByRTIdByTypeOfUpdate(VALID_CHANNEL_AND_OTHER_RELATED_DATA, accountsByRTIdByTypeOfUpdate, acc);
            } else if (this.isEmptyVisitFrequency(acc)) {
                this.initMapAccountByRTIdByTypeOfUpdate(EMPTY_VISIT_FREQUENCY, accountsByRTIdByTypeOfUpdate, acc);
            }
        }

        return accountsByRTIdByTypeOfUpdate;
    }

    private Map<String, Map<Id, List<EUR_CRM_Account__c>>> getAccountByRTIdByTypeOfUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate = new Map<String, Map<Id, List<EUR_CRM_Account__c>>>();

        for (EUR_CRM_Account__c acc : accounts) {
            if (this.isValidChannel(acc) &&
                (this.isChannelChanged(acc, oldAccountById)
                    || this.isValidOutletClassificationChanged(acc, oldAccountById)
                    || this.isValidOutletGroupOrImageLevelOrVolumePotentialChanged(acc, oldAccountById)
                )
                ) {
                this.initMapAccountByRTIdByTypeOfUpdate(VALID_CHANNEL_AND_OTHER_RELATED_DATA, accountsByRTIdByTypeOfUpdate, acc);
            } else if (this.isEmptyVisitFrequency(acc) && ! this.isEmptyVisitFrequency(oldAccountById.get(acc.Id))) {
                this.initMapAccountByRTIdByTypeOfUpdate(EMPTY_VISIT_FREQUENCY, accountsByRTIdByTypeOfUpdate, acc);
            }
        }

        return accountsByRTIdByTypeOfUpdate;
    }

    private void initMapAccountByRTIdByTypeOfUpdate(String typeOfUpdate, Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate, EUR_CRM_Account__c acc) {
        if (accountsByRTIdByTypeOfUpdate.containsKey(typeOfUpdate)) {
            if (accountsByRTIdByTypeOfUpdate.get(typeOfUpdate).containsKey(acc.RecordTypeId)) {
                accountsByRTIdByTypeOfUpdate.get(typeOfUpdate).get(acc.RecordTypeId).add(acc);
            } else {
                accountsByRTIdByTypeOfUpdate.get(typeOfUpdate).put(acc.RecordTypeId, new List<EUR_CRM_Account__c> { acc });
            }
        } else {
            accountsByRTIdByTypeOfUpdate.put(typeOfUpdate, new Map<Id, List<EUR_CRM_Account__c>> { acc.RecordTypeId => new List<EUR_CRM_Account__c> { acc }});
        }
    }

    private List<EUR_CRM_Account__c> getAccountsToUpdateViaVF(Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate, Map<String, String> rtDevNameById) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();

        for (String typeOfUpdate : accountsByRTIdByTypeOfUpdate.keySet()) {
            if (typeOfUpdate == EMPTY_VISIT_FREQUENCY) {
                Map<Id, List<EUR_CRM_Account__c>> accountsByRecordTypeId = accountsByRTIdByTypeOfUpdate.get(typeOfUpdate);
                for (Id rtId : accountsByRecordTypeId.keySet()) {
                    if (rtDevNameById.containsKey(rtId)) {
                        if (FI_ACCOUNT_RECORD_TYPE_DEV_NAMES.contains(rtDevNameById.get(rtId))) {
                            accounts.addAll(accountsByRecordTypeId.get(rtId));
                        }
                    }
                }
            }
        }

        return accounts;
    }

    private List<EUR_CRM_Account__c> getAccountsToUpdateViaVFC(Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate, Map<String, String> rtDevNameById) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();

        for (String typeOfUpdate : accountsByRTIdByTypeOfUpdate.keySet()) {
            if (typeOfUpdate == VALID_CHANNEL_AND_OTHER_RELATED_DATA) {
                Map<Id, List<EUR_CRM_Account__c>> accountsByRecordTypeId = accountsByRTIdByTypeOfUpdate.get(typeOfUpdate);
                for (Id rtId : accountsByRecordTypeId.keySet()) {
                    if (rtDevNameById.containsKey(rtId)) {
                        if (NG_ACCOUNT_RECORD_TYPE_DEV_NAMES.contains(rtDevNameById.get(rtId))) {
                            accounts.addAll(accountsByRecordTypeId.get(rtId));
                        }
                    }
                }
            }
        }

        return accounts;
    }

    private Map<String, Map<String, EUR_CRM_Visit_Frequency__c>> getVisitFrequenciesByNameByCountry(Set<String> visitFrequencyRTDevNames) {
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = this.selectVisitFrequenciesWhereRTDevNames(visitFrequencyRTDevNames);
        System.debug('\n\n visitFrequencies => ' + JSON.serializePretty(visitFrequencies) + '\n');
        if (visitFrequencies.isEmpty()) { return new Map<String, Map<String, EUR_CRM_Visit_Frequency__c>>(); }

        Map<String, Map<String, EUR_CRM_Visit_Frequency__c>> vfByNameByCountry = new Map<String, Map<String, EUR_CRM_Visit_Frequency__c>>();
        for (EUR_CRM_Visit_Frequency__c visitFrequency : visitFrequencies) {
            String countryCode = this.extractCountryCodeFromRTDevName(visitFrequency.RecordType.DeveloperName);
            if (vfByNameByCountry.containsKey(countryCode)) {
                vfByNameByCountry.get(countryCode).put(visitFrequency.Name, visitFrequency);
            } else {
                vfByNameByCountry.put(countryCode, new Map<String, EUR_CRM_Visit_Frequency__c> {visitFrequency.Name => visitFrequency });
            }
        }
        return vfByNameByCountry;
    }

    private Map<String, Map<String, EUR_CRM_Visit_Frequency_Criteria__c>> getVisitFrequencyCriteriaByKeyByRecordTypeDevName() {
        List<EUR_CRM_Visit_Frequency_Criteria__c> visitFrequencyCriteria = this.selectVisitFrequencyCriteriaWhereRTDevNames(VISIT_FREQUENCY_CRITERIA_RECORD_TYPE_DEV_NAMES);
        System.debug('\n\n visitFrequencyCriteria => ' + JSON.serializePretty(visitFrequencyCriteria) + '\n');

        Map<String, Map<String, EUR_CRM_Visit_Frequency_Criteria__c>> vfcByKeyByRTDevName = new Map<String, Map<String, EUR_CRM_Visit_Frequency_Criteria__c>>();

        for (EUR_CRM_Visit_Frequency_Criteria__c vfc : visitFrequencyCriteria) {
            String key = null;
            String rtDevName = null;
            if (vfc.RecordType.DeveloperName == ON_TRADE_VISIT_F_C_RT_DEV_NAME) {
                rtDevName = ON_TRADE_VISIT_F_C_RT_DEV_NAME;
                key = vfc.EUR_CRM_Group_Outlet_Type__c + ':' + vfc.EUR_CRM_Image_Level__c + ':' + vfc.EUR_CRM_Volume_Potential__c;

            } else if (vfc.RecordType.DeveloperName == OFF_TRADE_V_F_C_RT_DEV_NAME) {
                rtDevName = OFF_TRADE_V_F_C_RT_DEV_NAME;
                key = vfc.EUR_CRM_Outlet_Classification__c + ':' + vfc.EUR_CRM_Outlet_Classification_Type__c;
            }

            if (rtDevName != null && key != null) {
                if (vfcByKeyByRTDevName.containsKey(rtDevName)) {
                    vfcByKeyByRTDevName.get(rtDevName).put(key, vfc);
                } else {
                    vfcByKeyByRTDevName.put(
                        rtDevName, new Map<String, EUR_CRM_Visit_Frequency_Criteria__c> { key => vfc }
                    );
                }
            }
        }

        return vfcByKeyByRTDevName;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<String, String> getRTDevNameById(Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate) {
        Set<Id> rtIds = this.extractRecordTypeIds(accountsByRTIdByTypeOfUpdate);
        System.debug('\n\n rtIds => ' + JSON.serializePretty(rtIds) + '\n');

        List<RecordType> recordTypes = this.selectRecordTypeWhereIds(rtIds);

        Map<String, String> rtDevNameById = new Map<String, String>();
        for (RecordType recordType : recordTypes) {
            rtDevNameById.put(recordType.Id, recordType.DeveloperName);
        }
        return rtDevNameById;
    }

    private Set<Id> extractRecordTypeIds(Map<String, Map<Id, List<EUR_CRM_Account__c>>> accountsByRTIdByTypeOfUpdate) {
        Set<Id> rtIds = new Set<Id>();
        for (String typeOfUpdate : accountsByRTIdByTypeOfUpdate.keySet()) {
            rtIds.addAll(accountsByRTIdByTypeOfUpdate.get(typeOfUpdate).keySet());
        }
        return rtIds;
    }

    private Map<String, List<EUR_CRM_Account__c>> getAccountsByCountry(List<EUR_CRM_Account__c> accounts, Map<String, String> rtDevNameById) {
        Map<String, List<EUR_CRM_Account__c>> accountsByCountry = new Map<String, List<EUR_CRM_Account__c>>();

        for (EUR_CRM_Account__c acc : accounts) {
            String countryCode = this.getCountryCode(acc, rtDevNameById);
            if (accountsByCountry.containsKey(countryCode)) {
                accountsByCountry.get(countryCode).add(acc);
            } else {
                accountsByCountry.put(countryCode, new List<EUR_CRM_Account__c> { acc });
            }
        }

        return accountsByCountry;
    }

    private String getCountryCode(EUR_CRM_Account__c acc, Map<String, String> rtDevNameById) {
        if (String.isNotBlank(acc.EUR_CRM_Country_Code__c)) {
            return acc.EUR_CRM_Country_Code__c;
        }

        if (rtDevNameById.containsKey(acc.RecordTypeId)) {
            return this.extractCountryCodeFromRTDevName(rtDevNameById.get(acc.RecordTypeId));
        }

        return null;
    }

    private Set<String> getVisitFrequencyRTDevNames(Map<String, List<EUR_CRM_Account__c>> accountsByCountry) {
        Set<String> visitFrequencyRTDevNames = new Set<String>();
        for (String countryCode : accountsByCountry.keySet()) {
            visitFrequencyRTDevNames.add(this.configureVisitFrequencyRTDevName(countryCode));
        }
        return visitFrequencyRTDevNames;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isEmptyVisitFrequency(EUR_CRM_Account__c acc) {
        return acc.EUR_CRM_Visit_Frequency__c == null;
    }

    private String configureVisitFrequencyRTDevName(String countryCode) {
        return 'EUR_' + countryCode + '_Visit_Frequency';
    }

    private String extractCountryCodeFromRTDevName(String rtDevName) {
        if (rtDevName.startsWith('EUR_')) {
            return rtDevName.substring(4, 6);
        }
        return null;
    }

    private Boolean isValidChannel(EUR_CRM_Account__c acc) {
        return String.isNotBlank(acc.EUR_CRM_Channel__c)
            && VALID_ACCOUNT_CHANNELS.contains(acc.EUR_CRM_Channel__c)
        ;
    }

    private Boolean isChannelChanged(EUR_CRM_Account__c acc, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return acc.EUR_CRM_Channel__c != oldAccountById.get(acc.Id).EUR_CRM_Channel__c;
    }

    private Boolean isValidOutletClassification(EUR_CRM_Account__c acc) {
        return String.isNotBlank(acc.EUR_CRM_Outlet_Classification__c)
            && ! acc.EUR_CRM_Outlet_Classification__c.equalsIgnoreCase('--None--')
            && String.isNotBlank(acc.EUR_CRM_Outlet_Classification_Type__c)
            && ! acc.EUR_CRM_Outlet_Classification_Type__c.equalsIgnoreCase('--None--')
        ;
    }

    private Boolean isValidOutletClassificationChanged(EUR_CRM_Account__c acc, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return this.isValidOutletClassification(acc)
            && (
            acc.EUR_CRM_Outlet_Classification__c != oldAccountById.get(acc.Id).EUR_CRM_Outlet_Classification__c
            || acc.EUR_CRM_Outlet_Classification_Type__c != oldAccountById.get(acc.Id).EUR_CRM_Outlet_Classification_Type__c
        )
        ;
    }

    private Boolean isValidOutletGroupAndImageLevelAndVolumePotential(EUR_CRM_Account__c acc) {
        return acc.EUR_CRM_Group_Outlet_Type__c != null
            && acc.EUR_CRM_Image_Level__c != null
            && acc.EUR_CRM_Volume_Potential__c != null
        ;
    }

    private Boolean isValidOutletGroupOrImageLevelOrVolumePotentialChanged(EUR_CRM_Account__c acc, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return this.isValidOutletGroupAndImageLevelAndVolumePotential(acc)
            && (
            acc.EUR_CRM_Group_Outlet_Type__c != oldAccountById.get(acc.Id).EUR_CRM_Group_Outlet_Type__c
            || acc.EUR_CRM_Image_Level__c != oldAccountById.get(acc.Id).EUR_CRM_Image_Level__c
            || acc.EUR_CRM_Volume_Potential__c != oldAccountById.get(acc.Id).EUR_CRM_Volume_Potential__c
        )
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<RecordType> selectRecordTypeWhereIds(Set<Id> rtIds) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE Id IN :rtIds
                AND (
                    DeveloperName IN :FI_ACCOUNT_RECORD_TYPE_DEV_NAMES
                    OR DeveloperName IN :NG_ACCOUNT_RECORD_TYPE_DEV_NAMES
                )
        ];
    }

    private List<EUR_CRM_Visit_Frequency__c> selectVisitFrequenciesWhereRTDevNames(Set<String> rtDevNames) {
        return [
            SELECT Id
            ,   Name
            ,   RecordType.DeveloperName
            FROM EUR_CRM_Visit_Frequency__c
            WHERE RecordType.DeveloperName IN :rtDevNames
                AND Name IN :VISIT_FREQUENCY_NAMES

        ];
    }

    private List<EUR_CRM_Visit_Frequency_Criteria__c> selectVisitFrequencyCriteriaWhereRTDevNames(Set<String> rtDevNames) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            ,   EUR_CRM_Group_Outlet_Type__c
            ,   EUR_CRM_Image_Level__c
            ,   EUR_CRM_Volume_Potential__c
            ,   EUR_CRM_Outlet_Classification__c
            ,   EUR_CRM_Outlet_Classification_Type__c
            ,   EUR_CRM_Visit_Frequency__c
            FROM EUR_CRM_Visit_Frequency_Criteria__c
            WHERE RecordType.DeveloperName IN :rtDevNames
                AND (
                    (
                        EUR_CRM_Group_Outlet_Type__c != NULL
                        AND EUR_CRM_Image_Level__c != NULL
                        AND EUR_CRM_Volume_Potential__c != NULL
                    )
                    OR
                    (
                        EUR_CRM_Outlet_Classification__c != NULL
                        AND EUR_CRM_Outlet_Classification_Type__c != NULL
                    )
                )
                AND EUR_CRM_Visit_Frequency__c != NULL
        ];
    }

}