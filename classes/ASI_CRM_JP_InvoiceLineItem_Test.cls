/*********************************************************************************
 * Name:ASI_CRM_JP_InvoiceLineItem_Test
 * Description: Test Class for Invoice Line Item of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 6/1/2015       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_InvoiceLineItem_Test {
    
    @TestSetup
    public static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        
        system.runAs(u1){
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'INV{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_Cash_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'INV{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
            insert ap;
            ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(Name = 'TestSKU', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_JP_SKU'));
            insert sku;
            ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'), ASI_CRM_Representative_SKU__c = sku.id);
        	insert itemGroup;
            
            List<ASI_CRM_Payment_Invoice__c> invoiceList = new List<ASI_CRM_Payment_Invoice__c>();
            ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200', ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice'));
            ASI_CRM_Payment_Invoice__c invoice2 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200', ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice'));
            invoiceList.add(invoice1);
            invoiceList.add(invoice2);
            insert invoiceList;
            
        }
    }
    
    //Test for Class ASI_CRM_JP_PaymentInvoiceItemTgrHdlr
    static testMethod void ASI_CRM_JP_PaymentInvoiceItemTgrHdlr_Test(){
        User u1 = [SELECT Id FROM USER WHERE UserName='test1@laputa.com' LIMIT 1];
        ASI_CRM_Payment_Invoice__c focInvoice = [SELECT Id FROM ASI_CRM_Payment_Invoice__c WHERE RecordType.DeveloperName = 'ASI_CRM_JP_SPTD_FOC_Invoice' LIMIT 1];
        ASI_CRM_Payment_Invoice__c cashInvoice = [SELECT Id FROM ASI_CRM_Payment_Invoice__c WHERE RecordType.DeveloperName = 'ASI_CRM_JP_Cash_Invoice' LIMIT 1];
        ASI_MFM_AP_Code__c ap = [SELECT Id FROM ASI_MFM_AP_Code__c];
        ASI_MFM_Item_Group__c itemGroup = [SELECT Id FROM ASI_MFM_Item_Group__c];
        ASI_MFM_SKU_Code__c sku = [SELECT Id FROM ASI_MFM_SKU_Code__c];
       	system.runAs(u1){
            ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'));
            insert contract1;
            
            test.startTest();
            List<ASI_CRM_Purchase_Contract_Line_Item__c> contractLineList = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
            ASI_CRM_Purchase_Contract_Line_Item__c contractLine1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);        
            contractLineList.add(contractLine1);
            ASI_CRM_Purchase_Contract_Line_Item__c contractLine2 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 200, ASI_CRM_Quantity__c = 200, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);        
            contractLineList.add(contractLine2);
            insert contractLineList;
            
            List<ASI_CRM_Payment_Invoice_Line_Item__c> lineItemList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
            ASI_CRM_Payment_Invoice_Line_Item__c line1 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = focInvoice.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLineList.get(0).Id, ASI_CRM_SKU_Selection__c = 'Alternative SKU');
            ASI_CRM_Payment_Invoice_Line_Item__c line2 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_FOC_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = focInvoice.Id, ASI_CRM_Purchase_Contract_Line_Item__c = contractLineList.get(0).Id, ASI_CRM_SKU__c = sku.Id);
            ASI_CRM_Payment_Invoice_Line_Item__c line3 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = cashInvoice.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLineList.get(0).Id, ASI_CRM_SKU_Selection__c = 'Alternative SKU');
            ASI_CRM_Payment_Invoice_Line_Item__c line4 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_FOC_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = cashInvoice.Id, ASI_CRM_Purchase_Contract_Line_Item__c = contractLineList.get(0).Id, ASI_CRM_SKU__c = sku.Id);
            lineItemList.add(line1);
            lineItemList.add(line2);
            lineItemList.add(line3);
            lineItemList.add(line4);
            insert lineItemList;
            
            line1.ASI_CRM_Purchase_Contract_Line_Item__c = contractLineList.get(1).Id;
            line1.ASI_CRM_SKU_Selection__c = 'Representative SKU';
            line2.ASI_CRM_SKU_Selection__c = 'Alternative SKU';
            
            test.stopTest();
            
            try{
                update lineItemList;
            }catch(Exception e){
            
            }
            
            try{
                delete line1;
            }catch(Exception e){
            
            }
            //For auto close contract
            try{
                focInvoice.ASI_CRM_Status__c = 'Complete';
                update focInvoice;
            }catch(Exception e){
            
            }
        }
        
    }
}