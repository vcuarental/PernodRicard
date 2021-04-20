/**********************************************************************************
 * Name : ASI_CRM_JP_MassGroup_InvoiceCtrlTest
 * Created : DC @04/26/2016 12:33 PM
 * Revision History:
 * 1. 04/26/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_MassGroup_InvoiceCtrlTest {

    @TestSetup
    public static void setupData() {

        ASI_HK_CRM_Running_Number__c invoiceAutoNumber = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'INV-{YYYY}-{MM}-{00000}'
        );
        ASI_CRM_JP_TestClassHelper.createRunningNumbers();
        ASI_HK_CRM_Running_Number__c invoiceGroupName = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_JDE_Group_Name',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'GR-{00000}'
        );

        //insert new List<ASI_HK_CRM_Running_Number__c> {invoiceAutoNumber, invoiceGroupName};

        Id invoiceRecTypeId = Schema.SObjectType.ASI_CRM_Payment_Invoice__c
                                    .getRecordTypeInfosByName()
                                    .get('JP Cash Invoice Read-Only').getRecordTypeId();

        ASI_CRM_Payment_Invoice__c testInvoice1 = new ASI_CRM_Payment_Invoice__c(
            RecordTypeId = invoiceRecTypeId,
            ASI_CRM_Invoice_No__c = 'Inv123456',
            ASI_CRM_Invoice_Date__c = Date.today(),
            ASI_CRM_Payment_Date__c = Date.today(),
            ASI_CRM_Total_Invoice_Amount__c = 2323,
            OwnerId = UserInfo.getUserId(),
            ASI_CRM_Status__c = 'Approval in Progress'
        );
        
        ASI_CRM_Payment_Invoice__c testInvoice2 = new ASI_CRM_Payment_Invoice__c(
            RecordTypeId = invoiceRecTypeId,
            ASI_CRM_Invoice_No__c = 'Inv123456',
            ASI_CRM_Invoice_Date__c = Date.today(),
            ASI_CRM_Payment_Date__c = Date.today(),
            ASI_CRM_Total_Invoice_Amount__c = 2323,
            OwnerId = UserInfo.getUserId(),
            ASI_CRM_Status__c = 'Approval in Progress',
            ASI_CRM_JDE_Group_Name__c = 'GR00110'
        );
        
        ASI_CRM_Payment_Invoice__c testInvoice3 = new ASI_CRM_Payment_Invoice__c(
            RecordTypeId = invoiceRecTypeId,
            ASI_CRM_Invoice_No__c = 'Inv123456',
            ASI_CRM_Invoice_Date__c = Date.today(),
            ASI_CRM_Payment_Date__c = Date.today(),
            ASI_CRM_Total_Invoice_Amount__c = 2323,
            OwnerId = UserInfo.getUserId(),
            ASI_CRM_Status__c = 'Approval in Progress',
            ASI_CRM_JDE_Group_Name__c = 'GR00110'
        );

        invoiceRecTypeId = Schema.SObjectType.ASI_CRM_Payment_Invoice__c
                                 .getRecordTypeInfosByName()
                                 .get('JP SPTD Cash Invoice Read-Only').getRecordTypeId();
        
        ASI_CRM_Payment_Invoice__c testInvoice4 = new ASI_CRM_Payment_Invoice__c(
            RecordTypeId = invoiceRecTypeId,
            ASI_CRM_Invoice_No__c = 'Inv123456',
            ASI_CRM_Invoice_Date__c = Date.today(),
            ASI_CRM_Payment_Date__c = Date.today(),
            ASI_CRM_Total_Invoice_Amount__c = 2323,
            OwnerId = UserInfo.getUserId(),
            ASI_CRM_Status__c = 'Approval in Progress',
            ASI_CRM_JDE_Group_Name__c = 'GR00111'
        );
        
        ASI_CRM_Payment_Invoice__c testInvoice5 = new ASI_CRM_Payment_Invoice__c(
            RecordTypeId = invoiceRecTypeId,
            ASI_CRM_Invoice_No__c = 'Inv123456',
            ASI_CRM_Invoice_Date__c = Date.today(),
            ASI_CRM_Payment_Date__c = Date.today(),
            ASI_CRM_Total_Invoice_Amount__c = 2323,
            OwnerId = UserInfo.getUserId(),
            ASI_CRM_Status__c = 'Approval in Progress',
            ASI_CRM_JDE_Group_Name__c = 'GR00111'
        );

        insert new List<ASI_CRM_Payment_Invoice__c> {
            testInvoice1,
            testInvoice2,
            testInvoice3,
            testInvoice4,
            testInvoice5
        };
    }

    static testMethod void testConstructorAndInit() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_CRM_Payment_Invoice__c());

        ASI_CRM_JP_MassGroup_InvoiceController controller =
            new ASI_CRM_JP_MassGroup_InvoiceController(stdController);

        System.Test.startTest();
            controller.init();
            controller.runSearch();
       		controller.save();
        System.Test.stopTest();
    }

    static testMethod void testSort() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_CRM_Payment_Invoice__c());

        ASI_CRM_JP_MassGroup_InvoiceController controller =
            new ASI_CRM_JP_MassGroup_InvoiceController(stdController);

        System.Test.startTest();
            controller.init();
            controller.runSearch();
            controller.toggleSort();
        System.Test.stopTest();
    }

    static testMethod void testSearch() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_CRM_Payment_Invoice__c());

        ASI_CRM_JP_MassGroup_InvoiceController controller =
            new ASI_CRM_JP_MassGroup_InvoiceController(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_JP_MassGroup_Invoice);
        Apexpages.currentPage().getParameters().put('invoiceRefNo', 'INV-');
        Apexpages.currentPage().getParameters().put('payTo', 'abc');
        Apexpages.currentPage().getParameters().put('invoiceNo', 'Inv');
        Apexpages.currentPage().getParameters().put('invoiceDate', '2016-05-21');
        Apexpages.currentPage().getParameters().put('paymentDate', '2016-05-21');
        Apexpages.currentPage().getParameters().put('recordType', 'JP SPTD Cash Invoice Read-Only');
        Apexpages.currentPage().getParameters().put('owner', UserInfo.getLastName());

        System.Test.startTest();
            controller.init();
            controller.runSearch();
        System.Test.stopTest();
    }

    static testMethod void testSaveWithoutSelecting() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_CRM_Payment_Invoice__c());

        ASI_CRM_JP_MassGroup_InvoiceController controller =
            new ASI_CRM_JP_MassGroup_InvoiceController(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_JP_MassGroup_Invoice);
        
        System.Test.startTest();
            controller.init();
            controller.runSearch();
            controller.massGroupRecords();
        System.Test.stopTest();
    }

    static testMethod void testSelectAllAndSave() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_CRM_Payment_Invoice__c());

        ASI_CRM_JP_MassGroup_InvoiceController controller =
            new ASI_CRM_JP_MassGroup_InvoiceController(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_JP_MassGroup_Invoice);
        
        System.Test.startTest();
            controller.init();
            controller.runSearch();

            for(ASI_CRM_JP_MassGroup_InvoiceController.InvoiceWrapper wrapper : controller.lstPaymentInvoiceWrappers) {
                wrapper.isSelected = true;
            }

            controller.massGroupRecords();
        System.Test.stopTest();
    }

    static testMethod void testSelectSomeAndSave() {

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(new ASI_CRM_Payment_Invoice__c());

        ASI_CRM_JP_MassGroup_InvoiceController controller =
            new ASI_CRM_JP_MassGroup_InvoiceController(stdController);

        System.Test.setCurrentPage(Page.ASI_CRM_JP_MassGroup_Invoice);
        
        System.Test.startTest();
            controller.init();
            controller.runSearch();

            controller.lstPaymentInvoiceWrappers[1].isSelected = true;
            controller.lstPaymentInvoiceWrappers[2].isSelected = true;

            controller.massGroupRecords();
        System.Test.stopTest();
    }
}