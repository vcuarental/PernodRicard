@IsTest
private class EUR_CRM_RefreshDynGroupBatchTest {

    static testmethod void testRefreshAccountGroup() {
        createDateForAccountGroup();
        Integer countOfAccountInGroup = [
            SELECT count()
            FROM EUR_CRM_Account_in_Target_Group__c
        ];
        System.assertEquals(1, countOfAccountInGroup);

        Test.startTest();
        EUR_CRM_ScheduleRefreshDynGroupBatch m = new EUR_CRM_ScheduleRefreshDynGroupBatch();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Refresh AccountGroup Job', sch, m);
        Database.executeBatch(new EUR_CRM_DynGroupMembBatch(EUR_CRM_DynamicGroupService.GroupType.ACCOUNT), EUR_CRM_DynGroupMembBatch.GROUP_MEMBERS_SCOPE_SIZE);
        Test.stopTest();

        countOfAccountInGroup = [
            SELECT count()
            FROM EUR_CRM_Account_in_Target_Group__c
        ];
        System.assertEquals(0, countOfAccountInGroup);
    }

    private static EUR_CRM_Account_Target_Group__c createDateForAccountGroup() {
        List<EUR_CRM_Account__c> accounts = EUR_CRM_TestDataFactory.doInsert('EUR_CRM_Account__c',
            new Map<String, Object>{
                'Name' => 'Test cafe',
                'EUR_CRM_Postal_Code__c' => '11111',
                'EUR_JB_Approved_Date__c' => Date.today().addDays(-1)
            }, 1);
        List<EUR_CRM_Account_Target_Group__c> accountGroups = EUR_CRM_TestDataFactory.doInsert('EUR_CRM_Account_Target_Group__c',
            new Map<String, Object>{
                'EUR_CRM_Criteria__c' => '{"childItems":{},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE (EUR_JB_Approved_Date__c = TODAY)","objectName":"EUR_CRM_Account__c","items":[{"value":"TODAY","operator":"equals","field":"EUR_JB_Approved_Date__c"}],"filterLogic":"1"}',
                'EUR_CRM_IsDynamic__c' => true
            }, 1);
        System.debug('accounts = '+accounts);
        List<EUR_CRM_Account_in_Target_Group__c> accountInGroups = EUR_CRM_TestDataFactory.doInsert('EUR_CRM_Account_in_Target_Group__c',
            new Map<String, Object>{
                'EUR_CRM_Account__c' => accounts[0].Id,
                'EUR_CRM_Account_Target_Group__c' => accountGroups[0].Id
            }, 1);
        return accountGroups[0];
    }

}