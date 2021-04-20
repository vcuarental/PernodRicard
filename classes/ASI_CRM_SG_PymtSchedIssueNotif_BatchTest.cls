/***************************************************************************************************
 * Name : ASI_CRM_SG_PymtSchedIssueNotif_BatchTest
 * Created : DC @04/21/2016 9:30 AM
 * Revision History:
 * 1. 04/21/2016 - [DC 1.0] Created
 **************************************************************************************************/

@isTest
private class ASI_CRM_SG_PymtSchedIssueNotif_BatchTest {
    
    @TestSetup
    private static void setupData() {

        /* Replaced by ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Contract_No',
            ASI_HK_CRM_Running_Number__c = 1,
            ASI_HK_CRM_Format__c = 'PRS-{YY}-{0000}',
            ASI_HK_CRM_Fiscal_Year__c = 2016,
            ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7
        );
        insert runningNumber;
        */

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User testUser1 = new User(Alias = 'standt', Email='contractowner1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardProfile.Id, ManagerId = UserInfo.getUserId(),
            TimeZoneSidKey='America/Los_Angeles', UserName='contractowner1@testorg.com');

        User testUser2 = new User(Alias = 'standt', Email='contractowner2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardProfile.Id, ManagerId = UserInfo.getUserId(),
            TimeZoneSidKey='America/Los_Angeles', UserName='contractowner2@testorg.com');

        insert new List<User> {testUser1, testUser2};

        Id contractRecTypeId = Schema.SObjectType.ASI_TH_CRM_Contract__c 
                                                 .getRecordTypeInfosByName()
                                                 .get('ASI CRM SG 2. Contract').getRecordTypeId();

        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        

        ASI_TH_CRM_Contract__c contractInstance1 = new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Start_Date__c = Date.today().addMonths(-4),
            RecordTypeId = contractRecTypeId,
            ASI_TH_CRM_Contract_Status__c = 'Contract Approved',
            OwnerId = testUser1.Id,
            ASI_CRM_CN_Sys_Approver_2__c = testUser2.Id,
            ASI_CRM_Till_Date_Sales_Volume_9L__c = 30,
            ASI_CRM_SG_Total_Target_Sales_9L_Cases__c = 20,
            ASI_CRM_CN_Outlet_WS__c = customerC.customer.id
        );

        ASI_TH_CRM_Contract__c contractInstance2 = new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Start_Date__c = Date.today().addMonths(-2),
            RecordTypeId = contractRecTypeId,
            ASI_TH_CRM_Contract_Status__c = 'Contract Approved',
            OwnerId = testUser2.Id,
            ASI_CRM_CN_Sys_Approver_2__c = testUser1.Id,
            ASI_CRM_Till_Date_Sales_Volume_9L__c = 40,
            ASI_CRM_SG_Total_Target_Sales_9L_Cases__c = 10,
            ASI_CRM_CN_Outlet_WS__c = customerC.customer.id
        );

        insert new List<ASI_TH_CRM_Contract__c> {contractInstance1, contractInstance2};

        Id paymentRecTypeId = Schema.SObjectType.ASI_CRM_Payment_Schedule__c 
                                                .getRecordTypeInfosByName()
                                                .get('ASI CRM SG Payment Schedule').getRecordTypeId();

        List<ASI_CRM_Payment_Schedule__c> lstTestPaymentSchedules =
            new List<ASI_CRM_Payment_Schedule__c>();

        lstTestPaymentSchedules.add( new ASI_CRM_Payment_Schedule__c(
            ASI_CRM_Contract__c = contractInstance1.Id,
            ASI_CRM_Schedule_Date__c = Date.today().addMonths(1),
            ASI_CRM_Sponsorship__c = 100,
            ASI_CRM_Type__c = 'Cash Sponsorship',
            RecordTypeId = paymentRecTypeId
        ));

        lstTestPaymentSchedules.add( new ASI_CRM_Payment_Schedule__c(
            ASI_CRM_Contract__c = contractInstance1.Id,
            ASI_CRM_Sponsorship__c = 200,
            ASI_CRM_Percentof_achieved_Sales_Target__c = '15',
            ASI_CRM_Type__c = 'Cash Sponsorship',
            RecordTypeId = paymentRecTypeId
        ));



        lstTestPaymentSchedules.add( new ASI_CRM_Payment_Schedule__c(
            ASI_CRM_Contract__c = contractInstance2.Id,
            ASI_CRM_Schedule_Date__c = Date.today().addMonths(1),
            ASI_CRM_Sponsorship__c = 300,
            ASI_CRM_Type__c = 'Cash Sponsorship',
            RecordTypeId = paymentRecTypeId
        ));

        lstTestPaymentSchedules.add( new ASI_CRM_Payment_Schedule__c(
            ASI_CRM_Contract__c = contractInstance2.Id,
            ASI_CRM_Sponsorship__c = 400,
            ASI_CRM_Percentof_achieved_Sales_Target__c = '15',
            ASI_CRM_Type__c = 'Cash Sponsorship',
            RecordTypeId = paymentRecTypeId
        ));

        insert lstTestPaymentSchedules;
    }

    static testMethod void testBatchWithData() {
        System.Test.startTest();
            Database.executeBatch(new ASI_CRM_SG_PymtSchedIssuanceNotif_Batch());
        System.Test.stopTest();
    }
}