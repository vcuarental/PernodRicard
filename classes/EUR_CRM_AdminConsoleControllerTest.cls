@IsTest
private class EUR_CRM_AdminConsoleControllerTest {
    private static final String NL_COUNTRY_CODE = 'NL';
    private static final String SE_COUNTRY_CODE = 'SE';
    private static final String IDL_COUNTRY_CODE = 'IDL';
    private static final String DB_COUNTRY_CODE = 'DB';
    private static final String IT_COUNTRY_CODE = 'IT';
    private static final String DK_COUNTRY_CODE = 'DK';
    private static final Map<String, String> VALID_COUNTRY_CODE_BY_USER_ROLE_DEVELOPER_NAME = new Map<String, String>{
        NL_COUNTRY_CODE => 'EUR_NL_On_Trade',
        SE_COUNTRY_CODE => 'EUR_SE_On_Trade',
        IDL_COUNTRY_CODE => 'EUR_IDL_On_Trade',
        DB_COUNTRY_CODE => 'EUR_DB_On_Trade',
        IT_COUNTRY_CODE => 'EUR_IT_On_Trade',
        DK_COUNTRY_CODE => 'EUR_DK_On_Trade'
    };

    @IsTest
    private static void userNLTest() {
        User standardUser = createUser(NL_COUNTRY_CODE);
        System.runAs(standardUser) {
            EUR_CRM_AdminConsoleController controller = new EUR_CRM_AdminConsoleController();
            System.assertEquals(NL_COUNTRY_CODE, controller.countryCode);
            System.assertEquals('PR Nederland Admin Console', controller.pageTitle);
        }
    }

    @IsTest
    private static void userSETest() {
        User standardUser = createUser(SE_COUNTRY_CODE);
        System.runAs(standardUser) {
            EUR_CRM_AdminConsoleController controller = new EUR_CRM_AdminConsoleController();
            System.assertEquals(SE_COUNTRY_CODE, controller.countryCode);
            System.assertEquals('PR Sweden Admin Console', controller.pageTitle);
        }
    }

    @IsTest
    private static void userIDLTest() {
        User standardUser = createUser(IDL_COUNTRY_CODE);
        System.runAs(standardUser) {
            EUR_CRM_AdminConsoleController controller = new EUR_CRM_AdminConsoleController();
            System.assertEquals(IDL_COUNTRY_CODE, controller.countryCode);
            System.assertEquals('PR Ireland Admin Console', controller.pageTitle);
        }
    }

    @IsTest
    private static void userDBTest() {
        User standardUser = createUser(DB_COUNTRY_CODE);
        System.runAs(standardUser) {
            EUR_CRM_AdminConsoleController controller = new EUR_CRM_AdminConsoleController();
            System.assertEquals(DB_COUNTRY_CODE, controller.countryCode);
            System.assertEquals('PR United Kingdom Admin Console', controller.pageTitle);
        }
    }

    @IsTest
    private static void userITTest() {
        User standardUser = createUser(IT_COUNTRY_CODE);
        System.runAs(standardUser) {
            EUR_CRM_AdminConsoleController controller = new EUR_CRM_AdminConsoleController();
            System.assertEquals(IT_COUNTRY_CODE, controller.countryCode);
            System.assertEquals('PR Italy Admin Console', controller.pageTitle);
        }
    }

    @IsTest
    private static void userDKTest() {
        User standardUser = createUser(DK_COUNTRY_CODE);
        System.runAs(standardUser) {
            EUR_CRM_AdminConsoleController controller = new EUR_CRM_AdminConsoleController();
            System.assertEquals(DK_COUNTRY_CODE, controller.countryCode);
            System.assertEquals('PR Denmark Admin Console', controller.pageTitle);
        }
    }

    private static User createUser(String countryCode) {
        UserRole role = createUserRole(VALID_COUNTRY_CODE_BY_USER_ROLE_DEVELOPER_NAME.get(countryCode));
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Double randomNumber = Math.random() * 1000000;

        User u = new User();
        u.Alias = 'standt';
        u.Email = 'standarduser@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.Username = randomNumber + 'standard@test.com';
        u.UserRoleId = role.Id;

        return u;
    }

    private static UserRole createUserRole(String userRoleDevName) {
        UserRole role = new UserRole(Name = 'TestName', DeveloperName = userRoleDevName);
        insert role;
        return role;
    }
}