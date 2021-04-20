@IsTest
private class EUR_CRM_AccountChildrenSharingBatchTest {
    @IsTest
    private static void accountOwnerChangingTest() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 2];
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        EUR_CRM_Visit__c visit = new EUR_CRM_Visit__c (
                EUR_CRM_Account__c = acc.Id
        );
        insert visit;
        insert new EUR_CRM_Visit_Action__c (
                EUR_CRM_Visit_ID__c = visit.Id,
                RecordTypeId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Visit_Action_On_Trade_Ad_Hoc_Promo').getRecordTypeId()
        );
        insert new EUR_CRM_Competitor_Promo_Tracking__c (
                EUR_CRM_Account_Name__c = acc.Id,
                RecordTypeId = Schema.SObjectType.EUR_CRM_Competitor_Promo_Tracking__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_CPT').getRecordTypeId()
        );
        insert new EUR_CRM_Contract_Tracker__c (
                EUR_CRM_Account__c = acc.Id
        );
        insert new EUR_CRM_Brand_Security_Infringement__c (
                EUR_CRM_Outlet_Name__c = acc.Id
        );
        insert new EUR_CRM_GB_Objective__c (
                EUR_CRM_Account__c = acc.Id
        );

        List<EUR_CRM_Visit__Share> shares = [
                SELECT Id
                FROM EUR_CRM_Visit__Share
                WHERE ParentId = :visit.Id AND
                UserOrGroupId = :users[0].Id AND
                RowCause = :EUR_CRM_AccountChildrenSharingBatch.CHILDREN_SHARING_REASON
        ];
        System.assertEquals(false, shares.isEmpty());

        Test.startTest();
        acc.OwnerId = users[1].Id;
        update acc;
        Database.executeBatch(new EUR_CRM_AccountChildrenSharingBatch(new Set<Id>{
                acc.Id
        }, new List<String>(), new Set<String>{
                'EUR_CRM_Visit__c'
        }), EUR_CRM_AccountChildrenSharingBatch.BATCH_CHILD_SCOPE_SIZE);
        Test.stopTest();

        shares = [
                SELECT Id
                FROM EUR_CRM_Visit__Share
                WHERE ParentId = :visit.Id AND
                UserOrGroupId = :users[0].Id AND
                RowCause = :EUR_CRM_AccountChildrenSharingBatch.CHILDREN_SHARING_REASON
        ];
        System.assertEquals(true, shares.isEmpty());

        shares = [
                SELECT Id
                FROM EUR_CRM_Visit__Share
                WHERE ParentId = :visit.Id AND
                UserOrGroupId = :users[1].Id AND
                RowCause = :EUR_CRM_AccountChildrenSharingBatch.CHILDREN_SHARING_REASON
        ];
        System.assertEquals(false, shares.isEmpty());
    }

    @IsTest
    private static void AccountChildrenSharingCountryBatchTest() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        EUR_CRM_Visit__c visit = new EUR_CRM_Visit__c (
                EUR_CRM_Account__c = acc.Id
        );
        insert visit;

        delete [
                SELECT Id
                FROM EUR_CRM_Visit__Share
                WHERE ParentId = :visit.Id AND
                UserOrGroupId = :users[0].Id AND
                RowCause = :EUR_CRM_AccountChildrenSharingBatch.CHILDREN_SHARING_REASON
        ];

        Test.startTest();
        EUR_CRM_AccountChildrenSharingBatch.runForCountries(new List<String>{
                'DE'
        });
        Test.stopTest();

        List<EUR_CRM_Visit__Share> shares = [
                SELECT Id
                FROM EUR_CRM_Visit__Share
                WHERE ParentId = :visit.Id AND
                UserOrGroupId = :users[0].Id AND
                RowCause = :EUR_CRM_AccountChildrenSharingBatch.CHILDREN_SHARING_REASON
        ];
        System.assertEquals(false, shares.isEmpty());
    }

    @IsTest
    private static void VisitTriggerHandler_AfterUpdate_Test() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        EUR_CRM_Visit__c visit = new EUR_CRM_Visit__c (
                EUR_CRM_Account__c = acc.Id
        );
        insert visit;

        visit.EUR_CRM_End_Datetime__c = DateTime.now();
        update visit;
    }

    @IsTest
    private static void VisitTriggerHandler_BeforeDelere_Test() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        EUR_CRM_Visit__c visit = new EUR_CRM_Visit__c (
                EUR_CRM_Account__c = acc.Id
        );
        insert visit;

        delete visit;
    }

    @IsTest
    private static void VisitActionTriggerHandler_BeforeUpdate_Test() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        EUR_CRM_Visit__c visit = new EUR_CRM_Visit__c (
                EUR_CRM_Account__c = acc.Id
        );
        insert visit;

        EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c(
                EUR_CRM_Visit_ID__c = visit.Id,
                RecordTypeId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Visit_Action_On_Trade_Ad_Hoc_Promo').getRecordTypeId()
        );
        insert visitAction;

        visitAction.EUR_CRM_Start_Date__c = Date.today();
        update visitAction;
    }

    @IsTest
    private static void EUR_CRM_GB_ObjectiveTriggerHandler_BeforeUpdate_Test() {
        List<User> users = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                OwnerId = users[0].Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        EUR_CRM_Visit__c visit = new EUR_CRM_Visit__c (
                EUR_CRM_Account__c = acc.Id
        );
        insert visit;

        EUR_CRM_GB_Objective__c gbObjective = new EUR_CRM_GB_Objective__c(
                EUR_CRM_Visit__c = visit.Id
        );
        insert gbObjective;

        gbObjective.EUR_CRM_Start_Date__c = Date.today();
        update gbObjective;
    }

}