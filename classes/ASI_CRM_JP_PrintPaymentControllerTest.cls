/**********************************************************************************
 * Name : ASI_CRM_JP_PrintPaymentControllerTest
 * Created : DC @04/29/2016
 * Revision History:
 * 1. 04/29/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_PrintPaymentControllerTest {

    @TestSetup
    static void setTestData() {

        Id callRecordTypeId = Schema.SObjectType.ASI_CRM_Call_Detail__c
                                    .getRecordTypeInfosByName()
                                    .get('JP Call Result Detail Locked').getRecordTypeId();

        Id planRecordTypeId = Schema.SObjectType.ASI_CRM_Call_Plan__c
                                    .getRecordTypeInfosByName()
                                    .get('JP Call Plan Locked').getRecordTypeId(); 

        ASI_CRM_Call_Plan__c callPlanData = new ASI_CRM_Call_Plan__c(Name = 'TestCallPlan',
                                                                     ASI_CRM_Period_From__c = Date.today().addDays(-20),
                                                                     ASI_CRM_Period_To__c = Date.today().addDays(20),
                                                                     RecordTypeId = planRecordTypeId);
        insert callPlanData;

        ASI_CRM_Call_Detail__c callDetailData = 
            new ASI_CRM_Call_Detail__c(ASI_CRM_Payment_Option__c = 'Cash', 
                                       ASI_CRM_Call_Plan__c = callPlanData.Id,
                                       ASI_CRM_Visit_Date_From__c = Date.today(),
                                       ASI_CRM_Visit_Date_To__c = Date.today(), 
                                       ASI_CRM_Activity_Result__c = 'Ordered',
                                       ASI_CRM_Actual_Amount__c = 1000,
                                       ASI_CRM_Planned_Amount__c = 10000,
                                       ASI_CRM_Activity_Purpose__c = 'Join Event',
                                       RecordTypeId = callRecordTypeId);
        insert callDetailData;

    }

    static testMethod void testPrintPaymentCtrl() {

        PageReference pageRef = Page.ASI_CRM_JP_PrintPaymentPage;
        System.Test.setCurrentPageReference(pageRef); 
        ASI_CRM_Call_Plan__c testCallData = [SELECT Id
                                               FROM ASI_CRM_Call_Plan__c
                                              LIMIT 1];

        ASI_CRM_Call_Detail__c testPaymentData = [SELECT Id
                                                    FROM ASI_CRM_Call_Detail__c
                                                   LIMIT 1];

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('Id',testCallData.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testCallData);
            ASI_CRM_JP_PrintPaymentController paymentController = new ASI_CRM_JP_PrintPaymentController(sc);

            paymentController.getOptions();
            System.assertEquals('Cash', paymentController.paymentOpt);
            paymentController.changePaymentOpt();
            paymentController.displayList[0].selected = true;
            paymentController.print();
            System.assertEquals(testPaymentData.Id, paymentController.displayList[0].detail.Id);

        Test.stopTest(); // Stops the scope of test  

    }
}