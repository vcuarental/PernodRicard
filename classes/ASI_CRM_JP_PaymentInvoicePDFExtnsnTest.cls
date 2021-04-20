/**********************************************************************************
 * Name : ASI_CRM_JP_PaymentInvoicePDFExtnsnTest
 * Created : DC @04/27/2016
 * Revision History:
 * 1. 04/27/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_PaymentInvoicePDFExtnsnTest {

    @TestSetup
    static void createTestData() {

        Id paymentRecordType1 = Schema.SObjectType.ASI_CRM_Payment_Invoice__c
                                      .getRecordTypeInfosByName()
                                      .get('JP SPTD FOC Invoice').getRecordTypeId();

        Id payToRecordType = Schema.SObjectType.ASI_CRM_Pay_To__c
                                   .getRecordTypeInfosByName()
                                   .get('JP CRM Pay To').getRecordTypeId();
        
        ASI_CRM_Pay_To__c payTodata = new ASI_CRM_Pay_To__c(Name = 'testPayTo',
                                                            ASI_CRM_Active__c = True,
                                                            RecordTypeId = payToRecordType);
        insert payTodata;

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c customer = 
            new ASI_CRM_AccountsAdditionalField__c(Name = 'TestCustomer',
                                                   RecordTypeId = customerRecTypeId);
        insert customer;

        ASI_HK_CRM_Running_Number__c invoiceAutoNumber = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'V{YY}{00000}'
        );

        ASI_HK_CRM_Running_Number__c invoiceAutoNumberRebate = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_Rebate_No',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'P{YY}{00000}'
        );

        ASI_HK_CRM_Running_Number__c invoiceGroupName = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_JDE_Group_Name',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'GR-{00000}'
        );

        insert new List<ASI_HK_CRM_Running_Number__c> {invoiceAutoNumber, invoiceGroupName, invoiceAutoNumberRebate};

        ASI_CRM_Payment_Invoice__c paymentData1 = 
            new ASI_CRM_Payment_Invoice__c(//Name = 'TestPayment-DC-1',
                                           ASI_CRM_Pay_To__c = payTodata.Id,
                                           ASI_CRM_Invoice_No__c = 'IN001',
                                           ASI_CRM_Invoice_Date__c = Date.today(),
                                           ASI_CRM_Status__c = 'Draft',
                                           ASI_CRM_Payment_Date__c = Date.today().addDays(2),
                                           ASI_CRM_Customer_Ship_Pay_To__c = customer.Id,
                                            ASI_CRM_Delivery_Time__c = '0000-1200',
                                           //ASI_CRM_Total_Invoice_Amount__c = 10000,
                                           RecordTypeId = paymentRecordType1 );                 
        insert paymentData1;

    } 

    static testMethod void testPaymentInvoicePDFWithRT1() {

        PageReference pageRef = Page.ASI_CRM_JP_PaymentInvoice_PDFPage;
        System.Test.setCurrentPageReference(pageRef); 
        ASI_CRM_Payment_Invoice__c testPaymentData = [SELECT Id
                                                        FROM ASI_CRM_Payment_Invoice__c
                                                       LIMIT 1];

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('paymentId', testPaymentData.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testPaymentData);
            ASI_CRM_JP_PaymentInvoicePDFExtension pdfController = new ASI_CRM_JP_PaymentInvoicePDFExtension(sc);
        Test.stopTest(); // Stops the scope of test  

    }

    static testMethod void testPaymentInvoicePDFWithRT2() {

        PageReference pageRef = Page.ASI_CRM_JP_PaymentInvoice_PDFPage;
        System.Test.setCurrentPageReference(pageRef); 

        ASI_CRM_Pay_To__c testPayTo = [SELECT Id
                                         FROM ASI_CRM_Pay_To__c
                                        LIMIT 1 ];

        Id paymentRecordType2 = Schema.SObjectType.ASI_CRM_Payment_Invoice__c
                                      .getRecordTypeInfosByName()
                                      .get('JP SPTD Cash Invoice').getRecordTypeId();

        ASI_CRM_Payment_Invoice__c paymentData2 = 
            new ASI_CRM_Payment_Invoice__c(//Name = 'TestPayment-DC-2',
                                           ASI_CRM_Pay_To__c = testPayTo.Id,
                                           ASI_CRM_Invoice_No__c = 'IN0010',
                                           ASI_CRM_Invoice_Date__c = Date.today(),
                                           ASI_CRM_Status__c = 'Draft',
                                           ASI_CRM_Payment_Date__c = Date.today().addDays(2),
                                           ASI_CRM_Total_Invoice_Amount__c = 10000,
                                           RecordTypeId = paymentRecordType2 );                 
        insert paymentData2;

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('paymentId', paymentData2.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(paymentData2);
            ASI_CRM_JP_PaymentInvoicePDFExtension pdfController = new ASI_CRM_JP_PaymentInvoicePDFExtension(sc);
        Test.stopTest(); // Stops the scope of test 

    }

    static testMethod void testPaymentInvoicePDFWithRT3() {

        PageReference pageRef = Page.ASI_CRM_JP_PaymentInvoice_PDFPage;
        System.Test.setCurrentPageReference(pageRef); 

        ASI_CRM_Pay_To__c testPayTo = [SELECT Id
                                         FROM ASI_CRM_Pay_To__c
                                        LIMIT 1 ];
        Id paymentRecordType3 = Schema.SObjectType.ASI_CRM_Payment_Invoice__c
                                      .getRecordTypeInfosByName()
                                      .get('JP Indirect Rebate Invoice').getRecordTypeId();  

        ASI_CRM_Payment_Invoice__c paymentData3 = 
            new ASI_CRM_Payment_Invoice__c(//Name = 'TestPayment-DC-3',
                                           ASI_CRM_Pay_To__c = testPayTo.Id,
                                           ASI_CRM_Invoice_No__c = 'IN0011',
                                           ASI_CRM_Invoice_Date__c = Date.today(),
                                           ASI_CRM_Status__c = 'Draft',
                                           ASI_CRM_Payment_Date__c = Date.today().addDays(2),
                                           ASI_CRM_Total_Invoice_Amount__c = 10000,
                                           RecordTypeId = paymentRecordType3 );                 
        insert paymentData3;

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('paymentId', paymentData3.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(paymentData3);
            ASI_CRM_JP_PaymentInvoicePDFExtension pdfController = new ASI_CRM_JP_PaymentInvoicePDFExtension(sc);
        Test.stopTest(); // Stops the scope of test  

    }

}