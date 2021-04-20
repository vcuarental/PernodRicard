/**********************************************************************************
 * Name : ASI_CRM_SG_PopulateInfl_Distr_RateTest
 * Created : DC @04/19/2016 9:23 AM
 * Revision History:
 * 1. 04/19/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_SG_PopulateInfl_Distr_RateTest {
    
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

        List<ASI_CRM_SG_Rate__c> rateList = new List<ASI_CRM_SG_Rate__c>();

        rateList.add( new ASI_CRM_SG_Rate__c(
            Name = 'Distribution 20150101',
            ASI_CRM_SG_Type__c = 'Distribution',
            ASI_CRM_SG_Rate__c = 9.5,
            ASI_CRM_SG_Effective_Date__c = Date.today().addMonths(-12)
        ));

        rateList.add( new ASI_CRM_SG_Rate__c(
            Name = 'Inflation 20150101',
            ASI_CRM_SG_Type__c = 'Inflation',
            ASI_CRM_SG_Rate__c = 4.5,
            ASI_CRM_SG_Effective_Date__c = Date.today().addMonths(-12)
        ));

        rateList.add( new ASI_CRM_SG_Rate__c(
            Name = 'Distribution 20160101',
            ASI_CRM_SG_Type__c = 'Distribution',
            ASI_CRM_SG_Rate__c = 8.5,
            ASI_CRM_SG_Effective_Date__c = Date.today().addMonths(-2)
        ));

        rateList.add( new ASI_CRM_SG_Rate__c(
            Name = 'Inflation 20160101',
            ASI_CRM_SG_Type__c = 'Inflation',
            ASI_CRM_SG_Rate__c = 5.5,
            ASI_CRM_SG_Effective_Date__c = Date.today().addMonths(-2)
        ));

        insert rateList;
    }

    static testMethod void testInsertWithStartDate() {
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        
        Id contractRecTypeId = Schema.SObjectType.ASI_TH_CRM_Contract__c
                                                 .getRecordTypeInfosByName()
                                                 .get('ASI CRM SG 2. Contract').getRecordTypeId();

        ASI_TH_CRM_Contract__c contractInstance = new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Start_Date__c = Date.today(),
            RecordTypeId = contractRecTypeId,
            ASI_CRM_CN_Outlet_WS__c = customerC.customer.id
        );

        insert contractInstance;
    }

    static testMethod void testInsertWithoutStartDate() {
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        
        Id contractRecTypeId = Schema.SObjectType.ASI_TH_CRM_Contract__c
                                                 .getRecordTypeInfosByName()
                                                 .get('ASI CRM SG 2. Contract').getRecordTypeId();

        ASI_TH_CRM_Contract__c contractInstance = new ASI_TH_CRM_Contract__c(
            RecordTypeId = contractRecTypeId,
            ASI_CRM_CN_Outlet_WS__c = customerC.customer.id
        );

        insert contractInstance;
    }
}