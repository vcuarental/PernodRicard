@IsTest(IsParallel = true)
private class EUR_CRM_AccountGroupUserService_Test {

    @TestSetup
    private static void dataInit() {
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(
                Name = 'test name',
                EUR_CRM_Postal_Code__c = '1122',
                RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_DE_Off_Trade_Retail')
        );
        insert account;

        EUR_CRM_AccountGroup__c accountGroup = new EUR_CRM_AccountGroup__c(
                EUR_CRM_Account__c = account.Id,
                EUR_CRM_Status__c = 'Normal'
        );
        insert accountGroup;

        EUR_CRM_AccountGroupUser__c accountGroupUser = new EUR_CRM_AccountGroupUser__c(
                EUR_CRM_AccountGroup__c = accountGroup.Id,
                EUR_CRM_User__c = UserInfo.getUserId(),
                EUR_CRM_AccessLevel__c = 'Edit'
        );
        insert accountGroupUser;
    }

    @IsTest
    private static void checkInsertFirst() {
        EUR_CRM_Account__c account = [
                SELECT EUR_CRM_Visible_to_ID1__c
                FROM EUR_CRM_Account__c
        ];

        String choppedId = String.valueOf(UserInfo.getUserId()).substring(3) + ',';

        System.assertEquals(account.EUR_CRM_Visible_to_ID1__c, choppedId);
    }

    @IsTest
    private static void checkSendMails() {
        EUR_CRM_Account__c account = [
                SELECT Id
                FROM EUR_CRM_Account__c
        ];

        EUR_CRM_AccountGroupUser__c accountGroupUser = [
                SELECT EUR_CRM_User__c
                FROM EUR_CRM_AccountGroupUser__c
        ][0];

        List<String> addresses = new List<String>{
                'test@gmail.com'      // random email for test
        };

        Test.startTest();
        EUR_CRM_AccountGroupUserService.sendMail(account, accountGroupUser, addresses);
        EUR_CRM_AccountGroupUserService.sendMail('test', addresses);
        Test.stopTest();
    }

    @IsTest
    private static void EUR_CRM_AccountGroupUserBatch_Test() {
        Database.executeBatch(new EUR_CRM_AccountGroupUserBatch());
    }


    @IsTest
    private static void checkDelete() {
        List <EUR_CRM_AccountGroupUser__c> accountGroupUsers = [
                SELECT Id,
                        EUR_CRM_Status__c,
                        EUR_CRM_AllowDeletion__c
                FROM EUR_CRM_AccountGroupUser__c
        ];

        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.EUR_CRM_Status__c = 'To Delete';
            accountGroupUser.EUR_CRM_AllowDeletion__c = true;
        }

        Test.startTest();
        update accountGroupUsers;
        delete accountGroupUsers;
        undelete accountGroupUsers;
        Test.stopTest();
    }

    @IsTest
    static void accessLevelChangeTest() {
        EUR_CRM_AccountGroupUser__c accGrUser = [ SELECT Id,
                EUR_CRM_Status__c,
                EUR_CRM_AccessLevel__c
        FROM EUR_CRM_AccountGroupUser__c LIMIT 1];
        accGrUser.EUR_CRM_AccessLevel__c = 'Read';

        Test.startTest();

        update accGrUser;

        Test.stopTest();

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = [SELECT Id,
                EUR_CRM_Status__c,
                EUR_CRM_AccessLevel__c
        FROM EUR_CRM_AccountGroupUser__c];

        System.assertEquals(2, accountGroupUsers.size());
        for(EUR_CRM_AccountGroupUser__c accountGroupUser: accountGroupUsers) {
            if (accountGroupUser.Id == accGrUser.Id) {
                System.assertEquals(EUR_CRM_AccountGroupUserService.TO_DELETE_STATUS, accountGroupUser
                        .EUR_CRM_Status__c);
            } else {
                System.assertEquals(EUR_CRM_AccountGroupUserService.NEW_STATUS, accountGroupUser.EUR_CRM_Status__c);
            }
        }
    }
//    private static User makeUser() {
//        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
//        String orgId = UserInfo.getOrganizationId();
//        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
//        String uniqueName = randomInt + '_testUser';
//
//        return new User(
//            Username = uniqueName + '@test' + orgId + '.org',
//            LastName = uniqueName.substring(0, 5),
//            Email = uniqueName + '@test' + orgId + '.org',
//            EmailEncodingKey = 'ISO-8859-1',
//            Alias = uniqueName.substring(5, 10),
//            TimeZoneSidKey = 'America/Los_Angeles',
//            LocaleSidKey = 'en_US',
//            LanguageLocaleKey = 'en_US',
//            ProfileId = prof.Id
//        );
//    }

}