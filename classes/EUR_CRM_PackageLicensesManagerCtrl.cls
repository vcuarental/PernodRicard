public without sharing class EUR_CRM_PackageLicensesManagerCtrl {

    public static final String NONE = '--None--';
    public final static Map<String, List<SelectOption>> typesOperatorsMap {get; set;}
    static {
        typesOperatorsMap = new Map<String, List<SelectOption>>{
            'STRING' => new List<SelectOption>{
                    new SelectOption('', NONE),
                    new SelectOption('equals', 'equals'),
                    new SelectOption('not equal to', 'not equal to'),
                    new SelectOption('contains', 'contains'),
                    new SelectOption('does not contain', 'does not contain'),
                    new SelectOption('starts with', 'starts with'),
                    new SelectOption('ends with', 'ends with')
            },
            'BOOLEAN' => new List<SelectOption>{
                    new SelectOption('', NONE),
                    new SelectOption('equals', 'equals'),
                    new SelectOption('not equal to', 'not equal to')
            },
            'BOOLEAN_VALUES' => new List<SelectOption>{
                    new SelectOption('True', 'True'),
                    new SelectOption('False', 'False')
            }
        };
    }
    public PackageLicense clmPackageLicense {get; set;}

    public static String ADMIN_COUNTRIES  {get; set;}
    static {
        ADMIN_COUNTRIES = selectAdminCountries();
        if(ADMIN_COUNTRIES == null) ADMIN_COUNTRIES = '';
    }

    public Map<Id, CheckableUser> usersForAssigningById {get; set;}
    public Integer usersForAssigningSize {
        get{
            if (usersForAssigningById == null) return 0;
            return usersForAssigningById.size();
        } set;
    }
    public Map<Id, CheckableUser> assignedUsersById {get; set;}
    public Integer assignedUsersSize {
        get{
            if (assignedUsersById == null) return 0;
            return assignedUsersById.size();
        } set;
    }
    public List<FilterItem> usersForAssigningFilter {get; set;}
    public List<FilterItem> assignedUsersFilter {get; set;}

    public Boolean usersForAssigningSelectingAll {get; set;}
    public Boolean assignedUsersSelectingAll {get; set;}

    public EUR_CRM_PackageLicensesManagerCtrl(){
        clmPackageLicense = selectPackageLicense();
        initUsersForAssigningFilter();
        initAssignedUsersFilter();
//        initUsersForAssigning();
//        initAssignedUsers();
//        if(String.isBlank(ADMIN_COUNTRIES)) {
//            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.WARNING, Label.EUR_CRM_LM_Country_are_not_selected));
//        }
    }

    private void initUsersForAssigningFilter() {
        usersForAssigningFilter = new List<FilterItem>();
//        usersForAssigningFilter.add(new FilterItem('EUR_CRM_Country_Code__c', typesOperatorsMap.get('STRING')[1].getValue(), ADMIN_COUNTRIES));
        usersForAssigningFilter.add(new FilterItem('EUR_CRM_Country_Code__c', typesOperatorsMap.get('STRING')[1].getValue(), ''));
        usersForAssigningFilter.add(new FilterItem('IsActive', typesOperatorsMap.get('BOOLEAN')[1].getValue(), 'True'));
        usersForAssigningFilter.add(new FilterItem('Profile.Name', '', ''));
    }

    private void initAssignedUsersFilter() {
        assignedUsersFilter = new List<FilterItem>();
//        assignedUsersFilter.add(new FilterItem('EUR_CRM_Country_Code__c', typesOperatorsMap.get('STRING')[1].getValue(), ADMIN_COUNTRIES));
        assignedUsersFilter.add(new FilterItem('EUR_CRM_Country_Code__c', typesOperatorsMap.get('STRING')[1].getValue(), ''));
        assignedUsersFilter.add(new FilterItem('IsActive', typesOperatorsMap.get('BOOLEAN')[1].getValue(), 'True'));
        assignedUsersFilter.add(new FilterItem('Profile.Name', '', ''));
    }

    private void initUsersForAssigning() {
        usersForAssigningById = new Map<Id, CheckableUser>();
        for(User u : Database.query(getUserQuery(usersForAssigningFilter, false))) {
            usersForAssigningById.put(u.Id, new CheckableUser(u));
        }
        System.debug('\n usersForAssigningById.size() => ' + usersForAssigningById.size() + '\n');
    }
    @TestVisible
    private void initAssignedUsers() {
        assignedUsersById = new Map<Id, CheckableUser>();
        for(User u : Database.query(getUserQuery(assignedUsersFilter, true))) {
            assignedUsersById.put(u.Id, new CheckableUser(u));
        }
    }

    private String getWhereString(List<FilterItem> filter) {
//        String userAffiliatesCondition = '';
//        if(String.isBlank(ADMIN_COUNTRIES)) {
//            userAffiliatesCondition += 'Id = null';
//        } else {
//            userAffiliatesCondition += 'EUR_CRM_Country_Code__c IN (\'' + String.join(ADMIN_COUNTRIES.split(';'), '\',\'') + '\')';
//        }
        EUR_CRM_FilterBuilderService.ObjectFilterWrapper filterWrapper = new EUR_CRM_FilterBuilderService.ObjectFilterWrapper();
        filterWrapper.objectName = 'User';
        filterWrapper.items = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

        List<String> itemStringCounter = new List<String>();
        for(FilterItem fi : filter) {
            if(String.isBlank(fi.operator)) continue;
            filterWrapper.items.add(fi.getFilterItemWrapper());
            itemStringCounter.add('' + (itemStringCounter.size() + 1));
        }
//        if (itemStringCounter.isEmpty()) return ' WHERE ' + userAffiliatesCondition;
        if (itemStringCounter.isEmpty()) return ' ';
        filterWrapper.filterLogic = String.join(itemStringCounter, ' AND ');
        System.debug('filterWrapper: ' + filterWrapper);
//        return EUR_CRM_FilterBuilderService.getSelectionQueryCondition(filterWrapper) + ' AND ' + userAffiliatesCondition;
        return EUR_CRM_FilterBuilderService.getSelectionQueryCondition(filterWrapper);
    }

    private String getUserQuery(List<FilterItem> filter, Boolean isAssinedUserd) {
        String userQuery = 'SELECT Id, Name, UserRole.Name, IsActive, Profile.Name FROM User';
        userQuery += getWhereString(filter);
        userQuery += ' AND Id ' + (isAssinedUserd == true ? '' : 'NOT ') +  'IN (SELECT UserId FROM UserPackageLicense WHERE PackageLicenseId = \'' + clmPackageLicense.Id + '\')';
        userQuery += ' ORDER BY Name LIMIT 1500';
        System.debug('userQuery: ' + userQuery);
        return userQuery;
    }

    public PageReference applyForAssigningFilter() {
        ApexPages.getMessages().clear();
        usersForAssigningSelectingAll = false;
        initUsersForAssigning();
        return null;
    }

    public PageReference resetUsersForAssigning() {
        ApexPages.getMessages().clear();
        usersForAssigningSelectingAll = false;
        usersForAssigningById.clear();
        return null;
    }

    public PageReference applyAssignedFilter() {
        ApexPages.getMessages().clear();
        assignedUsersSelectingAll = false;
        initAssignedUsers();
        return null;
    }

    public PageReference resetAssignedUsers() {
        ApexPages.getMessages().clear();
        usersForAssigningSelectingAll = false;
        assignedUsersById.clear();
        return null;
    }

    public PageReference addUsers() {
        ApexPages.getMessages().clear();
        usersForAssigningSelectingAll = false;

        List<UserPackageLicense> licenses = new List<UserPackageLicense>();
        for(CheckableUser u : usersForAssigningById.values()) {
            if(u.checked == true) {
                licenses.add(new UserPackageLicense(
                        PackageLicenseId = clmPackageLicense.Id,
                        UserId = u.u.Id
                ));
            }
        }

        try {
            insert licenses;
            clmPackageLicense = selectPackageLicense();
            initUsersForAssigning();
            initAssignedUsers();
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.CONFIRM, Label.EUR_CRM_LM_Assigned_successfully));
        } catch(DMLException e) {
            ApexPages.addMessages(e);
        }

        return null;
    }

    public PageReference removeUsers() {
        ApexPages.getMessages().clear();
        assignedUsersSelectingAll = false;

        Set<Id> userIdsForRemoveAssigning = new Set<Id>();
        for(CheckableUser u : assignedUsersById.values()) {
            if(u.checked == true) {
                userIdsForRemoveAssigning.add(u.u.Id);
            }
        }

        try {
            delete [
                SELECT Id
                FROM UserPackageLicense
                WHERE PackageLicenseId = :clmPackageLicense.Id AND UserId IN :userIdsForRemoveAssigning
            ];
            clmPackageLicense = selectPackageLicense();
            initUsersForAssigning();
            initAssignedUsers();
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.CONFIRM, Label.EUR_CRM_LM_Removed_successfully));
        } catch(DMLException e) {
            ApexPages.addMessages(e);
        }

        return null;
    }


    private PackageLicense selectPackageLicense() {
        return [
                SELECT Id
                        ,   NamespacePrefix
                        ,   AllowedLicenses
                        ,   UsedLicenses
                        ,   ExpirationDate
                        ,   Status
                FROM PackageLicense
                WHERE NamespacePrefix = 'clm'
                LIMIT 1
        ];
    }

    private static String selectAdminCountries() {
        return [
                SELECT EUR_CRM_Affiliate_Code_Picklist__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ].EUR_CRM_Affiliate_Code_Picklist__c;
    }

    public class CheckableUser {
        public Boolean checked {get; set;}
        public User u {get; set;}

        public CheckableUser (User u) {
            this.u = u;
            checked = false;
        }
    }

    public class FilterItem  {
        private EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItemWrapper = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();

        public String field {get { return filterItemWrapper.field; } set { filterItemWrapper.field = value; }}
        public String operator {get { return filterItemWrapper.operator; } set { filterItemWrapper.operator = value; }}
        public String value {get { return filterItemWrapper.value; } set { filterItemWrapper.value = value; }}

        public FilterItem(String field, String operator, String value) {
            filterItemWrapper.field = field;
            filterItemWrapper.operator = operator;
            filterItemWrapper.value = value;
        }

        public EUR_CRM_FilterBuilderService.FiltersItemsWrapper getFilterItemWrapper() {
            EUR_CRM_FilterBuilderService.FiltersItemsWrapper clonnedItemWrapper = filterItemWrapper.clone();
            clonnedItemWrapper.value = clonnedItemWrapper.value.replace(';',',');
            return clonnedItemWrapper;
        }

    }
}