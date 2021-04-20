public with sharing class EUR_CRM_PRSSegmentationFilterCtrl {

    @TestVisible private static final String NONE = '--None--';
    @TestVisible private static final String PROS = 'PROS';
    @TestVisible private static final String PROFS = 'PROFS';

//    private static final Set<String> COLUMNS_AVAILABLE_ONLY_FOR_IDL_ROLES = new Set<String> {
//        'MAINSTREAM PREMIUM'
//    ,   'MAINSTREAM STANDARD'
//    };

//    private static final String PROS_ROWS = 'Restaurant,Night Club,Low Energy Bar,High Energy Bar';
    private static final String PROFS_ROWS = 'Hyper/Supermarket,Convenience,Cash & Carry,Discounters,Traditional Off Trade,Liquor Specialists,Online';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    @AuraEnabled
    public static List<SelectOptionWrapper> getSelectionMethodOptions() {
        String userCountryCode = getUserCountryCode();
        Map<String, Boolean> prosAndPROFSavailability = getPROSandPROFSavailabilityForCountry(userCountryCode);
        if (prosAndPROFSavailability.isEmpty()) { return new List<SelectOptionWrapper>(); }

        List<SelectOptionWrapper> options = new List<SelectOptionWrapper> { new SelectOptionWrapper(NONE, NONE) };
        if (prosAndPROFSavailability.get(PROS) == true) { options.add(new SelectOptionWrapper(PROS, PROS)); }
        if (prosAndPROFSavailability.get(PROFS) == true) { options.add(new SelectOptionWrapper(PROFS, PROFS)); }

        if (options.size() == 1) { return new List<SelectOptionWrapper>(); }
        return options;
    }

    @AuraEnabled
    public static List<PROSWrapperAura> getPROSTable() {
        List<PROSWrapperAura> prosWrappers = new List<PROSWrapperAura>();

        String userCountryCode = getUserCountryCode();
        Set<String> gotNames = getGotNames(userCountryCode);
        Set<String> iLNames = getILNames(userCountryCode);
        for (String gotName : gotNames) {
            prosWrappers.add(new PROSWrapperAura(gotName, iLNames));
        }
        System.debug('\n\n prosWrappers => ' + JSON.serializePretty(prosWrappers) + '\n');
        return prosWrappers;
    }

    @AuraEnabled
    public static List<PROFSWrapperAura> getPROFS() {
        List<PROFSWrapperAura> profsWrappers = new List<PROFSWrapperAura>();

        Schema.DescribeFieldResult fieldResult = EUR_CRM_PRS_Group_Outlet_Type__c.EUR_CRM_PRS_Group_Outlet_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            String got = f.getValue();
            if (PROFS_ROWS.containsIgnoreCase(got)) {
                profsWrappers.add(new PROFSWrapperAura(got));
            }
        }
        System.debug('\n\n profsWrappers => ' + JSON.serializePretty(profsWrappers) + '\n');
        return profsWrappers;
    }


    /* ========================================================= */
    /*     High Level Method
    /* ========================================================= */
    private static Map<String, Boolean> getPROSandPROFSavailabilityForCountry(String countryCode) {
        List<EUR_CRM_CT_Account_Target_Group_Setup__mdt> atgSetups = selectAccountTargetGroupSetupsWhereCountryCode(countryCode);
        if (atgSetups.isEmpty()) { return new Map<String, Boolean>(); }

        Map<String, Boolean> prosAndPROFSavailability = new Map<String, Boolean>();
        for (EUR_CRM_CT_Account_Target_Group_Setup__mdt setup : atgSetups) {
            prosAndPROFSavailability.put(PROS, setup.EUR_CRM_Is_PROS_Available__c);
            prosAndPROFSavailability.put(PROFS, setup.EUR_CRM_Is_PROFS_available__c);
        }
        return prosAndPROFSavailability;
    }

    private static Set<String> getGotNames(String countrCode) {
        List<EUR_CRM_PRS_Group_Outlet_Type__c> gots = selectGOTsWhereCountryCode(countrCode);
        Set<String> gotNames = new Set<String>();
        if (gots.isEmpty()) { return gotNames; }

        for (EUR_CRM_PRS_Group_Outlet_Type__c got : gots) {
            gotNames.add(got.EUR_CRM_PRS_Group_Outlet_Name__c);
        }
        return gotNames;
    }

    private static Set<String> getILNames(String countrCode) {
        List<EUR_CRM_PRS_Seg_Aspect__c> imageLevels = selectILSegAspectsWhereCountryCode(countrCode);

        Set<String> iLNames = new Set<String>();
        if (imageLevels.isEmpty()) { return iLNames; }

        for (EUR_CRM_PRS_Seg_Aspect__c imageLevel : imageLevels) {
            iLNames.add(imageLevel.EUR_CRM_Segmentation_IL_Aspect_Name__c);
        }
        return iLNames;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static String getUserCountryCode() {
		String countryCodes = getUserCountryCodes();
		if (String.isBlank(countryCodes)) { return ''; }
		return countryCodes.split('[,;]')[0];
    }

    private static String getUserCountryCodes() {
        return [
            SELECT Id
                , EUR_CRM_Country_Code__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ][0].EUR_CRM_Country_Code__c;
    }

    private static List<EUR_CRM_CT_Account_Target_Group_Setup__mdt> selectAccountTargetGroupSetupsWhereCountryCode(String countryCode) {
        return [
            SELECT Id
            ,   EUR_CRM_Country__c
            ,   EUR_CRM_Is_PROS_Available__c
            ,   EUR_CRM_Is_PROFS_available__c
            FROM EUR_CRM_CT_Account_Target_Group_Setup__mdt
            WHERE EUR_CRM_Country__c = :countryCode
        ];
    }

    private static List<EUR_CRM_PRS_Group_Outlet_Type__c> selectGOTsWhereCountryCode(String countryCode) {
        return [
            SELECT Id
            ,   EUR_CRM_PRS_Group_Outlet_Name__c
            FROM EUR_CRM_PRS_Group_Outlet_Type__c
            WHERE EUR_CRM_Country_Code__c = :countryCode
            AND RecordType.DeveloperName LIKE '%_On_Trade_%'
        ];
    }

    private static List<EUR_CRM_PRS_Seg_Aspect__c> selectILSegAspectsWhereCountryCode(String countryCode) {
        return [
            SELECT Id
            ,   EUR_CRM_Country_Code__c
            ,   EUR_CRM_Segmentation_IL_Aspect_Name__c
            ,   RecordType.DeveloperName
            FROM EUR_CRM_PRS_Seg_Aspect__c
            WHERE EUR_CRM_Country_Code__c = :countryCode
            AND RecordType.DeveloperName LIKE '%_image_level'
        ];
    }


    /* ========================================================= */
    /*     Class Wrappers
    /* ========================================================= */
    public class SelectOptionWrapper {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        public SelectOptionWrapper(String v, String l) {
            this.value = v;
            this.label = l;
        }
    }

    public class PROSWrapperAura {
        @AuraEnabled public String groupOutletType { get; set; }
        @AuraEnabled public Boolean selectAll { get; set; }
        @AuraEnabled public List<CheckboxWrapperAura> imageLevelCheckboxWrappers { get; set; }

        public PROSWrapperAura(String got, Set<String> iLNames) {
            this.groupOutletType = got;
            this.selectAll = false;

            this.imageLevelCheckboxWrappers = new List<CheckboxWrapperAura>();
            for (String iLName : iLNames) {
                this.imageLevelCheckboxWrappers.add(new CheckboxWrapperAura(iLName));
            }
        }
    }

    public class CheckboxWrapperAura {
        @AuraEnabled public String imageLevelName { get; set; }
        @AuraEnabled public Boolean isChecked { get; set; }

        public CheckboxWrapperAura(String ilName) {
            this.imageLevelName = ilName;
            this.isChecked = false;
        }
    }

    public class PROFSWrapperAura {
        @AuraEnabled public String Name { get; set; }
        public PROFSWrapperAura(String n) {
            this.name = n;
        }
    }

}