@IsTest (IsParallel = true)
private class EUR_CRM_GroupCreationCmpControllerTest {

    @TestSetup
    private static void init() {
        EUR_CRM_Account_Target_Group__c accountTargetGroup = new EUR_CRM_Account_Target_Group__c(
            Name = 'Test Group'
        ,   EUR_CRM_Criteria__c = '{"childItems":{},"testQuery":"SELECT Id, Name FROM EUR_CRM_Account__c WHERE Name LIKE \'%AccName%\' AND CreatedDate = 2018-01-12T16:50:00Z","objectName":"EUR_CRM_Account__c","items":[{"value":"AccName","operator":"contains","field":"Name"},{"value":"2018-01-12T16:50:00Z","operator":"equals","field":"CreatedDate"}],"filterLogic":null}'
        ,   EUR_CRM_IsDynamic__c = true
        );

        insert accountTargetGroup;
    }

    @IsTest
    private static void testLoadGroup() {
        EUR_CRM_Account_Target_Group__c accountGroup = [SELECT Id, Name FROM EUR_CRM_Account_Target_Group__c LIMIT 1];
        String recordInfo = EUR_CRM_GroupCreationCmpController.loadGroup(accountGroup.Id, 'EUR_CRM_Account_Target_Group__c');
        EUR_CRM_Account_Target_Group__c loadedRecord = (EUR_CRM_Account_Target_Group__c) JSON.deserialize(recordInfo, EUR_CRM_Account_Target_Group__c.class);
        System.assertEquals(loadedRecord.Name, accountGroup.Name);
    }

    @IsTest
    private static void testSaveGroup() {
        EUR_CRM_Account_Target_Group__c accountGroup = [SELECT Id FROM EUR_CRM_Account_Target_Group__c LIMIT 1];
        String result = EUR_CRM_GroupCreationCmpController.saveGroup(accountGroup);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(Boolean.valueOf(resultMap.get('success')), true);
        System.assertEquals(resultMap.get('recordId'), accountGroup.Id);
    }

    @IsTest
    private static void testSaveGroupError() {
        String result = EUR_CRM_GroupCreationCmpController.saveGroup(null);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(Boolean.valueOf(resultMap.get('success')), false);
        System.assertNotEquals(resultMap.get('message'), null);
    }

}