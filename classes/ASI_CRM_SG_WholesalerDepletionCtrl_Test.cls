/**********************************************************************************
 * Name : ASI_CRM_SG_WholesalerDepletionCtrl_Test
 * Created : DC @04/20/2016 12.30 PM
 * Revision History:
 * 1. 04/20/2016 - [DC 1.0] Created
 **********************************************************************************/
@isTest
private class ASI_CRM_SG_WholesalerDepletionCtrl_Test {

    @TestSetup
    static void createTestData() {

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c customer = 
            new ASI_CRM_AccountsAdditionalField__c(Name = 'TestCustomer',
                                                   RecordTypeId = customerRecTypeId);
        insert customer;

        Id skuRecTypeId = Schema.SObjectType.ASI_MFM_SKU_Code__c
                                .getRecordTypeInfosByName()
                                .get('SG SKU').getRecordTypeId();

        ASI_MFM_SKU_Code__c skuRecord = new ASI_MFM_SKU_Code__c(Name = 'TestSku',
                                                                ASI_HK_CRM_Available_Quantity__c = 0,
                                                                RecordTypeId = skuRecTypeId);
        insert skuRecord;

        Id stockRecTypeId = Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c
                                     .getRecordTypeInfosByName()
                                     .get('ASI_CRM_SG_WS_Depletion').getRecordTypeId();

        list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstStockRecords = 
            new list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();

        for(Integer i=300; i>=0; i--) {

            lstStockRecords.add(new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                ASI_CRM_SKU__c = skuRecord.Id,
                ASI_CRM_Customer__c = customer.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-i),
                ASI_TH_CRM_Beginning_Stock__c = NULL,
                ASI_TH_CRM_Sell_In__c = NULL,
                ASI_TH_CRM_FOC__c = NULL,
                ASI_TH_CRM_Total_Offtake_Final__c = NULL,
                ASI_CRM_Adjusted_Quantity__c = 200,
                ASI_TH_CRM_Ending_Stock_Final__c = 0,
                ASI_CRM_Adjusted_Reason__c = 'JanRecord',
                RecordTypeId = stockRecTypeId
            ));
        }
      
        insert lstStockRecords;

        list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstStockRecordsWithNullValue = 
            new list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();

        for(Integer i=300; i>=0; i--) {

            lstStockRecordsWithNullValue.add(new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                ASI_CRM_SKU__c = skuRecord.Id,
                ASI_CRM_Customer__c = customer.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-i),
                ASI_TH_CRM_Beginning_Stock__c = NULL,
                ASI_TH_CRM_Sell_In__c = NULL,
                ASI_TH_CRM_FOC__c = NULL,
                ASI_TH_CRM_Total_Offtake_Final__c = NULL,
                ASI_CRM_Adjusted_Quantity__c = NULL,
                ASI_TH_CRM_Ending_Stock_Final__c = NULL,
                ASI_CRM_Adjusted_Reason__c = NULL,
                RecordTypeId = stockRecTypeId
            ));
        }
        insert lstStockRecordsWithNullValue;

    } 

    static testMethod void testStockRecordIfExist() {

        PageReference pageRef = Page.ASI_CRM_SG_WholesalerDepletion;
        System.Test.setCurrentPageReference(pageRef); 

        ASI_CRM_AccountsAdditionalField__c testCustomerId = [SELECT Id
                                                               FROM ASI_CRM_AccountsAdditionalField__c
                                                              LIMIT 1];

        Test.startTest(); // Starts the scope of test

            ApexPages.CurrentPage().getparameters().put('customerId', testCustomerId.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testCustomerId);
            ASI_CRM_SG_WholesalerDepletionController controller = new ASI_CRM_SG_WholesalerDepletionController(sc);
            controller.initData();

            controller.selectedMonth = 'Mar';
            controller.selectedYear = '2016';
            controller.go();

            controller.selectedMonth = 'Apr';
            controller.selectedYear = '2016';
            controller.go();

            controller.cancelAndRedirect();

            controller.saveOfftakeDetails();

        Test.stopTest(); // Ends the scope of test

    }

    static testMethod void testStockRecordIfNotExist() {

        PageReference pageRef = Page.ASI_CRM_SG_WholesalerDepletion;
        System.Test.setCurrentPageReference(pageRef); 

        ASI_CRM_AccountsAdditionalField__c testCustomerId = [SELECT Id
                                                               FROM ASI_CRM_AccountsAdditionalField__c
                                                              LIMIT 1];
       
        Test.startTest(); // Starts the scope of test

            ApexPages.CurrentPage().getparameters().put('customerId', testCustomerId.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testCustomerId);
            ASI_CRM_SG_WholesalerDepletionController controller = new ASI_CRM_SG_WholesalerDepletionController(sc);
            controller.initData();

            controller.selectedMonth = 'Mar';
            controller.selectedYear = '2016';
            controller.go();

            controller.cancelAndRedirect();

            try {
                ApexPages.CurrentPage().getparameters().get('IS_QUICK_SAVE');
                controller.lstStockDetailWrapper[0].detailRecord.ASI_CRM_Adjusted_Quantity__c = 150;
                controller.saveOfftakeDetails();

            } catch(Exception e) {
                String expectedExceptionThrown =  e.getMessage();
            }

        Test.stopTest(); // Ends the scope of test

    }
    
    
    static testMethod void testPagination() {

        PageReference pageRef = Page.ASI_CRM_SG_WholesalerDepletion;
        System.Test.setCurrentPageReference(pageRef); 

        ASI_CRM_AccountsAdditionalField__c testCustomerId = [SELECT Id
                                                               FROM ASI_CRM_AccountsAdditionalField__c
                                                              LIMIT 1];
       
        Test.startTest(); // Starts the scope of test

            ApexPages.CurrentPage().getparameters().put('customerId', testCustomerId.Id);
            //ApexPages.CurrentPage().getparameters().put('ROW', '2');
            ApexPAges.StandardController sc = new ApexPages.StandardController(testCustomerId);
            ASI_CRM_SG_WholesalerDepletionController controller = new ASI_CRM_SG_WholesalerDepletionController(sc);
            controller.initData();


            controller.selectedMonth = 'Mar';
            controller.selectedYear = '2016';
            controller.go();

            controller.firstPage();
            controller.nextPage();
            //controller.prevPage();
            controller.lastPage();

        Test.stopTest(); // Ends the scope of test

    }
}