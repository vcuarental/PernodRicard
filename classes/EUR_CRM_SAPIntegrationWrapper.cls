public with sharing class EUR_CRM_SAPIntegrationWrapper {


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public Map<String, String> getAutoNumberFormatByCountryCodeAndRT(Set<String> transformedCountryCodes) {
        List<EUR_CRM_SAP_Integration__mdt> integrations = this.getSapIntegrations(transformedCountryCodes);
        System.debug('\n\n integrations.size() => ' + JSON.serializePretty(integrations.size()) + '\n');
        System.debug('\n\n integrations => ' + JSON.serializePretty(integrations) + '\n');
        if (integrations.isEmpty()) { return new Map<String, String>(); }

        Map<String, String> numFormatByCountryCodeAndRT = new Map<String, String>();
        for (EUR_CRM_SAP_Integration__mdt integr : integrations) {
            String countryCodeAndRT = integr.EUR_CRM_Country_Code__c + EUR_CRM_SalesOrderAutoNumber.COUNTRY_CODE_AND_RT_DELIM + integr.EUR_CRM_Sales_Order_Record_Type__c;
            numFormatByCountryCodeAndRT.put(countryCodeAndRT, integr.EUR_CRM_Autonumber_Format__c);
        }
        return numFormatByCountryCodeAndRT;
    }


    /* ========================================================= */
    /*      Custom Metadata Test mock
    /* ========================================================= */
    private List<EUR_CRM_SAP_Integration__mdt> getSapIntegrationsForTest() {
        return
            new List<EUR_CRM_SAP_Integration__mdt>{
                new EUR_CRM_SAP_Integration__mdt(
                    EUR_CRM_Sales_Order_Record_Type__c = 'EUR_Direct'
                    , EUR_CRM_Autonumber_Format__c = '009295089'
                    , EUR_CRM_Country_Code__c = 'IDL'
                ),
                new EUR_CRM_SAP_Integration__mdt(
                    EUR_CRM_Sales_Order_Record_Type__c = 'EUR_Indirect'
                    , EUR_CRM_Autonumber_Format__c = '001020300'
                    , EUR_CRM_Country_Code__c = 'NL'
                ),
                new EUR_CRM_SAP_Integration__mdt(
                    EUR_CRM_Sales_Order_Record_Type__c = 'EUR_Indirect'
                    , EUR_CRM_Autonumber_Format__c = '002030400'
                    , EUR_CRM_Country_Code__c = 'IDL'
                )
            }
            ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_SAP_Integration__mdt> getSapIntegrations(Set<String> countryCodes) {
        if (Test.isRunningTest()) { return this.getSapIntegrationsForTest(); }
        return [
            SELECT Id
                , EUR_CRM_Sales_Order_Record_Type__c
                , EUR_CRM_Autonumber_Format__c
                , EUR_CRM_Country_Code__c
            FROM EUR_CRM_SAP_Integration__mdt
            WHERE EUR_CRM_Country_Code__c IN :countryCodes
            AND EUR_CRM_Sales_Order_Record_Type__c != NULL
            AND EUR_CRM_Autonumber_Format__c != NULL
        ];
    }
}