/**
 * Created by larsz on 6/27/2020.
 */
@IsTest(IsParallel=true)
public with sharing class EUR_CRM_ZA_TestClassHelperTest {

    @IsTest
    static void testCreateObjects() {
        Test.startTest();

        List<EUR_CRM_Account__c> accounts = EUR_CRM_ZA_TestClassHelper.createEUAccount(2, 'Testing', 'EUR ZA On Trade' +
                ' Indirect');

        List<Contact> contacts = EUR_CRM_ZA_TestClassHelper.createContact(2, 'Testing', accounts[0]);

        List<EUR_CRM_Contract__c> contracts = EUR_CRM_ZA_TestClassHelper.createZAContract(2, 'Testing', accounts[0],
                contacts[0], 'EUR_ZA_Outlet_Contract');

        List<EUR_CRM_Contract_Activity_Item__c> cais = EUR_CRM_ZA_TestClassHelper.createContractActivityItem(2,
                contracts[0], new EUR_CRM_Mechanic_Type__c(Name = 'Test Mechanic'));

        List<EUR_CRM_Contract_Product_Item__c> cpis = EUR_CRM_ZA_TestClassHelper.createProductItem(2, cais[0]);

        List<EUR_CRM_Size__c> sizes = EUR_CRM_ZA_TestClassHelper.createBrandQualitySize(2, 'Test', 'externalId',
                'aA40Q0000004JngSAE');

        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = EUR_CRM_ZA_TestClassHelper.createVisitFrequency(2, 'Test');

        List<EUR_CRM_ObjPromo__c> objPromos = EUR_CRM_ZA_TestClassHelper.createObjAndProms(2, 'ZA Off Trade Promotion');

        List<EUR_CRM_Route_Template__c> routeTemplates = EUR_CRM_ZA_TestClassHelper.createRT(2, 'Test');

        List<EUR_CRM_Budget__c> budgets = EUR_CRM_ZA_TestClassHelper.createBudget(2);

        List<EUR_CRM_Budget_Transaction__c> budgetTransactions = EUR_CRM_ZA_TestClassHelper.createBudgetTransactions('EUR ' +
                'ZA On Trade Draft Transaction', 'aHC5E000000003nWAA', 2, 100.00, 'Contract Transaction', 'Debit');

        List<EUR_CRM_Account_Volume_Tracker__c> accountVolumeTrackers = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTracker(2, accounts[0]);

        List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> avtLineItems = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTrackerLineItem(2, accountVolumeTrackers[0]);

        List<EUR_CRM_Sales_Order__c> salesOrders = EUR_CRM_ZA_TestClassHelper.createSalesOrder(2,accounts[0]);

        List<EUR_CRM_POSM_Order__c> pOrders = EUR_CRM_ZA_TestClassHelper.createPOSMOrder(2,accounts[0]);

        List<EUR_CRM_Sales_Order_Items__c> salesOrderItems = EUR_CRM_ZA_TestClassHelper.createSalesOrderItem(2);

        List<EUR_CRM_POSM_Order_Item__c> pOrderItems = EUR_CRM_ZA_TestClassHelper.createPOSMOrderItems(2);

        List<EUR_CRM_SKU__c> skus = EUR_CRM_ZA_TestClassHelper.createSku(2);

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = EUR_CRM_ZA_TestClassHelper.createAccMap
                (1,accounts[0],objPromos[0]);

        List<EUR_CRM_Visit_Action__c> visitActions = EUR_CRM_ZA_TestClassHelper.createVisitAction(2,objPromos[0]);

        Test.stopTest();


    }
}