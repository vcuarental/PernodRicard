/**********************************************************************************
 * Name : ASI_CRM_JP_ContractPDFPageCtrlTest
 * Created : DC @04/27/2016
 * Revision History:
 * 1. 04/27/2016 - [DC 1.0] Created
 **********************************************************************************/
@isTest
private class ASI_CRM_JP_ContractPDFPageCtrlTest {

    @TestSetup
    static void createTestData() {

        Id contractRecordType1 = Schema.SObjectType.ASI_CRM_Purchase_Contract__c
                                       .getRecordTypeInfosByName()
                                       .get('JP Indirect Rebate Contract').getRecordTypeId();

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('JP Wholesaler').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c customer = 
            new ASI_CRM_AccountsAdditionalField__c(Name = 'TestCustomer',
                                                   ASI_CRM_CN_Inactive_Flag__c = False,
                                                   ASI_CRM_Active__c = true,
                                                   RecordTypeId = customerRecTypeId);
        insert customer;

        ASI_HK_CRM_Running_Number__c contractAutoNumber = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'R{YY}{00000}'
        );

        ASI_HK_CRM_Running_Number__c contractAutoNumberRebate = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_Rebate_No',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = '4{YY}{00000}'
        );

        insert new List<ASI_HK_CRM_Running_Number__c> {contractAutoNumber, contractAutoNumberRebate};

        ASI_CRM_Purchase_Contract__c contractData1 = 
            new ASI_CRM_Purchase_Contract__c(//Name = 'TestPayment-DC-1',
                                             ASI_CRM_BS_Retailer_Ship_To__c = customer.Id,
                                             ASI_CRM_Wholesaler__c = customer.Id,
                                             ASI_CRM_Start_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate(),
                                             ASI_CRM_Status__c = 'Draft',
                                             ASI_CRM_End_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate().addDays(2),
                                             RecordTypeId = contractRecordType1  );                 
        insert contractData1;

    } 

    static testMethod void testContractPDFWithRT1() {

        PageReference pageRef = Page.ASI_CRM_JP_PaymentInvoice_PDFPage;
        System.Test.setCurrentPageReference(pageRef); 
        ASI_CRM_Purchase_Contract__c testContractData = [SELECT Id
                                                           FROM ASI_CRM_Purchase_Contract__c
                                                          LIMIT 1];

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('paymentId', testContractData.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testContractData);
            ASI_CRM_JP_ContractPDFPageCtrl pdfController = new ASI_CRM_JP_ContractPDFPageCtrl(sc);
        Test.stopTest(); // Stops the scope of test   

    }

    static testMethod void testContractPDFWithRT2() {

        PageReference pageRef = Page.ASI_CRM_JP_PaymentInvoice_PDFPage;
        System.Test.setCurrentPageReference(pageRef); 

        ASI_CRM_AccountsAdditionalField__c testCustomer = [SELECT Id
                                                             FROM ASI_CRM_AccountsAdditionalField__c
                                                            LIMIT 1]; 

        Id contractRecordType2 = Schema.SObjectType.ASI_CRM_Purchase_Contract__c
                                       .getRecordTypeInfosByName()
                                       .get('JP Direct Rebate Contract').getRecordTypeId();

        ASI_CRM_Purchase_Contract__c contractData2 = 
            new ASI_CRM_Purchase_Contract__c(//Name = 'TestPayment-DC-2',
                                             ASI_CRM_BS_Retailer_Ship_To__c = testCustomer.Id,
                                             ASI_CRM_Wholesaler__c = testCustomer.Id,
                                             ASI_CRM_Start_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate(),
                                             ASI_CRM_Status__c = 'Draft',
                                             ASI_CRM_Which_To_Pay__c = 'Pay To Sold To',
                                             ASI_CRM_End_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate().addDays(2),
                                             RecordTypeId = contractRecordType2 );                 
        insert contractData2;

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('paymentId', contractData2.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(contractData2);
            ASI_CRM_JP_ContractPDFPageCtrl pdfController = new ASI_CRM_JP_ContractPDFPageCtrl(sc);
        Test.stopTest(); // Stops the scope of test   

    }

    static testMethod void testContractPDFWithRT3() {

        PageReference pageRef = Page.ASI_CRM_JP_PaymentInvoice_PDFPage;
        System.Test.setCurrentPageReference(pageRef); 

        ASI_CRM_AccountsAdditionalField__c testCustomer = [SELECT Id
                                                             FROM ASI_CRM_AccountsAdditionalField__c
                                                            LIMIT 1];

        Id contractRecordType3 = Schema.SObjectType.ASI_CRM_Purchase_Contract__c
                                       .getRecordTypeInfosByName()
                                       .get('JP SPTD Contract').getRecordTypeId();

        ASI_CRM_Purchase_Contract__c contractData3 = 
            new ASI_CRM_Purchase_Contract__c(//Name = 'TestPayment-DC-2',
                                             ASI_CRM_BS_Retailer_Ship_To__c = testCustomer.Id,
                                             ASI_CRM_Wholesaler__c = testCustomer.Id,
                                             ASI_CRM_Start_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate(),
                                             ASI_CRM_Status__c = 'Draft',
                                             ASI_CRM_End_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate().addDays(2),
                                             ASI_CRM_Request_Type__c = '  New Customer Development',
                                             RecordTypeId = contractRecordType3 );                 
        try{
        insert contractData3;
        
        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('paymentId', contractData3.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(contractData3);
            ASI_CRM_JP_ContractPDFPageCtrl pdfController = new ASI_CRM_JP_ContractPDFPageCtrl(sc);
        Test.stopTest(); // Stops the scope of test     
        }catch(exception e){
        
        }
    }
    
}