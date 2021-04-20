/**********************************************************************************
 * Name : ASI_CRM_JP_InvoiceWarnControllerTest
 * Created : DC @04/29/2016
 * Revision History:
 * 1. 04/29/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_InvoiceWarnControllerTest {

    @TestSetup
    static void setTestData() {

        Id paymentRecordType = Schema.SObjectType.ASI_CRM_Payment_Invoice__c
                                     .getRecordTypeInfosByName()
                                     .get('JP SPTD FOC Invoice').getRecordTypeId();

        Id paymentRecordType1 = Schema.SObjectType.ASI_CRM_Payment_Invoice__c
                                      .getRecordTypeInfosByName()
                                      .get('JP SPTD Cash Invoice').getRecordTypeId();

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

        List<ASI_CRM_Payment_Invoice__c> lstPayment = new List<ASI_CRM_Payment_Invoice__c>();
        ASI_CRM_Payment_Invoice__c paymentData = 
            new ASI_CRM_Payment_Invoice__c(ASI_CRM_Pay_To__c = payTodata.Id,
                                           ASI_CRM_Invoice_No__c = 'IN001',
                                           ASI_CRM_Invoice_Date__c = Date.today(),
                                           ASI_CRM_Status__c = 'Draft',
                                           ASI_CRM_Payment_Date__c = Date.today().addDays(1),
                                           ASI_CRM_Delivery_Time__c = '0000-1200',
                                           ASI_CRM_Customer_Ship_Pay_To__c = customer.Id,
                                           RecordTypeId = paymentRecordType );
        lstPayment.add(paymentData);

        ASI_CRM_Payment_Invoice__c paymentData1 = 
            new ASI_CRM_Payment_Invoice__c(ASI_CRM_Pay_To__c = payTodata.Id,
                                           ASI_CRM_Invoice_No__c = 'IN001',
                                           ASI_CRM_Invoice_Date__c = Date.today().addMonths(2),
                                           ASI_CRM_Status__c = 'Draft',
                                           ASI_CRM_Payment_Date__c = Date.today().addMonths(2),
                                           ASI_CRM_Delivery_Time__c = 'Before Noon',
                                           ASI_CRM_Customer_Ship_Pay_To__c = customer.Id,
                                           RecordTypeId = paymentRecordType1 );
        lstPayment.add(paymentData1);
        insert lstPayment; 

    } 

    static testMethod void testInvoiceWarnCtrl() {

        PageReference pageRef = Page.ASI_CRM_JP_InvoiceWarnPage;
        System.Test.setCurrentPageReference(pageRef); 
        ASI_CRM_Payment_Invoice__c testPaymentData = [SELECT Id
                                                           , ASI_CRM_Invoice_Date__c
                                                           , RecordTypeId
                                                        FROM ASI_CRM_Payment_Invoice__c
                                                       LIMIT 1];

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('Id',testPaymentData.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testPaymentData);
            ASI_CRM_JP_InvoiceWarnController invoiceController = new ASI_CRM_JP_InvoiceWarnController(sc);

            invoiceController.getOverdueFlag();
            System.assertEquals(system.today(), invoiceController.invoice.ASI_CRM_Invoice_Date__c);
            invoiceController.getIsFoc();
            System.assertEquals('ASI_CRM_JP_SPTD_FOC_Invoice', invoiceController.invoice.RecordType.DeveloperName);
        Test.stopTest(); // Stops the scope of test  

    }

    static testMethod void testInvoiceWarnCtrlWithNoMatch() {

        PageReference pageRef = Page.ASI_CRM_JP_InvoiceWarnPage;
        System.Test.setCurrentPageReference(pageRef); 
        ASI_CRM_Payment_Invoice__c testPaymentData = [SELECT Id
                                                        FROM ASI_CRM_Payment_Invoice__c
                                                       LIMIT 1
                                                      OFFSET 1];

        Test.startTest(); // Starts the scope of test            
            ApexPages.CurrentPage().getparameters().put('Id',testPaymentData.Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testPaymentData);
            ASI_CRM_JP_InvoiceWarnController invoiceController = new ASI_CRM_JP_InvoiceWarnController(sc);

            invoiceController.getOverdueFlag();
            invoiceController.getIsFoc();
        Test.stopTest(); // Stops the scope of test  

    }
}