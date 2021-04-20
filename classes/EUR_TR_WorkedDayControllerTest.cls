/**
 * Created by osman on 1.12.2020.
 */

@IsTest
private with sharing class EUR_TR_WorkedDayControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Definition__c dailyWorkDefinition = new EUR_TR_Definition__c();
        dailyWorkDefinition.EUR_TR_MaxVisitableAccountNumber__c = 10;
        dailyWorkDefinition.Name = 'Rota Tanımı';
        dailyWorkDefinition.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        insert dailyWorkDefinition;

    }

    @IsTest
    static void testGetCurrentWorkedDay() {
        Test.startTest();
        {
            EUR_TR_WorkedDayController.getCurrentWorkedDay();
        }
        Test.stopTest();
    }

    @IsTest
    static void testCheckIsDayStarted() {
        Test.startTest();
        {
            EUR_TR_WorkedDayController.checkIsDayStarted();
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetWorkedDayDefinition() {
        Test.startTest();
        {
            EUR_TR_WorkedDayController.getWorkedDayDefinition();
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetNotClosedVisitsByCurrentWorkedDay_success() {

        Test.startTest();
        {
            EUR_TR_WorkedDayController.getNotClosedVisitsByCurrentWorkedDayFromMiddleware('');
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetNotClosedVisitsByCurrentWorkedDay_error_day_is_not_started() {

        EUR_TR_WorkedDayController.startDay();
        Test.startTest();
        {
            EUR_TR_WorkedDayController.getNotClosedVisitsByCurrentWorkedDayFromMiddleware('');
        }
        Test.stopTest();

    }

    @IsTest
    static void testStartDayFromMiddleware() {
        Test.startTest();
        {
            String requestBody = '';
            EUR_TR_WorkedDayController.startDayFromMiddleware(requestBody);
        }
        Test.stopTest();
    }

    @IsTest
    static void testStartDayFromMiddleware_error() {
        Test.startTest();
        {
            try {
                String requestBody = '';
                EUR_TR_WorkedDayController.startDayFromMiddleware(requestBody);
                EUR_TR_WorkedDayController.startDayFromMiddleware(requestBody);
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }

        }
        Test.stopTest();
    }

    @IsTest
    static void testEndDayFromMiddleware() {
        String requestBody = '';
        EUR_TR_WorkedDayController.startDayFromMiddleware(requestBody);
        Test.startTest();
        {
            EUR_TR_WorkedDayController.endDayFromMiddleware(requestBody);
        }
        Test.stopTest();
    }

    @IsTest
    static void testEndDayFromMiddleware_error() {
        String requestBody = '';
        EUR_TR_WorkedDayController.startDayFromMiddleware(requestBody);
        Test.startTest();
        {
            try {
                EUR_TR_WorkedDayController.endDayFromMiddleware(requestBody);
                EUR_TR_WorkedDayController.endDayFromMiddleware(requestBody);
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }

        }
        Test.stopTest();
    }


    @IsTest
    static void testCheckIsDayStartedFromMiddleware() {
        String requestBody = '';
        Test.startTest();
        {
            EUR_TR_WorkedDayController.checkIsDayStartedFromMiddleware(requestBody);
        }
        Test.stopTest();
    }


}