@IsTest
private class EUR_CRM_QuizToRolesAssignAuraCtrlTest {

    @IsTest
    private static void getCountryCodeOptionsWhenUserAffiliateCodeNLTest() {
        User u = makeStandardUser();
        u.EUR_CRM_Affiliate_Code_Picklist__c = 'NL';
        System.runAs(u) {
            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            System.assertEquals(1, countryCodeOptions.size());
            System.assertEquals('NL', countryCodeOptions[0].value);
        }
    }

    @IsTest
    private static void getCountryCodeOptionsWhenUserAffiliateCodeEmptyTest() {
        System.runAs(makeStandardUser()) {
            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            System.assert(countryCodeOptions.size() > 1);
        }
    }

    @IsTest
    private static void getUserRolesForCountryWhenUserAffiliateCodeNLTest() {
        User u = makeStandardUser();
        u.EUR_CRM_Affiliate_Code_Picklist__c = 'NL';
        System.runAs(u) {
            insert makeQuiz();
            List<EUR_CRM_Quiz__c> quizzes = selectQuizzes();

            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            String countryCode = countryCodeOptions[0].value;

            List<UserRole> userRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getUserRolesForCountry(quizzes[0].Id, countryCode);
            System.assertNotEquals(0, userRoles.size());
            for (UserRole userRole : userRoles) {
                System.assert(userRole.DeveloperName.containsIgnoreCase('NL'));
            }
        }
    }

    @IsTest
    private static void getUserRolesForCountryWhenUserAffiliateCodeEmptyTest() {
        System.runAs(makeStandardUser()) {
            insert makeQuiz();
            List<EUR_CRM_Quiz__c> quizzes = selectQuizzes();

            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            String countryCode = countryCodeOptions[0].value;
            if (countryCode == EUR_CRM_QuizToRolesAssignAuraCtrl.NONE) { countryCode = countryCodeOptions[1].value; }

            List<UserRole> userRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getUserRolesForCountry(quizzes[0].Id, countryCode);
            System.assertNotEquals(0, userRoles.size());
        }
    }

    @IsTest
    private static void addRolesWhenUserAffiliateCodeNLTest() {
        User u = makeStandardUser();
        u.EUR_CRM_Affiliate_Code_Picklist__c = 'NL';
        System.runAs(u) {
            insert makeQuiz();
            List<EUR_CRM_Quiz__c> quizzes = selectQuizzes();

            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            String countryCode = countryCodeOptions[0].value;

            List<UserRole> userRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getUserRolesForCountry(quizzes[0].Id, countryCode);
            String result = EUR_CRM_QuizToRolesAssignAuraCtrl.addRoles(quizzes[0].Id, JSON.serialize(new List<String> { userRoles[0].DeveloperName }));
            System.assertEquals('OK', result);

            quizzes = selectQuizzes();
            System.assertEquals(userRoles[0].DeveloperName + ';', quizzes[0].EUR_CRM_Running_User_Roles__c);
        }
    }

    @IsTest
    private static void addRolesWhenUserAffiliateCodeEmptyTest() {
        System.runAs(makeStandardUser()) {
            insert makeQuiz();
            List<EUR_CRM_Quiz__c> quizzes = selectQuizzes();

            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            String countryCode = countryCodeOptions[0].value;
            if (countryCode == EUR_CRM_QuizToRolesAssignAuraCtrl.NONE) { countryCode = countryCodeOptions[1].value; }

            List<UserRole> userRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getUserRolesForCountry(quizzes[0].Id, countryCode);
            String result = EUR_CRM_QuizToRolesAssignAuraCtrl.addRoles(quizzes[0].Id, JSON.serialize(new List<String> { userRoles[0].DeveloperName }));
            System.assertEquals('OK', result);

            quizzes = selectQuizzes();
            System.assertEquals(userRoles[0].DeveloperName + ';', quizzes[0].EUR_CRM_Running_User_Roles__c);
        }
    }

