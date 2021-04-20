/**********************************************************************************
 * Name : ASI_CRM_JP_AssignJdeGrupName_InvoiceTest
 * Created : DC @04/28/2016
 * Revision History:
 * 1. 04/28/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_AssignJdeGrupName_InvoiceTest {

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

        /*ASI_HK_CRM_Running_Number__c invoiceGroupName1 = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_JDE_Group_Name',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'G{YY}{00000}'
        );*/

        insert new List<ASI_HK_CRM_Running_Number__c> {invoiceAutoNumber, invoiceGroupName, 
                                                       invoiceAutoNumberRebate};

        list<ASI_CRM_Payment_Invoice__c> lstPaymentData = new list<ASI_CRM_Payment_Invoice__c>();
        for(Integer i=0; i<20; i++) {

            ASI_CRM_Payment_Invoice__c paymentData = 
                new ASI_CRM_Payment_Invoice__c(//Name = 'TestPayment-DC-1',
                                               ASI_CRM_Pay_To__c = payTodata.Id,
                                               ASI_CRM_Invoice_No__c = 'IN0001'+ i,
                                               ASI_CRM_Invoice_Date__c = Date.today(),
                                               ASI_CRM_Status__c = 'Draft',
                                               ASI_CRM_Delivery_Time__c = '0000-1200',
                                               ASI_CRM_Payment_Date__c = Date.today().addDays(2),
                                               ASI_CRM_Customer_Ship_Pay_To__c = customer.Id,
                                               //ASI_CRM_Total_Invoice_Amount__c = 10000,
                                               RecordTypeId = paymentRecordType1,
                							   ASI_CRM_Remarks__c = '０１２３４５６７８９');
                lstPaymentData.add(paymentData);
        }                 
       
        insert lstPaymentData;


    } 

    static testMethod void testToAssignFirstGroupName() {

        list<ASI_CRM_Payment_Invoice__c> testListPaymentData =[SELECT Id
                                                                 FROM ASI_CRM_Payment_Invoice__c
                                                                LIMIT 10
                                                               OFFSET 0];

        Test.startTest(); // Starts the scope of test 
            ASI_CRM_JP_AssignJdeGroupName_Invoice groupName = new ASI_CRM_JP_AssignJdeGroupName_Invoice();
            testListPaymentData = groupName.assignGroupName(testListPaymentData);
            update testListPaymentData;
        Test.stopTest(); // Stops the scope of test 
        System.assertEquals('GR-00001', testListPaymentData[0].ASI_CRM_JDE_Group_Name__c);
        
    }

    static testMethod void testToAssignSecndGroupName() {

        list<ASI_CRM_Payment_Invoice__c> testListPaymentData =[SELECT Id
                                                                 FROM ASI_CRM_Payment_Invoice__c
                                                                LIMIT 10
                                                               OFFSET 10];
                                                                                                                      
        Test.startTest(); // Starts the scope of test 
            ASI_CRM_JP_AssignJdeGroupName_Invoice groupName = new ASI_CRM_JP_AssignJdeGroupName_Invoice();
            testListPaymentData = groupName.assignGroupName(testListPaymentData);
            update testListPaymentData;
        Test.stopTest(); // Stops the scope of test 

        System.assertEquals('GR-00001', testListPaymentData[0].ASI_CRM_JDE_Group_Name__c);
        
    }
}