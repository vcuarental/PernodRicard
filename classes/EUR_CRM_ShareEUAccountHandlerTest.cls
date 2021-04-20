@IsTest
private class EUR_CRM_ShareEUAccountHandlerTest {
    @TestSetup
    static void setup() {
        User newAccOwner = EUR_CRM_TestClassUtilityHelper.createUser('EUR GB On Trade FS Platform User');
        newAccOwner.Username ='6-3-2020OwnerMikhail@gmail.com';
        User managerOfAccountOwner = EUR_CRM_TestClassUtilityHelper.createUser('EUR GB Admin');
        managerOfAccountOwner.Username ='6-3-2020ManagerMikhail@gmail.com';

        insert managerOfAccountOwner;

       // Id accOwnerProfileId = [Select Id FROM Profile WHERE Name = 'EUR GB On Trade FS Platform User'].get(0).Id;
       // Id managerOfAccOwnerProfileId = [Select Id FROM Profile WHERE Name = 'EUR GB Admin'].get(0).Id;

        User manager = [Select Id FROM User WHERE Username = '6-3-2020ManagerMikhail@gmail.com'].get(0);
        newAccOwner.ManagerId = manager.Id;
        insert newAccOwner;

     //   User owner = [Select Id FROM User WHERE ProfileId =: accOwnerProfileId].get(0);


    }

    @IsTest
    static void test1() {
        Test.startTest();
        List<EUR_CRM_Account__c> accountList = EUR_CRM_TestClassUtilityHelper.createAccountsEU(3, 'GB FS Indirect');
        for (Integer i = 0; i < accountList.size(); i++) {
            EUR_CRM_Account__c parent = accountList.get(i);
            parent.Name = 'TestPare\'nt' + i;
            parent.EUR_CRM_Business_Type__c = 'Head Office';
        }
        insert accountList;

        Test.stopTest();
        accountList = [SELECT Id FROM EUR_CRM_Account__c];
        List<EUR_CRM_Account__Share> newAccountShares = [SELECT Id, ParentId FROM EUR_CRM_Account__Share WHERE ParentId IN : accountList];
        System.assertEquals(3, newAccountShares.size());
    }
    @IsTest
    static void test2() {

        Test.startTest();
        Id newAccOwnerProfileId = [Select Id FROM Profile WHERE Name = 'EUR GB On Trade FS Platform User'].get(0).Id;
        Id managerOfAccOwnerProfileId = [Select Id FROM Profile WHERE Name = 'EUR GB Admin'].get(0).Id;

        User newOwner = [Select Id ,ManagerId FROM User WHERE Username ='6-3-2020OwnerMikhail@gmail.com'].get(0);
       // User manager = [Select Id FROM User WHERE ProfileId =: managerOfAccOwnerProfileId].get(0);

        List<EUR_CRM_Account__c> accountList = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect');
        for (Integer i = 0; i < accountList.size(); i++) {
            EUR_CRM_Account__c acc = accountList.get(i);
            acc.Name = 'TestPare\'nt' + i;
            acc.EUR_CRM_Business_Type__c = 'Head Office';
        }

        insert accountList;
        accountList = [SELECT Id,EUR_CRM_Manager_of_Account_Owner__c FROM EUR_CRM_Account__c];
        for (EUR_CRM_Account__c acc: accountList){
            acc.OwnerId = newOwner.Id;
        }
        update accountList;
        Test.stopTest();
        accountList = [SELECT Id,EUR_CRM_Manager_of_Account_Owner__c FROM EUR_CRM_Account__c];
        List<EUR_CRM_Account__Share> newAccountShares = [SELECT Id, ParentId, UserOrGroupId FROM EUR_CRM_Account__Share WHERE RowCause =: Schema.EUR_CRM_Account__Share.RowCause.Manual];
        System.assertEquals(newOwner.ManagerId, newAccountShares.get(0).UserOrGroupId);
       // System.assert(true);

    }
}