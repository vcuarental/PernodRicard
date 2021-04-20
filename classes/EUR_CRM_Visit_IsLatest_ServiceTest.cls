/**
 * Created by Ilarion Tokarskyi on 10/22/2020.
 */
@IsTest
public with sharing class EUR_CRM_Visit_IsLatest_ServiceTest {
    @IsTest
    static void testVisitInsert () {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert account;
        account = [SELECT Id FROM EUR_CRM_Account__c];
        EUR_CRM_Visit__c visit1 = EUR_CRM_TestClassUtilityHelper.createVisit( 'EUR_GB_On_Trade_FS_Visit', account.Id);
        visit1.EUR_CRM_Mobile_ID__c = 'External_ID_1';
        visit1.EUR_CRM_Start_Datetime__c = Date.today();
        visit1.EUR_CRM_Status__c = EUR_CRM_Visit_IsLatest_Service.VISIT_FINISHED_STATUS;
        insert visit1;
        visit1 = [SELECT Id, EUR_CRM_Is_Latest__c FROM EUR_CRM_Visit__c];

        System.assertEquals(true, visit1.EUR_CRM_Is_Latest__c);

        Test.startTest();
        EUR_CRM_Visit__c visit2 = EUR_CRM_TestClassUtilityHelper.createVisit( 'EUR_GB_On_Trade_FS_Visit', account.Id);
        visit2.EUR_CRM_Mobile_ID__c = 'External_ID_2';
        visit2.EUR_CRM_Start_Datetime__c = Date.today().addDays(1);
        visit2.EUR_CRM_End_Datetime__c = Date.today().addDays(2);
        visit2.EUR_CRM_Status__c = EUR_CRM_Visit_IsLatest_Service.VISIT_FINISHED_STATUS;
        insert visit2;
        Test.stopTest();

        visit2 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Visit__c
                WHERE EUR_CRM_Mobile_ID__c =
                        'External_ID_2'
        ];
        visit1 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Visit__c
                WHERE EUR_CRM_Mobile_ID__c = 'External_ID_1'
        ];

        System.assertEquals(true, visit2.EUR_CRM_Is_Latest__c);
        System.assertEquals(false, visit1.EUR_CRM_Is_Latest__c);
    }
}