    @IsTest
    private static void getAssignedUserRolesWhenQuizRunningUserRolePopulatedTest() {
        User u = makeStandardUser();
        u.EUR_CRM_Affiliate_Code_Picklist__c = 'NL';
        System.runAs(u) {
            insert makeQuiz();
            List<EUR_CRM_Quiz__c> quizzes = selectQuizzes();

            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            String countryCode = countryCodeOptions[0].value;
            if (countryCode == EUR_CRM_QuizToRolesAssignAuraCtrl.NONE) { countryCode = countryCodeOptions[1].value; }

            List<UserRole> allUserRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getUserRolesForCountry(quizzes[0].Id, countryCode);
            String result = EUR_CRM_QuizToRolesAssignAuraCtrl.addRoles(quizzes[0].Id, JSON.serialize(new List<String> { allUserRoles[0].DeveloperName }));
            System.assertEquals('OK', result);

            List<UserRole> userRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getAssignedUserRoles(quizzes[0].Id);
            System.assertEquals(1, userRoles.size());
            System.assertEquals(allUserRoles[0].Id, userRoles[0].Id);
        }
    }

    @IsTest
    private static void getAssignedUserRolesWhenQuizRunningUserRoleEmptyTest() {
        System.runAs(makeStandardUser()) {
            insert makeQuiz();
            List<EUR_CRM_Quiz__c> quizzes = selectQuizzes();

            List<UserRole> userRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getAssignedUserRoles(quizzes[0].Id);
            System.assertEquals(0, userRoles.size());
        }
    }

    @IsTest
    private static void removeRolesTest() {
        User u = makeStandardUser();
        u.EUR_CRM_Affiliate_Code_Picklist__c = 'NL';
        System.runAs(u) {
            insert makeQuiz();
            List<EUR_CRM_Quiz__c> quizzes = selectQuizzes();

            List<EUR_CRM_QuizToRolesAssignAuraCtrl.SelectOptionWrapper> countryCodeOptions = EUR_CRM_QuizToRolesAssignAuraCtrl.getCountryCodeOptions();
            String countryCode = countryCodeOptions[0].value;
            if (countryCode == EUR_CRM_QuizToRolesAssignAuraCtrl.NONE) { countryCode = countryCodeOptions[1].value; }

            List<UserRole> userRoles = EUR_CRM_QuizToRolesAssignAuraCtrl.getUserRolesForCountry(quizzes[0].Id, countryCode);
            String result = EUR_CRM_QuizToRolesAssignAuraCtrl.addRoles(quizzes[0].Id, JSON.serialize(new List<String> { userRoles[0].DeveloperName }));
            System.assertEquals('OK', result);

            quizzes = selectQuizzes();
            System.assertEquals(userRoles[0].DeveloperName + ';', quizzes[0].EUR_CRM_Running_User_Roles__c);

            result = EUR_CRM_QuizToRolesAssignAuraCtrl.removeRoles(quizzes[0].Id, JSON.serialize(new List<String> { userRoles[0].DeveloperName }));
            System.assertEquals('OK', result);

            quizzes = selectQuizzes();
            System.assertEquals(null, quizzes[0].EUR_CRM_Running_User_Roles__c);
        }
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Quiz__c makeQuiz() {
        return new EUR_CRM_Quiz__c(
            Name = 'Test Quiz'
        );
    }

    private static User makeStandardUser() {
        return new User(
            Alias = 'standt'
        ,   Email = 'standarduser@testorg.com'
        ,   EmailEncodingKey = 'UTF-8'
        ,   LastName = 'Testing'
        ,   LanguageLocaleKey = 'en_US'
        ,   LocaleSidKey = 'en_US'
        ,   ProfileId = selectStandardUserProfileId()
        ,   TimeZoneSidKey = 'America/Los_Angeles'
        ,   Username = 'standarduser' + Datetime.now().getTime() + '@testorg.com');
    }


    /* ========================================================= */
    /*     SOQL Helpers
    /* ========================================================= */
    private static List<EUR_CRM_Quiz__c> selectQuizzes() {
        return [
            SELECT Id
            ,   EUR_CRM_Running_User_Roles__c
            FROM EUR_CRM_Quiz__c
        ];
    }

    private static Id selectStandardUserProfileId() {
        return [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ][0].Id;
    }

}