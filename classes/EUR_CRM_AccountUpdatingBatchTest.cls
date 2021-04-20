@IsTest
private class EUR_CRM_AccountUpdatingBatchTest {
    @IsTest
    private static void accountUpdatingBatchTest() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        String counrtyCode = 'DE';
        String fieldToSet = 'RecordTypeId';
        Object valueToSet = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get('EUR DE Off Trade Retail').getRecordTypeId();
        String soqlWhereCondition = 'RecordType.Name = \'EUR DE On Trade B2B\'';

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountUpdatingBatch(counrtyCode, fieldToSet, valueToSet, soqlWhereCondition));
        Test.stopTest();

        List<EUR_CRM_Account__c> accs = [SELECT Id, RecordTypeId FROM EUR_CRM_Account__c WHERE Name ='Test Name'];
        System.assertEquals((Id)valueToSet, accs[0].RecordTypeId);
    }

    @IsTest
    private static void accountDeletingBatchTest() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        String counrtyCode = 'DE';
        String soqlWhereCondition = 'RecordType.Name = \'EUR DE On Trade B2B\'';

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountUpdatingBatch(EUR_CRM_AccountUpdatingBatch.ProcessType.DELETING, counrtyCode, soqlWhereCondition));
        Test.stopTest();

        List<EUR_CRM_Account__c> accs = [SELECT Id, RecordTypeId FROM EUR_CRM_Account__c WHERE Name ='Test Name'];
        System.assertEquals(true, accs.isEmpty());
    }
}