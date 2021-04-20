@isTest
private class EUR_CRM_AccountOwnerManagerHandlerTest {

    @IsTest
    private static void createAccountTest() {
        Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_GB_FS_Indirect' AND SobjectType = 'EUR_CRM_Account__c' LIMIT 1].Id;
        User u = [SELECT Id, ManagerId FROM User WHERE UserType = 'Standard' AND IsActive = TRUE AND ManagerId != NULL LIMIT 1];

        EUR_CRM_Account__c account = new EUR_CRM_Account__c(Name = 'test account', OwnerId = u.Id, RecordTypeId = rtId, EUR_CRM_Postal_Code__c = '112233');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = [SELECT Id, EUR_CRM_Manager_of_Account_Owner__c FROM EUR_CRM_Account__c WHERE Id = :account.Id];
        System.assertEquals(u.ManagerId, account.EUR_CRM_Manager_of_Account_Owner__c);

    }

}