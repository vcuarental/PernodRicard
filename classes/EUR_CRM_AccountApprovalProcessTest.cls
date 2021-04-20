@IsTest(IsParallel = true)
private class EUR_CRM_AccountApprovalProcessTest {

    @IsTest
    private static void unlockTest() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = TRUE AND IsActive = TRUE AND ManagerId != NULL LIMIT 1];
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        System.runAs(users[0]) {

        insert acc;

        Approval.lock(acc.Id);
        System.assertEquals(true, Approval.isLocked(acc));

        Test.startTest();
        EUR_CRM_AccountApprovalProcess.unlock(new List<EUR_CRM_Account__c>{acc});
        Test.stopTest();

        }
        System.assertEquals(false, Approval.isLocked(acc));
    }

    @IsTest
    private static void submitForApprovalTest() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = TRUE AND IsActive = TRUE AND ManagerId != NULL LIMIT 1];
        insert EUR_CRM_RU_TestClassHelper.createApexConfig();

        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_On_Trade').getRecordTypeId(),
                EUR_CRM_Status__c = 'New',
                EUR_CRM_Status_Requested__c = 'Active'
        );
        System.runAs(users[0]) {
            Test.startTest();
            insert acc;
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :acc.Id].size());
    }


}