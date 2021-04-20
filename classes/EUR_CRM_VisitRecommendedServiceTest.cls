/**
 * Created by larsz on 06.11.2020.
 */

@IsTest
private class EUR_CRM_VisitRecommendedServiceTest {
    @TestSetup
    static void setup() {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        account.EUR_CRM_IsRecommended__c = true;
        insert account;
    }
    @IsTest
    static void testInsertVisit() {
        EUR_CRM_Account__c account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_Visit__c visit1 = EUR_CRM_TestClassUtilityHelper.createVisit( 'EUR_GB_On_Trade_FS_Visit', account.Id);
        visit1.EUR_CRM_Mobile_ID__c = 'External_ID_1';
        visit1.EUR_CRM_Start_Datetime__c = Date.today();
        visit1.EUR_CRM_Status__c = EUR_CRM_Visit_IsLatest_Service.VISIT_FINISHED_STATUS;

        Test.startTest();
        insert visit1;
        Test.stopTest();

        visit1 = [SELECT Id, EUR_CRM_IsRecommendationSuccessful__c FROM EUR_CRM_Visit__c LIMIT 1];
        System.assertEquals(true, visit1.EUR_CRM_IsRecommendationSuccessful__c);
    }
    @IsTest
    static void testUpdateVisit() {
        EUR_CRM_Account__c account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_Visit__c visit1 = EUR_CRM_TestClassUtilityHelper.createVisit( 'EUR_GB_On_Trade_FS_Visit', account.Id);
        visit1.EUR_CRM_Mobile_ID__c = 'External_ID_1';
        visit1.EUR_CRM_Start_Datetime__c = Date.today();
        visit1.EUR_CRM_Status__c = 'In Progress';
        insert visit1;
        visit1 = [SELECT Id, EUR_CRM_IsRecommendationSuccessful__c FROM EUR_CRM_Visit__c LIMIT 1];
        System.assertEquals(false, visit1.EUR_CRM_IsRecommendationSuccessful__c);

        Test.startTest();
        visit1.EUR_CRM_Status__c = EUR_CRM_Visit_IsLatest_Service.VISIT_FINISHED_STATUS;
        update visit1;
        Test.stopTest();

        visit1 = [SELECT Id, EUR_CRM_IsRecommendationSuccessful__c FROM EUR_CRM_Visit__c LIMIT 1];
        System.assertEquals(true, visit1.EUR_CRM_IsRecommendationSuccessful__c);
    }
}