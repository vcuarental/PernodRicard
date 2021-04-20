@IsTest
private class EUR_CRM_PackageLicensesManagerCtrlTest {

    @TestSetup
    static void setup() {
        User testUser = new User();
        testUser.FirstName = 'TestFirstName';
        testUser.LastName = 'TestLastName';
        testUser.Alias = 'Test';
        testUser.Email = 'test1294944@pr.com';
        testUser.Username = 'TestFirstName@@pr.com';
        testUser.CommunityNickname = 'test1294944';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_Us';
        testUser.LanguageLocaleKey = 'en_Us';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
//        testUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name LIKE '%_DE_%' LIMIT 1].Id;
        testUser.Country = 'DE';
        testUser.EUR_CRM_Affiliate_Code_Picklist__c = 'DE';
        insert testUser;
    }

    @IsTest
    static void testUserAssigning() {
        User testUser = [SELECT Id FROM User WHERE Username = 'TestFirstName@@pr.com'];

        Test.startTest();
        System.runAs(testUser) {
            Test.setCurrentPage(Page.EUR_CRM_PackageLicensesManager);

            EUR_CRM_PackageLicensesManagerCtrl lmController = new EUR_CRM_PackageLicensesManagerCtrl();
            lmController.applyForAssigningFilter();
            lmController.applyAssignedFilter();
            System.assertEquals(false, lmController.usersForAssigningById.isEmpty());
            Id testedUserId = lmController.usersForAssigningById.values()[0].u.Id;
            lmController.usersForAssigningById.values()[0].checked = true;
            lmController.addUsers();

            System.assertEquals(false, [
                    SELECT Id
                    FROM UserPackageLicense
                    WHERE PackageLicenseId = :lmController.clmPackageLicense.Id AND UserId = :testedUserId
            ].isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void testUserRemovingAssigning() {
        User testUser = [SELECT Id FROM User WHERE Username = 'TestFirstName@@pr.com'];

        System.runAs(testUser) {

            Test.startTest();
            insert new UserPackageLicense(
                    PackageLicenseId = new EUR_CRM_PackageLicensesManagerCtrl().clmPackageLicense.Id,
                    UserId = testUser.Id
            );

            Test.setCurrentPage(Page.EUR_CRM_PackageLicensesManager);

            EUR_CRM_PackageLicensesManagerCtrl lmController = new EUR_CRM_PackageLicensesManagerCtrl();
            lmController.assignedUsersFilter[0].operator = 'contains';
            lmController.assignedUsersFilter[0].value = 'DE';
            lmController.initAssignedUsers();
            System.assertEquals(false, lmController.assignedUsersById.isEmpty());
            Id testedUserId = lmController.assignedUsersById.values()[0].u.Id;
            lmController.assignedUsersById.values()[0].checked = true;
            lmController.removeUsers();

            System.assertEquals(true, [
                    SELECT Id
                    FROM UserPackageLicense
                    WHERE PackageLicenseId = :lmController.clmPackageLicense.Id AND UserId = :testedUserId
            ].isEmpty());

            Test.stopTest();
        }
    }

}