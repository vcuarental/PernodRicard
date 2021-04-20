/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoice_Test
 * Description: Test Class for ASI CRM Payment Invoice CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 5/1/2015         Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_PaymentInvoice_Test {
    //Test for Class ASI_CRM_JP_PaymentInvoiceTgrHdlr
    //Also test for Class ASI_CRM_JP_AssignAutoNumber_Invoice and Class ASI_CRM_JP_AssignApprover_LineManager
    static testMethod void ASI_CRM_JP_PaymentInvoiceTgrHdlr_Test() {
        insert new ASI_JP_TnE_Tax_Date_Mapping__c(Name = 'Test', ASI_JP_TnE_Start_Date__c = system.today().addYears(-1), ASI_JP_TnE_End_Date__c = system.today().addYears(1), ASI_JP_TnE_Tax_Rate__c = 0);
        ASI_CRM_Payment_Invoice__c invoice = new ASI_CRM_Payment_Invoice__c( RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Invoice_Date__c = system.today(), ASI_CRM_Tax_Rate__c = null);
        insert invoice;
        invoice.ASI_CRM_Invoice_Date__c = system.today().addDays(1);
        invoice.ASI_CRM_Tax_Rate__c = null;
        update invoice;
        invoice.ASI_CRM_Status__c = 'Cancelled';
        update invoice;
    }
    
    @TestSetup
    static void setupTestData() {
        ASI_CRM_JP_ObjectPickListHelper helper = new ASI_CRM_JP_ObjectPickListHelper('ASI_CRM_Payment_Invoice_Line_Item__c', 'ASI_CRM_SKU__c', 'Id != null');
        ASI_CRM_JP_ObjectPickListHelper helper2 = new ASI_CRM_JP_ObjectPickListHelper('ASI_CRM_Payment_Invoice_Line_Item__c', 'ASI_CRM_Payment_Invoice__c', 'Id != null');
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<User> userList = new List<user>();

        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test4@laputa.com');
        insert u4;

        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test111@laputa.com');
        userList.add(u1);
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test112@laputa.com');
        userList.add(u2);
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test113@laputa.com',
            managerid = u4.id);
        userList.add(u3);

        
        insert userList;
        
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'INV{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Sys_Allow_Submit_Approval__c = true,ASI_CRM_Delivery_Time__c = '0000-1200',ASI_CRM_Status__c = 'Draft', ownerId = u3.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice'));
        insert invoice1;
        invoice1.ASI_CRM_Approver_1__c = u2.id;
        invoice1.ASI_CRM_Approver_2__c = u3.id;
        invoice1.ASI_CRM_Approver_3__c = u4.id;
        update invoice1;
        
        ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'));
        insert contract1;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
        insert ap;
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(Name = 'TestSKU', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_JP_SKU'));
       	insert sku;
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'), ASI_CRM_Representative_SKU__c = sku.Id);
       	insert itemGroup;
        ASI_CRM_Purchase_Contract_Line_Item__c contractLine1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
        insert contractLine1;
    }
    
    //Test for Invoice PDF (91%) & ASI_CRM_JP_FinalPrintController & ASI_CRM_JP_PaymentInvoicePDFExtension
    static testMethod void ASI_CRM_JP_InvoicePDF(){
        User u1 = [SELECT Id FROM User WHERE UserName='test111@laputa.com' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE UserName='test112@laputa.com' LIMIT 1];
        User u3 = [SELECT Id FROM User WHERE UserName='test113@laputa.com' LIMIT 1];
        ASI_CRM_Payment_Invoice__c invoice1 = [SELECT Id FROM ASI_CRM_Payment_Invoice__c LIMIT 1];
        ASI_CRM_Purchase_Contract_Line_Item__c contractLine1 = [SELECT Id FROM ASI_CRM_Purchase_Contract_Line_Item__c LIMIT 1];
        ASI_MFM_SKU_Code__c sku = [SELECT Id FROM ASI_MFM_SKU_Code__c LIMIT 1];
        
        test.startTest();
        List<ASI_CRM_Payment_Invoice_Line_Item__c> lineList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
        ASI_CRM_Payment_Invoice_Line_Item__c line1 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_Cash_Invoice_Line_Item'), ASI_CRM_Payment_Invoice_Item_Owner__c = u1.Id, ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id);
        lineList.add(line1);
        ASI_CRM_Payment_Invoice_Line_Item__c line2 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_Cash_Invoice_Line_Item'), ASI_CRM_Payment_Invoice_Item_Owner__c = u1.Id, ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id);
        lineList.add(line2);
        ASI_CRM_Payment_Invoice_Line_Item__c line3 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_Cash_Invoice_Line_Item'), ASI_CRM_Payment_Invoice_Item_Owner__c = u3.Id, ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id);
        lineList.add(line3);
        ASI_CRM_Payment_Invoice_Line_Item__c line4 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_FOC_Invoice_Line_Item'), ASI_CRM_Payment_Invoice_Item_Owner__c = u3.Id, ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id, ASI_CRM_SKU__c = sku.Id);
		lineList.add(line4);
        insert lineList;
        
        line3.ASI_CRM_Payment_Invoice_Item_Owner__c = u3.Id;
        update line3;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice1);
        PageReference pageRef = Page.ASI_CRM_JP_PaymentInvoice_PDFPage;
        pageRef.getParameters().put('Id', invoice1.Id);
        Test.setCurrentPage(pageRef);
        ASI_CRM_JP_PaymentInvoicePDFController controller = new ASI_CRM_JP_PaymentInvoicePDFController();
        // Create an approval request for the account
        
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(invoice1.id);
        req1.setSubmitterId(u2.Id); 
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {u3.id});
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        System.RunAs(u3){
            Approval.ProcessResult result2 =  Approval.process(req2);
        }
        
        controller.setcurrentHeaderId(invoice1.Id); 
        controller.setinit(invoice1.Id);
        controller.Header = null;
        controller.getHeader();
        controller.details = null;
        controller.getDetails();
        controller.getapprovalDetails();
        controller.getCheckIfJP();
        controller.getcurrentHeaderId();
        controller.getIsFinalPrint();
        controller.checkForUpdate();
        controller.getCashDetailsGroup(); 
        
        test.stopTest();
        ASI_CRM_JP_PaymentInvoicePDFExtension extenstion = new ASI_CRM_JP_PaymentInvoicePDFExtension(sc);
        extenstion.checkForUpdate();
        
        pageRef = Page.ASI_CRM_JP_SetStatusDraftPage;
        pageRef.getParameters().put('Id', invoice1.Id);
        Test.setCurrentPage(pageRef);
        ASI_CRM_JP_SetStatusDraftController controller3 = new ASI_CRM_JP_SetStatusDraftController(sc);
        controller3.save();
        
        pageRef = Page.ASI_CRM_JP_FinalPrintPage;
        pageRef.getParameters().put('Id', invoice1.Id);
        Test.setCurrentPage(pageRef);
        
        ASI_CRM_JP_FinalPrintController controller2 = new ASI_CRM_JP_FinalPrintController(sc);
        controller2.save();
    }

    static testMethod void isHalfWidthCharacterTest(){
        // Half-width
        System.assert(ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('1'));
        System.assert(ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('A'));
        System.assert(ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('('));
        System.assert(ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter(')'));
        System.assert(ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('-'));
        System.assert(ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('ｱ'));
        System.assert(ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('ｶ'));

        // Full-width
        System.assert(!ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('あ'));
        System.assert(!ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('ア'));
        System.assert(!ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('日'));
        System.assert(!ASI_CRM_JP_PaymentInvoicePDFController.isHalfWidthCharacter('本'));
    }

    static testMethod void splitLineTest(){
        String input = 'あいうえお';
        System.assertEquals('あいう<br/>えお', ASI_CRM_JP_PaymentInvoicePDFController.splitLine(input, 3));
        System.assertEquals('あいうえお', ASI_CRM_JP_PaymentInvoicePDFController.splitLine(input, 6));

        input = 'aあいうえお';
        System.assertEquals('aあい<br/>うえお', ASI_CRM_JP_PaymentInvoicePDFController.splitLine(input, 3));

        input = '東亜商事(株)-93956日本ｱｸｾｽ広域営業部門CVS加工食品・飲料営業部';
        System.assertEquals('東亜商事(株)-93956日本ｱｸｾｽ広域営業部門CV<br/>S加工食品・飲料営業部', ASI_CRM_JP_PaymentInvoicePDFController.splitLine(input, 20));

    }
}