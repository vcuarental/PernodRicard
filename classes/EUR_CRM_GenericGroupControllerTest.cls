@IsTest (IsParallel = true)
private class EUR_CRM_GenericGroupControllerTest {

    @IsTest
    private static void selectRecordsTest() {
        List<SObject> result = EUR_CRM_GenericGroupController.selectRecords('SELECT Id FROM User LIMIT 100', new List<String>());
        System.assert(!result.isEmpty());
    }

    @IsTest
    private static void countRecordsTest() {
        Integer result = EUR_CRM_GenericGroupController.countRecords('SELECT COUNT() FROM User LIMIT 100', new List<String>());
        System.assert(result > 0);
    }

    @IsTest
    private static void selectAndCountRecordsTest() {
        Map<String, Object> result = EUR_CRM_GenericGroupController.selectAndCountRecords('SELECT Id FROM User LIMIT 100', 'SELECT COUNT() FROM User LIMIT 100', new List<String>());
        System.assert(!((List<SObject>) result.get('queryResult')).isEmpty());
        System.assert((Integer) result.get('countQueryResult') > 0);
    }

    @IsTest
    private static void selectAccountGroupsTest() {
        List<EUR_CRM_Account_Target_Group__c> positiveResult = EUR_CRM_GenericGroupController.selectAccountGroups('Something');
        List<EUR_CRM_Account_Target_Group__c> negativeResult = EUR_CRM_GenericGroupController.selectAccountGroups('');
        System.assertNotEquals(null, positiveResult);
        System.assertEquals(null, negativeResult);
    }

}