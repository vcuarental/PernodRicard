@isTest
public class ASI_CRM_JP_InputPaymentItemsTest {

    
    @testSetup 
    static void setup() {
        RecordType recordType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                 FROM RecordType 
                                 WHERE SobjectType = 'ASI_CRM_Payment_Invoice__c'
                                 AND DeveloperName = 'ASI_CRM_JP_SPTD_FOC_Invoice'];
        
        ASI_CRM_Payment_Invoice__c paymentinvoice = new ASI_CRM_Payment_Invoice__c();
        paymentinvoice.RecordTypeId = recordType.Id;
        //insert paymentinvoice;
    }
    
    
    @isTest
     static void ASI_CRM_JP_InputPaymentItemsControllerV2_TestMethod1()
    {
        RecordType rtrn = [SELECT Id, Name, DeveloperName, SobjectType 
                           FROM RecordType 
                           WHERE DeveloperName = 'ASI_CN_Running_Number'];
        
        ASI_HK_CRM_Running_Number__c rn = new ASI_HK_CRM_Running_Number__c();
        rn.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No';
        rn.ASI_HK_CRM_Running_Number__c = 100;
        rn.RecordTypeId = rtrn.Id;
        rn.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        rn.ASI_HK_CRM_Fiscal_Year__c = 2019;
        rn.ASI_HK_CRM_Format__c = '4{YY}{00000}';
        insert rn;
        
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        /*
        User u1 = 
            new User(
                Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com'
            );
        insert u1;
        */
        
        ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test0');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
        
        ASI_CRM_Pay_To__c customer = 
            new ASI_CRM_Pay_To__c(
                Name = 'test', 
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),
                ASI_CRM_Active__c=true
            );
        insert customer;
        
        ASI_CRM_AccountsAdditionalField__c customer2 = 
            new ASI_CRM_AccountsAdditionalField__c(
                Name='Test0', 
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_Off_Trade_Outlet'), 
                ASI_TH_CRM_OutletType__c = outletType.Id, 
                ASI_CRM_PostalCode__c = postalCode.Name
            );
        insert customer2;

        ASI_HK_CRM_Running_Number__c num = new ASI_HK_CRM_Running_Number__c();
        num.ASI_HK_CRM_Running_Number__c = 100;
        num.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No';
        num.ASI_HK_CRM_Format__c = '';
        num.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 4;
        num.ASI_HK_CRM_Fiscal_Year__c = 2019;
        insert num;
        
        ASI_CRM_Purchase_Contract__c contract1 = 
            new ASI_CRM_Purchase_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'),
            Name = 'TestContract123',
            ASI_CRM_Status__c = 'Draft',
            ASI_CRM_Sys_Allow_Submit_Approval__c = true,
            OwnerId = UserInfo.getUserId(),
            ASI_CRM_Start_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate(),
            ASI_CRM_End_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate().addMonths(1),
            ASI_CRM_Request_Type__c = 'New Customer Development'
        );
        insert contract1;
        
        ASI_MFM_Item_Group__c itemGroup = 
            new ASI_MFM_Item_Group__c(
                Name = 'Test', 
                ASI_CRM_Lowest_1__c = 100, 
                ASI_CRM_Lowest_2__c = 100, 
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group')
            );
        insert itemGroup;
        
        RecordType rtrn1 = [SELECT Id, Name, DeveloperName, SobjectType 
                           FROM RecordType 
                           WHERE sObjectType = 'ASI_CRM_Payment_Invoice__c'
                           AND DeveloperName = 'ASI_CRM_JP_SPTD_Cash_Invoice'];
        system.debug('record type=' + rtrn1);
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lstpcli = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = 
            new ASI_CRM_Purchase_Contract_Line_Item__c(
                ASI_CRM_Purchase_Contract__c = contract1.Id, 
                ASI_CRM_Item_Group__c = itemGroup.Id, 
                ASI_CRM_Pay_To__c = customer.Id, 
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item'), 
                ASI_CRM_Unit_Price__c  = 100, 
                ASI_CRM_Rebate_Type__c = '08 - Direct Supporting', 
                ASI_CRM_Quantity__c = 100, 
                ASI_CRM_Target_Volume__c = 10000
            );
        lstpcli.add(line1);
        insert lstpcli;
        
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lineItemList = 
            [select Id from ASI_CRM_Purchase_Contract_Line_Item__c where ASI_CRM_Purchase_Contract__c = :contract1.Id];
        List<Id> lineItemIds = new List<Id>();
        for(ASI_CRM_Purchase_Contract_Line_Item__c lineItem: lineItemList)
        {
            system.debug('line item id=' + lineItem.Id);
            lineItemIds.add(lineItem.Id);
        }
        
        ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ASI_CRM_Status__c = 'Submitted',RecordTypeId = rtrn1.Id);
        insert invoice1;
        
        String jsonInput = JSON.serialize(lineItemIds);
        system.debug(jsonInput);
        
        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('purchaseContractLineItemIds',jsonInput);
        pageRef.getParameters().put('Id', String.valueOf(invoice1.Id));
         pageRef.getParameters().put('recordtypeOpt','AP');
        ASI_CRM_JP_InputPaymentItemsControllerV2 controller = new ASI_CRM_JP_InputPaymentItemsControllerV2();
        
        controller.addAllPaymentInvoiceLineItem();
        ASI_CRM_JP_InputPaymentItemsControllerV2.getPaymentLineItemCustomCriteria();
        
        try{
            Id idval = ASI_CRM_JP_InputPaymentItemsControllerV2.getPaymentLineItemDefaultRecordTypeId(invoice1, 'JP Indirect Rebate Invoice Line Item');
            controller.addPaymentInvoiceLineItem();
        }
        catch(Exception e){

        }
            
    }
    
    @isTest
     static void ASI_CRM_JP_InputPaymentItemsControllerV2_TestMethod2()
    {
        RecordType rtrn = [SELECT Id, Name, DeveloperName, SobjectType 
                           FROM RecordType 
                           WHERE DeveloperName = 'ASI_CN_Running_Number'];
        
        ASI_HK_CRM_Running_Number__c rn = new ASI_HK_CRM_Running_Number__c();
        rn.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No';
        rn.ASI_HK_CRM_Running_Number__c = 100;
        rn.RecordTypeId = rtrn.Id;
        rn.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        rn.ASI_HK_CRM_Fiscal_Year__c = 2019;
        rn.ASI_HK_CRM_Format__c = '4{YY}{00000}';
        insert rn;
        
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        /*
        User u1 = 
            new User(
                Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com'
            );
        insert u1;
        */
        
        ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test0');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
        
        ASI_CRM_Pay_To__c customer = 
            new ASI_CRM_Pay_To__c(
                Name = 'test', 
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),
                ASI_CRM_Active__c=true
            );
        insert customer;
        
        ASI_CRM_AccountsAdditionalField__c customer2 = 
            new ASI_CRM_AccountsAdditionalField__c(
                Name='Test0', 
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_Off_Trade_Outlet'), 
                ASI_TH_CRM_OutletType__c = outletType.Id, 
                ASI_CRM_PostalCode__c = postalCode.Name
            );
        insert customer2;

        ASI_HK_CRM_Running_Number__c num = new ASI_HK_CRM_Running_Number__c();
        num.ASI_HK_CRM_Running_Number__c = 100;
        num.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No';
        num.ASI_HK_CRM_Format__c = '';
        num.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 4;
        num.ASI_HK_CRM_Fiscal_Year__c = 2019;
        insert num;
        
        ASI_CRM_Purchase_Contract__c contract1 = 
            new ASI_CRM_Purchase_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'),
            Name = 'TestContract123',
            ASI_CRM_Status__c = 'Draft',
            ASI_CRM_Sys_Allow_Submit_Approval__c = true,
            OwnerId = UserInfo.getUserId(),
            ASI_CRM_Start_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate(),
            ASI_CRM_End_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate().addMonths(1),
            ASI_CRM_Request_Type__c = 'New Customer Development'
        );
        insert contract1;
        
        ASI_MFM_Item_Group__c itemGroup = 
            new ASI_MFM_Item_Group__c(
                Name = 'Test', 
                ASI_CRM_Lowest_1__c = 100, 
                ASI_CRM_Lowest_2__c = 100, 
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group')
            );
        insert itemGroup;
        
        RecordType rtrn1 = [SELECT Id, Name, DeveloperName, SobjectType 
                           FROM RecordType 
                           WHERE sObjectType = 'ASI_CRM_Payment_Invoice__c'
                           AND DeveloperName = 'ASI_CRM_JP_SPTD_Cash_Invoice'];
        system.debug('record type=' + rtrn1);
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lstpcli = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = 
            new ASI_CRM_Purchase_Contract_Line_Item__c(
                ASI_CRM_Purchase_Contract__c = contract1.Id, 
                ASI_CRM_Item_Group__c = itemGroup.Id, 
                ASI_CRM_Pay_To__c = customer.Id, 
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item'), 
                ASI_CRM_Unit_Price__c  = 100, 
                ASI_CRM_Rebate_Type__c = '08 - Direct Supporting', 
                ASI_CRM_Quantity__c = 100, 
                ASI_CRM_Target_Volume__c = 10000
            );
        lstpcli.add(line1);
        insert lstpcli;
        
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lineItemList = 
            [select Id from ASI_CRM_Purchase_Contract_Line_Item__c where ASI_CRM_Purchase_Contract__c = :contract1.Id];
        List<Id> lineItemIds = new List<Id>();
        for(ASI_CRM_Purchase_Contract_Line_Item__c lineItem: lineItemList)
        {
            system.debug('line item id=' + lineItem.Id);
            lineItemIds.add(lineItem.Id);
        }
        
        ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ASI_CRM_Status__c = 'Submitted',RecordTypeId = rtrn1.Id);
        insert invoice1;
        
        String jsonInput = JSON.serialize(lineItemIds);
        system.debug(jsonInput);
        
        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('purchaseContractLineItemIds',jsonInput);
        pageRef.getParameters().put('Id', String.valueOf(invoice1.Id));
         pageRef.getParameters().put('recordtypeOpt','AP');
        ASI_CRM_JP_InputPaymentItemsControllerV2 controller = new ASI_CRM_JP_InputPaymentItemsControllerV2();
        
        ASI_CRM_JP_InputPaymentItemsControllerV2.getPaymentLineItemCustomCriteria();
        
        try{
            Id idval = ASI_CRM_JP_InputPaymentItemsControllerV2.getPaymentLineItemDefaultRecordTypeId(invoice1, 'JP Indirect Rebate Invoice Line Item');
            controller.addPaymentInvoiceLineItem();
        }
        catch(Exception e){

        }
            
    }
}