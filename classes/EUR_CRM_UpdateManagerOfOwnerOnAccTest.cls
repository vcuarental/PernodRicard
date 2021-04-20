@IsTest
private class EUR_CRM_UpdateManagerOfOwnerOnAccTest {
    @TestSetup
    static void setup() {
        List<User> users = new List<User>();
        User managerOfAccountOwner = EUR_CRM_TestClassUtilityHelper.createUser('EUR GB Admin');
        managerOfAccountOwner.Username ='6-3-2020ManagerMikhail@gmail.com';
        insert managerOfAccountOwner;

        User accOwner = EUR_CRM_TestClassUtilityHelper.createUser('EUR GB On Trade FS Platform User');
        User manager = [SELECT Id FROM User WHERE Username = '6-3-2020ManagerMikhail@gmail.com'].get(0);
        accOwner.Username ='6-3-2020OwnerMikhail@gmail.com';
        accOwner.ManagerId = manager.Id;
        users.add(accOwner);

        User tempUser = EUR_CRM_TestClassUtilityHelper.createUser('EUR GB On Trade FS Platform User');
        tempUser.Username ='6-3-2020TempUserMikhail@gmail.com';
       // tempUser.ManagerId = manager.Id;
        users.add(tempUser);

        User userWithoutManager = EUR_CRM_TestClassUtilityHelper.createUser('EUR GB On Trade FS Platform User');
        userWithoutManager.Username ='6-3-2020userWithoutManager@gmail.com';
        userWithoutManager.ManagerId = null;
        users.add(userWithoutManager);
        insert users;
    }

        @IsTest
        static void wrongManager() {
            User accOwner = [SELECT Id,ManagerId FROM User WHERE Username = '6-3-2020OwnerMikhail@gmail.com'].get(0);
            User tempUser = [SELECT Id FROM User WHERE Username = '6-3-2020TempUserMikhail@gmail.com'].get(0);
            EUR_CRM_Account__c testAcc = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect').get(0);

            testAcc.Name = 'TestParent';
            testAcc.EUR_CRM_Business_Type__c = 'Head Office';
            testAcc.OwnerId = accOwner.Id;
            testAcc.EUR_CRM_Manager_of_Account_Owner__c = tempUser.Id;
            insert testAcc;

        Test.startTest();
            EUR_CRM_Account__c  accounts = [SELECT Id,EUR_CRM_Manager_of_Account_Owner__c, OwnerId FROM EUR_CRM_Account__c WHERE Name = 'TestParent'].get(0);
            accounts.EUR_CRM_Manager_of_Account_Owner__c = tempUser.Id;
            update accounts;
        Database.executeBatch(new EUR_CRM_UpdateManagerOfOwnerOnAcc('GB'));
        Test.stopTest();
            User owner = [SELECT Id, ManagerId FROM User WHERE Username ='6-3-2020OwnerMikhail@gmail.com'].get(0);
            EUR_CRM_Account__c acc = [SELECT EUR_CRM_Manager_of_Account_Owner__c FROM EUR_CRM_Account__c WHERE EUR_CRM_Business_Type__c = 'Head Office'].get(0);
            System.assertEquals(owner.ManagerId,acc.EUR_CRM_Manager_of_Account_Owner__c);

    }
    @IsTest
    static void UserWithoutManager() {
        User userWithoutManager = [SELECT ManagerId FROM User WHERE Username ='6-3-2020userWithoutManager@gmail.com'].get(0);
        User tempUser = [SELECT Id FROM User WHERE Username = '6-3-2020TempUserMikhail@gmail.com'].get(0);
        List<EUR_CRM_Account__c> accounts = EUR_CRM_TestClassUtilityHelper.createAccountsEU(2, 'GB FS Indirect');
        for (Integer i = 0; i < accounts.size(); i++) {
            EUR_CRM_Account__c acc = accounts.get(i);
            acc.Name = 'TestParent' + i;
            acc.EUR_CRM_Business_Type__c = 'Head Office';
            acc.OwnerId = userWithoutManager.Id;
            acc.EUR_CRM_Manager_of_Account_Owner__c = tempUser.Id;
        }
        insert accounts;
       // tempUser.ManagerId=null;
        Test.startTest();
        accounts = [SELECT Id, EUR_CRM_Manager_of_Account_Owner__c FROM EUR_CRM_Account__c];
         for (EUR_CRM_Account__c account : accounts){
             account.EUR_CRM_Manager_of_Account_Owner__c = null;
         }
        update accounts;
        Database.executeBatch(new EUR_CRM_UpdateManagerOfOwnerOnAcc('GB'));
        Test.stopTest();
        System.assertEquals(2,[SELECT Id FROM EUR_CRM_Account__c WHERE EUR_CRM_Manager_of_Account_Owner__c = NULL].size());
    }
}