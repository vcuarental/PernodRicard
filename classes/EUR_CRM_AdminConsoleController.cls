public with sharing class EUR_CRM_AdminConsoleController {

    private static final String PAGE_TITLE_TEMPLATE = 'PR {0} Admin Console';
    private final Map<String, String> VALID_COUNTRY_CODE_BY_COUNTRY_NAME = this.getCountryNameByCountryCode();
//    private static final Map<String, String> VALID_COUNTRY_CODE_BY_COUNTRY_NAME = new Map<String, String>{
//        'NL' => 'Netherlands',
//        'SE' => 'Sweden',
//        'IDL' => 'Ireland',
//        'DB' => 'Dylan Bass',
//        'IT' => 'Italy',
//        'DK' => 'Denmark',
//        'FI' => 'Finland',
//        'BG' => 'Bulgaria'
//    };
    public String countryCode { get; set; }

    public String pageTitle { get; set; }

    public EUR_CRM_AdminConsoleController() {
        countryCode = this.selectCurrentUser().EUR_CRM_Country_Code__c;
        if (String.isNotBlank(countryCode)) {
            countryCode = countryCode.split(';')[0];
        }
        pageTitle = String.format(PAGE_TITLE_TEMPLATE, new List<String>{VALID_COUNTRY_CODE_BY_COUNTRY_NAME.get(countryCode)});
    }


    /* ========================================================= */
    /*      High Level Helpers
    /* ========================================================= */
    private Map<String, String> getCountryNameByCountryCode() {
        List<EUR_CRM_Rollout_Country__mdt> rcs = this.selectRolloutCountries();
        if (rcs.isEmpty()) { return new Map<String, String>(); }

        Map<String, String> rolloutCountryByCode = new Map<String, String>();
        for (EUR_CRM_Rollout_Country__mdt rc : rcs) {
            rolloutCountryByCode.put(rc.DeveloperName, rc.CountryName__c);
        }
        return rolloutCountryByCode;
    }

    /*==============================
        SOQL Selectors
    * ==============================*/
    private User selectCurrentUser() {
        return [
            SELECT EUR_CRM_Country_Code__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }

    private List<EUR_CRM_Rollout_Country__mdt> selectRolloutCountries() {
        return [
            SELECT
                CountryName__c
            ,   DeveloperName
            FROM EUR_CRM_Rollout_Country__mdt
        ];
    }
}