/*********************************************************************************
 * Name:ASI_CRM_JP_ContractLineItem_Test
 * Description: Test Class for Purchase Contract Line Items of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 5/1/2015       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_ContractLineItem_Test {
    //Test for Clas ASI_CRM_JP_ContractItemTgrHdlr
    static testMethod void ASI_CRM_JP_ContractItemTgrHdlr_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        insert u1;
        ASI_CRM_JP_TestClassHelper.createRunningNumbers();
        ASI_CRM_Pay_To__c customer = new ASI_CRM_Pay_To__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'));
        insert customer;
        
        ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test0');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
        ASI_CRM_AccountsAdditionalField__c customer2 = new ASI_CRM_AccountsAdditionalField__c(Name='Test0', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_Off_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType.Id, ASI_CRM_PostalCode__c = postalCode.Name);
        insert customer2;
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
        insert itemGroup;
        ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, ASI_CRM_BS_Retailer_Ship_To__c = customer2.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addMonths(2));
        insert contract1;
        ASI_CRM_Direct_Rebate_Data__c data = new ASI_CRM_Direct_Rebate_Data__c(ASI_CRM_End_Date__c = system.today().addDays(5), ASI_CRM_Item_Group__c = itemGroup.Id, ASI_CRM_Pay_To__c = customer.Id, ASI_CRM_Ship_To__c = customer2.Id, ASI_CRM_Rebate_Type__c = '08 - Direct Supporting', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Direct_Rebate_Data__cASI_CRM_JP_Direct_Rebate_Data'));
        insert data;
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = new ASI_CRM_Purchase_Contract_Line_Item__c(ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Item_Group__c = itemGroup.Id, ASI_CRM_Pay_To__c = customer.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item'), ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Rebate_Type__c = '08 - Direct Supporting', ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000);
        ASI_CRM_Purchase_Contract_Line_Item__c line2 = new ASI_CRM_Purchase_Contract_Line_Item__c(ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Item_Group__c = itemGroup.Id, ASI_CRM_Pay_To__c = customer.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item'), ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Rebate_Type__c = '07 - Key Account Listing Spot', ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000);
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lineList = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        lineList.add(line1);
        lineList.add(line2);
        insert lineList;
        line2.ASI_CRM_Unit_Price__c = 99;
        line2.ASI_CRM_Rebate_Type__c = '08 - Direct Supporting';
        line1.ASI_CRM_Rebate_Type__c = '07 - Key Account Listing Spot';
        update lineList;
        delete line2;
    }
}