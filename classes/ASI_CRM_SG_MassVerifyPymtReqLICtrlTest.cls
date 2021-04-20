/**********************************************************************************
 * Name : ASI_CRM_SG_MassVerifyPaymentReqLICtrl
 * Created : DC @04/22/2016 12:27 PM
 * Revision History:
 * 1. 04/22/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_SG_MassVerifyPymtReqLICtrlTest {
    
    @TestSetup
    private static void setupData() {

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('Outlet (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c testWholesaler =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'testWholesaler',
            RecordTypeId = customerRecTypeId,
            ASI_CRM_SG_Local_Channel__c = 'MBR'
        );

        customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                  .getRecordTypeInfosByName()
                                  .get('Supplier (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c testVendor =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'testVendor',
            RecordTypeId = customerRecTypeId
        );

        /* Replaced by ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_HK_CRM_Running_Number__c runningNumberContract = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Contract_No',
            ASI_HK_CRM_Running_Number__c = 1,
            ASI_HK_CRM_Format__c = 'PRS-{YY}-{0000}',
            ASI_HK_CRM_Fiscal_Year__c = 2016,
            ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7
        );

        ASI_HK_CRM_Running_Number__c runningNumberReqHeader = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Payment_Request_No',
            ASI_HK_CRM_Running_Number__c = 1,
            ASI_HK_CRM_Format__c = 'PRS-{YY}-{0000}',
            ASI_HK_CRM_Fiscal_Year__c = 2016,
            ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7
        );

        insert new List<ASI_HK_CRM_Running_Number__c> {runningNumberContract, runningNumberReqHeader};
        */

        Id contractRecTypeId = Schema.SObjectType.ASI_TH_CRM_Contract__c
                                                 .getRecordTypeInfosByName()
                                                 .get('ASI CRM SG Contract (Read-Only)').getRecordTypeId();

        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);

        ASI_TH_CRM_Contract__c contractInstance = new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Start_Date__c = Date.today(),
            RecordTypeId = contractRecTypeId,
            ASI_CRM_CN_Status__c = 'Contract Approved',
			ASI_CRM_Type__c = 'Key Account',
            ASI_CRM_Revising__c = true,
            ASI_CRM_CN_Outlet_WS__c = customerC.customer.id
        );

        insert contractInstance;

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

        ASI_CRM_ContractTarget__c contractTarget1 = new ASI_CRM_ContractTarget__c(
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
            ASI_CRM_Contract__c = contractInstance.id,
            ASI_CRM_SKU__c = testSku1.Id,
            ASI_CRM_SG_FOC_Calculation__c = '--None--',
            ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 10,
            ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
            ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
            ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
            ASI_CRM_SG_Btls_Per_Case__c = 3,
            ASI_CRM_SG_Size_cl__c = 4,
            ASI_CRM_Subbrand__c = testSubBrand1.Id,
            ASI_CRM_SG_Sales_Incentive__c = 3, 
            ASI_CRM_SG_Cash__c = 2000
        );

        ASI_CRM_ContractTarget__c contractTarget2 = new ASI_CRM_ContractTarget__c(
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
            ASI_CRM_Contract__c = contractInstance.id,
            ASI_CRM_SKU__c = testSku2.Id,
            ASI_CRM_SG_FOC_Calculation__c = '--None--',
            ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 10,
            ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 50,
            ASI_CRM_SG_IGC_Cost_Per_case__c = 20,
            ASI_CRM_SG_IGC_Cost_Per_9Lc__c = 10,
            ASI_CRM_SG_Btls_Per_Case__c = 3,
            ASI_CRM_SG_Size_cl__c = 4,
            ASI_CRM_Subbrand__c = testSubBrand2.Id,
            ASI_CRM_SG_Sales_Incentive__c = 3, 
            ASI_CRM_SG_Cash__c = 2000
        );

        insert new List<ASI_CRM_ContractTarget__c> {contractTarget1, contractTarget2};

        Id reqHeaderRecTypeId = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c
                                      .getRecordTypeInfosByName()
                                      .get('ASI CRM SG Payment Request').getRecordTypeId();

        ASI_TH_CRM_PaymentRequest__c testRequestHeader = new ASI_TH_CRM_PaymentRequest__c(
            ASI_CRM_CN_OutletWS__c = customerC.customer.id,
            ASI_CRM_Vendor__c = testVendor.Id,
            ASI_CRM_SG_Invoice_No__c = 'Testing001',
            ASI_TH_CRM_GL_Date__c = Date.today(),
            ASI_CRM_SG_Invoice_Date__c = Date.today()-1,
            ASI_TH_CRM_Status__c = 'Approved',
            ASI_CRM_Sync_to_JDE__c = false,
            ASI_CRM_SG_Finance_Verified__c = false,
            ASI_TH_CRM_Contract__c = contractInstance.Id,
            RecordTypeId = reqHeaderRecTypeId
        );

        insert testRequestHeader;
        
        Id reqLineItemRecTypeId = Schema.SObjectType.ASI_TH_CRM_PaymentRequestLineItem__c
                                      .getRecordTypeInfosByName()
                                      .get('ASI CRM SG Payment Request Detail').getRecordTypeId();
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> testRequestLines =
            new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

        for(Integer index = 0; index < 100; index ++) {

            testRequestLines.add( new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c = testRequestHeader.Id,
                ASI_CRM_SG_Type__c = 'Cash - Target Achieved',
                ASI_CRM_Verified__c = false,
                ASI_TH_CRM_UnitCost__c = 10,
                ASI_TH_CRM_Amount__c = 10,
                ASI_CRM_SG_Sub_brand__c = testSubBrand1.Id,
                RecordTypeId = reqLineItemRecTypeId,
                ASI_CRM_SG_Invoice_Date__c = null,
                ASI_TH_CRM_Invoice_No__c = null,
                ASI_CRM_GL_Date__c = null
            ));
        }

        for(Integer index = 0; index < 100; index ++) {

            testRequestLines.add( new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c = testRequestHeader.Id,
                ASI_CRM_SG_Type__c = 'Cash - Target Achieved',
                ASI_CRM_Verified__c = true,
                ASI_TH_CRM_UnitCost__c = 10,
                ASI_TH_CRM_Amount__c = 10,
                ASI_CRM_SG_Sub_brand__c = testSubBrand2.Id,
                RecordTypeId = reqLineItemRecTypeId
            ));
        }

        insert testRequestLines;

    }

    static testMethod void testConstructorAndInit() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_TH_CRM_PaymentRequest__c());

        ASI_CRM_SG_MassVerifyPaymentReqLICtrl controller =
            new ASI_CRM_SG_MassVerifyPaymentReqLICtrl(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_SG_MassVerifyPaymentReqLI);

        System.Test.startTest();
            controller.init();
        
            controller.validateDataOnSave();
            
            Apexpages.currentPage().getParameters().put('headerId', controller.lstTotalLineItems.get(0).ASI_TH_CRM_Payment_Request__r.Id);
            Apexpages.currentPage().getParameters().put('invoiceNo', 'Testing002');
            
            controller.validateData();  
        System.Test.stopTest();
    }

    static testMethod void testPaginationAndSort() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_TH_CRM_PaymentRequest__c());

        ASI_CRM_SG_MassVerifyPaymentReqLICtrl controller =
            new ASI_CRM_SG_MassVerifyPaymentReqLICtrl(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_SG_MassVerifyPaymentReqLI);

        System.Test.startTest();
            controller.init();
            //controller.toggleSort();
            controller.firstPage();
            controller.nextPage();
            controller.prevPage();
            controller.lastPage();
        System.Test.stopTest();
    }

    static testMethod void testSearch() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_TH_CRM_PaymentRequest__c());

        ASI_CRM_SG_MassVerifyPaymentReqLICtrl controller =
            new ASI_CRM_SG_MassVerifyPaymentReqLICtrl(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_SG_MassVerifyPaymentReqLI);

        System.Test.startTest();
            controller.init();
            
            Apexpages.currentPage().getParameters().put('PaymentRequestNo', 'PRS');
            Apexpages.currentPage().getParameters().put('PaymentRequestRef', 'test');
            Apexpages.currentPage().getParameters().put('Outlet', 'test');
            Apexpages.currentPage().getParameters().put('Vendor', 'test');
            Apexpages.currentPage().getParameters().put('fromGLdates', '2016-02-01');
            Apexpages.currentPage().getParameters().put('toGLdates', '2016-02-01');
            Apexpages.currentPage().getParameters().put('ContractNo', 'PRS');
            Apexpages.currentPage().getParameters().put('JdeCoaCode', '123');
            Apexpages.currentPage().getParameters().put('Status', 'Draft');

            controller.runSearch();
        System.Test.stopTest();
    }

    static testMethod void testVerifySome() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_TH_CRM_PaymentRequest__c());

        ASI_CRM_SG_MassVerifyPaymentReqLICtrl controller =
            new ASI_CRM_SG_MassVerifyPaymentReqLICtrl(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_SG_MassVerifyPaymentReqLI);

        System.Test.startTest();
            controller.init();

            controller.lstLineItems.get(0).ASI_CRM_Verified__c = true;
            controller.lstLineItems.get(0).ASI_CRM_GL_Date__c = Date.today();
            controller.lstLineItems.get(1).ASI_CRM_Verified__c = true;
            controller.lstLineItems.get(2).ASI_CRM_Verified__c = true;

            controller.save();
        System.Test.stopTest();
    }

    static testMethod void testVerifyAll() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_TH_CRM_PaymentRequest__c());

        ASI_CRM_SG_MassVerifyPaymentReqLICtrl controller =
            new ASI_CRM_SG_MassVerifyPaymentReqLICtrl(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_SG_MassVerifyPaymentReqLI);

        System.Test.startTest();
            controller.init();

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineIterator : controller.lstLineItems) {
                lineIterator.ASI_CRM_Verified__c = true;
            }
        
            controller.save();
        System.Test.stopTest();
    }
}