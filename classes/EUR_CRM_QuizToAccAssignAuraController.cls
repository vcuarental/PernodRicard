public with sharing class EUR_CRM_QuizToAccAssignAuraController {

    @TestVisible private static final String ACCOUNT_LIST_VIEWS = 'Account list views';
    @TestVisible private static final String CUSTOMER_TAXONOMY = 'Customer taxonomy';
    @TestVisible private static final String PROS = 'PROS';
    @TestVisible private static final String PROFS = 'PROFS';
    @TestVisible private static final String NONE = '--None--';
    @TestVisible private static final String SUCCESS_RESULT = 'OK';

    private static final String DEFAULT_ORDERING = 'ORDER BY Name';
    private static final String DEFAULT_LIMIT = ' LIMIT 10000';

    private static final Set<String> ADDITIONAL_ROLES = new Set<String> {
        'IDL'
    ,   'DB'
    };
    private static final String MAINSTREAM = 'MAINSTREAM';
    private static final Set<String> ADDITIONAL_MAINSTREAM = new Set<String> {
        'MAINSTREAM PREMIUM'
    ,   'MAINSTREAM STANDARD'
    ,   'MAINSTREAM QUALITY'            
    };

    private static final String PROS_ROWS = 'Restaurant,Night Club,Low Energy Bar,High Energy Bar';
    private static final String PROFS_ROWS = 'Hyper/Supermarket,Convenience,Cash & Carry,Discounters,Traditional Off Trade,Liquor Specialists,Online';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    @AuraEnabled
    public static List<SelectOptionWrapper> getSelectionMethodOptions() {
        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
        options.add(new SelectOptionWrapper(NONE, NONE));
        options.add(new SelectOptionWrapper(ACCOUNT_LIST_VIEWS, ACCOUNT_LIST_VIEWS));
        options.add(new SelectOptionWrapper(CUSTOMER_TAXONOMY, CUSTOMER_TAXONOMY));

        String userCountryCodes = getUserCountryCodes();
        Map<String, Boolean> prosAndPROFSavailability = getPROSandPROFSavailabilityForCountry(userCountryCodes);

        if (prosAndPROFSavailability.isEmpty()) {
            options.add(new SelectOptionWrapper(PROS, PROS));
            options.add(new SelectOptionWrapper(PROFS, PROFS));
        } else {
            if (prosAndPROFSavailability.get(PROS) == true) { options.add(new SelectOptionWrapper(PROS, PROS)); }
            if (prosAndPROFSavailability.get(PROFS) == true) { options.add(new SelectOptionWrapper(PROFS, PROFS)); }
        }

        return options;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getAccountListViewOptions() {
        String query = 'SELECT Id FROM EUR_CRM_Account__c LIMIT 1';
        ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator(query));

        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
        options.add(new SelectOptionWrapper(NONE, NONE));
        for (SelectOption so : con.getListViewOptions()) {
            options.add(new SelectOptionWrapper(so.getValue(), so.getLabel()));
        }

        return options;
    }

//    @AuraEnabled
//    public static List<SelectOptionWrapper> getCustomerTaxonomyOptions() {
//        List<AggregateResult> aggregateResults = selectCustomerTaxonomyAggRes();
//
//        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
//        options.add(new SelectOptionWrapper(NONE, NONE));
//        for (AggregateResult result : aggregateResults) {
//            String chain = String.valueOf(result.get('Chain'));
//            options.add(new SelectOptionWrapper(chain, chain));
//        }
//        return options;
//    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getCustomerTaxonomyOptions() {
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = selectCustomerTaxonomies();

        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
        options.add(new SelectOptionWrapper(NONE, NONE));
        for (EUR_CRM_Customer_Taxonomy__c ct : customerTaxonomies) {
            options.add(new SelectOptionWrapper(ct.Name, ct.Name));
        }
        return options;
    }

    @AuraEnabled
    public static List<PROSWrapperAura> getPROSTable() {
        List<PROSWrapperAura> prosWrappers = new List<PROSWrapperAura>();

        String userCountryCode = getUserCountryCodes();
        if (String.isNotBlank(userCountryCode) && userCountryCode.containsIgnoreCase(';')) {
            userCountryCode = userCountryCode.split(';')[0];
        }
        Schema.DescribeFieldResult fieldResult = EUR_CRM_PRS_Group_Outlet_Type__c.EUR_CRM_PRS_Group_Outlet_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            String got = f.getValue();
            if (PROS_ROWS.containsIgnoreCase(got)) {
                prosWrappers.add(new PROSWrapperAura(got, userCountryCode));
            }
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

    @AuraEnabled
    public static List<AccountWrapperAura> getAccountsOfListView(String filterId, String recordId) {
        String query = getInitialQuery();
        query += DEFAULT_ORDERING + DEFAULT_LIMIT;

        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        controller.setPageSize(1000);
        controller.setFilterId(Id.valueOf(filterId));

        List<sObject> lstAccs = new List<sObject>();
        lstAccs.addAll(controller.getRecords());
        while(controller.getHasNext()){
            controller.next();
            lstAccs.addAll(controller.getRecords());
        }

        return convertToWrapper(lstAccs, recordId, true);
    }

    @AuraEnabled
    public static List<AccountWrapperAura> getAccountsOfCustomerTaxonomy(String customerTaxonomy, String recordId) {
        String query = getInitialQuery();
//        query += 'WHERE EUR_CRM_Customer_Taxonomy_Chain__c = \'' + customerTaxonomy + '\' ';
        query += 'WHERE EUR_CRM_Customer_Taxonomy_Name__c = \'' + customerTaxonomy + '\' ';
        query += DEFAULT_ORDERING;

        return convertToWrapper(Database.query(query), recordId, true);
    }

    @AuraEnabled
    public static List<AccountWrapperAura> getAccountsOfPros(String prosWrappersJSON, String recordId) {
        List<PROSWrapperAura> prosWrappers = (List<PROSWrapperAura>)System.JSON.deserializeStrict(prosWrappersJSON, List<PROSWrapperAura>.class);

        String condition = getConditionString(prosWrappers);
        System.debug('\n\n condition => ' + JSON.serializePretty(condition) + '\n');

        String query = getInitialQuery();
        query += condition;
        query += ' AND EUR_CRM_Status__c != \'Inactive\' ';
        query += DEFAULT_ORDERING;
        System.debug('\n\n query => ' + JSON.serializePretty(query) + '\n');

        return convertToWrapper(Database.query(query), recordId, true);
    }

    @AuraEnabled
    public static List<AccountWrapperAura> getAccountsOfProfs(String profsWrappersJSON, String recordId) {
        List<PROFSWrapperAura> profsWrappers = (List<PROFSWrapperAura>)System.JSON.deserializeStrict(profsWrappersJSON, List<PROFSWrapperAura>.class);

        String condition = getConditionString(profsWrappers);
        System.debug('\n\n condition => ' + JSON.serializePretty(condition) + '\n');

        String query = getInitialQuery();
        query += condition;
        query += DEFAULT_ORDERING;
        System.debug('\n\n query => ' + JSON.serializePretty(query) + '\n');

        return convertToWrapper(Database.query(query), recordId, true);
    }

    @AuraEnabled
    public static List<AccountWrapperAura> getAssignedAccounts(String recordId) {
        String query = getInitialQuery();
        query += 'WHERE Id IN (SELECT EUR_CRM_AccountId__c FROM EUR_CRM_QuizPartaker__c WHERE EUR_CRM_QuizId__c = \'' + recordId + '\') ';
        query += DEFAULT_ORDERING;

        System.debug('\n\n query => ' + JSON.serializePretty(query) + '\n');

        return convertToWrapper(Database.query(query), recordId, false);
    }

    @AuraEnabled
    public static String assignToAccounts(String accountIdsJSON, String recordId) {
        Set<String> accountIds = (Set<String>)System.JSON.deserializeStrict(accountIdsJSON, Set<String>.class);

        List<EUR_CRM_QuizPartaker__c> quizPartakers = new List<EUR_CRM_QuizPartaker__c>();
        for (Id accId : accountIds) {
            quizPartakers.add(new EUR_CRM_QuizPartaker__c(
                EUR_CRM_AccountId__c = accId
            ,   EUR_CRM_QuizId__c = recordId
            ));
        }
        insert quizPartakers;

        return 'OK';
    }

    @AuraEnabled
    public static String deleteAccountAssignments(String accountIdsJSON, String recordId) {
        Set<String> accountIds = (Set<String>)System.JSON.deserializeStrict(accountIdsJSON, Set<String>.class);

        List<EUR_CRM_QuizPartaker__c> quizPartakers = [
            SELECT Id
            FROM EUR_CRM_QuizPartaker__c
            WHERE EUR_CRM_AccountId__c IN :accountIds
                AND EUR_CRM_QuizId__c = :recordId
        ];
        delete quizPartakers;

        return 'OK';
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private static Map<String, Boolean> getPROSandPROFSavailabilityForCountry(String countryCodes) {
        if (String.isBlank(countryCodes)) { return new Map<String, Boolean>(); }

        List<EUR_CRM_CT_Account_Target_Group_Setup__mdt> atgSetups = selectAccountTargetGroupSetupsWhereCountryCode(countryCodes);
        if (atgSetups.isEmpty()) { return new Map<String, Boolean>(); }

        Map<String, Boolean> prosAndPROFSavailability = new Map<String, Boolean> {
            PROS => false
        ,   PROFS => false
        };
        for (EUR_CRM_CT_Account_Target_Group_Setup__mdt setup : atgSetups) {
            if (setup.EUR_CRM_Is_PROS_Available__c == true) {
                prosAndPROFSavailability.put(PROS, setup.EUR_CRM_Is_PROS_Available__c);
            }

            if (setup.EUR_CRM_Is_PROFS_available__c == true) {
                prosAndPROFSavailability.put(PROFS, setup.EUR_CRM_Is_PROFS_available__c);
            }
        }
        return prosAndPROFSavailability;
    }

    private static List<AccountWrapperAura> convertToWrapper(List<EUR_CRM_Account__c> accounts, Id recordId, Boolean doQuizPartakerFiltering) {
        System.debug('\n\n accounts.size() => ' + JSON.serializePretty(accounts.size()) + '\n');
        //System.debug('\n\n accounts => ' + JSON.serializePretty(accounts) + '\n');

        Map<Id, EUR_CRM_QuizPartaker__c> quizPartakerByAccountId = getQuizPartakerByAccountId(accounts, recordId);
        System.debug('\n\n quizPartakerByAccountId.size() => ' + JSON.serializePretty(quizPartakerByAccountId.size()) + '\n');
        System.debug('\n\n quizPartakerByAccountId => ' + JSON.serializePretty(quizPartakerByAccountId) + '\n');

        List<AccountWrapperAura> wrappers = new List<AccountWrapperAura>();
        for (EUR_CRM_Account__c account : accounts) {
            if (doQuizPartakerFiltering == true) {
                if ( ! quizPartakerByAccountId.containsKey(account.Id)) {
                    wrappers.add(new AccountWrapperAura(account));
                }
            } else {
                wrappers.add(new AccountWrapperAura(account));
            }
        }
        return wrappers;
    }

    private static String getConditionString(List<PROSWrapperAura> prosWrappers) {
        Map<String, Set<String>> imageLevelsByGOT = getImageLevelsByGOT(prosWrappers);
        System.debug('\n\n imageLevelsByGOT => ' + JSON.serializePretty(imageLevelsByGOT) + '\n');
        if (imageLevelsByGOT.isEmpty()) { return ''; }

        String condition = 'WHERE EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c IN (\'' + String.join(new List<String>(imageLevelsByGOT.keySet()), '\',\'') + '\')';
        condition += ' AND EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_On_Trade_Group_Outlet_Type\' ';

        Set<String> imageLevels = new Set<String>();
        for (String got : imageLevelsByGOT.keySet()) {
            imageLevels.addAll(imageLevelsByGOT.get(got));
        }
        System.debug('\n\n imageLevels => ' + JSON.serializePretty(imageLevels) + '\n');

        condition += ' AND EUR_CRM_PRS_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c IN (\'' + String.join(new List<String>(imageLevels), '\',\'') + '\')';
        condition += ' AND EUR_CRM_PRS_Image_Level__r.RecordType.DeveloperName LIKE \'%_Image_Level\' ';

        return condition;
    }

    private static String getConditionString(List<PROFSWrapperAura> profsWrappers) {
        List<String> profs = extractPROFS(profsWrappers);
        System.debug('\n\n profs => ' + JSON.serializePretty(profs) + '\n');
        if (profs.isEmpty()) { return ''; }

        String condition = 'WHERE EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c IN (\'' + String.join(profs, '\',\'') + '\')';
        condition += ' AND EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName LIKE \'%_PRS_Off_Trade_Group_Outlet_Type\' ';

        return condition;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private static Map<Id, EUR_CRM_QuizPartaker__c> getQuizPartakerByAccountId(List<EUR_CRM_Account__c> accounts, Id recordId) {
        List<EUR_CRM_QuizPartaker__c> quizPartakers = selectQuizPartakers(new Map<Id, EUR_CRM_Account__c>(accounts).keySet(), recordId);
        System.debug('\n\n quizPartakers => ' + JSON.serializePretty(quizPartakers) + '\n');

        Map<Id, EUR_CRM_QuizPartaker__c> quizPartakerByAccountId = new Map<Id, EUR_CRM_QuizPartaker__c>();
        for (EUR_CRM_QuizPartaker__c quizPartaker : quizPartakers) {
            quizPartakerByAccountId.put(quizPartaker.EUR_CRM_AccountId__c, quizPartaker);
        }
        return quizPartakerByAccountId;
    }

    private static Map<String, Set<String>> getImageLevelsByGOT(List<PROSWrapperAura> prosWrappers) {
        Map<String, Set<String>> imageLevelsByGOT = new Map<String, Set<String>>();

        for (PROSWrapperAura prosWrapper : prosWrappers) {
            for (CheckboxWrapperAura checkboxWrapper : prosWrapper.imageLevelCheckboxWrappers) {
                if (checkboxWrapper.isChecked == true) {
                    if (imageLevelsByGOT.containsKey(prosWrapper.groupOutletType)) {
                        imageLevelsByGOT.get(prosWrapper.groupOutletType).add(checkboxWrapper.imageLevelName);
                    } else {
                        imageLevelsByGOT.put(prosWrapper.groupOutletType, new Set<String> { checkboxWrapper.imageLevelName });
                    }
                }
            }
        }

        return imageLevelsByGOT;
    }

    private static List<String> extractPROFS(List<PROFSWrapperAura> profsWrappers) {
        List<String> profs = new List<String>();
        for (PROFSWrapperAura wrapper : profsWrappers) {
            profs.add(wrapper.Name);
        }
        return profs;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private static String getUserCountryCodes() {
        return [
            SELECT Id
            ,   EUR_CRM_Affiliate_Code_Picklist__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ][0].EUR_CRM_Affiliate_Code_Picklist__c;
    }

    private static List<EUR_CRM_CT_Account_Target_Group_Setup__mdt> selectAccountTargetGroupSetupsWhereCountryCode(String countryCodes) {
        return [
            SELECT Id
            ,   EUR_CRM_Country__c
            ,   EUR_CRM_Is_PROS_Available__c
            ,   EUR_CRM_Is_PROFS_available__c
            FROM EUR_CRM_CT_Account_Target_Group_Setup__mdt
            WHERE EUR_CRM_Country__c IN :countryCodes.split(';')
        ];
    }

    private static String getInitialQuery() {
        return '' +
        'SELECT Id' +
        ',  Name ' +
        ',  EUR_CRM_Status__c ' +
        ',  EUR_CRM_Channel__c ' +
        ',  EUR_CRM_Region__c ' +
        ',  EUR_CRM_Territory__r.Name ' +
        ',  RecordType.Name ' +
        ',  OwnerId ' +
        ',  Owner.Name ' +
        'FROM EUR_CRM_Account__c ';
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
//    private static List<AggregateResult> selectCustomerTaxonomyAggRes() {
//        return [
//            SELECT EUR_CRM_Chain__c Chain, COUNT(Id)
//            FROM EUR_CRM_Customer_Taxonomy__c
//            WHERE EUR_CRM_Chain__c != NULL
//            GROUP BY EUR_CRM_Chain__c
//        ];
//    }

    private static List<EUR_CRM_Customer_Taxonomy__c> selectCustomerTaxonomies() {
        return [
            SELECT Id, Name
            FROM EUR_CRM_Customer_Taxonomy__c
        ];
    }

    private static List<EUR_CRM_QuizPartaker__c> selectQuizPartakers(Set<Id> accIds, Id recordId) {
        return [
            SELECT Id
            ,   EUR_CRM_AccountId__c
            FROM EUR_CRM_QuizPartaker__c
            WHERE EUR_CRM_AccountId__c IN :accIds
                AND EUR_CRM_QuizId__c = :recordId
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

    public class AccountWrapperAura {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public String Channel { get; set; }
        @AuraEnabled public String Region { get; set; }
        @AuraEnabled public String TerritoryName { get; set; }
        @AuraEnabled public String RecordTypeName { get; set; }
        @AuraEnabled public String OwnerId { get; set; }
        @AuraEnabled public String OwnerName { get; set; }

        public AccountWrapperAura(EUR_CRM_Account__c account) {
            this.Id = account.Id;
            this.Name = account.Name;
            this.Status = account.EUR_CRM_Status__c;
            this.Channel = account.EUR_CRM_Channel__c;
            this.Region = account.EUR_CRM_Region__c;
            this.TerritoryName = account.EUR_CRM_Territory__r.Name;
            this.RecordTypeName = account.RecordType.Name;
            this.OwnerId = account.OwnerId;
            this.OwnerName = account.Owner.Name;
        }
    }

    public class PROSWrapperAura {
        @AuraEnabled public String groupOutletType { get; set; }
        @AuraEnabled public Boolean selectAll { get; set; }
        @AuraEnabled public List<CheckboxWrapperAura> imageLevelCheckboxWrappers { get; set; }

        public PROSWrapperAura(String got, String userCountryCode) {
            this.groupOutletType = got;
            this.selectAll = false;

            this.imageLevelCheckboxWrappers = new List<CheckboxWrapperAura>();
            Schema.DescribeFieldResult fr = EUR_CRM_PRS_Seg_Aspect__c.EUR_CRM_Segmentation_IL_Aspect_Name__c.getDescribe();
            List<Schema.PicklistEntry> p = fr.getPicklistValues();
            for (PicklistEntry entry : p) {
                String imageLevel = entry.getValue();
                if (imageLevel.toUpperCase().contains(MAINSTREAM.toUpperCase())) {
                    if (ADDITIONAL_MAINSTREAM.contains(imageLevel.toUpperCase())) {
                        if (String.isBlank(userCountryCode) || ADDITIONAL_ROLES.contains(userCountryCode)) {
                            this.imageLevelCheckboxWrappers.add(new CheckboxWrapperAura(imageLevel));
                        }
                    }

                    if (imageLevel.toUpperCase().equalsIgnoreCase(MAINSTREAM) && ! ADDITIONAL_ROLES.contains(userCountryCode)) {
                        this.imageLevelCheckboxWrappers.add(new CheckboxWrapperAura(imageLevel));
                    }
                } else {
                    this.imageLevelCheckboxWrappers.add(new CheckboxWrapperAura(imageLevel));
                }
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
            this.Name = n;
        }
    }

}