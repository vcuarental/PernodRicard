/**
 * Created by Ilarion Tokarskyi on 24.11.2020.
 */

@IsTest
private class EUR_CRM_RecommendedAccountBatchTest {
    @TestSetup
    static void setup() {
        List<EUR_CRM_Account__c> accounts = EUR_CRM_TestClassUtilityHelper.createAccountsEU(5, 'EUR DE On Trade B2B');
        for (Integer i = 0; i < accounts.size(); i++) {
            accounts[i].EUR_CRM_External_ID__c = 'External_ID_' + i;
        }
        accounts[0].EUR_CRM_IsRecommended__c = TRUE;
        insert accounts;
        EUR_CRM_Week_KDP__c week = createWeek(Date.today(), 'DE', 2);
        insert week;
        List<EUR_CRM_Recommended_Account__c> recAccs = createReccAccounts(week.Id, accounts);
        insert recAccs;
    }

    @IsTest
    static void simplePositiveTestBatch() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_RecommendedAccountBatch());
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c WHERE EUR_CRM_IsRecommended__c = TRUE];
        System.assertEquals(5, accounts.size());
    }

    @IsTest
    static void testScheduleBatch() {
        Test.startTest();
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_RecommendedAccountBatch scheduledJob = new EUR_CRM_RecommendedAccountBatch();
        System.schedule('Test Job', cronExpression, scheduledJob);
        Test.stopTest();
    }

    static EUR_CRM_Week_KDP__c createWeek(Date startDate, String countryCode, Integer numberOfBDVisits) {
        return new EUR_CRM_Week_KDP__c(
                EUR_CRM_Week_Start_Date__c = startDate,
                EUR_CRM_Country_Code__c = countryCode,
                EUR_CRM_Number_of_recommended_BD_visits__c = numberOfBDVisits);
    }

    static List<EUR_CRM_Recommended_Account__c> createReccAccounts(Id weekId,
            List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Recommended_Account__c> result = new List<EUR_CRM_Recommended_Account__c>();
        for (Integer i = 0; i < accounts.size(); i++) {
            result.add(new EUR_CRM_Recommended_Account__c(
                    EUR_CRM_Week_KDP__c = weekId,
                    EUR_CRM_Account__c = accounts[i].Id,
                    EUR_CRM_Business_Development_Score__c = 2.5,
                    EUR_CRM_Days_since_last_visit__c = 2.5,
                    EUR_CRM_Promotion_Score__c = 2.5,
                    EUR_CRM_Visit_Type__c = 'Promotion'));
        }
        return result;
    }
}