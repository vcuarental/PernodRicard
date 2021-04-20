public with sharing class EUR_CRM_QuizToRolesAssignAuraCtrl {

    @TestVisible private static final String NONE = '--None--';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    @AuraEnabled
    public static List<SelectOptionWrapper> getCountryCodeOptions() {
        String userCountryCodes = getUserCountryCodes();
        System.debug('\n\n userCountryCodes => ' + JSON.serializePretty(userCountryCodes) + '\n');
        if (String.isNotBlank(userCountryCodes) && ! userCountryCodes.contains(';') && ! userCountryCodes.equalsIgnoreCase('000')) {
            return new List<SelectOptionWrapper> { new SelectOptionWrapper(userCountryCodes) } ;
        }

        List<String> countryCodes = getListOfCountryCodes(userCountryCodes);

        List<SelectOptionWrapper> optionWrappers = new List<SelectOptionWrapper>();
        optionWrappers.add(new SelectOptionWrapper(NONE));
        for (String countryCode : countryCodes) {
            optionWrappers.add(new SelectOptionWrapper(countryCode));
        }

        System.debug('\n\n optionWrappers => ' + JSON.serializePretty(optionWrappers) + '\n');
        return optionWrappers;
    }

    @AuraEnabled
    public static List<UserRole> getUserRolesForCountry(String recordId, String countryCode) {
        String userCountryCodes = getUserCountryCodes();
        System.debug('\n\n userCountryCodes => ' + JSON.serializePretty(userCountryCodes) + '\n');
        System.debug('\n\n countryCode => ' + JSON.serializePretty(countryCode) + '\n');
        if (String.isNotBlank(userCountryCodes) && ! userCountryCodes.containsIgnoreCase(countryCode)) { return new List<UserRole>(); }

        System.debug('\n\n recordId => ' + JSON.serializePretty(recordId) + '\n');
        List<EUR_CRM_Quiz__c> quizzes = getQuizzesWhereId(recordId);

        String userRolesAsString = escapeTags(getExistsRolesAsString(quizzes[0]));
        List<String> userRoleDevNames = userRolesAsString.split(';');

        List<UserRole> userRoles = selectUserRolesWhereCountryCodeAndDeveloperNamesNotIn(countryCode, userRoleDevNames);
        System.debug('\n\n userRoles => ' + JSON.serializePretty(userRoles) + '\n');
        return userRoles;
    }

    @AuraEnabled
    public static List<UserRole> getAssignedUserRoles(String recordId) {
        System.debug('\n\n recordId => ' + JSON.serializePretty(recordId) + '\n');
        List<EUR_CRM_Quiz__c> quizzes = getQuizzesWhereId(recordId);

        String userRolesAsString = escapeTags(getExistsRolesAsString(quizzes[0]));
        if (String.isBlank(userRolesAsString)) { return new List<UserRole>(); }

        List<UserRole> userRoles = selectUserRolesWhereDeveloperNames(userRolesAsString.split(';'));
        System.debug('\n\n userRoles => ' + JSON.serializePretty(userRoles) + '\n');
        return userRoles;
    }

    @AuraEnabled
    public static String addRoles(String recordId, String userRoleDevNamesJSON) {
        System.debug('\n\n recordId => ' + JSON.serializePretty(recordId) + '\n');
        System.debug('\n\n userRoleDevNamesJSON => ' + JSON.serializePretty(userRoleDevNamesJSON) + '\n');

        List<String> userRoleDevNames = (List<String>)JSON.deserialize(userRoleDevNamesJSON, List<String>.class);
        List<EUR_CRM_Quiz__c> quizzes = getQuizzesWhereId(recordId);

        quizzes[0].EUR_CRM_Running_User_Roles__c = addRolesToString(escapeTags(getExistsRolesAsString(quizzes[0])), userRoleDevNames);
        System.debug('\n\n quizzes[0] => ' + JSON.serializePretty(quizzes[0]) + '\n');
        update quizzes[0];

        return 'OK';
    }

    @AuraEnabled
    public static String removeRoles(String recordId, String userRoleDevNamesJSON) {
        System.debug('\n\n recordId => ' + JSON.serializePretty(recordId) + '\n');
        System.debug('\n\n userRoleDevNamesJSON => ' + JSON.serializePretty(userRoleDevNamesJSON) + '\n');

        List<String> userRoleDevNames = (List<String>)JSON.deserialize(userRoleDevNamesJSON, List<String>.class);
        List<EUR_CRM_Quiz__c> quizzes = getQuizzesWhereId(recordId);

        String existsRolesAsString = escapeTags(getExistsRolesAsString(quizzes[0]));
        if (String.isBlank(existsRolesAsString)) { return 'OK'; }

        quizzes[0].EUR_CRM_Running_User_Roles__c = removeRolesFromString(existsRolesAsString, userRoleDevNames);
        System.debug('\n\n quizzes[0] => ' + JSON.serializePretty(quizzes[0]) + '\n');
        update quizzes[0];

        return 'OK';
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private static List<String> getListOfCountryCodes(String userCountryCodes) {
        List<UserRole> userRoles = selectAllEURuserRoles();

        Set<String> countryCodesSet = new Set<String>();
        List<String> countryCodesList = new List<String>();
        for (UserRole role : userRoles) {
            String countyCode = extractCountryCode(role.Name);
            if (countyCode == null) { continue ; }

            if (String.isNotBlank(userCountryCodes) && ! userCountryCodes.containsIgnoreCase(countyCode)) { continue; }

            if ( ! countryCodesSet.contains(countyCode)) {
                countryCodesSet.add(countyCode);
                countryCodesList.add(countyCode);
            }
        }
        return countryCodesList;
    }

    private static String addRolesToString(String existsRolesAsString, List<String> rolesToAdd) {
        for (String role : rolesToAdd) {
            if ( ! existsRolesAsString.contains(role+';')) {
                existsRolesAsString += role + ';';
            }
        }
        return existsRolesAsString;
    }

    private static String removeRolesFromString(String existsRolesAsString, List<String> rolesToRemove) {
        for (String role : rolesToRemove) {
            if (existsRolesAsString.contains(role)) {
                existsRolesAsString = existsRolesAsString.remove(role + ';');
            }
        }
        return existsRolesAsString;
    }

    private static String getUserCountryCodes() {
        return [
            SELECT Id
            ,   EUR_CRM_Affiliate_Code_Picklist__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ][0].EUR_CRM_Affiliate_Code_Picklist__c;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private static String extractCountryCode(String str) {
        String countryCode = str.split(' ')[1];
        return isValidCountryCode(countryCode) ? countryCode : null;
    }

    private static Boolean isValidCountryCode(String countryCode) {
        return countryCode.isAllUpperCase();
    }

    private static String getExistsRolesAsString(EUR_CRM_Quiz__c quiz) {
        return String.isNotBlank(quiz.EUR_CRM_Running_User_Roles__c) ? quiz.EUR_CRM_Running_User_Roles__c : '';
    }

    private static String escapeTags(String str){
        return String.isNotBlank(str)? str.replaceAll('<[^>]*>', ''): '';
    }

    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<UserRole> selectAllEURuserRoles() {
        return [
            SELECT Id
            ,   Name
            FROM UserRole
            WHERE Name LIKE 'EUR %'
            ORDER BY Name
        ];
    }

    private static List<UserRole> selectUserRolesWhereCountryCodeAndDeveloperNamesNotIn(String countryCode, List<String> devNames) {
        return [
            SELECT Id
            ,   Name
            ,   DeveloperName
            FROM UserRole
            WHERE Name LIKE :'EUR ' + countryCode + '%'
                AND DeveloperName NOT IN :devNames
            ORDER BY Name
        ];
    }

    private static List<UserRole> selectUserRolesWhereDeveloperNames(List<String> developerNames) {
        return [
            SELECT Id
            ,   Name
            ,   DeveloperName
            FROM UserRole
            WHERE DeveloperName IN :developerNames
            ORDER BY Name
        ];
    }

    private static List<EUR_CRM_Quiz__c> getQuizzesWhereId(Id quizId) {
        return [
            SELECT Id
            ,   EUR_CRM_Running_User_Roles__c
            FROM EUR_CRM_Quiz__c
            WHERE Id = :quizId
        ];
    }


    /* ========================================================= */
    /*     Class Wrappers
    /* ========================================================= */
    public class SelectOptionWrapper {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }

        public SelectOptionWrapper(String str) {
            this.value = str;
            this.label = str;
        }
    }

}