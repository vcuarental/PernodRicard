@isTest
private class ASI_CRM_SG_YtdAchievementNotif_BatchTest {

    @TestSetup
    private static void setupData() {

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
            Name = 'Test-Sku-123',
            ASI_HK_CRM_Std_Bottle_Size__c = 100
        );
        //insert testSku1;
        ASI_MFM_SKU_Code__c testSku2 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-456',
            ASI_HK_CRM_Std_Bottle_Size__c = 100
        );
        
        ASI_MFM_SKU_Code__c testSku3 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-456',
            ASI_HK_CRM_Std_Bottle_Size__c = 100
        );

        insert new List<ASI_MFM_SKU_Code__c> {testSku1, testSku2, testSku3};

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost1 = new ASI_CRM_MY_SKUPriceCost__c(
            ASI_CRM_EffectiveDate__c = Date.today(),
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'),
            ASI_CRM_Cost__c = 10,
            ASI_CRM_Price__c = 20,
            ASI_CRM_SKU__c = testSku1.Id
        );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost2 = new ASI_CRM_MY_SKUPriceCost__c(
            ASI_CRM_EffectiveDate__c = Date.today(),
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle'),
            ASI_CRM_Cost__c = 10,
            ASI_CRM_Price__c = 20,
            ASI_CRM_SKU__c = testSku1.Id
        );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost3 = new ASI_CRM_MY_SKUPriceCost__c(
            ASI_CRM_EffectiveDate__c = Date.today(),
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle'),
            ASI_CRM_Cost__c = 10,
            ASI_CRM_Price__c = 20,
            ASI_CRM_SKU__c = testSku1.Id
        );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost4 = new ASI_CRM_MY_SKUPriceCost__c(
            ASI_CRM_EffectiveDate__c = Date.today(),
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'),
            ASI_CRM_Cost__c = 10,
            ASI_CRM_Price__c = 20,
            ASI_CRM_SKU__c = testSku1.Id
        );

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost5 = new ASI_CRM_MY_SKUPriceCost__c(
            ASI_CRM_EffectiveDate__c = Date.today(),
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'),
            ASI_CRM_Cost__c = 10,
            ASI_CRM_Price__c = 20,
            ASI_CRM_SKU__c = testSku1.Id
        );

        insert new List<ASI_CRM_MY_SKUPriceCost__c> {skuPriceCost1, skuPriceCost2, skuPriceCost3, skuPriceCost4, skuPriceCost5};
        //insert skuPriceCost;

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
                                                 .get('ASI CRM SG Contract (Read-Only)').getRecordTypeId();

        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        
        ASI_TH_CRM_Contract__c contractInstance1 = new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Start_Date__c = Date.today(),
            ASI_TH_CRM_End_Date__c = Date.today().addMonths(3),
            RecordTypeId = contractRecTypeId,
            ASI_TH_CRM_Contract_Status__c = 'Contract Approved',
            OwnerId = testUser1.Id,
            ASI_CRM_CN_Sys_Approver_2__c = testUser2.Id,
            ASI_CRM_Till_Date_Sales_Volume_9L__c = 300,
            //ASI_CRM_Till_Date_Sales_Percent_Achieved__c = 100,
            ASI_CRM_SG_Total_Target_Sales_9L_Cases__c = 3, 
            ASI_CRM_Sales_Revenue__c = 300,
            ASI_CRM_Sales_Revenue_Target__c = 3,
            ASI_CRM_CN_Outlet_WS__c = customerC.customer.id,
			ASI_CRM_Type__c = 'Key Account'
        );
        
        ASI_TH_CRM_Contract__c contractInstance2 = new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Start_Date__c = Date.today(),
            ASI_TH_CRM_End_Date__c = Date.today().addMonths(3),
            RecordTypeId = contractRecTypeId,
            ASI_TH_CRM_Contract_Status__c = 'Contract Approved',
            OwnerId = testUser2.Id,
            ASI_CRM_CN_Sys_Approver_2__c = testUser1.Id,
            ASI_CRM_Till_Date_Sales_Volume_9L__c = 400,
            //ASI_CRM_Till_Date_Sales_Percent_Achieved__c = 100,
            ASI_CRM_SG_Total_Target_Sales_9L_Cases__c = 4,
            ASI_CRM_CN_Outlet_WS__c = customerC.customer.id,
			ASI_CRM_Type__c = 'Key Account'
        );

        insert new List<ASI_TH_CRM_Contract__c> {contractInstance1, contractInstance2};
    
        Id actualOfftakeRecTypeId = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c
                                          .getRecordTypeInfosByName()
                                          .get('ASI CRM SG Actual Offtake').getRecordTypeId();

        ASI_TH_CRM_Actual_Offtake__c testActualOfftake1 = new ASI_TH_CRM_Actual_Offtake__c(
            RecordTypeId = actualOfftakeRecTypeId,
            ASI_CRM_FromWS__c = testCustomer1.Id,
            ASI_CRM_SKU__c = testSku1.Id,
            ASI_TH_CRM_Quantity__c = 100,
            ASI_TH_CRM_Offtake_G_L_Date__c = Date.today().addMonths(1),
            ASI_CRM_Contract__c = contractInstance1.Id
        );

        ASI_TH_CRM_Actual_Offtake__c testActualOfftake2 = new ASI_TH_CRM_Actual_Offtake__c(
            RecordTypeId = actualOfftakeRecTypeId,
            ASI_CRM_FromWS__c = testCustomer2.Id,
            ASI_CRM_SKU__c = testSku1.Id,
            ASI_TH_CRM_Quantity__c = 90,
            ASI_TH_CRM_Offtake_G_L_Date__c = Date.today().addMonths(-11),
            ASI_CRM_Contract__c = contractInstance2.Id
        );

        insert new List<ASI_TH_CRM_Actual_Offtake__c> {testActualOfftake1, testActualOfftake2};

        ASI_CRM_ContractTarget__c contractTarget1 = new ASI_CRM_ContractTarget__c(
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
            ASI_CRM_Contract__c = contractInstance1.id,
            ASI_CRM_SKU__c = testSku1.Id,
            ASI_CRM_SG_Consumer_Price_Offer__c = 0,
            ASI_CRM_SG_FOC_Calculation__c = '--None--',
            ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 1,
            ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
            ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
            ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
            ASI_CRM_SG_Btls_Per_Case__c = 12,
            ASI_CRM_SG_Size_cl__c = 75,
            ASI_CRM_Subbrand__c = testSubBrand1.Id,
            ASI_CRM_SG_Sales_Incentive__c = 3,
            ASI_CRM_TargetCase__c = 10
        );

        ASI_CRM_ContractTarget__c contractTarget2 = new ASI_CRM_ContractTarget__c(
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
            ASI_CRM_Contract__c = contractInstance2.id,
            ASI_CRM_SKU__c = testSku1.Id,
            ASI_CRM_SG_Consumer_Price_Offer__c = 0,
            ASI_CRM_SG_FOC_Calculation__c = '--None--',
            ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 1,
            ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
            ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
            ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
            ASI_CRM_SG_Btls_Per_Case__c = 12,
            ASI_CRM_SG_Size_cl__c = 75,
            ASI_CRM_Subbrand__c = testSubBrand2.Id,
            ASI_CRM_SG_Sales_Incentive__c = 3,
            ASI_CRM_TargetCase__c = 10
        );

        insert new List<ASI_CRM_ContractTarget__c> {contractTarget1, contractTarget2};

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
            //ASI_CRM_Percentof_achieved_Sales_Target__c = '70',
            //ASI_CRM_Achieved__c = TRUE,
            ASI_CRM_Payment_Issued__c = FALSE,
            RecordTypeId = paymentRecTypeId
        ));


        lstTestPaymentSchedules.add( new ASI_CRM_Payment_Schedule__c(
            ASI_CRM_Contract__c = contractInstance2.Id,
            //ASI_CRM_Schedule_Date__c = Date.today().addMonths(1),
            ASI_CRM_Sponsorship__c = 300,
            ASI_CRM_Type__c = 'Cash Sponsorship',
            ASI_CRM_Percentof_achieved_Sales_Target__c = '70',
            //ASI_CRM_Achieved__c = TRUE,
            ASI_CRM_Payment_Issued__c = FALSE,
            RecordTypeId = paymentRecTypeId
        ));

        insert lstTestPaymentSchedules;
    }

    static testMethod void testBatchWithData() {
        
        List<ASI_TH_CRM_Contract__c> lstUpdatedContracts =
            [SELECT Id,
                    Name,
                    OwnerId,
                    Owner.Name,
                    Owner.Email,
                    ASI_CRM_CN_Sys_Approver_2__c,
                    ASI_CRM_CN_Sys_Approver_2__r.Email,
                    ASI_CRM_Till_Date_Sales_Volume_9L__c,
                    ASI_CRM_Till_Date_Sales_Percent_Achieved__c,
                    (SELECT Id,
                            ASI_CRM_Sponsorship__c,
                            ASI_CRM_Schedule_Date__c,
                            ASI_CRM_Percentof_achieved_Sales_Target__c
                       FROM Payment_Schedules__r
                      WHERE ASI_CRM_Type__c = 'Cash Sponsorship'
                        AND ASI_CRM_Achieved__c = TRUE
                        AND ASI_CRM_Payment_Issued__c = FALSE)
               FROM ASI_TH_CRM_Contract__c
              // WHERE  ASI_CRM_Till_Date_Sales_Percent_Achieved__c >= 90
                /* [VL 4.0] END */
            ];
            System.debug('------ lstUpdatedContracts ------ : ' + lstUpdatedContracts);

        System.Test.startTest();
            Database.executeBatch(new ASI_CRM_SG_YtdAchievementNotif_Batch());
        System.Test.stopTest();
    }
}