/**********************************************************************************
 * Name : ASI_CRM_SG_GenWholesalerDepletion_Batch
 * Created : DC @04/20/2016 9:09 AM
 * Revision History:
 * 1. 04/20/2016 - [DC 1.0] Created
 * 1. 04/21/2016 - [DC 1.1] Added revision history
 **********************************************************************************/

@isTest
private class ASI_CRM_SG_GenWholesalerDepln_BatchTest {

    @TestSetup
    private static void createTestData() {

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c testCustomer1 =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Testcompany',
            RecordTypeId = customerRecTypeId
        );

        ASI_CRM_AccountsAdditionalField__c testCustomer2 =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Testcustomer',
            RecordTypeId = customerRecTypeId
        );
        
        ASI_CRM_AccountsAdditionalField__c testCustomer3 =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Testcustomer',
            RecordTypeId = customerRecTypeId
        );

        insert new List<ASI_CRM_AccountsAdditionalField__c> {testCustomer1, testCustomer2, testCustomer3};

        Id subBrandRecTypeId = Schema.SObjectType.ASI_MFM_Sub_brand__c
                                     .getRecordTypeInfosByName()
                                     .get('SG Sub-brand').getRecordTypeId();

        ASI_MFM_Sub_brand__c testSubBrand1 = new ASI_MFM_Sub_brand__c(
            RecordTypeId = subBrandRecTypeId,
            Name = 'TestSubBrand1'
        );
        
        ASI_MFM_Sub_brand__c testSubBrand2 = new ASI_MFM_Sub_brand__c(
            RecordTypeId = subBrandRecTypeId,
            Name = 'TestSubBrand2'
        );

        insert new List<ASI_MFM_Sub_brand__c> {testSubBrand1, testSubBrand2};

        Id skuRecTypeId = Schema.SObjectType.ASI_MFM_SKU_Code__c
                                .getRecordTypeInfosByName()
                                .get('SG SKU').getRecordTypeId();

        ASI_MFM_SKU_Code__c testSku1 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-123'
        );
        
        ASI_MFM_SKU_Code__c testSku2 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-456'
        );
        
        ASI_MFM_SKU_Code__c testSku3 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-456'
        );

        insert new List<ASI_MFM_SKU_Code__c> {testSku1, testSku2, testSku3};

        Id wsDepletionRecTypeId = Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c
                                        .getRecordTypeInfosByName()
                                        .get('ASI_CRM_SG_WS_Depletion').getRecordTypeId();

        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion1 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer1.Id,
                ASI_CRM_SKU__c = testSku1.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-2)
            );
            
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion2 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer1.Id,
                ASI_CRM_SKU__c = testSku2.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-1)
            );

        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion3 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer2.Id,
                ASI_CRM_SKU__c = testSku2.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-1)
            );

        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion4 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer1.Id,
                ASI_CRM_SKU__c = testSku3.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-1)
            );

        insert new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> {
            testWsDepletion1, testWsDepletion2, testWsDepletion3, testWsDepletion4};

        Id actualOfftakeRecTypeId = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c
                                          .getRecordTypeInfosByName()
                                          .get('ASI CRM SG Actual Offtake').getRecordTypeId();

        ASI_TH_CRM_Actual_Offtake__c testActualOfftake1 = new ASI_TH_CRM_Actual_Offtake__c(
            RecordTypeId = actualOfftakeRecTypeId,
            ASI_CRM_FromWS__c = testCustomer1.Id,
            ASI_CRM_SKU__c = testSku1.Id,
            ASI_TH_CRM_Quantity__c = 10
        );

        ASI_TH_CRM_Actual_Offtake__c testActualOfftake2 = new ASI_TH_CRM_Actual_Offtake__c(
            RecordTypeId = actualOfftakeRecTypeId,
            ASI_CRM_FromWS__c = testCustomer2.Id,
            ASI_CRM_SKU__c = testSku3.Id,
            ASI_TH_CRM_Quantity__c = 9
        );

        insert new List<ASI_TH_CRM_Actual_Offtake__c> {testActualOfftake1, testActualOfftake2};

        Account testAccount = new Account(
            Name = 'TestWholesaler'
        );

        insert testAccount;

        Id soHistoryRecTypeId = Schema.SObjectType.ASI_HK_CRM_Sales_Order_History__c
                                      .getRecordTypeInfosByName()
                                      .get('SG CRM Sales Order History').getRecordTypeId();

        ASI_HK_CRM_Sales_Order_History__c testSoHistory = new ASI_HK_CRM_Sales_Order_History__c(
            RecordTypeId = soHistoryRecTypeId,
            ASI_HK_CRM_Account_PA__c = testAccount.Id,
            ASI_CRM_Sold_To__c = testCustomer1.Id,
            ASI_HK_CRM_Order_Type__c = 'Singapore DF & DP Free Issue - F1'
        );

        insert testSoHistory;

        Id soHistoryDetailRecTypeId = Schema.SObjectType.ASI_HK_CRM_Sales_Order_History_Detail__c
                                            .getRecordTypeInfosByName()
                                            .get('SG CRM Sales Order History Detail').getRecordTypeId();

        ASI_HK_CRM_Sales_Order_History_Detail__c testSoHistoryDetail =
            new ASI_HK_CRM_Sales_Order_History_Detail__c(
                RecordTypeId = soHistoryDetailRecTypeId,
                ASI_HK_CRM_Sales_Order_History__c = testSoHistory.Id,
                ASI_HK_CRM_Product_SKU__c = testSku1.Id
            );

        insert testSoHistoryDetail;

    }

    static testMethod void testGenerationBatch() {

        System.Test.startTest();
            Database.executeBatch(new ASI_CRM_SG_GenWholesalerDepletion_Batch());
            System.schedule(
                'Test Batch',
                '0 0 0 1 1 ? *',
                new ASI_CRM_SG_GenWholesalerDepletion_Batch()
            );
        System.Test.stopTest();
        
    }
}