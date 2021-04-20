public with sharing class EUR_CRM_SalesOrderAutoNumber {

    public static final String COUNTRY_CODE_AND_RT_DELIM = '_&_';

    private final Map<String, String> TRANSFORMED_COUNTRY_CODE_BY_COUNTRY_CODE = new Map<String, String> {
        'IDL' => 'IDL'
    ,   'DB'  => 'IDL'
    };

    private Set<String> transformedCountryCodes = new Set<String>();
    private Set<String> rtDevNames = new Set<String>();



    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void setupAutonumber(List<EUR_CRM_Sales_Order__c> salesOrdersToInsert) {
        System.debug('\n salesOrdersToInsert.size() => ' + salesOrdersToInsert.size() + '\n');
        System.debug('\n salesOrdersToInsert => ' + JSON.serializePretty(salesOrdersToInsert) + '\n');
        Set<String> countryCodes = this.extractCountryCodesOfValidSalesOrders(salesOrdersToInsert);
        System.debug('\n\n countryCodes.size() => ' + JSON.serializePretty(countryCodes.size()) + '\n');
        System.debug('\n\n countryCodes => ' + JSON.serializePretty(countryCodes) + '\n');
        if (countryCodes.isEmpty()) { return ; }

        Set<String> transformedCountryCodes = this.transformCountryCodesForCountriesUsedOneNumberSequence(countryCodes);

        Map<String, String> autoNumFormatByCountryCodeAndRT = new EUR_CRM_SAPIntegrationWrapper().getAutoNumberFormatByCountryCodeAndRT(transformedCountryCodes);
        System.debug('\n autoNumFormatByCountryCodeAndRT.size() => ' + autoNumFormatByCountryCodeAndRT.size() + '\n');
        System.debug('\n autoNumFormatByCountryCodeAndRT => ' + JSON.serializePretty(autoNumFormatByCountryCodeAndRT) + '\n');
        if (autoNumFormatByCountryCodeAndRT.isEmpty()) { return; }

        Map<String, List<EUR_CRM_Sales_Order__c>> salesOrdersToProceedByCountryCodeAndRT = this.getSalesOrdersToProceedByCountryCodeAndRT(autoNumFormatByCountryCodeAndRT, salesOrdersToInsert);
        System.debug('\n salesOrdersToProceedByCountryCodeAndRT.size() => ' + salesOrdersToProceedByCountryCodeAndRT.size() + '\n');
        System.debug('\n salesOrdersToProceedByCountryCodeAndRT => ' + JSON.serializePretty(salesOrdersToProceedByCountryCodeAndRT) + '\n');
        if (salesOrdersToProceedByCountryCodeAndRT.isEmpty()) { return; }

        Map<String, EUR_CRM_SalesOrderAutoNumber__c> autoNumSettingByCountryCodeAndRT = this.getAutoNumSettingByCountryCodeAndRT(salesOrdersToProceedByCountryCodeAndRT.keySet());
        System.debug('\n\n autoNumSettingByCountryCodeAndRT.size() => ' + JSON.serializePretty(autoNumSettingByCountryCodeAndRT.size()) + '\n');
        System.debug('\n\n autoNumSettingByCountryCodeAndRT => ' + JSON.serializePretty(autoNumSettingByCountryCodeAndRT) + '\n');

        for (String ccAndRt : salesOrdersToProceedByCountryCodeAndRT.keySet()) {
            String lastNumber = autoNumFormatByCountryCodeAndRT.get(ccAndRt);
            String prefix = this.getPrefix(lastNumber);

            if (autoNumSettingByCountryCodeAndRT.containsKey(ccAndRt)) {
                lastNumber = autoNumSettingByCountryCodeAndRT.get(ccAndRt).EUR_CRM_LastNumber__c;
            }

            for (EUR_CRM_Sales_Order__c order : salesOrdersToProceedByCountryCodeAndRT.get(ccAndRt)) {
                Decimal num = Decimal.valueOf(lastNumber) + 1;
                String finalNumber = prefix + String.valueOf(num);
                order.EUR_CRM_SF_Order_Number__c = finalNumber;
                lastNumber = finalNumber;
            }

            if (autoNumSettingByCountryCodeAndRT.containsKey(ccAndRt)) {
                autoNumSettingByCountryCodeAndRT.get(ccAndRt).EUR_CRM_LastNumber__c = lastNumber;
            } else {
                autoNumSettingByCountryCodeAndRT.put(ccAndRt, new EUR_CRM_SalesOrderAutoNumber__c(
                    Name = ccAndRt
                    ,   EUR_CRM_Country_Code__c = ccAndRt.split(COUNTRY_CODE_AND_RT_DELIM)[0]
                    ,   EUR_CRM_SalesOrderRecordType__c = ccAndRt.split(COUNTRY_CODE_AND_RT_DELIM)[1]
                    ,   EUR_CRM_LastNumber__c = lastNumber
                ));
            }
        }
        System.debug('\n UPSERT autoNumSettingByCountryCodeAndRT.size() => ' + autoNumSettingByCountryCodeAndRT.size() + '\n');
        System.debug('\n UPSERT autoNumSettingByCountryCodeAndRT => ' + JSON.serializePretty(autoNumSettingByCountryCodeAndRT) + '\n');
		List<Database.UpsertResult> upsertResults = Database.upsert(autoNumSettingByCountryCodeAndRT.values());
		System.debug('\n upsertResults.size() => ' + upsertResults.size() + '\n');
		System.debug('\n upsertResults => ' + JSON.serializePretty(upsertResults) + '\n');
	}


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<String, List<EUR_CRM_Sales_Order__c>> getSalesOrdersToProceedByCountryCodeAndRT(
        Map<String, String> autoNumberFormatByRTbyCountryCode, List<EUR_CRM_Sales_Order__c> salesOrdersToInsert) {
 
        Map<Id, RecordTypeInfo> rtInfoByDevName = Schema.SobjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosById();
        Map<String, List<EUR_CRM_Sales_Order__c>> salesOrdersToProceedByRTandCountryCode = new Map<String, List<EUR_CRM_Sales_Order__c>>();

        for (EUR_CRM_Sales_Order__c order : salesOrdersToInsert) {
            String rtDevName = rtInfoByDevName.get(order.RecordTypeId).getDeveloperName();
            String transformedCountryCode = this.getCountryCode(order.EUR_CRM_Country_Code__c);
            String countryCodeAndRT = transformedCountryCode + COUNTRY_CODE_AND_RT_DELIM + rtDevName;
            System.debug('\n order => ' + JSON.serializePretty(order) + '\n');
            System.debug('\n countryCodeAndRT => ' + countryCodeAndRT + '\n');
            System.debug('\n autoNumberFormatByRTbyCountryCode.containsKey(countryCodeAndRT => ' + autoNumberFormatByRTbyCountryCode.containsKey(countryCodeAndRT) + '\n');
            if (autoNumberFormatByRTbyCountryCode.containsKey(countryCodeAndRT)) {
                if (salesOrdersToProceedByRTandCountryCode.containsKey(countryCodeAndRT)) {
                    salesOrdersToProceedByRTandCountryCode
                        .get(countryCodeAndRT)
                        .add(order);
                } else {
                    salesOrdersToProceedByRTandCountryCode
                        .put(countryCodeAndRT, new List<EUR_CRM_Sales_Order__c>{ order });
                }
            }
        }
        return salesOrdersToProceedByRTandCountryCode;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<String> extractCountryCodesOfValidSalesOrders(List<EUR_CRM_Sales_Order__c> salesOrders) {
        Set<String> countryCodes = new Set<String>();
        for (EUR_CRM_Sales_Order__c so : salesOrders) {
            // PARX yle : Add filter to check whether the order is created from Service cloud in order to prevent creation of order created from other systems
            if (so.EUR_CRM_IsMobile__c == true || so.EUR_NIM_IsServiceCloud__c) 
            {
                countryCodes.add(so.EUR_CRM_Country_Code__c);
            }
        }
        return countryCodes;
    }

    private Set<String> transformCountryCodesForCountriesUsedOneNumberSequence(Set<String> countryCodes) {
        Set<String> transformedCountryCodes = new Set<String>();
        for (String countryCode : countryCodes) {
            if (TRANSFORMED_COUNTRY_CODE_BY_COUNTRY_CODE.containsKey(countryCode)) {
                transformedCountryCodes.add(TRANSFORMED_COUNTRY_CODE_BY_COUNTRY_CODE.get(countryCode));
            } else {
                transformedCountryCodes.add(countryCode);
            }
        }
        return transformedCountryCodes;
    }

    private String getCountryCode(String countryCode) {
        if (TRANSFORMED_COUNTRY_CODE_BY_COUNTRY_CODE.containsKey(countryCode)) {
            return TRANSFORMED_COUNTRY_CODE_BY_COUNTRY_CODE.get(countryCode);
        }
        return countryCode;
    }

    private Map<String, EUR_CRM_SalesOrderAutoNumber__c> getAutoNumSettingByCountryCodeAndRT(Set<String> countryCodeAndRT) {
        this.splitCountryCodeAndRT(countryCodeAndRT);
        if (this.transformedCountryCodes.isEmpty() || this.rtDevNames.isEmpty()) { return new Map<String, EUR_CRM_SalesOrderAutoNumber__c>(); }

        List<EUR_CRM_SalesOrderAutoNumber__c> settingAutoNumbers = this.selectSalesOrderAutoNumbers(this.rtDevNames, this.transformedCountryCodes);
        System.debug('\n salesOrderAutoNumbers.size() => ' + settingAutoNumbers.size() + '\n');
        System.debug('\n salesOrderAutoNumbers => ' + JSON.serializePretty(settingAutoNumbers) + '\n');

        Map<String, EUR_CRM_SalesOrderAutoNumber__c> settingByCountryCodeAndRT = new Map<String, EUR_CRM_SalesOrderAutoNumber__c>();
        for (EUR_CRM_SalesOrderAutoNumber__c setting : settingAutoNumbers) {
            String ccAndRT = setting.EUR_CRM_Country_Code__c + COUNTRY_CODE_AND_RT_DELIM + setting.EUR_CRM_SalesOrderRecordType__c;
            settingByCountryCodeAndRT.put(ccAndRT, setting);
        }
        return settingByCountryCodeAndRT;
    }

    private void splitCountryCodeAndRT(Set<String> countryCodeAndRT) {
        for (String ccAndRt : countryCodeAndRT) {
            List<String> ccAndRts = ccAndRt.split(COUNTRY_CODE_AND_RT_DELIM);
            if (ccAndRts.size() > 1) {
                this.transformedCountryCodes.add(ccAndRt.split(COUNTRY_CODE_AND_RT_DELIM)[0]);
                this.rtDevNames.add(ccAndRt.split(COUNTRY_CODE_AND_RT_DELIM)[1]);
            }
        }
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private String getPrefix(String autoNumberFormat) {
        String prefix = '';
        for (Integer i = 0; i < autoNumberFormat.length(); i++) {
            if (autoNumberFormat.charAt(i) == 48) {
                prefix += '0';
            } else {
                break;
            }
        }
        return prefix;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_SalesOrderAutoNumber__c> selectSalesOrderAutoNumbers(Set<String> rtDevNames, Set<String> countryCodes) {
        return [
            SELECT Id
                ,   EUR_CRM_SalesOrderRecordType__c
                ,   EUR_CRM_LastNumber__c
                ,   EUR_CRM_Country_Code__c
            FROM EUR_CRM_SalesOrderAutoNumber__c
            WHERE EUR_CRM_SalesOrderRecordType__c IN :rtDevNames
                AND EUR_CRM_Country_Code__c IN :countryCodes
                FOR UPDATE
        ];
    }

}