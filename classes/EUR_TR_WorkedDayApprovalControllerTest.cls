/**
 * Created by osman on 12.01.2021.
 */

@IsTest
private with sharing class EUR_TR_WorkedDayApprovalControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Visit__c workedDay = new EUR_TR_Visit__c();
        workedDay.EUR_TR_StartDateTime__c = Datetime.now();
        workedDay.EUR_TR_EndDateTime__c = Datetime.now().addMinutes(5);
        workedDay.OwnerId = UserInfo.getUserId();
        workedDay.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        insert workedDay;

    }

    @IsTest
    static void testCreateWorkedDayApprovalRequest() {

        Test.startTest();
        {
            EUR_TR_WorkedDayApprovalController.createWorkedDayApprovalRequestFromMiddleware('');
            EUR_TR_Approval__c approval = [SELECT Id FROM EUR_TR_Approval__c LIMIT 1];
            System.assert(approval.Id != null);
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleAction_approve() {

        EUR_TR_WorkedDayApprovalController.createWorkedDayApprovalRequest();
        EUR_TR_Approval__c approval = [SELECT Id FROM EUR_TR_Approval__c LIMIT 1];
        Test.startTest();
        {
            EUR_TR_WorkedDayApprovalController.handleAction(approval.Id, 'Onayla');
        }
        Test.stopTest();

    }


    @IsTest
    static void testHandleAction_reject() {

        EUR_TR_WorkedDayApprovalController.createWorkedDayApprovalRequest();
        EUR_TR_Approval__c approval = [SELECT Id FROM EUR_TR_Approval__c LIMIT 1];
        Test.startTest();
        {
            EUR_TR_WorkedDayApprovalController.handleAction(approval.Id, 'Reddet');
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleAction_error_unknown_actionName() {

        EUR_TR_WorkedDayApprovalController.createWorkedDayApprovalRequest();
        EUR_TR_Approval__c approval = [SELECT Id FROM EUR_TR_Approval__c LIMIT 1];
        Test.startTest();
        {
            try {
                EUR_TR_WorkedDayApprovalController.handleAction(approval.Id, 'Unknown_Action');
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage() != null);
            }

        }
        Test.stopTest();

    }

}