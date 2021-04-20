/**
 * Created by larsz on 8/4/2020.
 */

@IsTest
private class EUR_CRM_LookupFieldControllerTest {
    @IsTest
    static void testLookupFieldController() {
        insert makeAccount('EUR_DE_On_Trade_B2B');
        List<string> returnFields = new List<string> {'EUR_CRM_Postal_Code__c'};
        EUR_CRM_Account__c a = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_LookupFieldController.getObjectDetails('EUR_CRM_Account__c');
        EUR_CRM_LookupFieldController.getRecentRecords('EUR_CRM_Account__c', returnFields, 5);
        EUR_CRM_LookupFieldController.searchRecords('EUR_CRM_Account__c', returnFields, returnFields, '', 'EUR_CRM_Postal_Code__c', 'ASC', 5,
                'CreatedDate > 2001-01-01T00:00:01Z');
        EUR_CRM_LookupFieldController.getRecord('EUR_CRM_Account__c', returnFields, a.Id);
    }

    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
                RecordTypeId = rtId
                ,   EUR_CRM_Postal_Code__c = '112233'
        );
    }
}